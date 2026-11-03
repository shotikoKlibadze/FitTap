---
name: code-style
description: Use when writing or organizing any Swift code — file organization and style rules (one type per file) and documentation comments (DocC `///`, what to document and how plainly).
paths:
  - "FitTap/**/*.swift"
  - "Packages/**/*.swift"
---

# Code Style

## One type per file

- Every type (struct, enum, class, protocol) gets its own file, named after the type: `MuscleGroup.swift` holds `MuscleGroup` and nothing else.
- Tightly coupled types may share a file only when one is meaningless without the other (a type and its private helper, a protocol and its single trivial default extension). When in doubt, split.
- Extensions of a type live in the type's file; cross-cutting extensions (e.g. `Container+Dependencies`) get a `Type+Purpose.swift` file.
- `#if DEBUG` sample fixtures live in the file of the type they sample.

## Documentation comments

Agents write most of the code, so the human owner learns how it works by reading it. DocC (`///`) comments carry that understanding. Write them for a smart developer who didn't write the code and has to change it safely.

**What gets a comment:**
- **Every non-trivial type:** what it is, what it's responsible for, why it exists, and what it must *not* do ("the only type that touches SwiftData; injected into stores only").
- **Complex functions:** business rules, anything with side effects, order that matters, state transitions, translation or diffing, anything that would surprise a reader.
- **Not the obvious ones.** A getter, a one-line forward, a `didTap…` that only sets a destination, or a name that already says it all gets nothing. Never restate the name or narrate the code line by line.

**How it reads: about 70% plain English, 30% technical.**
- Explain the rule as a person would, ideally with a concrete example, then name the technical consequence.
- First line: one summary sentence. Then discussion paragraphs.
- Use `- Parameters:`, `- Returns:` and `- Throws:` only when they add information.
- Use `> Important:` for traps (things that silently break if done differently).

```swift
/// Freezes a session so its history can never change.
///
/// Until it starts, a planned session follows its workout: plan Push Day on
/// Monday, edit Push Day on Wednesday, and Friday shows the edit. Starting
/// takes a copy of the workout as it is right now and stores it in the
/// session, so later edits to Push Day, or deleting it, never touch what was
/// logged.
///
/// > Important: The copy's exercises and sets get fresh ids; only the
/// > workout's own id stays, so stats can still group sessions by workout.
func startSession(id: UUID) throws { … }
```

**Keep them true.** When logic changes, its comment changes in the same edit. A wrong comment is worse than none.

## Rules recap

1. One type per file, file named after the type.
2. Sharing a file is the exception and needs the "meaningless apart" test.
3. Extensions: same file as the type, or `Type+Purpose.swift`.
4. DocC on every non-trivial type and every complex function (rules, side effects, order, transitions); never on the obvious. About 70% plain English with a concrete example, 30% technical; `> Important:` for traps; updated in the same edit as the logic.
