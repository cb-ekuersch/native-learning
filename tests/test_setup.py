"""Fresh-clone setup checks; no native SDKs or third-party Python packages required."""
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class SetupTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="native-learning-setup-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        shutil.copytree(ROOT / "scripts", self.root / "scripts")
        (self.root / "templates").mkdir()
        shutil.copy2(ROOT / "templates/LESSONS.template.md", self.root / "templates")
        shutil.copy2(ROOT / ".gitignore", self.root)
        # Metadata fixture only: no app builds or learner code is copied.
        lesson = self.root / "lessons/01-ios-intro"
        lesson.mkdir(parents=True)
        (lesson / ".lesson").write_text(
            "PLATFORM=ios\nNUM=01\nTITLE='Intro views'\nAPP=Intro\nBUNDLE=com.example.intro\n"
        )

    def run_script(self, name, *args, ok=True):
        result = subprocess.run(
            [str(self.root / "scripts" / name), *args], cwd=self.root,
            text=True, capture_output=True,
        )
        if ok:
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        else:
            self.assertNotEqual(result.returncode, 0)
        return result

    def test_fresh_init_has_no_lesson_rows(self):
        self.run_script("init.sh")
        log = (self.root / "LESSONS.md").read_text()
        self.assertEqual(log, (self.root / "templates/LESSONS.template.md").read_text())
        self.assertNotIn("| 01 |", log)

    def test_init_preserves_existing_log_byte_for_byte(self):
        data = b"Personal progress\r\nDo not overwrite\n"
        (self.root / "LESSONS.md").write_bytes(data)
        self.run_script("init.sh")
        self.run_script("init.sh")
        self.assertEqual((self.root / "LESSONS.md").read_bytes(), data)

    def test_init_refuses_symlink(self):
        target = self.root / "private.md"
        target.write_text("untouched")
        (self.root / "LESSONS.md").symlink_to(target)
        self.run_script("init.sh", ok=False)
        self.assertEqual(target.read_text(), "untouched")

    def test_init_refuses_directory(self):
        (self.root / "LESSONS.md").mkdir()
        self.run_script("init.sh", ok=False)

    def test_show_auto_initializes(self):
        result = self.run_script("log-lesson.sh", "show")
        self.assertIn("| # | Date |", result.stdout)
        self.assertNotIn("| 01 |", result.stdout)

    def test_enroll_complete_and_reenroll_preserves_progress(self):
        self.run_script("log-lesson.sh", "start", "lessons/01-ios-intro", "View/body")
        log = self.root / "LESSONS.md"
        self.assertIn("| assigned |", log.read_text())
        self.assertIn("| View/body |", log.read_text())
        self.run_script("log-lesson.sh", "status", "01", "completed", "clicked")
        data = log.read_bytes()
        self.run_script("log-lesson.sh", "start", "lessons/01-ios-intro", ok=False)
        self.assertEqual(log.read_bytes(), data)
        self.assertIn("| completed | clicked |", log.read_text())
        self.assertIn("## Planning notes", log.read_text())

    def test_invalid_status_preserves_log(self):
        self.run_script("log-lesson.sh", "start", "lessons/01-ios-intro")
        log = self.root / "LESSONS.md"
        data = log.read_bytes()
        self.run_script("log-lesson.sh", "status", "01", "typo", ok=False)
        self.assertEqual(log.read_bytes(), data)

    def test_remove_drops_open_lesson_but_refuses_completed(self):
        log = self.root / "LESSONS.md"
        self.run_script("log-lesson.sh", "start", "lessons/01-ios-intro")
        self.run_script("log-lesson.sh", "remove", "01")
        self.assertNotIn("| 01 |", log.read_text())
        self.run_script("log-lesson.sh", "remove", "01", ok=False)
        self.run_script("log-lesson.sh", "start", "lessons/01-ios-intro")
        self.run_script("log-lesson.sh", "status", "01", "completed")
        data = log.read_bytes()
        self.run_script("log-lesson.sh", "remove", "01", ok=False)
        self.assertEqual(log.read_bytes(), data)

    def test_private_files_ignored_shared_template_not_ignored(self):
        subprocess.run(["git", "init", "-q", str(self.root)], check=True)
        for name in ["LESSONS.md", ".pi/mcp.json", ".idea/workspace.xml",
                     "lessons/example/local.properties", ".env", "lessons/example/build/output",
                     "lessons/01-ios-intro/.lesson", "lessons/example/README.md",
                     "lessons/example/Sources/App.swift", "lessons/example/Solutions/answer.kt"]:
            result = subprocess.run(["git", "check-ignore", "-q", name], cwd=self.root)
            self.assertEqual(result.returncode, 0, name)
        for name in ["templates/LESSONS.template.md", "scripts/init.sh",
                     "templates/ios/Sources/App.swift", "templates/README.template.md"]:
            result = subprocess.run(["git", "check-ignore", "-q", name], cwd=self.root)
            self.assertEqual(result.returncode, 1, name)

    def test_invalid_doctor_track_fails_with_usage(self):
        result = self.run_script("doctor.sh", "invalid", ok=False)
        self.assertIn("usage:", result.stderr)


if __name__ == "__main__":
    unittest.main()
