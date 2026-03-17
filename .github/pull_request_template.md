## What
Brief description of what this PR changes / implements

### Closes
The issue this PR closes, if applicable

## Why
Why this change is needed.

## Notes
Key decisions, tradeoffs, or implementation details reviewers should know.

## Testing
- [ ] `xcodebuild build -project src/dotmap.xcodeproj -scheme dotmap -quiet`
- [ ] `xcodebuild test -project src/dotmap.xcodeproj -scheme dotmap -quiet`
- [ ] `swiftlint lint --strict`
- [ ] Manual verification completed

Manual test notes:
- 

## Checklist
- [ ] Targets `dev`
- [ ] No direct commits to `main`/`dev`
- [ ] User-visible changes documented in `CHANGELOG.md` (`[Unreleased]`) when applicable
- [ ] No force unwraps (`!`) or `try!` in production paths
- [ ] Parser behavior preserves unrecognized content as `.unmanaged(raw:)` when parser code is touched

