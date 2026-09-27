"""一時リポジトリで Git フックを検証する Medium テスト。"""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


CONFIG_DIR = Path(__file__).resolve().parents[2] / "config"


class TestAgentBranchName(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / "repo"
        self.env = {
            key: value for key, value in os.environ.items()
            if not key.startswith(("GIT_", "CODEX_")) and key != "CLAUDECODE"
        }
        self.env.update(
            HOME=str(self.root),
            XDG_CONFIG_HOME=str(CONFIG_DIR),
            GIT_CONFIG_GLOBAL=str(CONFIG_DIR / "git/conf.d/core.conf"),
            GIT_CONFIG_NOSYSTEM="1",
        )
        self.git("init", "-b", "main", str(self.repo), cwd=self.root, agent=None)
        self.git("commit", "--allow-empty", "-m", "initial", agent=None)

    def git(self, *args, agent="codex", check=True, cwd=None):
        env = self.env.copy()
        if agent in ("codex", "both"):
            env["CODEX_THREAD_ID"] = "test-session"
        if agent in ("claude", "both"):
            env["CLAUDECODE"] = "1"
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

    def test_claude_create_branch_with_wrong_prefix_is_rejected(self):
        # Arrange: Claude Code では許可されないブランチ名を用意する
        commands = [
            ("switch", "-c", "feature/claude"),
            ("branch", "agent/codex/wrong"),
        ]
        for command in commands:
            with self.subTest(command=command[-1]):
                # Act: Claude Code 環境から命名規則に違反するブランチを作る
                result = self.git(*command, agent="claude", check=False)
                # Assert: 作成が拒否され、参照が残らない
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("agent/claude/", result.stderr)
                self.assertNotEqual(
                    self.git("show-ref", "--verify", f"refs/heads/{command[-1]}", check=False).returncode,
                    0,
                )

    def test_claude_create_branch_with_claude_prefix_is_allowed(self):
        # Arrange: 正しいプレフィックスとネストしたブランチ名を用意する
        branch = "agent/claude/topic/fix"
        # Act: Claude Code 環境からブランチを作る
        result = self.git("switch", "-c", branch, agent="claude")
        # Assert: 指定したブランチに切り替わる
        self.assertEqual(result.returncode, 0)
        self.assertEqual(self.git("branch", "--show-current").stdout.strip(), branch)

    def test_codex_prefix_wins_when_both_env_are_set(self):
        # Act: Claude Code から codex CLI を呼ぶ状況を再現し、両方のプレフィックスを試す
        allowed = self.git("branch", "agent/codex/both", agent="both", check=False)
        rejected = self.git("branch", "agent/claude/both", agent="both", check=False)
        # Assert: Codex のプレフィックスだけが通る
        self.assertEqual(allowed.returncode, 0)
        self.assertNotEqual(rejected.returncode, 0)
        self.assertIn("agent/codex/", rejected.stderr)

    def test_claude_checkout_existing_remote_branch_is_allowed(self):
        # Arrange: 規則外の名前のブランチを持つリモートを用意して取得する
        branch = "feature/remote"
        source = self.root / "source"
        self.git("clone", str(self.repo), str(source), cwd=self.root, agent=None)
        self.git("switch", "-c", branch, cwd=source, agent=None)
        self.git("remote", "add", "origin", str(source), agent=None)
        self.git("fetch", "origin", agent=None)
        # Act: Claude Code 環境からリモートのブランチをチェックアウトする
        result = self.git("switch", branch, agent="claude", check=False)
        # Assert: PR の取得などは制限されない
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.git("branch", "--show-current").stdout.strip(), branch)

    def test_create_branch_outside_agent_is_allowed(self):
        # Act: 通常の環境から任意の名前でブランチを作る
        result = self.git("branch", "feature/human", agent=None)
        # Assert: 人間の操作は制限されない
        self.assertEqual(result.returncode, 0)

    def test_force_update_existing_branch_is_allowed(self):
        # Arrange: 規則外の既存ブランチと更新先のコミットを用意する
        self.git("branch", "feature/existing", agent=None)
        self.git("commit", "--allow-empty", "-m", "next")
        # Act: 既存ブランチの参照を更新する
        result = self.git("branch", "-f", "feature/existing", "HEAD")
        # Assert: 新規作成ではないので更新できる
        self.assertEqual(result.returncode, 0)
        self.assertEqual(self.git("rev-parse", "feature/existing").stdout,
                         self.git("rev-parse", "HEAD").stdout)

    def test_delete_existing_branch_is_allowed(self):
        # Arrange: 規則外の既存ブランチを用意する
        self.git("branch", "feature/existing", agent=None)
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

    def test_detached_worktree_commit_is_rejected_before_signing(self):
        # Arrange: 調査用 worktree と、呼ばれた場合に記録を残す署名プログラムを用意する
        worktree = self.root / "detached"
        self.git("worktree", "add", "--detach", str(worktree))
        signer = self.root / "signer"
        signer.write_text("#!/bin/sh\ntouch signer-called\nexit 1\n")
        signer.chmod(0o755)
        before = self.git("rev-parse", "HEAD", cwd=worktree).stdout
        commit_command = (
            "-c", "commit.gpgsign=true", "-c", "gpg.format=openpgp",
            "-c", f"gpg.program={signer}", "-c", "user.signingkey=test-key",
            "commit", "--no-verify", "--allow-empty", "-m", "detached",
        )
        for agent in ("codex", "claude", "both"):
            with self.subTest(agent=agent):
                # Act: --no-verify でも署名処理に到達しないことを確かめる
                result = self.git(
                    *commit_command, agent=agent, cwd=worktree, check=False,
                )
                # Assert: ブランチの案内で停止し、署名もコミットも行われない
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("detached HEAD", result.stderr)
                expected_agent = "claude" if agent == "claude" else "codex"
                self.assertIn(f"agent/{expected_agent}/", result.stderr)
                self.assertFalse((worktree / "signer-called").exists())
                self.assertEqual(self.git("rev-parse", "HEAD", cwd=worktree).stdout, before)
        # 対照: エージェント判定がなければ同じコマンドが署名処理に到達する
        self.git(*commit_command, agent=None, cwd=worktree, check=False)
        self.assertTrue((worktree / "signer-called").exists())

    def test_named_worktree_loads_agent_config_and_commits(self):
        # Arrange: detached worktree に作業ブランチを付け、実際の条件付き設定を読む
        worktree = self.root / "named"
        self.git("worktree", "add", "--detach", str(worktree))
        self.git("switch", "-c", "agent/codex/worktree", cwd=worktree)
        env = dict(self.env, CODEX_THREAD_ID="test-session",
                   GIT_CONFIG_GLOBAL=str(CONFIG_DIR / "git/config"))
        # Act: テスト用の作者・署名設定による上書きなしでコミットする
        result = subprocess.run(
            ["git", "commit", "--allow-empty", "-m", "named"],
            cwd=worktree, env=env, text=True, capture_output=True,
        )
        # Assert: 条件付き設定だけで署名せずにエージェントの作者情報を使える
        self.assertEqual(result.returncode, 0, result.stderr)
        expected_name = self.git("config", "--file", str(CONFIG_DIR / "git/conf.d/agent.conf"),
                                 "user.name").stdout.strip()
        self.assertEqual(self.git("log", "-1", "--format=%an", cwd=worktree).stdout.strip(),
                         expected_name)
        self.assertEqual(self.git("log", "-1", "--format=%G?", cwd=worktree).stdout.strip(), "N")

    def test_human_detached_commit_is_allowed(self):
        self.git("switch", "--detach")
        result = self.git("commit", "--allow-empty", "-m", "human", agent=None)
        self.assertEqual(result.returncode, 0)

    def test_detached_merge_commit_is_rejected(self):
        self.git("switch", "-c", "agent/codex/topic")
        self.git("commit", "--allow-empty", "-m", "topic")
        self.git("switch", "--detach", "main")
        before = self.git("rev-parse", "HEAD").stdout
        result = self.git("merge", "--no-ff", "--no-edit", "agent/codex/topic", check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("detached HEAD", result.stderr)
        self.assertEqual(self.git("rev-parse", "HEAD").stdout, before)

    def test_named_branch_rebase_is_allowed(self):
        # Git 内部の detached HEAD を拒否して通常の rebase を壊さない
        self.git("switch", "-c", "agent/codex/rebase")
        (self.repo / "topic").write_text("topic\n")
        self.git("add", "topic")
        self.git("commit", "-m", "topic")
        for backend in ("--merge", "--apply"):
            with self.subTest(backend=backend):
                result = self.git("rebase", backend, "--no-update-refs", "--force-rebase", "main",
                                  check=False)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.git("branch", "--show-current").stdout.strip(),
                                 "agent/codex/rebase")

    def test_commit_with_existing_repository_hook_runs_both(self):
        hook = self.repo / ".git/hooks/prepare-commit-msg"
        hook.write_text('#!/bin/sh\nprintf "called\\n" >> .git/commit-hook-events\n')
        hook.chmod(0o755)
        self.git("switch", "-c", "agent/codex/coexist")
        self.git("commit", "--allow-empty", "-m", "coexist")
        self.assertEqual((self.repo / ".git/commit-hook-events").read_text(), "called\n")


if __name__ == "__main__":
    unittest.main()
