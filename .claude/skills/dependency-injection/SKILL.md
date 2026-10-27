---
name: dependency-injection
description: Use when creating or consuming services, API clients, stores, or managers, wiring a screen model's dependencies, or writing tests/previews that need mocks — dependencies are injected with the Factory library (hmlongco/Factory), never constructed inline or reached as globals.
---

# Dependency Injection with Factory

All shared dependencies — API/service clients, stores, managers — are registered in and resolved through [Factory](https://github.com/hmlongco/Factory) (SPM: `https://github.com/hmlongco/Factory`; `import FactoryKit` in Factory 3+, `import Factory` in older setups — match what the project already imports). Screen models consume registered dependencies; they never construct clients, stores, or services themselves, and nothing is reached through ad-hoc `.shared` globals.

Full code examples: [reference.md](reference.md).

This layers on the `architecture` skill: injection lives in **ScreenModels, stores, and managers** — never in a dumb View, and Screens only in rare app-wiring cases.

## One registration surface

Every registration lives in a single file: `Core/Dependencies/Container+Dependencies.swift`, as computed properties on `Container`. No feature-local registrations — a new shared dependency is added here and treated as a cross-cutting change.

→ [reference.md §1](reference.md#1-registrations-in-coredependenciescontainerdependenciesswift)

Registration rules:

- **`@MainActor` on the factory property**, `MainActor.assumeIsolated` in the body — dependencies are main-actor objects consumed by `@MainActor` screen models.
- **Factories compose through the container**: a store that needs the client calls `self.apiClient()` inside its own registration — the dependency graph lives in this one file.
- **Protocols only where substitution is real.** Stores that have mock/live implementations register as `Factory<any SomeStore>`. Managers and clients with a single implementation register concretely — don't invent a protocol just to satisfy a DI aesthetic.
- **Mock vs live is decided at the registration boundary**, behind a single runtime switch (`AppDataSource.usesMocks`) wrapped in `#if DEBUG` so mocks can't ship. Feature code never checks "am I mocked."
- **Scopes:** `.singleton` for one process-wide owner (the normal case for clients/stores/managers); `.cached` persists until reset; `.unique` (default) builds fresh every resolve; `.shared` weak-holds. Choose deliberately — `.singleton` only where one owner is intentional.

## Consuming — `@Injected` in screen models

→ [reference.md §2](reference.md#2-consuming-in-a-screen-model)

- **`@ObservationIgnored` is mandatory** on injected properties inside an `@Observable` class — dependencies are not observable state.
- Injection belongs in screen models, stores, managers, and other infrastructure owners. **Never in a dumb View**; a View gets values and callbacks per the `architecture` skill.
- Use the exact key path from `Container+Dependencies.swift` — read it before naming one.

### `@Injected` vs `@DynamicInjected`

- **`@Injected`** resolves **once, when the owner is created**. Right for short-lived owners (a screen's screen model resolves fresh on each screen visit) and for true process-lifetime infrastructure.
- **`@DynamicInjected`** resolves **on every access**. Required for **objects that outlive a scope reset** — the app root, long-lived contexts/sessions — because a plain `@Injected` there would keep handing back an instance the container has already dropped.

## Scope reset — e.g. sign-out

User-scoped stores hold one user's data. On sign-out, drop the cached instances without touching registrations:

→ [reference.md §3](reference.md#3-scope-reset-on-sign-out)

`reset(.scope)` clears the cached instance and leaves the registration (and any test override) alone. This only works end-to-end because long-lived owners hold these stores with `@DynamicInjected` — the next access resolves a fresh store for the next user.

## Tests and previews

Override the same registration the production code reads; always reset so state can't leak into neighboring tests:

→ [reference.md §4](reference.md#4-test-or-preview-override) — `.register { }` then `defer { Container.shared.reset() }`.

Keep overrides local to the test or the focused `#Preview` host. Never mutate registrations from production feature code.

## Rules recap

1. All registrations in `Core/Dependencies/Container+Dependencies.swift`; none feature-local.
2. Screen models consume via `@ObservationIgnored @Injected(\.key)` — they never construct clients, stores, or services, and never touch `.shared` globals.
3. Dumb Views are injection-free.
4. Protocol registrations (`any SomeStore`) only where a mock/live substitution exists; concrete otherwise.
5. Mock/live selection happens at the registration boundary behind one `#if DEBUG` switch.
6. `.singleton` only for intentional process-wide owners; user-scoped stores get a `reset(.scope)` teardown on sign-out.
7. Objects that outlive a scope reset hold their dependencies with `@DynamicInjected`; everything else uses `@Injected`.
8. Test/preview overrides use `.register { }` + `defer { reset() }`, scoped to the test.
