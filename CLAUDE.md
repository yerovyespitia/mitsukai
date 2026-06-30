# Project Coding Guidelines

These guidelines apply to all contributors and coding agents working in this repository.

## Code Readability

- Keep code simple, explicit, and easy to scan.
- Prefer clear names over clever abbreviations.
- Prefer readable control flow over compact cleverness.
- Avoid deeply nested control flow; use `guard`, early returns, and small helper methods when they improve clarity.
- Write comments only when they explain intent, constraints, tradeoffs, or non-obvious decisions.

## File Size

- Keep source files small and focused.
- As a readability target, source files should usually stay between 300 and 400 lines at most.
- If a file grows beyond this range, split it by responsibility before adding more behavior.
- Avoid large root files such as `ContentView.swift`; root views should mainly coordinate navigation and layout.

## File Responsibility

- Each file should have one primary responsibility.
- Avoid placing unrelated functions, models, views, helpers, or services in the same file.
- Multiple private helpers are acceptable when they directly support the file's single responsibility.
- Move supporting logic into dedicated files instead of hiding multiple behaviors in one large file.
- Separate reusable logic from feature-specific code when it is used in more than one place.

## Swift Style

- Prefer `struct` over `class` unless identity, inheritance, or reference semantics are required.
- Prefer immutable values with `let` unless mutation is truly needed.
- Use `private` and `fileprivate` deliberately to keep implementation details contained.
- Avoid force unwraps (`!`) except in tests or cases that are impossible by construction and documented.
- Avoid `try?` when losing the error would make debugging harder.
- Keep computed properties lightweight; move expensive work into explicit methods or services.
- Use meaningful type names that describe domain intent instead of implementation details.

## SwiftUI

- Keep SwiftUI views small, composable, and focused on presentation.
- Avoid putting business rules directly inside `View` bodies.
- Extract complex view sections into dedicated view files.
- Keep side effects out of `body`; trigger work from explicit actions or lifecycle hooks.
- Use `@State`, `@Binding`, `@Observable`, `@Environment`, and related property wrappers only where ownership is clear.
- Keep reusable domain logic outside SwiftUI views so it can be tested without rendering UI.

## Design

- Preserve Orzen's dark, cinematic macOS style: black base surfaces, white text, subtle translucent layers, and artwork-led screens.
- Use `OrzenLayout` for shared measurements. Keep the sidebar at `230` points by default, content horizontal insets at `24`, and the home banner height at `500`.
- Compose the root shell with `NavigationSplitView`, a `.sidebar` styled `List`, and plain sidebar row buttons. Sidebar rows use SF Symbols, 10-point icon/text spacing, 8-point horizontal padding, 10-point vertical padding, and an 8-point rounded white selection fill at `0.1` opacity.
- Keep primary content on black backgrounds with `Color.black.ignoresSafeArea()`. Use horizontal scrolling shelves for home sections and adaptive grids for catalog screens.
- Section headings use bold white headline text with leading/trailing content insets. Horizontal shelf cards use 14-point item spacing, 2-point vertical shelf padding, and 22-point bottom section padding.
- Reuse existing card components before creating new ones. Poster cards keep a 2:3 aspect ratio, 8-point continuous corner radius, a white border at `0.08` opacity, and reveal title metadata on hover over a black `0.4` overlay.
- Watching/backdrop cards use 252 by 142 sizing, 8-point continuous corners, a bottom black gradient, 12-point internal padding, a 6-point capsule progress bar, and a slight hover scale of about `1.015`.
- Use subtle hover feedback instead of loud color shifts. Common hover fills move from white `0.08` opacity to about `0.16`, strokes from about `0.06` to `0.14`, and animations should stay near `easeInOut` with `0.12` to `0.2` seconds.
- Buttons should usually be `.buttonStyle(.plain)` with SF Symbol icons, `.help(...)`, and accessibility labels. Circular icon buttons use 32 to 34 point frames for regular actions, 28 point frames for compact player controls, 54/76 point frames for center transport controls, and `Circle()` hit targets.
- Selected filter pills use a white capsule background with dark text. Unselected filters use translucent white capsule fills, 14 to 16 point horizontal padding, 7 to 8 point vertical padding, and a subtle white stroke.
- For macOS 26 and newer, prefer `GlassEffectContainer` and `.glassEffect(.regular.interactive(), in: Circle())` or capsule glass where the existing UI already does this. Always provide a non-glass fallback that matches the same opacity, radius, and spacing.
- Feature rows and settings panels use restrained translucent containers: white fills around `0.06` to `0.08`, 18-point rounded rectangles for larger rows/panels, 20 to 24 point padding, and secondary text at white opacity around `0.58` to `0.7`.
- Detail hero views should stay artwork-forward: large poster at 220 by 320 with 16-point corners, 32-point spacing to text, 40-point bold title, white metadata pills, and top padding around `116` when over backdrop art.
- Player chrome overlays use full-screen gradients rather than boxed panels. Keep 24-point horizontal padding, 22-point top padding, 18-point bottom padding, white controls, compact monospaced time labels, and hover-revealed circular transport controls.
- Prefer established symbols and components (`FilterButton`, `SourceFilterPicker`, `PlayerIconButton`, `CatalogPosterCard`, `CatalogSectionView`, addon action buttons) over one-off visual treatments.
- Avoid introducing bright brand colors, heavy borders, nested cards, large rounded marketing sections, or decorative gradients that compete with poster/backdrop artwork.

## Architecture

- Separate UI, business rules, data access, formatting, and platform integration into different files.
- Use responsibility-based folders such as `Views`, `Components`, `Models`, `Services`, `State`, and `Extensions` when the project grows.
- Keep view files focused on presentation and interaction.
- Keep models focused on domain data and behavior.
- Keep services focused on external systems, persistence, platform APIs, or other side effects.
- Prefer dependency injection over hardcoded global access when logic needs to be testable.
- Keep platform-specific code isolated when possible.

## Reuse

- Reuse existing logic before adding new implementations.
- Do not duplicate logic across files; extract shared behavior into a clearly named helper, service, model, component, or extension.
- When similar code appears in multiple places, consolidate it into a shared unit.
- Prefer small reusable units over large generic abstractions.
- Add abstractions only when they reduce real duplication or make the code easier to understand.

## Error Handling

- Prefer clear, intentional error handling over silent failure.
- Do not ignore thrown errors unless there is a documented reason.
- Surface recoverable errors to the UI in a user-friendly way.
- Make sure new logic handles edge cases deliberately rather than accidentally.

## Concurrency

- Use `async`/`await` for asynchronous work.
- Mark UI-facing updates with `@MainActor` when needed.
- Avoid unstructured `Task {}` blocks unless lifecycle and cancellation are considered.
- Handle cancellation for long-running work where appropriate.

## Performance

- Avoid expensive work in SwiftUI `body`.
- Avoid unnecessary recomputation in frequently rendered views.
- Reuse expensive formatters or resources where appropriate.
- Keep animations intentional and lightweight.
- Watch for large state objects causing too many view updates.

## Testing

- Add tests for domain logic, formatting, parsing, persistence, and state transitions when a test target exists.
- Keep business rules outside SwiftUI views so they can be tested directly.
- Test edge cases, not only happy paths.
- When fixing a bug, add a regression test if practical.
- Validate behavior with the most relevant build or test command available.

## Project Hygiene

- Keep changes scoped to the requested behavior.
- Avoid unrelated refactors while implementing a feature or fix.
- Preserve existing project conventions unless there is a clear reason to improve them.
- When adding new files, place them where their responsibility naturally belongs.
- Keep build settings, entitlements, and project configuration changes intentional and minimal.
- Avoid adding dependencies unless they remove meaningful complexity.
- Prefer Apple frameworks and standard Swift features before third-party packages.
- Keep generated files, local IDE files, and secrets out of git.
- Document non-obvious project setup in `README.md`.
