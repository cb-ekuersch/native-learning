# Curriculum (guideline, not a contract)

Concept-first, design-system-neutral. Each item = one 30–60 min lesson with a single goal.
Pick the earliest item on the chosen track whose prerequisites are **completed** in LESSONS.md.
Default: alternate tracks day to day (SwiftUI, Compose, SwiftUI, …). Cross-platform comparisons are allowed
only for concepts already completed on the other track. Adjust order or add items when a lesson
reveals a gap (record why in LESSONS.md Notes). Lesson numbers below link to shared materials; they do not
indicate that the current learner has completed them. Keep personal sequencing requests in LESSONS.md.

## Typography lessons (S1a / C1a)

Custom fonts and reusable text APIs can follow each track's introductory lesson, before language essentials.
Keep each lesson within 30–60 minutes.
Teach the small amount of extension/function/parameter syntax needed inline; do not assume S2/C2 or S3/C3.
Focus on reusable text styling and custom parameters, rather than subclassing or changing built-in APIs.
Include accessibility-aware font scaling in both lessons; broader accessibility remains in S15/C15.

## SwiftUI track (S)
| ID | Concept | Prereqs | Lesson |
|---|---|---|---|
| S1 | Views, `body`, stacks (`VStack`/`HStack`/`ZStack`/`Spacer`), modifiers & their order, `#Preview` | — | 01 |
| S1a | Custom fonts & reusable text APIs: bundle/register font files, font names and weights, `Font.custom` with Dynamic Type, `Text` extensions (`Text` vs `some View` returns), a small wrapper view with custom parameters | S1 | |
| S2 | Swift essentials for UI: structs vs classes, enums w/ associated values, optionals, closures, trailing-closure syntax | S1 | |
| S3 | Composing views: extracting subviews, init params as props, `@ViewBuilder` content (children) | S1, S2 | |
| S4 | Local state: `@State`, re-rendering model, `@Binding` (lifting state up) | S3 | |
| S5 | Lists & identity: `ForEach`, `List`, `Identifiable`, stable IDs (vs RN `key`) | S4 | |
| S6 | Shared/observable state: `@Observable`, `@Bindable`, ownership vs injection | S4 | |
| S7 | Environment: reading built-in values, custom `@Entry` keys, `.environment` (vs React context) | S6 | |
| S8 | Navigation: `NavigationStack`, `navigationDestination`, value-based paths, sheets | S5 | |
| S9 | Layout in depth: frames, alignment, `GeometryReader`, `Layout` protocol, safe areas | S3 | |
| S10 | Async work: `.task`, async/await, loading/error states, cancellation | S6 | |
| S11 | Forms & input: `TextField`, `Toggle`, focus (`@FocusState`), keyboard | S4 | |
| S12 | Animation: implicit vs explicit (`withAnimation`), transitions, `matchedGeometryEffect` | S4 | |
| S13 | Gestures: tap/drag/long-press, gesture state, composing gestures | S12 | |
| S14 | Reusable styling: custom `ViewModifier`s, `ButtonStyle`, style protocols | S7 | |
| S15 | Accessibility: labels, traits, Dynamic Type, VoiceOver testing | S3 | |
| S16 | Testing & previews: preview variants, unit-testing view models, UI tests / snapshot basics | S6 | |
| S17 | Interop: hosting UIKit in SwiftUI (`UIViewRepresentable`) and vice versa | S9 | |

## Jetpack Compose track (C)
| ID | Concept | Prereqs | Lesson |
|---|---|---|---|
| C1 | Composables, `Column`/`Row`/`Box`, `Modifier` chains & order, `@Preview` | — | 02 |
| C1a | Custom fonts & reusable text APIs: `res/font`, `FontFamily` and weight mapping, `TextStyle`/`copy`, font scaling with `sp`, a wrapper composable with custom parameters and forwarded `Modifier`/text options | C1 | |
| C2 | Kotlin essentials for UI: data classes, sealed classes, null safety, lambdas, trailing lambdas | C1 | |
| C3 | Composing UI: parameters as props, slot APIs (`content: @Composable () -> Unit`) | C1, C2 | |
| C4 | State & recomposition: `remember`, `mutableStateOf`, state hoisting | C3 | |
| C5 | Lists & identity: `LazyColumn`, `items(key=)`, stable keys | C4 | |
| C6 | ViewModel & state holders: `ViewModel`, `StateFlow`, `collectAsStateWithLifecycle` | C4 | |
| C7 | CompositionLocals: built-ins, custom locals (vs React context) | C6 | |
| C8 | Navigation: Navigation Compose, type-safe routes, back stack | C5 | |
| C9 | Layout in depth: intrinsic sizes, `weight`, `BoxWithConstraints`, custom `Layout` | C3 | |
| C10 | Side effects: `LaunchedEffect`, `rememberCoroutineScope`, `DisposableEffect` (vs `useEffect`) | C6 | |
| C11 | Text input & forms: `TextField` state, focus, IME actions | C4 | |
| C12 | Animation: `animate*AsState`, `AnimatedVisibility`, `updateTransition` | C4 | |
| C13 | Gestures: `pointerInput`, `draggable`, `detectDragGestures` | C12 | |
| C14 | Theming & reusable styling: `MaterialTheme`, custom theme objects, component defaults | C7 | |
| C15 | Accessibility: semantics, content descriptions, font scale, TalkBack | C3 | |
| C16 | Testing: Compose UI tests (`createComposeRule`), preview variants, screenshot basics | C6 | |
| C17 | Interop: `AndroidView` and `ComposeView` | C9 | |
