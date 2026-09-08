"""一時リポジトリで Git フックを検証する Medium テスト。"""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


CONFIG_DIR = Path(__file__).resolve().parents[2] / "config"


class TestCodexBranchName(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / "repo"
        self.env = {
            key: value for key, value in os.environ.items()
            if not key.startswith(("GIT_", "CODEX_"))
        }
        self.env.update(
            HOME=str(self.root),
            XDG_CONFIG_HOME=str(CONFIG_DIR),
            GIT_CONFIG_GLOBAL=str(CONFIG_DIR / "git/conf.d/core.conf"),
            GIT_CONFIG_NOSYSTEM="1",
        )
        self.git("init", "-b", "main", str(self.repo), cwd=self.root, codex=False)
        self.git("commit", "--allow-empty", "-m", "initial", codex=False)

    def git(self, *args, codex=True, check=True, cwd=None):
        env = self.env.copy()
        if codex:
            env["CODEX_THREAD_ID"] = "test-session"
        return subprocess.run(
            ["git", "-c", "user.name=Test", "-c", "user.email=test@example.com",
             "-c", "commit.gpgsign=false", *args],
            cwd=cwd or self.repo, env=env, text=True, capture_output=True, check=check,
        )

    def test_create_branch_with_wrong_prefix_is_rejected(self):
        # Arrange: 代表的なブランチ作成コマンドを用意する
        commands = [
            ("branch", "feature/branch"),
            ("switch", "-c", "feature/switch"),
            ("checkout", "-b", "feature/checkout"),
            ("worktree", "add", "-b", "feature/worktree", str(self.root / "worktree")),
        ]
        for command in commands:
            with self.subTest(command=command[0]):
                # Act: Codex 環境から命名規則に違反するブランチを作る
                result = self.git(*command, check=False)
                # Assert: 作成が拒否され、参照が残らない
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("agent/codex/", result.stderr)
                self.assertNotEqual(
                    self.git("show-ref", "--verify", f"refs/heads/feature/{command[0]}", check=False).returncode,
                    0,
                )

    def test_create_branch_with_codex_prefix_is_allowed(self):
        # Arrange: 正しいプレフィックスとネストしたブランチ名を用意する
        branch = "agent/codex/topic/fix"
        # Act: Codex 環境からブランチを作る
        result = self.git("switch", "-c", branch)
        # Assert: 指定したブランチに切り替わる
        self.assertEqual(result.returncode, 0)
        self.assertEqual(self.git("branch", "--show-current").stdout.strip(), branch)

    def test_create_branch_outside_codex_is_allowed(self):
        # Act: 通常の環境から任意の名前でブランチを作る
        result = self.git("branch", "feature/human", codex=False)
        # Assert: 人間の操作は制限されない
        self.assertEqual(result.returncode, 0)

    def test_force_update_existing_branch_is_allowed(self):
        # Arrange: 規則外の既存ブランチと更新先のコミットを用意する
        self.git("branch", "feature/existing", codex=False)
        self.git("commit", "--allow-empty", "-m", "next")
        # Act: 既存ブランチの参照を更新する
        result = self.git("branch", "-f", "feature/existing", "HEAD")
        # Assert: 新規作成ではないので更新できる
        self.assertEqual(result.returncode, 0)
        self.assertEqual(self.git("rev-parse", "feature/existing").stdout,
                         self.git("rev-parse", "HEAD").stdout)

    def test_delete_existing_branch_is_allowed(self):
        # Arrange: 規則外の既存ブランチを用意する
        self.git("branch", "feature/existing", codex=False)
        # Act: 既存ブランチを削除する
        result = self.git("branch", "-d", "feature/existing")
        # Assert: 削除は制限されない
        self.assertEqual(result.returncode, 0)

    def test_create_tag_is_allowed(self):
        # Act: ブランチ以外の参照を作る
        result = self.git("tag", "v1")
        # Assert: タグは制限されない
        self.assertEqual(result.returncode, 0)

    def test_clone_repository_is_allowed(self):
        # Act: Codex 環境でローカルのリポジトリを取得する
        result = self.git("clone", str(self.repo), str(self.root / "clone"))
        # Assert: 初期ブランチの作成は制限されない
        self.assertEqual(result.returncode, 0)

    def test_initial_commit_is_allowed(self):
        # Arrange: コミットのないリポジトリを用意する
        empty_repo = self.root / "empty"
        self.git("init", "-b", "main", str(empty_repo))
        # Act: Codex 環境から初回コミットを作る
        result = self.git("commit", "--allow-empty", "-m", "initial", cwd=empty_repo)
        # Assert: 初期ブランチは制限されない
        self.assertEqual(result.returncode, 0)

    def test_create_branch_with_existing_repository_hook_runs_both(self):
        # Arrange: リポジトリ側に既存のフックを配置する
        hook = self.repo / ".git/hooks/reference-transaction"
        hook.write_text('#!/bin/sh\nprintf "%s\\n" "$1" >> .git/hook-events\n')
        hook.chmod(0o755)
        # Act: 正しい名前でブランチを作る
        result = self.git("branch", "agent/codex/coexist")
        # Assert: ブランチが作られ、既存フックも実行される
        self.assertEqual(result.returncode, 0)
        self.assertIn("committed", (self.repo / ".git/hook-events").read_text())


if __name__ == "__main__":
    unittest.main()
