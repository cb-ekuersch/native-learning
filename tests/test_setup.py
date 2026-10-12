"""Fresh-clone setup checks; no native SDKs or third-party Python packages required."""
import os
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

    def run_script(self, name, *args, ok=True, env=None):
        result = subprocess.run(
            [str(self.root / "scripts" / name), *args], cwd=self.root,
            text=True, capture_output=True, env=env,
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
        for name in ["LESSONS.md", ".state/devices", ".pi/mcp.json", ".idea/workspace.xml",
                     "lessons/example/local.properties", ".env", "lessons/example/build/output",
                     "lessons/01-ios-intro/.lesson", "lessons/example/README.md",
                     "lessons/example/Sources/App.swift", "lessons/example/Solutions/answer.kt"]:
            result = subprocess.run(["git", "check-ignore", "-q", name], cwd=self.root)
            self.assertEqual(result.returncode, 0, name)
        for name in ["templates/LESSONS.template.md", "scripts/init.sh",
                     "templates/ios/Sources/App.swift", "templates/README.template.md"]:
            result = subprocess.run(["git", "check-ignore", "-q", name], cwd=self.root)
            self.assertEqual(result.returncode, 1, name)

    def fake_devices(self):
        """Stub xcrun/adb/osascript/pgrep: one managed + one user-owned simulator and emulator."""
        bin_dir, state = self.root / "bin", self.root / "fake"
        bin_dir.mkdir(); state.mkdir()
        (state / "sims").write_text("AAAAAAAA-0000-0000-0000-000000000001\nBBBBBBBB-0000-0000-0000-000000000002\n")
        (state / "emus").write_text("emulator-5554\nemulator-5556\n")
        stubs = {
            "xcrun": """case "$*" in
  "simctl list devices booted"|"simctl list devices") sed 's/.*/    iPhone (&) (Booted)/' "$S/sims" ;;
  "simctl shutdown "*) grep -vx "$3" "$S/sims" > "$S/t" || true; mv "$S/t" "$S/sims" ;;
esac""",
            "adb": """case "$*" in
  devices) echo "List of devices attached"; sed 's/$/\tdevice/' "$S/emus" ;;
  *"emu kill") grep -vx "$2" "$S/emus" > "$S/t" || true; mv "$S/t" "$S/emus" ;;
esac""",
            "osascript": "true", "pgrep": "true",
        }
        for name, body in stubs.items():
            f = bin_dir / name
            f.write_text(f'#!/usr/bin/env bash\nS="{state}"\necho "{name} $*" >> "$S/calls"\n{body}\n')
            f.chmod(0o755)
        env = {**os.environ, "PATH": f"{bin_dir}:{os.environ['PATH']}", "ANDROID_HOME": str(self.root / "sdk")}
        (self.root / ".state").mkdir()
        (self.root / ".state/devices").write_text(
            "ios\tAAAAAAAA-0000-0000-0000-000000000001\t01\t\n"
            "ios\tsimulator-app\t01\t\n"
            "android\temulator-5554\t01\tPixel:999999\n"
        )
        return env, state

    def test_stop_devices_only_stops_recorded_devices(self):
        env, state = self.fake_devices()
        result = self.run_script("stop-devices.sh", "lessons/01-ios-intro", env=env)
        calls = (state / "calls").read_text()
        self.assertIn("simctl shutdown AAAAAAAA-0000-0000-0000-000000000001", calls)
        self.assertIn("adb -s emulator-5554 emu kill", calls)
        self.assertNotIn("shutdown BBBBBBBB", calls)
        self.assertNotIn("emulator-5556 emu kill", calls)
        self.assertNotIn("osascript", calls)  # a user-owned simulator is still booted
        self.assertIn("simctl terminate BBBBBBBB-0000-0000-0000-000000000002 com.example.intro", calls)
        self.assertIn("Stopped 2", result.stdout)
        self.assertIn("emulator-5556", result.stdout)  # reported as left running
        self.assertFalse((self.root / ".state/devices").exists())

    def test_stop_devices_dry_run_changes_nothing(self):
        env, state = self.fake_devices()
        registry = (self.root / ".state/devices").read_bytes()
        result = self.run_script("stop-devices.sh", "--dry-run", env=env)
        self.assertNotIn("shutdown", (state / "calls").read_text())
        self.assertNotIn("emu kill", (state / "calls").read_text())
        self.assertIn("Would stop 2", result.stdout)
        self.assertEqual((self.root / ".state/devices").read_bytes(), registry)

    def test_record_device_is_idempotent(self):
        cmd = 'source scripts/_lib.sh; record_device ios X 01; record_device ios X 02; record_device android X 02'
        subprocess.run(["bash", "-c", cmd], cwd=self.root, check=True)
        self.assertEqual((self.root / ".state/devices").read_text(), "ios\tX\t01\t\nandroid\tX\t02\t\n")

    def test_invalid_doctor_track_fails_with_usage(self):
        result = self.run_script("doctor.sh", "invalid", ok=False)
        self.assertIn("usage:", result.stderr)


if __name__ == "__main__":
    unittest.main()
