"""OS のインストール操作をローカルの代替コマンドで検証する Medium テスト。"""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


REPO_DIR = Path(__file__).resolve().parents[2]


class TestInstall(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        self.events = self.root / "events"
        self.events.touch()
        self.ready = self.root / "clt-ready"
        self.checkout = self.root / "workspaces/github.com/0maru/dotfiles"
        self.checkout.mkdir(parents=True)
        shutil.copytree(REPO_DIR / "scripts", self.checkout / "scripts")
        shutil.copy2(REPO_DIR / "install.sh", self.checkout / "install.sh")
        (self.checkout / "scripts/setup.sh").write_text(
            '#!/bin/bash\nprintf "setup\\n" >> "$TEST_EVENTS"\n'
        )
        self.env = {
            **os.environ,
            "HOME": str(self.root),
            "PATH": f"{self.bin}:/usr/bin:/bin",
            "TEST_EVENTS": str(self.events),
            "TEST_READY": str(self.ready),
            "TEST_SOURCE": str(self.root / "source"),
        }
        self.env.pop("BASH_ENV", None)
        self.command("xcode-select", '''
case "$1" in
  --print-path|-p) [ -f "$TEST_READY" ] ;;
  --install) printf 'clt-install\n' >> "$TEST_EVENTS"; exit "${TEST_CLT_EXIT:-0}" ;;
  *) exit 90 ;;
esac
''')
        self.command("xcrun", '[ -f "$TEST_READY" ] && [ "${TEST_BROKEN_CLANG:-0}" = 0 ]')
        self.command("sleep", '''
if [ "${TEST_CLT_NEVER_READY:-0}" = 0 ]; then
  touch "$TEST_READY"
fi
''')
        self.command("git", '''
printf 'git\n' >> "$TEST_EVENTS"
[ -f "$TEST_READY" ] || exit 70
if [ "$1" = clone ]; then
  cp -R "$TEST_SOURCE" "$3"
fi
''')
        self.command("curl", "exit 90")
        self.command("brew", '''
printf 'brew %s\n' "$*" >> "$TEST_EVENTS"
[ -f "$TEST_READY" ] || exit 70
case " $* " in *" --no-lock "*) exit 71 ;; esac
''')

    def command(self, name, body):
        target = self.bin / name
        target.write_text("#!/bin/bash\nset -euo pipefail\n" + body)
        target.chmod(0o755)

    def run_script(self, script, **env):
        return subprocess.run(
            ["/bin/bash", str(REPO_DIR / script)],
            env={**self.env, **env}, capture_output=True, text=True, timeout=10,
        )

    def test_install_without_clt_waits_before_git(self):
        # Act: 開発ツールがない状態からインストールする
        result = self.run_script("install.sh")
        # Assert: 導入完了後にだけ Git とセットアップへ進む
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.events.read_text().splitlines(), ["clt-install", "git", "setup"])

    def test_install_without_checkout_waits_before_clone(self):
        # Arrange: Git が取得する内容だけを用意し、インストール先は空にする
        self.checkout.rename(self.root / "source")
        # Act: 新しい Mac の初回インストールを再現する
        result = self.run_script("install.sh")
        # Assert: 開発ツールの導入後に取得・セットアップが完了する
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue((self.checkout / "scripts/setup.sh").is_file())
        self.assertEqual(self.events.read_text().splitlines(), ["clt-install", "git", "setup"])

    def test_install_with_clt_skips_reinstallation(self):
        # Arrange: 開発ツールは導入済みとする
        self.ready.touch()
        # Act: 既存環境で再実行する
        result = self.run_script("install.sh")
        # Assert: 開発ツールを再導入せず更新する
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.events.read_text().splitlines(), ["git", "setup"])

    def test_install_with_broken_compiler_stops_before_git(self):
        # Arrange: 開発ツールのパスだけが残っている状態にする
        self.ready.touch()
        # Act: コンパイラが使えない状態から実行する
        result = self.run_script("install.sh", TEST_BROKEN_CLANG="1", TEST_CLT_EXIT="1")
        # Assert: パスだけで導入済みと判断せず後続処理を止める
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.events.read_text().splitlines(), ["clt-install"])

    def test_install_failed_clt_request_stops_before_git(self):
        # Act: OS が開発ツールのインストール要求を拒否する
        result = self.run_script("install.sh", TEST_CLT_EXIT="1")
        # Assert: 失敗時には後続処理を実行しない
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.events.read_text().splitlines(), ["clt-install"])

    def test_install_cancelled_clt_request_times_out(self):
        # Act: インストール画面を閉じた状態を再現する
        result = self.run_script("install.sh", TEST_CLT_NEVER_READY="1")
        # Assert: 永久に待たず、未導入のまま Git へ進まない
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("Command Line Tools", result.stderr)
        self.assertEqual(self.events.read_text().splitlines(), ["clt-install"])

    def test_setup_brew_without_clt_waits_before_bundle(self):
        # Act: Homebrew のセットアップだけを直接実行する
        result = self.run_script("scripts/setup-brew.sh")
        # Assert: 開発ツールが利用可能になってから bundle を実行する
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.events.read_text().splitlines(), [
            "clt-install", f"brew bundle --file {REPO_DIR}/config/homebrew/Brewfile",
        ])

    def test_setup_without_clt_waits_before_nix(self):
        # Arrange: セットアップ本体を残し、環境を書き換える処理だけ代替する
        shutil.copy2(REPO_DIR / "scripts/setup.sh", self.checkout / "scripts/setup.sh")
        for stage in ("nix", "brew", "link"):
            (self.checkout / f"scripts/setup-{stage}.sh").write_text(
                '#!/bin/bash\n[ -f "$TEST_READY" ] || exit 70\n'
                f'printf "{stage}\\n" >> "$TEST_EVENTS"\n'
            )
        # Act: 取得済みリポジトリから直接セットアップする
        result = self.run_script(self.checkout / "scripts/setup.sh")
        # Assert: Git の更新を行わず、開発ツールを先に用意する
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.events.read_text().splitlines(), ["clt-install", "nix", "brew", "link"])

    def test_setup_brew_with_clt_uses_supported_bundle_options(self):
        # Arrange: 開発ツールと Homebrew は導入済みとする
        self.ready.touch()
        # Act: Homebrew のセットアップを再実行する
        result = self.run_script("scripts/setup-brew.sh")
        # Assert: 廃止済みオプションで失敗しない
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.events.read_text().splitlines(), [
            f"brew bundle --file {REPO_DIR}/config/homebrew/Brewfile",
        ])


if __name__ == "__main__":
    unittest.main()
