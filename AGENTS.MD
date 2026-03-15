# AGENTS.md — Dotmap

This file is the authoritative instruction set for AI agents (Codex, Claude, etc.) working in this repository. Read it fully before making any changes. The rules here are not suggestions.

For full context, see:
- `docs/PRD.md` — what Dotmap is and what it's building
- `docs/CODING_PRACTICES.md` — full coding standards
- `docs/ENGINEERING_PROCESS.md` — full process and release conventions

---

## What Dotmap Is

Dotmap is a local-first, open-source native macOS desktop app built in **pure Swift, SwiftUI, and AppKit**. It gives developers a visual map of their shell environment — parsing zsh config files (`.zshrc`, `.zprofile`, `.zshenv`, sourced files) and surfacing aliases, env vars, PATH entries, functions, load order, and health issues with full source attribution.

There is no Tauri, no Electron, no Rust, no React, no TypeScript, no web layer of any kind. Pure Swift, single Xcode project.

**Core invariants that must never be violated:**
- No outbound network calls except the passive GitHub release check (`api.github.com/repos/[owner]/dotmap/releases/latest`). No telemetry, no analytics, ever.
- No silent file modification. Every write requires a diff preview and explicit user confirmation.
- The parser must never crash or throw on a valid shell file. Unrecognized content → `.unmanaged(raw:)`.
- No account, login, or remote database. Everything runs locally.
- Native macOS only. No web layer, no cross-platform abstractions.

---

## Repo Structure

```
Dotmap/
├── App/                  # Entry point, top-level app state
├── Parser/               # Shell config parsing — most critical code
│   ├── ConfigParser.swift
│   ├── ConfigEntry.swift  # The ConfigEntry enum
│   ├── BlockDetector.swift
│   └── SourceResolver.swift
├── Watcher/              # FSEvents file watching
├── Shell/                # Process spawning for live env evaluation
├── Health/               # Health check analysis
├── Models/               # Alias, EnvVar, PathEntry, ShellFunction, ConfigFile
├── Views/
│   ├── Home/
│   ├── Environment/      # AliasesView, VariablesView, PathsView, FunctionsView
│   ├── Config/           # ConfigView, BlockView, EditorView
│   ├── Health/
│   ├── Search/
│   ├── Settings/
│   └── Shared/           # Sidebar, DetailPanel, reusable components
└── Storage/              # Local JSON persistence in Application Support

DotmapTests/
├── ParserTests.swift
├── HealthCheckerTests.swift
└── Fixtures/             # Real-world .zshrc files for parser tests
```

---

## Branch & Commit Rules

- **Never commit directly to `main` or `dev`.** All work goes on a feature branch.
- Always cut feature branches from `dev`, not `main`.
- Branch naming: `<type>/<short-description>`
  - Types: `feat/`, `fix/`, `chore/`, `docs/`
  - Examples: `feat/alias-parser`, `fix/path-symlink-resolution`, `chore/update-codedit`
- PRs target `dev`. Only release PRs target `main`.
- Squash merge into `dev`. PR title becomes the squash commit message.
- `dev` → `main` is a regular merge commit titled `Release vx.y.z`.

---

## Before Every Push — Required Checks

```bash
xcodebuild build -scheme Dotmap -quiet
xcodebuild test -scheme Dotmap -quiet
swiftlint lint --strict
```

Zero build errors. Zero warnings. All tests green. No SwiftLint violations.

---

## Swift Rules

### Never do these
- **No `!` force unwraps** in production code paths — use `guard let`, `if let`, or `do/catch`
- **No `try!`** — always use `do/catch` with proper error handling
- **No completion handlers** — use `async/await` and Swift concurrency throughout
- **No business logic in SwiftUI view bodies** — views render, models think

```swift
// ✅ correct
guard let contents = try? String(contentsOf: url, encoding: .utf8) else { return [] }

// ❌ crashes in production
let contents = try! String(contentsOf: url, encoding: .utf8)
```

### The parser — special rules
- **Pure functions only.** Input in, output out. No side effects, no global state, no I/O inside parser functions.
- **Never throw, never crash on valid input.** Unrecognized content → `.unmanaged(raw: line, sourceLine: n)`.
- **Every new parsing pattern requires a unit test** in `DotmapTests/ParserTests.swift`.
- **Add a fixture file** to `DotmapTests/Fixtures/` when you encounter a real-world config pattern not already covered.

```swift
// The parser output type — unrecognized content is PRESERVED, never dropped
enum ConfigEntry {
    case alias(name: String, expansion: String, sourceLine: Int)
    case envVar(key: String, value: String, sourceLine: Int)
    case pathEntry(path: String, sourceLine: Int)
    case function(name: String, body: String, sourceLineStart: Int, sourceLineEnd: Int)
    case source(path: String, sourceLine: Int)
    case toolBlock(tool: KnownTool, lines: [String], startLine: Int, endLine: Int)
    case unmanaged(raw: String, sourceLine: Int) // ALWAYS use this, never drop content
}
```

### Views
- One view per file. File name matches the view name.
- Use `@Observable` for model classes (Swift 5.9+), not `ObservableObject`/`@Published`.
- View bodies should be ~60 lines max. Split into subviews if longer.
- Use `NSViewRepresentable` for AppKit components SwiftUI can't express (vibrancy, panel behavior).

### The detail panel
- **Absolutely positioned overlay** sliding in from the right over content.
- Has a dim layer behind it (`Color.black.opacity(0.35)` or similar).
- Dismiss by tapping the dim layer or pressing Escape.
- **Does NOT push or shrink the list behind it.** The list stays at full width and is not reflowed.

---

## UI Rules

### Block view vs editor view
- Both views are accessed via a segmented toggle in the topbar (`Blocks` / `Editor`).
- The toggle only appears on config file pages — not on home, health checks, or environment views.
- **In MVP, block view is read-only** — expand/collapse only, no inline editing, no drag-to-reorder.
- Write-back and drag-to-reorder come in v0.2.

### Tool-managed blocks
- Identified by known comment marker patterns (`# >>> nvm initialize >>>`, etc.)
- Displayed with a lock icon, colored left border, and a tool name label
- Cannot be dragged or edited — ever
- When expanded, show raw code with a "🔒 Managed by [tool]. Editing is disabled." notice

### Sensitive variables
- Variables matching `*_KEY`, `*_TOKEN`, `*_SECRET`, `*_PASSWORD`, `*_PASS` are sensitive
- Display value as `••••••••` by default with a Reveal toggle
- Never log sensitive values. Never include them in error messages or crash reports.

---

## Health Checks — What Gets Checked

- Dead PATH entries (directory doesn't exist on disk)
- Duplicate PATH entries (same path declared in multiple places)
- Shadowed aliases (same alias name defined more than once)
- Shadowed variables (same var exported multiple times)
- Dead source directives (sourced file doesn't exist)
- Performance notices (nvm eager initialization, deep source chains)

---

## Changelog Rules

- Every PR that changes user-visible behavior adds an entry to `CHANGELOG.md` under `## [Unreleased]`
- Entries go under `Added`, `Fixed`, `Changed`, or `Removed`
- Write from the user's perspective: `Add source attribution for PATH entries` not `Implement PathEntry.sourceLine property`
- Chores, dep bumps, and internal refactors don't need entries

---

## Release Rules

- Version number lives in `Dotmap.xcodeproj` — bump marketing version AND build number
- Release tag format: `vMAJOR.MINOR.PATCH` — the `v` prefix triggers the release GitHub Action
- Always tag on `main`, never on `dev`
- App Store build uses `Dotmap-AppStore.entitlements` (sandboxed)
- Direct DMG build uses `Dotmap-Direct.entitlements` (hardened runtime, unsandboxed)

---

## What Not To Do

| Don't                                                        | Do instead                       |
| ------------------------------------------------------------ | -------------------------------- |
| Force unwrap with `!`                                        | `guard let` or `if let`          |
| Use `try!`                                                   | `do/catch` with `DotmapError`    |
| Put logic in SwiftUI view bodies                             | `@Observable` model class        |
| Make the detail panel push/shrink the list                   | Absolutely positioned overlay    |
| Drop unrecognized parser content                             | `.unmanaged(raw:)`               |
| Write to a config file silently                              | Diff preview + user confirmation |
| Make any outbound network call (except GitHub release check) | It's local-first. No exceptions. |
| Use Electron, Tauri, React, or any web tech                  | Pure Swift, SwiftUI, AppKit      |
| Add `!` or `try!` anywhere in production paths               | Proper error handling            |
| Edit or move a tool-managed block                            | Display only, always locked      |
| Log or include sensitive variable values in errors           | Mask them, always                |
| Commit to `main` or `dev` directly                           | Always use a feature branch + PR |
