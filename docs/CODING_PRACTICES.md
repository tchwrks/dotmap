# Dotmap — Coding Practices
**Version:** 0.2  
**Scope:** All code in the Dotmap repository

---

## Guiding Principle

Dotmap is a free, open-source tool that people will trust with their shell environment. The code should reflect that trust. It should be readable by a contributor who has never seen the repo before, debuggable at 2am when something breaks, and extensible without requiring a rewrite. Cleverness is not a virtue here. Clarity is.

---

## Repository Structure

Dotmap is a single Xcode project. No monorepo tooling, no separate frontend/backend packages.

```
dotmap/
├── Dotmap.xcodeproj/
├── Dotmap/
│   ├── App/
│   │   ├── DotmapApp.swift          # @main entry point
│   │   └── AppState.swift           # Top-level observable state
│   ├── Parser/
│   │   ├── ConfigParser.swift       # Core parser — most critical file
│   │   ├── ConfigEntry.swift        # ConfigEntry enum and associated types
│   │   ├── BlockDetector.swift      # Tool-managed block detection
│   │   └── SourceResolver.swift     # Resolves source directives recursively
│   ├── Watcher/
│   │   └── ConfigWatcher.swift      # FSEvents file watching
│   ├── Shell/
│   │   └── ShellEnvironment.swift   # Process spawning for live env evaluation
│   ├── Health/
│   │   └── HealthChecker.swift      # Health check analysis
│   ├── Models/
│   │   ├── Alias.swift
│   │   ├── EnvVar.swift
│   │   ├── PathEntry.swift
│   │   ├── ShellFunction.swift
│   │   └── ConfigFile.swift
│   ├── Views/
│   │   ├── Home/
│   │   ├── Environment/
│   │   │   ├── AliasesView.swift
│   │   │   ├── VariablesView.swift
│   │   │   ├── PathsView.swift
│   │   │   └── FunctionsView.swift
│   │   ├── Config/
│   │   │   ├── ConfigView.swift
│   │   │   ├── BlockView.swift
│   │   │   └── EditorView.swift
│   │   ├── Health/
│   │   ├── Search/
│   │   ├── Settings/
│   │   └── Shared/
│   │       ├── Sidebar.swift
│   │       ├── DetailPanel.swift
│   │       └── Components/
│   ├── Storage/
│   │   └── AppStorage.swift         # Local JSON persistence in Application Support
│   └── Resources/
│       └── Assets.xcassets
├── DotmapTests/
│   ├── ParserTests.swift
│   ├── HealthCheckerTests.swift
│   └── Fixtures/                    # Real-world .zshrc sample files for tests
└── README.md
```

**Rules:**
- One type per file. The file name matches the primary type it defines.
- The `Parser/` group is the most critical and most tested code. Treat it like library code — pure functions, no side effects, comprehensive tests.
- Views are organized by feature, not by type. `AliasesView` lives in `Views/Environment/`, not in a flat `Views/` dump.
- No deeply nested group hierarchies. If a group has more than ~8 files, consider splitting into sub-groups. If it has fewer than 3, it probably doesn't need its own group.

---

## Swift — General

- Use Swift 6 with Swift concurrency (`async/await`, `@MainActor`, `Sendable`) throughout. No completion handler callbacks or NotificationCenter for async coordination.
- All public types and functions must have documentation comments (`///`). Private members should have doc comments if their purpose isn't immediately obvious.
- Prefer explicitness over brevity. A slightly longer variable name that reads like English is better than a short name that requires context.
- Use `guard` for early returns rather than deeply nested `if` statements.
- No force unwraps (`!`) in production code paths. No `try!`. Use `guard let`, `if let`, or `do/catch` instead.

```swift
// ✅ correct
guard let contents = try? String(contentsOf: url, encoding: .utf8) else {
    return []
}

// ❌ wrong — will crash on any config file with unexpected encoding
let contents = try! String(contentsOf: url, encoding: .utf8)
```

---

## The Parser

The parser is the heart of Dotmap. It gets special treatment.

**Pure functions only.** Parser functions take input (`String` file content or a file `URL`) and return output. No global state, no side effects, no I/O inside parser functions except the initial file read.

**The parser must never throw or crash on a valid shell file.** If a construct is unrecognized, return `.unmanaged(raw: line)`. Never silently drop content.

```swift
enum ConfigEntry {
    case alias(name: String, expansion: String, sourceLine: Int)
    case envVar(key: String, value: String, sourceLine: Int)
    case pathEntry(path: String, sourceLine: Int)
    case function(name: String, body: String, sourceLineStart: Int, sourceLineEnd: Int)
    case source(path: String, sourceLine: Int)
    case toolBlock(tool: KnownTool, lines: [String], startLine: Int, endLine: Int)
    case unmanaged(raw: String, sourceLine: Int)
}
```

**Every parser function has unit tests.** Tests live in `DotmapTests/ParserTests.swift`. New parsing patterns require a new test. Tests run against real-world fixture files in `DotmapTests/Fixtures/`.

**Tool-managed block detection** uses a registry of known comment marker patterns. When a block matches a known pattern, it is classified as a `toolBlock` with a `KnownTool` enum value rather than being parsed line by line.

---

## SwiftUI Views

**Views are for rendering.** Business logic, data fetching, and state management live in `@Observable` model classes or `@StateObject` view models, not in view bodies. A view body that exceeds ~60 lines should probably be split.

**One view per file.** The file name matches the view name.

**Prefer `@Observable` (Swift 5.9+) over `ObservableObject`/`@Published`.** It's cleaner and more performant.

```swift
// ✅ correct — logic in model, view just renders
struct AliasesView: View {
    @State private var model = AliasesModel()
    
    var body: some View {
        List(model.filtered) { alias in
            AliasRow(alias: alias)
                .onTapGesture { model.select(alias) }
        }
    }
}

// ❌ wrong — view doing data work
struct AliasesView: View {
    @State private var aliases: [Alias] = []
    
    var body: some View {
        // ... fetching and filtering inline
    }
}
```

**The detail panel is an overlay.** It is absolutely positioned over the content, not a split pane that shrinks the list. It uses a dim layer behind it and slides in from the right. Dismiss by clicking the dim layer or pressing Escape.

**Use AppKit where SwiftUI falls short.** The sidebar vibrancy (`NSVisualEffectView`), window panel behavior, and any platform-specific interactions that SwiftUI doesn't expose cleanly should use `NSViewRepresentable` or `NSViewControllerRepresentable` wrappers. Don't fight SwiftUI — supplement it.

---

## Naming

- Types, protocols, enums: `PascalCase`
- Functions, variables, properties: `camelCase`
- Constants: `camelCase` (Swift convention, not `SCREAMING_SNAKE_CASE`)
- Files: `PascalCase` matching the primary type they contain
- No abbreviations unless universally understood (`env`, `config`, `path` are fine; `mgr`, `vc`, `vm` are not)

---

## Error Handling

Use Swift's `throws`/`do-catch` for operations that can fail. Never use `try!`. Error messages should be human-readable — they may surface in the UI.

```swift
// ✅ correct
func readConfig(at url: URL) throws -> String {
    do {
        return try String(contentsOf: url, encoding: .utf8)
    } catch {
        throw DotmapError.fileReadFailed(path: url.path, underlying: error)
    }
}

// ❌ wrong
func readConfig(at url: URL) -> String {
    return try! String(contentsOf: url, encoding: .utf8)
}
```

Define a `DotmapError` enum for app-specific errors with associated values for context.

---

## Testing

**Parser functions: required, comprehensive.** Test the happy path, edge cases, and malformed/unusual input. Tests live in `DotmapTests/ParserTests.swift`.

**Fixtures:** `DotmapTests/Fixtures/` contains sample `.zshrc` files representing real-world patterns — clean hand-written configs, nvm-injected configs, oh-my-zsh configs, multi-file sourcing chains, configs with sensitive variables. Add a new fixture when you encounter a pattern not already covered.

**Health checker: unit tested.** Each health check category has corresponding test cases.

**Views: light smoke tests only.** Confirm they render without crashing. Don't test every interaction.

**What not to test:** Apple framework behavior, trivial getters/setters, one-liner passthroughs.

Run tests with `⌘U` in Xcode or `xcodebuild test` from the command line.

---

## Comments & Documentation

Write comments that explain **why**, not **what**. The code explains what. Comments explain decisions, constraints, and non-obvious reasoning.

```swift
// ✅ correct — explains a non-obvious decision
// We use static parsing rather than subprocess evaluation because evaluating
// a .zshrc can have side effects (tool initialization, network calls, etc.)
// and would be significantly slower on complex configs.
func parse(_ content: String) -> [ConfigEntry] { ... }

// ❌ wrong — restates the code
// Parse the config content
func parse(_ content: String) -> [ConfigEntry] { ... }
```

TODO comments must include a GitHub issue number:
```swift
// TODO(#42): Handle nested source directives beyond depth 3
```

---

## Dependencies

Dotmap has minimal external dependencies. The Swift standard library and Apple frameworks handle almost everything needed.

**Approved external dependencies:**
- `CodeEditSourceEditor` — syntax-highlighted editor component for the Editor View (Swift Package Manager)

Do not add dependencies without strong justification. Every dependency is a maintenance burden and a potential App Store review complication.

---

## Sensitive Data

Variables whose names match patterns like `*_KEY`, `*_TOKEN`, `*_SECRET`, `*_PASSWORD`, `*_PASS` should be treated as sensitive. They are masked by default in the Variables view and detail panel, with a Reveal toggle. Never log sensitive values. Never include them in error messages.

---

## What Codex / AI Agents Should Know

When generating code for Dotmap:

- **The parser is the most sensitive code.** Generated parser code must include unit tests. If you add a new parsing pattern, add a test in the same output.
- **Never use force unwrap** (`!`) or `try!` in production code paths.
- **The parser must never crash or throw on a valid shell file.** Unrecognized content → `.unmanaged(raw:)`.
- **The detail panel is an overlay**, not a split pane. It slides in from the right over the content with a dim layer behind it.
- **Views render, models think.** Business logic goes in `@Observable` model classes, not in SwiftUI view bodies.
- **Use Swift concurrency** (`async/await`, `@MainActor`). No completion handlers, no NotificationCenter for coordination.
- **Sensitive variables are masked by default.** Any variable whose name matches the sensitive patterns should have its value displayed as `••••••••` with a Reveal toggle.
- **Block view vs editor view.** In MVP, the block view is read-only (expand/collapse only). Write-back and drag-to-reorder come in v0.2.
- **File watching uses FSEvents/DispatchSource**, not polling.
- **App Store entitlements matter.** File access outside the sandbox requires the correct entitlements. Don't assume arbitrary file access works — use `NSOpenPanel` for user-selected files and the appropriate entitlements for home directory access.
