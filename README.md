# native-learning — React Native → SwiftUI / Jetpack Compose

Self-contained, concept-first lessons with worked explanations, independent exercises, and reference solutions.
Each lesson takes 30–60 minutes. Use a coding agent with `AGENTS.md`, or follow the lesson READMEs yourself.

## Quick start

The current build/run scripts target **macOS** for both tracks. Initialization only requires Bash and Python 3.

```sh
git clone https://github.com/cb-ekuersch/native-learning.git
cd native-learning
./scripts/init.sh
```

This creates your private `LESSONS.md` from `templates/LESSONS.template.md`. It starts empty; shared lesson folders
do not count as completed lessons. Rerunning initialization preserves your existing log byte-for-byte.
No tools are installed, lessons assigned, or simulators launched by initialization.

### Install the tools for your track

- **iOS:** Xcode 16 or newer with an iOS 18+ simulator runtime and an iPhone simulator; open Xcode once to finish setup and accept its license. Install [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen` if you use Homebrew).
- **Android:** Android Studio, JDK 17+ (the scripts use Android Studio's bundled JDK when available), Android SDK Platform 37, SDK Build-Tools, Platform-Tools, Android Emulator, and a Pixel AVD created through Device Manager. Accept the SDK licenses in Android Studio. Gradle is bundled via its wrapper; the first build needs internet access.
- **Both:** Python 3 and standard macOS command-line tools (`bash`, `git`, `rsync`).

```sh
./scripts/doctor.sh ios       # or: android / both
```

If you use a non-default Xcode installation, set `DEVELOPER_DIR`. For a custom Android SDK, set `ANDROID_HOME`;
set `JAVA_HOME` if needed. The defaults and device overrides are described below.

### Start learning

With a coding agent: **“Read AGENTS.md and start my first native lesson.”** The skill initializes missing state,
checks prerequisites, and reuses the introductory lessons before generating new material.

Without an agent, choose one of the included lessons and enroll locally:

```sh
./scripts/log-lesson.sh start lessons/01-ios-views-stacks-modifiers
# Or: ./scripts/log-lesson.sh start lessons/02-android-composables-layout-modifiers
```

Read that folder's `README.md`, then use its `run.sh` and exercises. Follow its completion command only after
finishing. Re-enrollment refuses to overwrite progress; use `log-lesson.sh status` to change an existing entry.
Newly generated lessons use the next available folder number, which may differ from your personal lesson count.

## Privacy and sharing

- `LESSONS.md` contains your progress, notes, and preferences. It is ignored by Git and is never seeded from another learner's history.
- Back up your log privately if you need it on another machine. Git ignore prevents ordinary commits; it is not encryption and does not prevent `git add -f` or manual sharing.
- Local agent settings (`.pi/`), IDE settings, local SDK paths, common credential files, and build output are ignored.
- Lesson source, solutions, curriculum, scripts, and templates are shared. Review `git diff --cached` before pushing, especially if you put personal content in exercises.
- Curriculum lesson links describe available materials, not personal completion. Keep personal next-topic requests in your local log.

## Project map

| File | Purpose |
|---|---|
| `AGENTS.md`, `.agents/skills/daily-native-lesson/` | Agent context and lesson workflow. |
| `LESSONS.md` | Private, ignored learner memory; created by `scripts/init.sh`. |
| `templates/LESSONS.template.md` | Blank learning-log template for fresh clones. |
| `CURRICULUM.md` | Ordered concept tracks used to pick the next lesson. |
| `templates/` | `ios/` (XcodeGen SwiftUI app), `android/` (Gradle Compose app), `README.template.md`. |
| `lessons/NN-<platform>-<slug>/` | One lesson: `README.md`, starter code, `Solutions/`, `run.sh`, `verify.sh`, `.lesson`. |

## Scripts (`scripts/`)

```sh
init.sh                                      # create private learner state without overwriting it
doctor.sh [ios|android|both]                   # check the chosen platform's toolchain
new-lesson.sh <ios|android> <slug> "<Title>" "<concepts>"   # scaffold next lesson + log it as assigned
run-lesson.sh <dir>     (or <dir>/run.sh)       # boot sim/emulator, build, install, launch
verify-lesson.sh <dir>  (or <dir>/verify.sh)    # build starter, then starter+Solutions overlay
log-lesson.sh start <lesson-dir>              # enroll in existing shared material
log-lesson.sh status <NN> completed "note"     # update memory; also: add, show
```

iOS uses Xcode 27 (then Xcode 16, then xcode-select) via `DEVELOPER_DIR` without changing global settings.
Overrides: `SIM_DEVICE=<udid>`, `AVD=<name>`.

## Lesson conventions

- One goal per lesson; concept-first, generic examples; no design-system lens.
- Teach first, then practice: the lesson README contains a self-contained walkthrough with worked code, explanations, and expected results. No required documentation lookup or trial-and-error discovery.
- Exercises are independent variations/recombinations of the walkthrough examples, with exact TODO locations, clear outcomes, and optional hints. Explain small new twists inline; keep full answers in `Solutions/`.
- Documentation links remain available for optional deeper reading. Budget 15–20 min for teaching, 15–30 min for coding, and 5–10 min for checks.
- Starter must build and launch before any edits; exercises are marked `TODO (Ex N)` in code.
- Walkthrough code may exist only as illustrative code blocks in the lesson README. It need not be runnable or included in the app; keep it accurate and explain any necessary context. Build verification applies to the starter and solution overlay.
- `Solutions/` mirrors the starter's relative paths and overlays it; never compiled into the app.
- README follows `templates/README.template.md` sections exactly.

## Toolkit tests

Run `python3 -m unittest discover -s tests -v` for initialization, log enrollment, and privacy checks.
These tests do not build native apps or require Xcode/Android SDKs.
