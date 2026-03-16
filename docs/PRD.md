# Dotmap — Product Requirements Document
**Version:** 0.3  
**Last updated:** March 2026

---

## Overview & Problem Statement

Shell environments are invisible by default. Every developer accumulates years of configuration across `.zshrc`, `.zprofile`, `.zshenv`, and a sprawl of sourced files — injected by tools like nvm, Homebrew, rbenv, and pyenv, written by hand at 2am, copied from Stack Overflow, forgotten entirely. Nobody actually knows what's in their shell config in full. The file is the documentation, and the file is a mess.

The existing ecosystem has addressed one dimension of this problem well: sync and portability. Tools like chezmoi, yadm, and GNU Stow let developers version-control and replicate their dotfiles across machines. They are the "git" of shell configuration.

**Nobody has built the GitHub.**

The visual layer — the thing that makes the underlying reality of a shell environment readable, navigable, and debuggable by a human being — doesn't exist. There is no tool that looks at your live shell environment and tells you: where this PATH entry came from, why this alias is being silently overridden, which sourced file doesn't exist anymore, what actually runs on startup and in what order.

**Dotmap is that tool.** It is a local-first, open-source native macOS application that gives developers a clear, visual map of their shell environment. Not a sync tool, not a generic editor, not a framework. A window into what's actually happening — and eventually, a control panel for managing it.

Windows has had a system UI for environment variables since the 90s, clunky as it is. macOS never built one. Dotmap fills that gap — and goes far beyond it.

---

## Target User

**Primary:** macOS developers who use zsh as their daily driver. This is the default shell on macOS since Catalina, making it the single largest coherent population. The user has been accumulating shell config for at least a year, uses common toolchain managers (nvm, Homebrew, rbenv, pyenv, etc.), and has a `.zshrc` they could not fully explain under pressure.

**Secondary:** macOS developers using bash. The problem is universal across shells; the initial scope is zsh.

**The user is not:** a sysadmin managing fleet configuration, a developer looking for a dotfiles sync tool, or a beginner learning shell for the first time. Dotmap assumes you already have a shell environment worth understanding.

**The user has seen some shit.** They've spent at least one afternoon debugging why a command isn't found in PATH, only to discover nvm injected something that broke the load order two years ago. They know the pain Dotmap solves before they even open it.

**Distribution:** Three channels, all active from launch.
- **GitHub** — direct DMG download, OSS repo, the primary home for the developer audience
- **Mac App Store** — for legitimacy, passive discoverability, and the developer who only installs signed apps
- **Homebrew cask** — `brew install --cask dotmap` — for bootstrap scripts and setup guides, the compounding long-tail distribution channel

---

## Product Philosophy

**Native macOS, always.** Dotmap is a pure Swift/SwiftUI/AppKit application. It uses real `NSVisualEffectView` for vibrancy, real `NSPanel` for window behavior, real macOS controls and conventions. It feels like it should have shipped with the OS. This is non-negotiable — the target user has strong aesthetic opinions and will notice immediately if the app feels like a web wrapper.

**Local-first, always.** Shell configs contain sensitive information — API keys, tokens, internal path structures, company project names. Dotmap never phones home. No telemetry, no analytics, no remote database, no account required. Everything runs on the user's machine. This is not a tradeoff — it is a core design principle and a precondition for trust with the target audience.

**100% open source.** MIT licensed. The code is public from day one. The local-first architecture means there is nothing to hide — every line of code that touches a user's shell config is publicly readable. This transparency is both an ethical stance and a practical one.

**Read-first, write-carefully.** Dotmap's primary value is inspection. When write-back is introduced, it is always non-destructive — every change is shown as a diff before writing, the original file is preserved, and the user is always in control. Dotmap never silently modifies a config file.

**Complement, don't replace.** Dotmap is not a replacement for vim, chezmoi, or any existing tool. It sits alongside them as the visual layer they never provided. No prerequisites.

**Less but better.** Each feature earns its place. Scope creep is the primary risk for a vibe-coded solo project — the PRD exists to prevent it.

---

## Architecture

**Language & Framework:** Pure Swift, SwiftUI + AppKit, macOS only. Single Xcode project. No Electron, no Tauri, no web layer of any kind.

**Why native Swift over Tauri/Electron:**
- Real `NSVisualEffectView` vibrancy — the frosted glass sidebar effect that Electron cannot replicate natively
- Real `NSPanel` overlay behavior for window chrome and modal interactions
- Near-instant launch — Dotmap is a tool you pop open, check something, close. Startup time matters.
- Native controls, native accessibility, native macOS conventions throughout
- Single language, one mental context, no IPC boundary to cross

**Key Swift/Foundation APIs:**
- `FileManager` and `String(contentsOf:)` — reading config files, resolving symlinks
- `Process` — spawning shell subprocesses for live environment evaluation
- `DispatchSource.makeFileSystemObjectSource` / FSEvents — file watching, detecting config changes on disk
- `UserDefaults` or a small JSON file in `~/Library/Application Support/Dotmap/` — local app state (last scan, preferences, recently changed history)
- `NSWorkspace` — Reveal in Finder actions on PATH entries

**Parsing strategy:**
Dotmap uses static analysis, not full shell evaluation. Static parsing is fast and attributable. For the live environment view, Dotmap spawns a clean shell subprocess via `Process` and reads the evaluated output.

Swift enums with associated values are used for the parser output — identical in expressiveness to Rust enums for this use case:

```swift
enum ConfigEntry {
    case alias(name: String, expansion: String, sourceLine: Int)
    case envVar(key: String, value: String, sourceLine: Int)
    case pathEntry(path: String, sourceLine: Int)
    case function(name: String, body: String, sourceLine: Int)
    case source(path: String, sourceLine: Int)
    case unmanaged(raw: String) // anything the parser couldn't confidently classify
}
```

The parser handles the 80% case. Unrecognized constructs become `unmanaged` — never silently dropped, never incorrectly attributed.

**Local persistence:**
- Small JSON file in Application Support for app state (no SQLite needed for MVP)
- File modification timestamps from `FileManager` drive the recently changed feature
- Future: SQLite for shell history analytics

**Sandbox & App Store:**
Dotmap ships both sandboxed (App Store) and unsandboxed (direct DMG). The App Store version uses `com.apple.security.files.user-selected.read-write` and appropriate home directory entitlements. This is a solved problem for developer tools.

**Shell support:**
- v1: zsh only
- Future: bash, then fish

---

## UI & Design Language

Dotmap is a dark, minimal, native macOS app. Design DNA is Linear and Notion — high information density, consistent visual hierarchy, restrained color use.

**Key UI decisions:**
- `NSVisualEffectView` with `.behindWindow` blending for the sidebar
- Sidebar sections: top nav (Home, Health Checks), Environment (Aliases, Variables, PATHs, Functions with counts), Configs (detected config files with sourced file tree), Settings pinned to footer
- Main content topbar: breadcrumb left, contextual chrome center (view mode toggle on config pages only, update chip when available), search pill right (`⌘K`)
- **Detail panel:** Absolutely positioned overlay from the right. Slides over content, dim layer behind it, dismiss by clicking dim or pressing Escape. Does NOT shrink or reflow the list behind it.
- Phosphor icons throughout — consistent stroke weight
- All-caps muted section labels in sidebar (`ENVIRONMENT`, `CONFIGS`)
- Counts right-aligned in sidebar nav items

**Config view — dual mode (toggle in topbar):**

*Block View (default)* — config parsed into semantic blocks. Each block is an expandable unit showing real syntax-highlighted code. User blocks have `⠿` drag handles. Tool-managed blocks have lock icons, cannot be dragged. Hover any line to reveal Edit/Copy inline actions. `+ Add block` insert zones appear between blocks on hover. This is the novel view that doesn't exist anywhere else.

*Editor View* — enhanced raw file. Full syntax highlighting. Tool-managed sections have colored left border and floating tool name label. Line numbers in gutter.

**Environment views (Aliases, Variables, PATHs, Functions):**
Filterable list with status indicator dots, item name in monospace, middle content column, status badges, right-aligned source attribution. Clicking a row opens the overlay detail panel. Filter chips vary by type.

---

## Full Feature Set (End Goal)

### 1. Home Dashboard
- Health summary card with issues count, severity, top issues preview, See All link
- Recently changed configs — FSEvents-driven, file names + timestamps, scrollable
- Your environment stats — alias/variable/PATH/function counts
- Config load order — visual chain of root configs and sourced children

### 2. Shell Environment Inspector
- **Aliases** — name, expansion, source. Filter: All / Conflicts / Tool-managed. Panel: expansion block, conflict warning if shadowed, source metadata, Show in Config / Copy alias actions.
- **Variables** — key, value (masked for sensitive vars), source. Filter: All / Tool-managed / Sensitive. Panel: value with Reveal toggle for sensitive vars, source metadata, Show in Config / Copy value actions.
- **PATHs** — path, existence dot (green=live, red=dead), source. Filter: All / Dead / Duplicates / Homebrew. Panel: status pill, dead/duplicate warnings, source metadata, Show in Config / Reveal in Finder / Copy path actions.
- **Functions** — name, line count, source. Filter: All / Tool-managed. Panel: full function body in syntax-highlighted code block, source metadata, Show in Config / Copy function actions.

### 3. Config File View — Dual Mode
As described in UI section. Breadcrumb shows `Configs › .zshrc`. Clicking a sourced child in the sidebar (e.g. `nvm`) navigates to the parent config scrolled to that block.

### 4. Health Checks
Category-organized full diagnostic page: PATH, Aliases, Sources, Variables, Performance. Summary strip at top with severity counts and Rescan (`⌘R`). Expandable issue rows with Show in Config action. Categories with no issues show a clean green "No issues detected" state.

**Checked items:** dead PATH entries, duplicate PATH entries, shadowed aliases, shadowed variables, dead source directives, performance notices (nvm eager init, deep source chains).

### 5. Search (`⌘K`)
Command palette modal — centered overlay, real input, categorized results across all environment types. Keyboard navigable, ESC to dismiss.

### 6. Block Ordering & Safety Model
- Tier 1: Known tool blocks — auto-locked by comment markers
- Tier 2: Comment-declared ordering — respected and locked
- Tier 3: Static dependency warnings — flagged but not blocked
- Tier 4: Free user blocks — drag freely, diff shown before write
- Implicit ordering is disclaimed. Users can pin any block via right-click or add comments in Editor View.

### 7. Non-Destructive Write-Back
Diff preview before every write. File backed up before write. Tool-managed blocks never touched. Formatting, comments, structure preserved.

### 8. Automation Builder (Post-MVP)
Script scaffolding, pattern templates, argument/flag builder, run with live output, context-aware (knows your existing environment), optional AI assistance.

### 9. Shell History Analytics (Post-MVP)
Optional `preexec` shell plugin logging to local SQLite. Surfaces unused aliases, most-used commands. Fallback: parse `.zsh_history` with no install required.

### 10. Per-Project Shell Profiles (Post-MVP)
Visual direnv-style environment overrides per project directory.

### 11. Dotfile Export & Sync (Post-MVP)
Environment snapshot export, optional GitHub Gist backup.

### 12. Update Checks
Passive, opt-out. Checks `api.github.com/repos/[owner]/dotmap/releases/latest` at most once per 24 hours. Dismissible chip in topbar when update available. No auto-download. GitHub is the only permitted third-party endpoint.

---

## Invariants, Constraints & Axioms

These are non-negotiable.

1. **No telemetry, no user data leaves the machine.** The only permitted outbound call is the passive update check described above. No other network calls. Ever.
2. **No silent file modification.** Every file write requires a diff preview and explicit user confirmation.
3. **Original files are preserved.** Backup created before any write. User can always restore.
4. **Parser failures are surfaced, not hidden.** Unrecognized content → `unmanaged`. Never silently dropped.
5. **Tool-managed blocks are read-only.** Identified by comment markers. Displayed, never modified.
6. **No required account or login.** Dotmap works fully offline without authentication. Ever.
7. **zsh/macOS first.** All feature decisions prioritize zsh on macOS. Everything else is additive.
8. **The file is the source of truth.** No shadow database. Reads from and writes to actual config files.
9. **Native macOS only.** Pure Swift, SwiftUI, AppKit. No web layer, no cross-platform abstractions.

---

## MVP Feature Set

The MVP includes both inspection **and editing** of user-written config content. The block view and editor view are both editable from day one. Tool-managed blocks are always read-only regardless of view.

**Included in MVP:**

*Home Dashboard* — health summary, recently changed, environment stats, config load order (all states: empty and populated)

*Environment Inspector (read-only)* — Aliases, Variables (with masking), PATHs (with health indicators), Functions — all with overlay detail panels and filter chips. Environment views are inspect-only in MVP — editing is done via the Config File View.

*Config File View — Block View* — expand/collapse, syntax highlighting, inline editing of user-written blocks, drag-to-reorder user blocks, per-block Save + Undo appearing only when a block has been modified, `+ Add block` insert zones between blocks. Tool-managed blocks (nvm, Homebrew, oh-my-zsh, rbenv etc.) are locked and read-only with a lock icon. Diff preview before any write.

*Config File View — Editor View* — full syntax-highlighted editable view of the config file, line numbers, tool section labels with colored left borders, file-level dirty state with Undo + Save in topbar, diff preview modal before write. Tool sections are read-only.

*Non-Destructive Write-Back (both views)* — diff preview before every save, backup created before write, formatting and comments preserved, tool-managed blocks never touched.

*Health Checks* — dead PATHs, duplicates, shadowed aliases, dead sources, performance notices

*Search* — `⌘K` command palette across all environment items

*Settings* — update check toggle, default view preference (Blocks or Editor)

**Non-goals for MVP:**
- Live vs static environment diff
- Automation builder
- Per-project profiles
- Export / sync
- History analytics / shell plugin
- bash / fish support
- AI-assisted anything

---

## Post-MVP Roadmap

**v0.2 — Environment View Editing**
Add/edit/delete aliases, variables, PATH entries directly from the environment views without going into the config file view. Same diff preview and write-back safety model.

**v0.3 — Live Environment View**
Spawn clean shell subprocess, diff static vs live.

**v0.4 — Automation Builder (basic)**
Script scaffolding, pattern templates, run with live output.

**v0.5 — bash support**

**Later:** Shell history analytics, per-project profiles, AI-assisted script generation with environment context, dotfile export/sync, fish support, team/enterprise profiles.

---

## Technical Notes for Development

- **Start with the parser.** It is the hardest and most critical piece. Build it first, test it against real-world `.zshrc` files including messy ones with tool-injected blocks, conditionals, and nested sources.
- **Scope the parser honestly.** Handle `alias`, `export`, `PATH=`, `source`/`.`, and function definitions. Everything else → `unmanaged`.
- **The parser must never crash.** Every valid shell file must produce output. Unrecognized content → `unmanaged`. Never throw, never return nil on valid input.
- **File watching matters.** Users edit `.zshrc` in another editor while Dotmap is open. Refresh the UI within ~1 second of any change.
- **Sensitive variable detection.** Variables matching `*_KEY`, `*_TOKEN`, `*_SECRET`, `*_PASSWORD` patterns should be masked by default with a Reveal toggle.
- **Design matters.** The target user has strong aesthetic opinions. Dotmap should feel like something from Odd Theory — intentional, sharp, native. The vibrancy sidebar, the overlay panel, the Phosphor icons, the dark palette — all of it signals craft.
