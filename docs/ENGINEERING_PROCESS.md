# Dotmap — Engineering Process
**Version:** 0.2  
**Scope:** All development and release activity on the Dotmap repository

---

## Guiding Principle

Dotmap is a public OSS project. The engineering process exists to keep `main` trustworthy, releases predictable, and the contributor experience frictionless. Process serves the product — not the other way around.

---

## Branch Strategy

Dotmap uses a simplified Gitflow variant.

| Branch           | Purpose                                                                | Protected |
| ---------------- | ---------------------------------------------------------------------- | --------- |
| `main`           | Production. Every commit here is a tagged release.                     | Yes       |
| `dev`            | Default branch. Integration target for all feature work.               | Yes       |
| `<type>/<scope>` | Feature, fix, or chore branches. Cut from `dev`, merged back to `dev`. | No        |

### Branch Naming

`<type>/<short-description>` — lowercase, hyphen-separated.

**Types:** `feat/`, `fix/`, `chore/`, `docs/`

**Examples:**
```
feat/alias-parser
feat/config-block-view
fix/path-health-check-symlinks
chore/update-codedit-source-editor
docs/contributing-guide
```

### Flow

1. Cut branch from `dev`
2. Do work
3. Open PR targeting `dev`
4. CI passes, squash merge into `dev`
5. When `dev` is release-ready, merge `dev` → `main` via PR
6. Tag the release on `main`

**Never commit directly to `main` or `dev`.** All work goes through PRs.

---

## Pull Requests

Every PR needs:
- A title that completes "This PR..." — present tense, specific (`Add alias parser with source attribution` not `Aliases`)
- A description covering what changed, why, and any decisions worth noting
- A linked issue if one exists (`Closes #42`)

### PR Template

```markdown
## What
Brief description of what this PR does.

## Why
Why this change is needed.

## Notes
Decisions, tradeoffs, or things a reviewer should know.

## Testing
How this was tested. Unit tests added? Manual testing steps?

Closes #[issue if applicable]
```

### Merging

- Squash merge into `dev`. Squashed commit message = PR title.
- Delete feature branch after merge.
- `dev` → `main` uses a regular merge commit titled `Release vx.y.z`.

---

## CI / GitHub Actions

CI runs on every PR targeting `dev` or `main`, and on every push to `dev`.

### CI Pipeline

```
on: pull_request (dev, main)
    push (dev)

jobs:
  build-and-test:
    runs-on: macos-latest
    steps:
      - xcodebuild build -scheme Dotmap
      - xcodebuild test -scheme Dotmap
      - swiftlint lint --strict

  release:
    on: push (tags: v*)
    runs-on: macos-latest
    steps:
      - xcodebuild archive
      - xcodebuild -exportArchive (notarize + sign)
      - Create GitHub Release
      - Upload .dmg artifact
      - Body populated from CHANGELOG.md for this version
```

### Required Checks

All must pass before merge:
- `build-and-test / build` — project compiles without errors or warnings
- `build-and-test / test` — all unit tests pass
- `build-and-test / swiftlint` — no SwiftLint violations

### Local Checks Before Pushing

```bash
xcodebuild build -scheme Dotmap -quiet
xcodebuild test -scheme Dotmap -quiet
swiftlint lint --strict
```

### SwiftLint

A `.swiftlint.yml` at the repo root. Key rules enabled:
- `force_unwrapping` — no `!` in production code
- `force_try` — no `try!` in production code
- `implicitly_unwrapped_optional` — warn on `var x: Type!` in non-IBOutlet contexts
- `file_length` — warn at 400 lines, error at 600
- `function_body_length` — warn at 50 lines

---

## Versioning & Releases

Semantic versioning: `MAJOR.MINOR.PATCH`

| Increment | When                                     |
| --------- | ---------------------------------------- |
| `MAJOR`   | Breaking behavior changes. Rare pre-1.0. |
| `MINOR`   | New features, backwards compatible.      |
| `PATCH`   | Bug fixes only.                          |

Pre-1.0: all releases are `0.x.y`. Minor bumps represent meaningful new capability.

### Release Process

1. Ensure `dev` is stable, all intended PRs merged
2. Update `CHANGELOG.md` on `dev` with the new version section
3. Bump version in `Dotmap.xcodeproj` (marketing version + build number)
4. Commit on `dev`: `chore: bump version to vx.y.z`
5. Open PR: `dev` → `main`, titled `Release vx.y.z`
6. Merge (regular merge commit)
7. Tag on `main`: `git tag vx.y.z && git push origin vx.y.z`
8. GitHub Actions release workflow triggers, builds `.dmg`, creates GitHub Release
9. Submit to Mac App Store via App Store Connect (manual step post-release)

### Signing & Notarization

Certificates and provisioning profiles are stored in GitHub Actions secrets — never in the repo. The CI pipeline handles signing and notarization for the DMG release. For the App Store build, use Xcode's automatic signing with the appropriate team.

---

## Changelog

`CHANGELOG.md` at repo root, following [Keep a Changelog](https://keepachangelog.com):

```markdown
# Changelog

## [Unreleased]

## [0.2.0] - 2026-05-15
### Added
- Block view with expand/collapse for all config blocks
- Inline editing for user-written blocks
- Drag-to-reorder for user blocks with ordering safety model

### Fixed
- Source attribution missing for deeply nested sourced files

## [0.1.0] - 2026-03-28
### Added
- Initial release
- Home dashboard with health summary, environment stats, config load order
- Environment inspector: Aliases, Variables, PATHs, Functions
- Config dual view: Block View and Editor View (read-only in v0.1)
- Health checks: dead PATHs, duplicates, shadowed aliases, dead sources
- ⌘K search command palette
```

**Rules:**
- Every PR that changes user-visible behavior adds an entry under `[Unreleased]`
- Write from the user's perspective, not the implementer's
- Chores, dep updates, and internal refactors with no behavior change don't need entries

---

## Issues & Labels

| Label              | Meaning                              |
| ------------------ | ------------------------------------ |
| `bug`              | Something isn't working              |
| `feat`             | New feature request                  |
| `chore`            | Maintenance, deps, tooling           |
| `docs`             | Documentation                        |
| `parser`           | Related to the config parser         |
| `ui`               | Frontend / SwiftUI only              |
| `health`           | Health checks feature                |
| `good first issue` | Suitable for first-time contributors |
| `blocked`          | Waiting on something external        |

---

## Contributing (External Contributors)

1. Open an issue before writing code — especially for non-trivial changes
2. Fork the repo, cut a branch from `dev`
3. Follow the coding practices doc
4. Open a PR targeting `dev`
5. CI must pass before review

### What Gets Merged
- Bug fixes with a reproduction case
- Parser improvements with new fixture tests
- Features that align with the PRD roadmap

### What Doesn't Get Merged
- Features that contradict the invariants in the PRD (network calls, silent file modification, etc.)
- Code with `!` force unwraps or `try!` in production paths
- UI changes without prior discussion — Dotmap has a specific aesthetic and UI PRs need alignment first

---

## App Store Specifics

- The App Store build uses a separate entitlements file (`Dotmap-AppStore.entitlements`) with sandbox enabled and home directory access entitlements
- The direct DMG build uses `Dotmap-Direct.entitlements` with hardened runtime but no sandbox
- Both builds must pass CI before release
- App Store review metadata, screenshots, and App Store description live in `AppStore/` in the repo
- Minimum deployment target: macOS 13 Ventura

---

## What Codex / AI Agents Should Know

When generating code that will be committed to Dotmap:

- All work goes on a feature branch cut from `dev`. Never target `main` directly.
- Branch naming: `<type>/<short-description>` — e.g. `feat/alias-parser`, `fix/path-health-check`.
- Every PR that changes user-visible behavior needs a `CHANGELOG.md` entry under `[Unreleased]`.
- Version number lives in `Dotmap.xcodeproj` — bump both marketing version and build number.
- CI rejects: build errors, test failures, SwiftLint violations. Run checks locally first.
- Release tag format: `vMAJOR.MINOR.PATCH` — the `v` prefix is required for the release workflow to trigger.
- App Store and direct DMG builds use different entitlements files — don't conflate them.
- Screenshots and App Store metadata live in `AppStore/` — update them when UI changes ship.
