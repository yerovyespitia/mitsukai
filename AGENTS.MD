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
