---
name: code-style
description: Use when writing or organizing any Swift code — file organization and style rules, starting with one type per file.
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

## Rules recap

1. One type per file, file named after the type.
2. Sharing a file is the exception and needs the "meaningless apart" test.
3. Extensions: same file as the type, or `Type+Purpose.swift`.
