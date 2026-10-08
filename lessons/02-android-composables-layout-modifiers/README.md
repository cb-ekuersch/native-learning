# Lesson 02 — Composables, layouts and modifiers

**Platform:** Jetpack Compose · **Date:** 2026-10-06 · **Time:** 35–60 min · Curriculum: C1

Read the walkthrough first, then build the event card yourself. Everything needed for the exercises is taught here. Links and stretch work are optional.

**Plan:** walkthrough 15–20 min → coding 15–30 min → checks 5–10 min.

## Goal
Build a small screen from `@Composable` functions using `Column`/`Row`/`Box` and a `Modifier` chain, and predict how modifier order changes the result.

## Assumes
React Native + TypeScript only. No Kotlin or Compose, and no completed native lessons required—including Lesson 01. This walkthrough starts from the beginning.

## Run it
From the workspace root:

```sh
cd lessons/02-android-composables-layout-modifiers
./run.sh        # build, install, launch on the Android emulator
./verify.sh     # build the starter and a temporary copy with Solutions overlaid
```

Re-run `./run.sh` after edits, or open this lesson folder in Android Studio and use Run. Split/Design view shows the `@Preview`; use the emulator for checking touch feedback.

Edit only **`app/src/main/java/com/example/lessons/l02eventcard/MainActivity.kt`**, called `MainActivity.kt` below. Its imports are already provided. Leave the `MainActivity` class and `LessonScreen` startup code alone; your work is in `EventCard`, `DateTile`, and `RsvpButton`.

The starter displays a plain column of the supplied pieces. The walkthrough examples below are **reading material**, not extra files or code you must run. After the first example, snippets omit imports and surrounding functions and are intended to illustrate code inside a composable.

## Concept

### 1. A composable is a function that describes UI

In RN, a component returns JSX. In Compose, a function marked `@Composable` contributes UI by calling other composables.

```kotlin
@Composable
fun ReadingNote(modifier: Modifier = Modifier) {
    Column(modifier = modifier) {
        Text("Evening reading")
        Text("Chapter 3")
    }
}

@Preview(showBackground = true)
@Composable
private fun ReadingNotePreview() {
    MaterialTheme {
        ReadingNote()
    }
}
```

This illustrative declaration assumes the usual Compose imports; you do not need to add it to the starter.

Read the Kotlin syntax this way:

- `fun` declares a function. UI-producing composables conventionally start with a capital letter.
- `@Composable` enables calls to other composables in the function. These examples return `Unit`—Kotlin's “no useful return value”—rather than a JSX element.
- `modifier: Modifier = Modifier` declares a parameter named `modifier`, of type `Modifier`, whose default is the empty `Modifier` chain. The lowercase name is the value the caller passes; the uppercase name is the type/empty starting value.
- `Column(modifier = modifier)` uses a named argument; Kotlin uses `=` at the call site.
- `{ ... }` after `Column` is a **trailing lambda**, a block passed as its final content argument. Calls inside that block become children.
- `@Preview` marks an editor preview, and `showBackground = true` gives its canvas a background. `private` keeps the preview function local to the file.

**Expected result:** two text lines in a column. Your starter already has the equivalent preview, so you don't need to write one.

`MaterialTheme` supplies the built-in text styles and color palette used by this starter. You'll read those values later; no theme configuration or design-system knowledge is required.

A reusable composable accepts the caller's `modifier` and applies it **once to its root layout**. That lets its parent control its outer spacing/size without accidentally applying the same padding to every child. New internal children usually start with their own `Modifier`.

Compose can re-run composables when observed state changes, and can skip work when appropriate. This is called recomposition; today you only need to keep these functions focused on describing UI, without side effects.

**Optional deeper reading:** [Thinking in Compose](https://developer.android.com/develop/ui/compose/mental-model) and [previews](https://developer.android.com/develop/ui/compose/tooling/previews).

### 2. Arrange children and allocate the remaining space

Use `Column` for vertical children and `Row` for horizontal children. Nest them to group text:

```kotlin
Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
    ) {
        Text("Book")
        Column {
            Text("Evening reading")
            Text("Chapter 3")
        }
        Spacer(Modifier.weight(1f))
        Text("Open")
    }
    Text("A short session before dinner.")
}
```

- `12.dp` is a density-independent distance. Kotlin lets the `.dp` extension turn a number into a `Dp` value, much like RN's logical layout numbers rather than physical pixels.
- `Arrangement.spacedBy(...)` inserts gaps along the container's main axis: vertical for `Column`, horizontal for `Row`.
- `Alignment.CenterVertically` centers the row's children across its axis. A column instead uses `horizontalAlignment`, for example `Alignment.CenterHorizontally`.
- `.fillMaxWidth()` asks the row to use the available width within its parent's constraints.
- `Spacer(Modifier.weight(1f))` receives the remaining row width. `1f` means a floating-point number; the weight API expects a `Float`.
- Trailing commas before `)` are valid Kotlin and make multiline arguments easier to edit.

**Expected result:** “Book,” a two-line text group, and “Open” appear in one row with a description below. For these short labels, the weighted spacer pushes “Open” to the end.

However, a spacer isn't a fix for long text. The row measures **unweighted children first**, then distributes the remaining width among weighted children. A long unweighted title can consume room the action needs. Put the weight on the content that should flex instead:

```kotlin
Row(
    modifier = Modifier.fillMaxWidth(),
    horizontalArrangement = Arrangement.spacedBy(8.dp),
    verticalAlignment = Alignment.CenterVertically,
) {
    Text("Book")
    Column(Modifier.weight(1f)) {
        Text("A much longer reading session title")
        Text("Chapter 3")
    }
    Text("Open")
}
```

Now the row measures “Book” and “Open” first and gives the middle column the remaining width. That column can wrap its text. **No extra spacer is needed.** This is the version to adapt for the event card's title/details between its date tile and RSVP, at normal phone widths.

`weight` is a scoped modifier: this call is available inside `Row` content and describes a direct child's width allocation. Inside `Column`, it allocates height instead. `Box` doesn't distribute space this way, so its content alone doesn't provide `weight`.

**Optional deeper reading:** [Layout basics](https://developer.android.com/develop/ui/compose/layouts/basics) and [modifier scope safety and weight](https://developer.android.com/develop/ui/compose/modifiers#scope-safety).

### 3. Read modifier chains from the outside inward

A `Modifier` chain configures a composable's layout, drawing, and interaction. Earlier elements surround the later ones. Here are two deliberately different results:

```kotlin
// A: clear space outside a tightly painted label
Text(
    "Read",
    modifier = Modifier
        .padding(12.dp)
        .background(MaterialTheme.colorScheme.primaryContainer),
)

// B: a painted label INCLUDING the padding around its text
Text(
    "Read",
    modifier = Modifier
        .background(MaterialTheme.colorScheme.primaryContainer)
        .padding(12.dp),
)
```

In A, you encounter the padding before the background, so the background occupies the smaller inner area. In B, the background surrounds the padding, so the colored area includes that space. The rule is already known before you try anything in the editor.

Use that nesting to build a card. This excerpt assumes a composable with a `modifier` parameter:

```kotlin
Column(
    modifier = modifier
        .padding(24.dp)
        .fillMaxWidth()
        .clip(RoundedCornerShape(12.dp))
        .background(MaterialTheme.colorScheme.surfaceVariant)
        .padding(12.dp),
    verticalArrangement = Arrangement.spacedBy(8.dp),
) {
    Text("Tonight's reading")
    Text("One chapter, then a break.")
}
```

Read inward: caller's modifiers → 24dp outside → use the remaining width → rounded clipping → painted background → 12dp inside → child content.

`RoundedCornerShape(12.dp)` describes the shape; `.clip(...)` clips subsequent drawing to it. Putting `clip` **before** a rectangular `background` rounds that background too. Putting it after the background would leave that earlier background's corners uncut. There is no separate `margin` modifier here; padding outside the painted area provides the visible outer gap.

**Expected result:** a full-available-width card with clear outer space and inset text. Changing `Arrangement.spacedBy` changes gaps **between children**, while padding changes space around the whole group.

A related form already in `DateTile` is:

```kotlin
Modifier
    .size(56.dp)
    .background(MaterialTheme.colorScheme.primaryContainer, RoundedCornerShape(12.dp))
```

`.size(56.dp)` requests both width and height, subject to parent constraints. Passing a shape directly to `background` paints that shape; it does **not** clip later child drawing. This is sufficient for the starter's tile with text inside it. Use `clip` when subsequent drawing, such as a ripple, must also be clipped.

**Optional deeper reading:** [Compose modifiers](https://developer.android.com/develop/ui/compose/modifiers) covers ordering and constraints.

### 4. Layer a badge with Box

`Box` places children in overlapping layers; later children draw in front. This example adds a “TIP” badge to a small book tile:

```kotlin
Box {
    Text(
        "Book",
        modifier = Modifier
            .size(64.dp)
            .background(MaterialTheme.colorScheme.primaryContainer),
    )
    Text(
        "TIP",
        style = MaterialTheme.typography.labelSmall,
        color = MaterialTheme.colorScheme.onError,
        modifier = Modifier
            .align(Alignment.BottomEnd)
            .offset(x = 4.dp, y = 4.dp)
            .background(MaterialTheme.colorScheme.error, CircleShape)
            .border(2.dp, MaterialTheme.colorScheme.surfaceVariant, CircleShape)
            .padding(horizontal = 6.dp, vertical = 2.dp),
    )
}
```

- In this example the 64dp tile is larger than the badge and establishes the box's size. In general, ordinary `Box` children participate in its sizing; don't assume the first child always determines it.
- `.align(Alignment.BottomEnd)` is a `BoxScope` modifier applied to the badge, a direct child. It aligns that child to the bottom-end corner. In a left-to-right layout, end means right. `Alignment.TopEnd` selects the upper corner instead.
- `.offset(...)` shifts the child's placement **without reserving extra layout space**. Positive `y` moves down; negative `y` moves up. Positive `x` moves toward the layout's end (right in left-to-right layouts).
- Kotlin writes a negative dp value as `(-4).dp`. The parentheses apply `.dp` to the negative number.
- `CircleShape` uses fully rounded corners; on a wide text badge this makes a pill. `.border(...)` draws the 2dp outline. Padding inside the background gives the word breathing room.
- `error` is a built-in accent color, and `onError` is its matching foreground color. The role names are just a convenient palette here; the badge isn't reporting an error.

**Expected result:** a small pill at the tile's bottom-end, shifted 4dp outward. The box doesn't grow to reserve room for the offset. Don't clip the whole box if the badge should stick out.

Your existing `DateTile` uses a `Column` to center “14” above “OCT.” Keep that inner tile; put a `Box` around it and make the new badge its sibling. Move the supplied `modifier` to that new root `Box`, and start the inner tile's chain with `Modifier`.

**Optional deeper reading:** [BoxScope](https://developer.android.com/reference/kotlin/androidx/compose/foundation/layout/BoxScope) and [offset](https://developer.android.com/develop/ui/compose/modifiers#offset).

### 5. Style text and place clickable before its padding

Compose text gets its appearance through arguments:

```kotlin
Text("Evening reading", style = MaterialTheme.typography.titleMedium)
Text(
    "Chapter 3 · 15 minutes",
    style = MaterialTheme.typography.bodyMedium,
    color = MaterialTheme.colorScheme.onSurfaceVariant,
)
Text(
    "A longer description of the chapter and what to look for as you read.",
    maxLines = 2,
    overflow = TextOverflow.Ellipsis,
)
```

`style` selects a text style; `color` sets the foreground. Built-in typography uses scalable text sizing. If specifying raw text sizes yourself, Compose uses `sp` for text rather than `dp`, but you don't need raw sizes today. The existing date tile additionally uses `fontWeight = FontWeight.Bold` to emphasize its number.

`maxLines = 2` sets a maximum, not a fixed two-line height. `TextOverflow.Ellipsis` displays “…” when text overflows the allowed space; without it, the default overflow mode clips instead.

For an interactive-looking label:

```kotlin
Text(
    "Open",
    color = MaterialTheme.colorScheme.onPrimary,
    style = MaterialTheme.typography.labelLarge,
    modifier = Modifier
        .clip(CircleShape)
        .background(MaterialTheme.colorScheme.primary)
        .clickable { }
        .padding(horizontal = 12.dp, vertical = 6.dp),
)
```

The background and matching `onPrimary` text color form a readable pair in the built-in palette. `clickable { }` installs click handling with an empty callback: it shows the default pressed/ripple feedback in this themed app but performs no app action. No state or RSVP logic is needed today.

These modifier fragments show why order matters:

```kotlin
// The clickable layout and bounded ripple include the padding.
Modifier.clickable { }.padding(16.dp)

// The clickable layout and bounded ripple are inside the padding.
Modifier.padding(16.dp).clickable { }
```

In the pill example, clipping comes before the background and clickable indication, keeping their drawing within the pill. Place `clickable` before padding so its layout bounds include the padded label.

**Touch caveat:** Compose can expand small touch targets beyond their visual/layout bounds to meet the minimum touch target size, normally 48dp. Therefore, “outside the ripple” doesn't always mean “untappable.” Judge this lesson's order by the described bounds and visible ripple, not by trying to find an exact tap boundary. A production control also needs accessibility and action semantics; this small exercise isolates modifier behavior.

**Expected result:** a white “Open” label on a colored pill, with feedback across the padded pill when pressed in the emulator. It won't navigate anywhere.

**Optional deeper reading:** [Text](https://developer.android.com/develop/ui/compose/text) and [minimum touch targets](https://developer.android.com/develop/ui/compose/accessibility/api-defaults#minimum-touch-target-sizes).

### Coming from React Native

| React Native | Jetpack Compose | Watch out |
|---|---|---|
| Component returning JSX | `@Composable fun ...` | UI is contributed by composable calls; no JSX return value. |
| Column/row `View` containers | `Column` / `Row` | Arrangement is main-axis; alignment is cross-axis. |
| Flexible content or spacer | `Modifier.weight(1f)` | Use it on the content that should receive remaining space. |
| Passing a `style` prop | Accepting a `modifier` | Apply the caller's modifier to the root once. |
| Padding/background styles | Ordered modifier chain | Earlier modifiers surround later ones. |
| Absolutely positioned badge | `Box` plus child `align` | `offset` doesn't reserve extra layout space. |
| `numberOfLines={2}` | `maxLines = 2`, `overflow = TextOverflow.Ellipsis` | Choose the overflow behavior explicitly. |
| `Pressable` | `Modifier.clickable { }` | Position controls the clickable layout/ripple bounds. |
| Storybook story | `@Preview` function | Use the running app to test touch behavior. |

## Exercises

All edits are in **`app/src/main/java/com/example/lessons/l02eventcard/MainActivity.kt`**, at the `TODO (Ex N)` markers. Keep the supplied content and implement the changes yourself. Imports needed for the core exercises are already present.

### 1. Arrange the event card

- **Builds on:** [step 1](#1-a-composable-is-a-function-that-describes-ui) and [step 2](#2-arrange-children-and-allocate-the-remaining-space).
- **Edit:** `TODO (Ex 1)` in `EventCard`.
- **Your task:** keep an outer `Column`. Put `DateTile()`, a title/details column, and `RsvpButton()` in one header `Row`; leave the description below that row. Give the title/details column `weight(1f)`. Use 12dp gaps between the row's children and between the header and description; vertically center the row's children.
- **Expected result:** date on the left, title over details in the middle, RSVP on the right, description underneath. Long title text gets the middle column's width rather than pushing RSVP away at normal phone widths.

<details>
<summary>Hint</summary>

Adapt the second reading-row example, where the middle column has weight. Don't add a weighted spacer too. Keep the caller's `modifier` on the outer `Column`.

</details>

### 2. Add the card's modifier chain

- **Builds on:** [step 3](#3-read-modifier-chains-from-the-outside-inward).
- **Edit:** `TODO (Ex 2)` on `EventCard`'s outer `Column`.
- **Your task:** use 20dp of outer space, fill the remaining width, clip to 16dp rounded corners, paint `MaterialTheme.colorScheme.surfaceVariant`, and use 16dp of inner space. Extend the supplied `modifier` rather than replacing it with a new empty chain.
- **Expected result:** a tinted card with rounded corners, inset content, and clear space outside. The screen's supplied safe-area padding stays respected.

<details>
<summary>Hint</summary>

Use the nesting order from the reading-card example with different values. Outer padding comes before the background; inner padding comes after. The supplied `LessonScreen` wrapper already handles system-bar spacing and lets the card wrap its height, so leave that setup intact.

</details>

### 3. Add the NEW badge

- **Builds on:** [step 4](#4-layer-a-badge-with-box).
- **Edit:** `TODO (Ex 3)` in `DateTile`.
- **Your task:** wrap the existing tile in a `Box`, putting the incoming `modifier` on that root. Add a sibling “NEW” text badge aligned `TopEnd`, shifted with `x = 6.dp` and `y = (-6).dp`. Use `labelSmall`, `onError` text on an `error` pill, a 2dp `surfaceVariant` border, and padding of 6dp horizontally and 2dp vertically.
- **Expected result:** the badge overlaps the tile's top-end corner without creating a separate row or moving the other header elements.

<details>
<summary>Hint</summary>

Keep the inner date `Column`'s existing size/background/centering, but start its chain with `Modifier` after moving the caller's `modifier` to the `Box`. Apply `align` to the badge inside `Box` content, not inside the date column.

</details>

### 4. Style text and the RSVP pill

- **Builds on:** [step 5](#5-style-text-and-place-clickable-before-its-padding).
- **Edit:** `TODO (Ex 4)` in both `EventCard` and `RsvpButton`.
- **Your task:** use `titleMedium` for the title, `bodyMedium` and `onSurfaceVariant` for the details, and at most two description lines with ellipsis. Make RSVP a pill with `primary` background, `onPrimary` text, `labelLarge`, and 16dp horizontal/8dp vertical padding. Include an empty click callback before the padding and clip its drawing to `CircleShape`. Preserve `RsvpButton`'s incoming modifier.
- **Expected result:** clear text hierarchy, a capped description, and press feedback across the padded RSVP pill in the emulator. No RSVP state change is expected.

<details>
<summary>Hint</summary>

Adapt the “Open” label example. `Text` takes both `style` and `color` arguments; the modifier chain handles its background, clipping, padding, and interaction. You don't need to move `clickable` around experimentally—the walkthrough already explains the result.

</details>

## Done when

Approximate layout, not a pixel-perfect target:

```text
┌──────────────────────────────────────────┐
│ ┌────┐NEW                                │
│ │ 14 │  Design meetup            (RSVP)  │
│ │OCT │  Thu 18:30 · Community hall       │
│ └────┘                                   │
│ An evening of short talks about building │
│ small, friendly apps, followed by sna…   │
└──────────────────────────────────────────┘
```

- [ ] The card uses 20dp outer padding, rounded 16dp corners, and 16dp inner padding.
- [ ] The date, weighted title/details column, and RSVP share one row; the description is below it.
- [ ] The “NEW” badge sits at the tile's top-end corner with its small outward offset.
- [ ] The description uses at most two lines and shows “…” if it overflows the available width.
- [ ] RSVP's ripple covers its padded pill. Tapping it does not need to perform an action.

`./verify.sh` checks compilation, not these visual requirements. Use the emulator or preview for layout checks and the emulator for touch feedback.

## Check your understanding

1. Why does `.padding(20.dp).background(color)` leave unpainted space, while `.background(color).padding(20.dp)` paints the padded area?
2. Why put `weight(1f)` on the title column rather than only on a spacer after a long title?
3. Why move the incoming `modifier` to the `Box` when wrapping `DateTile`, instead of applying it to both the box and the inner column?

<details>
<summary>Check your answers</summary>

1. Earlier modifiers surround later ones. In the first chain, padding is outside the background; in the second, the background surrounds the padding.
2. A row measures unweighted children first. Weighting the title column lets the row reserve space for the date and RSVP, then allocate the remainder to text. A weighted spacer alone can't protect against an unweighted title consuming that room.
3. The caller's modifier should describe the composable's outer/root layout once. Reusing it on the inner column could duplicate effects such as padding and give the parent unexpected control over internal details.

</details>

## Stretch (optional)

- Change the existing preview to `@Preview(showBackground = true, widthDp = 280)` and try longer text. Explore limits at narrow widths; handling every screen and text size isn't required today.
- Add `.border(1.dp, Color.Red)` at different positions in the card's modifier chain to see the bounds there. This optional experiment needs `import androidx.compose.ui.graphics.Color`.
- Change the tile's `.size(56.dp)` to `.width(56.dp)`. Width is now fixed while height can wrap its content. Compare that predicted result with the preview.

## Docs

Optional rabbit holes—no required reading to finish this lesson:

- [Compose layout basics](https://developer.android.com/develop/ui/compose/layouts/basics): more layout patterns and measurement context.
- [Compose modifiers](https://developer.android.com/develop/ui/compose/modifiers): ordering, scope safety, size, and offset examples.
- [Thinking in Compose](https://developer.android.com/develop/ui/compose/mental-model): the mental model behind recomposition.
- [Composable previews](https://developer.android.com/develop/ui/compose/tooling/previews): preview parameters and tools.
- [Text and typography](https://developer.android.com/develop/ui/compose/text): more styling and overflow options.
- [Accessibility defaults](https://developer.android.com/develop/ui/compose/accessibility/api-defaults): touch-target sizing and behavior beyond visual bounds.
- [Kotlin basic syntax](https://kotlinlang.org/docs/basic-syntax.html): more language context when you want it.

## After the lesson

The full reference is in `Solutions/app/src/main/java/com/example/lessons/l02eventcard/MainActivity.kt`. Compare it after trying; it is not compiled into the running starter app. `verify.sh` overlays it only in a temporary copy.

When you're satisfied with the checks, record completion from this lesson folder:

```sh
../../scripts/log-lesson.sh status 02 completed "optional note: what clicked / what didn't"
```
