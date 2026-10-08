---
name: daily-native-lesson
description: Initialize, run, continue, or review daily 30-60 minute native UI lessons (SwiftUI / Jetpack Compose) for a React Native developer. Use when asked to set up a fresh clone, start today's lesson, present the current lesson, mark a lesson done, pick the next topic, scaffold a SwiftUI/Compose lesson, or adjust the lesson format or teaching style.
---

# Daily native UI lesson

Project root = the folder containing this `.agents/` directory. All paths below are relative to it.

## Rules
- **Memory:** `LESSONS.md` is the ONLY source of truth for what the learner knows. Never infer knowledge from anything else
  (other repos, `~/workspace/*`, Android Studio projects, git history, past agent sessions, shell history).
  Only status `completed` counts as known. Baseline = React Native + TypeScript.
- **Private state and content:** `LESSONS.md` and all of `lessons/` are Git-ignored. Never force-add them or copy personal progress/preferences into shared docs. Only the toolkit, curriculum, and templates are shared.
- **Concept-first, design-system-neutral.** Plain, generic examples. Do not frame lessons around CDS or any design system.
  React Native comparisons are encouraged.
- **One focused goal per lesson**, 30–60 min. Don't reteach completed concepts as the main goal; reuse them in examples and exercises.
- Cross-platform comparisons (SwiftUI ↔ Compose) only for concepts already completed on the other track.
- Docs: authoritative only — developer.apple.com, docs.swift.org, developer.android.com, kotlinlang.org.
- Use the toolkit; never hand-roll projects. If a script lacks something, improve the script/template (keep it reusable).
- **All lesson source code lives in this workspace** as one folder per lesson: `lessons/NN-<platform>-<slug>/`
  (created by `scripts/new-lesson.sh`). Never create lesson code outside it (no `/tmp`, `~/`, or other repos), except
  throwaway copies made by `verify.sh`.
- **Session name:** as soon as the lesson number is known, call `set_session_scope` with a title that starts with the
  lesson number, format `Lesson NN: <Title>` (e.g. `Lesson 02: Compose basics`). Rename only if the lesson changes.

## Teaching style: guided explanation, independent practice
The learner has limited study time. Teach the concepts inside the lesson's `README.md`, then let them write the exercise code. Reading external docs or discovering behavior by trial and error should not be necessary to complete the core lesson.

- **Teach before asking.** Make `Concept` a self-contained, numbered walkthrough, not a short glossary. For each new concept: explain what it does and when to use it, show a small worked code example, explain the important lines (including unfamiliar Swift/Kotlin syntax), and describe the expected UI or behavior and why it happens. Keep React Native comparisons as a bridge, not a substitute for native explanations.
- **Show contrasts explicitly.** For order-sensitive APIs or common pitfalls, show both variants and explain their different results before practice. Don't require the learner to swap things blindly to discover the rule; optional experiments can confirm an already-taught rule.
- **Use accurate, focused demonstrations.** Check APIs and behavior against authoritative docs and the lesson's configured SDK/dependencies. Walkthrough code can live solely in fenced code blocks in the README; it does not need to be runnable, standalone, included in the starter app, or compiled by `verify.sh`. Omit imports and boilerplate when they distract from the concept. Explain any context needed to understand the snippet, and label excerpts or pseudocode clearly rather than presenting them as complete runnable code.
- **Keep teaching examples separate from exercise implementation.** Use small illustrative snippets to explain the concept without implementing the learner's exercise for them. Add runnable demonstrations only when they help the lesson, not as a requirement.
- **Practice through variations.** Sequence 3–5 small exercises from a close variation of a worked example to a modest recombination. Point each exercise to the relevant walkthrough step, exact file and `TODO (Ex N)`, intended change, and observable result. Change content, layout, values, or composition so the learner applies the pattern rather than transcribes the completed answer.
- **Allow bounded novelty.** An exercise may add a small new API or twist, but explain it inline with a mini-example and enough context to use it. No required step should depend on an unexplained API or external research. Put open-ended discovery in `Stretch (optional)`.
- **Keep implementation independent.** Supply requirements and optional collapsible hints, not a step-by-step finished exercise implementation. Keep full exercise answers in `Solutions/`. Add short collapsible answers to understanding checks so the learner can self-check without searching.
- **Keep references optional.** Link authoritative references beside relevant explanations and in `Docs`, with a short note on what each link expands on. Say explicitly that the core lesson is self-contained and links are for optional deeper reading.
- **Budget the whole lesson.** Aim for 15–20 min of walkthrough, 15–30 min of coding, and 5–10 min of checks (35–60 min total). If that is too much, reduce scope rather than turn teaching into a reading assignment. Optional docs and stretch work are outside this budget.

## Workflow: initialize a fresh clone

1. Run `scripts/init.sh`. It creates `LESSONS.md` from `templates/LESSONS.template.md` only if absent; never reset an existing log.
2. Read `README.md` for platform prerequisites. Ask which platform to start with if unspecified; SwiftUI is the default when both are wanted.
3. Run `scripts/doctor.sh ios` or `scripts/doctor.sh android` for the chosen track. Explain missing tools; do not install software without permission.
4. Read the private log. A fresh clone starts with no completed lessons and no generated lesson folders. Honor personal topic requests only from this log or the current user.
5. Continue with the lesson workflow below. Initialization alone must not assign or complete any lesson.

## Workflow: start today's lesson
1. Run `scripts/init.sh`, then read `LESSONS.md` and `CURRICULUM.md`.
2. If the latest lesson is `assigned`/`in-progress`, ask whether it's finished (offer: mark completed via
   `scripts/log-lesson.sh status NN completed "note"`, continue it, or redo). In an unattended run, present the open
   lesson and remaining exercises instead of assigning another, unless the user explicitly requested a new one. Never mark it completed automatically.
3. Choose the track: alternate from the last lesson's platform (SwiftUI ↔ Compose) unless the user says otherwise.
   Pick the earliest item on that track whose prereqs are completed. Adjust/add curriculum items if a gap appears (note why in LESSONS.md Notes).
   Reuse an existing local lesson matching the chosen concept if its prerequisites are met. Register it with
   `scripts/log-lesson.sh start lessons/NN-<platform>-<slug> "concepts introduced"` (only if absent from the log),
   then verify/run and present it without scaffolding another copy. Preserve existing learner edits; never reset them silently.
   Lesson numbers are local to this workspace. For an empty log, begin with S1 or C1 and scaffold if no suitable local lesson exists.
4. Scaffold: `scripts/new-lesson.sh <ios|android> <slug> "<Title>" "<concepts introduced>"` → prints `lessons/NN-<platform>-<slug>`
   and logs it as `assigned`. Immediately name the session `Lesson NN: <Title>` via `set_session_scope`.
5. Write the starter (must build & launch before edits; exercises marked `TODO (Ex N)`), and reference solutions under
   `Solutions/` mirroring starter-relative paths.
   - iOS: sources in `Sources/` (XcodeGen picks up new files automatically).
   - Android: Kotlin in `app/src/main/java/<pkg path>/`; package from `.lesson` (`PKG`).
6. Fill `README.md` section-for-section per `templates/README.template.md`
   (Goal, Assumes [lesson numbers], Run it, Concept, Coming from React Native table, Exercises, Done when, Check your understanding, Stretch, Docs, After the lesson).
   Apply the teaching style above: worked walkthroughs first, then exercises that explicitly vary those examples.
7. Review coverage: every required exercise concept is taught in the walkthrough or an inline mini-example, each exercise maps to an example, and docs are optional. Review README snippets for conceptual/API accuracy and clear context; they do not require compilation. Run `lessons/NN-…/verify.sh` — starter AND solution overlay must build. Fix until green.
8. `lessons/NN-…/run.sh` — boots simulator/emulator and launches (iOS: Xcode 27 → 16 → xcode-select via DEVELOPER_DIR; Android: a Pixel AVD).
9. Record the curriculum ID (such as S1) in the local lesson README. Keep lesson-number mappings, personal completion, and next-topic requests only in `LESSONS.md`, not the shared curriculum.
10. Present: goal, what it builds on, how to run, the README's guided walkthrough and practice sequence, done-when checks, optional docs, and the
    reminder to run `scripts/log-lesson.sh status NN completed "note"`. Make the lesson README the primary teaching material, not a list of reading assignments.

## Other requests
- "Present today's lesson": name the session `Lesson NN: <Title>`, re-run the latest lesson's `run.sh`, then present its README content (step 10 format).
- "Mark done": `scripts/log-lesson.sh status NN completed "note"`; show `scripts/log-lesson.sh show`.
- Toolchain problems: `scripts/doctor.sh`.
