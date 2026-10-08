# native-learning — React Native → SwiftUI / Jetpack Compose

A toolkit for generating self-contained, concept-first lessons with explanations, exercises, and reference solutions.
Each lesson takes 30–60 minutes. The toolkit is shared; generated lessons and learner progress stay local.

## Quick start

The current build/run scripts target **macOS** for both tracks. Initialization only requires Bash and Python 3.

```sh
git clone https://github.com/cb-ekuersch/native-learning.git
cd native-learning
./scripts/init.sh
```

This creates your private `LESSONS.md` from `templates/LESSONS.template.md`. It starts empty.
Rerunning initialization preserves your existing log byte-for-byte. No generated lessons are included in a fresh clone.
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
checks prerequisites, and generates a first lesson for your chosen platform in the ignored `lessons/` folder.

To scaffold a lesson manually (this creates a template, not a finished walkthrough or exercise set):

```sh
./scripts/new-lesson.sh ios first-screen "Views, stacks and modifiers" "View/body, stacks, modifiers"
# Or choose android and a Compose topic.
```

Fill the generated README, starter code, and solutions using the lesson skill's conventions, then verify/run it.
Scaffolding registers the lesson locally. Follow its completion command only after finishing the exercises.
`log-lesson.sh start <lesson-dir>` can register an existing local lesson after restoring a private backup;
it refuses to overwrite existing progress. Lesson numbers are local to each learner's workspace.

## Ask your agent for a personalized curriculum

Open a coding-agent session in this clone and paste the prompt below. You can replace the bracketed
preferences up front or let the agent ask you about them:

```text
Help me create my own native UI curriculum in this repository.
Read AGENTS.md, .agents/skills/daily-native-lesson/SKILL.md, and CURRICULUM.md.
Run scripts/init.sh and read my private LESSONS.md without resetting it.

My goals: [e.g. build production-quality native screens from a React Native background].
Platforms: [SwiftUI, Jetpack Compose, or both].
Time budget: [e.g. 30–60 minutes per session, 4 days per week].
Topics I especially want: [e.g. typography, accessibility, navigation, state].

Ask a few focused questions to fill in missing goals, experience, and constraints.
Treat LESSONS.md as the only existing record of my knowledge; don't infer experience
from lesson folders. Record any starting-baseline changes only after confirming with me.
Use completed lessons to avoid reteaching concepts, but keep prerequisites explicit.

Propose an ordered curriculum with one focused goal per lesson, stable topic IDs,
prerequisites, and a small practice outcome. Include the language basics needed for
each topic. Keep lessons concept-first and design-system-neutral, with React Native
comparisons where useful. If I choose both platforms, propose an alternating sequence.
Don't introduce a cross-platform comparison before I've learned the other side.

Show me the proposed plan and ask for approval before replacing CURRICULUM.md.
Preserve unrelated edits and existing lesson files. Keep personal goals, sequencing
preferences, experience, and progress in LESSONS.md; make CURRICULUM.md a generic
topic/prerequisite plan without personal details or completion state.
Do not generate lesson code, mark anything complete, commit, push, or create an
automation yet. After I approve the plan, tell me how to start its first lesson.
```

Review the proposed order and workload before approving it. Then ask **“Start my next lesson using
my updated curriculum and local planning notes.”** The daily automation below reads the same files, so
future runs will use the new plan without needing a new automation.

`CURRICULUM.md` is tracked: customizing it creates a local Git change. Commit/share that plan only if
you intend to publish it. Keep private context in ignored `LESSONS.md`; keep generated lessons in ignored
`lessons/`. If you later pull toolkit updates, review any curriculum conflict rather than overwriting your plan.

## Daily lessons with a Toshi automation

Set up the tools above and run one lesson interactively first, so authentication, permissions, and native
toolchain issues are resolved before an unattended run. Scheduling uses Toshi's Automations hub; this repository
does not install a scheduler or create an automation when you run `init.sh`.

### Create the automation

In a Toshi session opened in this clone, paste the request below. Replace the example path and time first
(`pwd` prints your clone's absolute path):

```text
Create a local Toshi automation named "Daily native lesson".
Run daily at 09:00 in /absolute/path/to/native-learning.
Use this exact checkout, without creating a worktree. Use fresh context for each run.
Use the default model. Before creating anything, check for an existing automation
with this name and checkout so we don't create duplicates.

Task prompt:
Work only in /absolute/path/to/native-learning.
Read AGENTS.md and .agents/skills/daily-native-lesson/SKILL.md.
Run scripts/init.sh, then read LESSONS.md and CURRICULUM.md.
Treat LESSONS.md as the only record of my knowledge and personal topic requests.
If a lesson is assigned or in-progress, present that lesson and its remaining
exercises instead of generating another. Never mark it completed automatically.
Otherwise prepare one 30–60 minute lesson using the skill's workflow.
Alternate SwiftUI and Compose unless my local planning notes request otherwise;
start with SwiftUI when the log is empty. Teach prerequisites before using them.
Keep generated content under lessons/. Never commit or push lessons/ or LESSONS.md.
End with the local README path, run command, lesson goal, and completion command.
```

The scheduled run opens a local Toshi sidebar session and sends the task prompt. Open the
[Automations hub](toshi://automations) to review the saved schedule and next-run time, or create the
job there manually using the same task prompt and settings:

| Setting | Value |
|---|---|
| Scope | Local / this Mac |
| Repository path | The absolute path of your initialized clone |
| Schedule | Daily at your preferred time (or weekdays); verify the displayed next run |
| Checkout | Existing checkout, no new worktree (`use_worktree: false`) |
| Context | Fresh (`context_mode: fresh`); durable learner memory stays in `LESSONS.md` |

**Use the same checkout every day.** A new clone, isolated worktree, or cloud runner will not contain
your ignored log or lessons and can incorrectly start you from scratch. Local execution also gives the
agent access to Xcode, the Android SDK, and your simulators/emulators. Keep your Mac awake and Toshi
running at the scheduled time; don't rely on missed-run catch-up. Runs consume your configured model usage
and may build apps or launch a simulator/emulator as part of the lesson workflow.

### Test and manage it

1. Use the Automations hub to run the job once on demand. Confirm its session is working in the exact
   checkout you chose and that the lesson README and log entry appear there.
2. Finish the lesson, then mark it completed from the repository root (replace `NN` with its number):

   ```sh
   ./scripts/log-lesson.sh status NN completed "optional note"
   ```

3. The next run can build on that completion. If you haven't finished, it should continue the open lesson
   rather than create a backlog. Never run two lesson-generation jobs against the same checkout at once.
4. Inspect recent runs and the next scheduled run in the hub. Pause/resume it there, or ask Toshi to change
   the time or use weekdays. Check for an existing job before creating another.

The automation configuration lives in Toshi, not in this public repository. Cloning this toolkit does not
copy anyone else's schedule, lessons, or learning history.

## Privacy and sharing

- `LESSONS.md` contains your progress, notes, and preferences. It is ignored by Git and is never seeded from another learner's history.
- All of `lessons/` is ignored, including generated walkthroughs, exercise code, and solutions. Back it up along with your log privately. Git ignore is not encryption and does not prevent `git add -f` or manual sharing.
- Local agent settings (`.pi/`), IDE settings, local SDK paths, common credential files, and build output are ignored.
- Only the curriculum, agent instructions, scripts, tests, and templates are shared. Review `git diff --cached` before pushing.
- Keep personal lesson mappings, completion, and next-topic requests in your local log, not the curriculum.

## Project map

| File | Purpose |
|---|---|
| `AGENTS.md`, `.agents/skills/daily-native-lesson/` | Agent context and lesson workflow. |
| `LESSONS.md` | Private, ignored learner memory; created by `scripts/init.sh`. |
| `templates/LESSONS.template.md` | Blank learning-log template for fresh clones. |
| `CURRICULUM.md` | Ordered concept tracks used to pick the next lesson. |
| `templates/` | `ios/` (XcodeGen SwiftUI app), `android/` (Gradle Compose app), `README.template.md`. |
| `lessons/NN-<platform>-<slug>/` | Ignored local lesson: walkthrough, starter code, solutions, and run/verify scripts. |

## Scripts (`scripts/`)

```sh
init.sh                                      # create private learner state without overwriting it
doctor.sh [ios|android|both]                   # check the chosen platform's toolchain
new-lesson.sh <ios|android> <slug> "<Title>" "<concepts>"   # scaffold next lesson + log it as assigned
run-lesson.sh <dir>     (or <dir>/run.sh)       # boot sim/emulator, build, install, launch
verify-lesson.sh <dir>  (or <dir>/verify.sh)    # build starter, then starter+Solutions overlay
log-lesson.sh start <lesson-dir>              # register existing local material in your log
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
