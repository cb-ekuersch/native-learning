---
name: complete-lesson
description: Mark a native UI lesson completed in LESSONS.md and shut down the simulators/emulators this workspace booted for lessons. Invoke as /skill:complete-lesson <lesson number, path, or description> [— optional note].
disable-model-invocation: true
---

# Complete a lesson

Project root = the folder containing this `.agents/` directory. Run all commands from it.
The text after `/skill:complete-lesson` is the **argument**: which lesson to complete, optionally followed by a note.

## Rules
- `LESSONS.md` is the only learner record. Change it only with `scripts/log-lesson.sh`; never edit rows by hand.
- Mark exactly one lesson, and only the one the argument identifies. Never complete a lesson the user didn't name.
- Shut down only devices this workspace booted, via `scripts/stop-devices.sh`. Never run `simctl shutdown all`,
  `adb emu kill` on unrecorded devices, or kill Simulator/emulator processes directly.
- Do not scaffold or assign the next lesson here; just suggest it.

## Workflow
1. **Read state.** Run `scripts/init.sh`, then `scripts/log-lesson.sh show`.
2. **Resolve the lesson from the argument.**
   - A number (`3`, `03`, `lesson 3`) or a path (`lessons/03-ios-…`): match the `#` or `Path` column.
   - A description (`custom fonts`, `the compose layout one`, `latest`/`current`): match it against Goal, Concepts, Path,
     and Platform. `latest`/`current` = the highest-numbered row that is `assigned`/`in-progress`.
   - Note: text after the identifier, separated by `—`, `-`, `:`, or `note:` (e.g. `03 — enums clicked`), is the note.
     If there is no note, leave the existing note alone.
   - **No argument, no match, or more than one plausible match:** ask with `ask_user_question`, listing the open
     (`assigned`/`in-progress`) lessons as options. Do not guess.
3. **Check the status.**
   - Already `completed`: say so. Only update the note if the user gave a new one. Still continue to step 5.
   - `skipped`: confirm before changing it to `completed`.
4. **Mark it completed:** `scripts/log-lesson.sh status NN completed "note"` (omit the note argument if none).
   Optional heads-up (doesn't block): if `grep -rn "TODO (Ex" lessons/NN-*/` still finds exercise markers, mention
   how many remain. The user decides whether the lesson is done.
5. **Shut down devices:** `scripts/stop-devices.sh lessons/NN-<platform>-<slug>`.
   - This shuts down simulators/emulators recorded in `.state/devices` (booted by `run-lesson.sh` for any lesson),
     quits Simulator.app if the workspace opened it, and quits this lesson's app on anything left running.
   - If it lists devices as **left running**, those were already running before a lesson launched, or were booted
     before tracking existed. Ask whether to shut them down. Only on a clear yes, shut down exactly the listed ones
     (`xcrun simctl shutdown <udid>` / `adb -s <serial> emu kill`). In an unattended run, report them and leave them running.
6. **Report** in a few lines:
   - Which lesson was marked completed, plus the note. Show the updated row from `scripts/log-lesson.sh show`.
   - Which devices were shut down and which were left running.
   - The next lesson the `daily-native-lesson` skill would pick (alternate platform, earliest item in `CURRICULUM.md`
     with completed prereqs, honoring `LESSONS.md` planning notes). Don't scaffold it.

## Examples
- `/skill:complete-lesson 03`
- `/skill:complete-lesson custom fonts — Text vs some View finally clicked`
- `/skill:complete-lesson the latest one`
