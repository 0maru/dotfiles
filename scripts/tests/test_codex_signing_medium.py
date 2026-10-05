"""Medium tests for commit signing through the non-interactive shell."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


CONFIG_DIR = Path(__file__).resolve().parents[2] / "config"


class TestCodexSigning(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / "repo"
        self.env = {
            key: value for key, value in os.environ.items()
            if not key.startswith(("GIT_", "CODEX_"))
            and key not in ("CLAUDECODE", "ZDOTDIR")
        }
        self.env.update(
            HOME=str(self.root),
            GIT_CONFIG_GLOBAL=str(CONFIG_DIR / "git/config"),
            GIT_CONFIG_NOSYSTEM="1",
        )
        (self.root / ".zshenv").symlink_to(CONFIG_DIR / "zsh/.zshenv")
        (self.root / ".config").symlink_to(CONFIG_DIR)
        self.run_command("git", "init", "-b", "main", str(self.repo), cwd=self.root)
        key = self.root / "signing-key"
        self.run_command("ssh-keygen", "-q", "-t", "ed25519", "-N", "", "-f", str(key))
        for name, value in {
            "user.name": "Signing Test",
            "user.email": "signing@example.com",
            "user.signingkey": str(key),
            "gpg.format": "ssh",
            "gpg.ssh.program": "ssh-keygen",
            "commit.gpgsign": "true",
        }.items():
            self.run_command("git", "config", name, value)

    def run_command(self, *args, env=None, cwd=None):
        return subprocess.run(
            args, cwd=cwd or self.repo, env=self.env if env is None else env,
            text=True, capture_output=True, check=True,
        )

    def test_commit_with_codex_on_any_branch_is_unsigned(self):
        # Arrange: Start from branches created outside the agent environment.
        for branch in ("main", "feature/existing", "agent/codex/topic"):
            with self.subTest(branch=branch):
                if branch != "main":
                    self.run_command("git", "switch", "-c", branch)
                env = dict(self.env, CODEX_THREAD_ID="test-session")
                # Act: Use the same non-interactive shell startup as Codex.
                self.run_command(
                    "zsh", "-c", 'exec "$@"', "--",
                    "git", "commit", "--allow-empty", "-m", "codex", env=env,
                )
                # Assert: The resulting commit has no signature.
                commit = self.run_command("git", "cat-file", "commit", "HEAD").stdout
                self.assertNotIn("\ngpgsig ", commit)

    def test_commit_without_codex_remains_signed(self):
        # Act: Commit from a normal non-interactive shell.
        self.run_command(
            "zsh", "-c", 'exec "$@"', "--",
            "git", "commit", "--allow-empty", "-m", "human",
        )
        # Assert: The normal signing configuration still produces a signature.
        commit = self.run_command("git", "cat-file", "commit", "HEAD").stdout
        self.assertIn("\ngpgsig -----BEGIN SSH SIGNATURE-----", commit)

    def test_commit_with_existing_runtime_config_preserves_other_settings(self):
        # Arrange: Inherit a signing override and an unrelated author setting.
        env = dict(
            self.env, CODEX_THREAD_ID="test-session", GIT_CONFIG_COUNT="2",
            GIT_CONFIG_KEY_0="commit.gpgsign", GIT_CONFIG_VALUE_0="true",
            GIT_CONFIG_KEY_1="user.name", GIT_CONFIG_VALUE_1="Inherited Author",
        )
        # Act: Commit through nested shells, as a tool subprocess would.
        self.run_command(
            "zsh", "-c", 'exec "$@"', "--",
            "zsh", "-c", 'exec "$@"', "--",
            "git", "commit", "--allow-empty", "-m", "nested", env=env,
        )
        # Assert: Signing is disabled without losing the inherited author.
        commit = self.run_command("git", "cat-file", "commit", "HEAD").stdout
        self.assertNotIn("\ngpgsig ", commit)
        self.assertIn("\nauthor Inherited Author <signing@example.com>", commit)


if __name__ == "__main__":
    unittest.main()
