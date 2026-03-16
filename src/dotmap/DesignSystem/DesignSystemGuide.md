# Dotmap Design System

This folder contains primitive design tokens derived from the current Figma file.

## What is included
- `Tokens/DotmapColor.swift` — semantic color tokens
- `Tokens/DotmapSpacing.swift` — spacing scale
- `Tokens/DotmapRadius.swift` — corner radius scale
- `Tokens/DotmapTypography.swift` — text styles mapped to font family/weight/size/line-height/tracking
- `Fonts/DotmapFonts.swift` — bundled font registration + fallbacks
- `Icons/DotmapIcon.swift` — icon token registry with asset-first loading
- `scripts/sync_figma_icons.sh` — syncs icon SVGs from Figma MCP URLs into `Assets.xcassets`

## Font setup (required)
Drop font files into:
- `src/dotmap/Fonts/`

Expected families:
- Geist (sans)
- Geist Mono

Recommended files:
- `Geist-Medium.ttf`
- `Geist-MediumItalic.ttf`
- `Geist-SemiBold.ttf`
- `Geist-SemiBoldItalic.ttf`
- `GeistMono-Medium.ttf`
- `GeistMono-MediumItalic.ttf`
- `GeistMono-SemiBold.ttf`
- `GeistMono-SemiBoldItalic.ttf` (optional)

Notes:
- `dotmapApp` calls `DotmapFonts.registerBundledFonts()` at launch.
- If PostScript names differ, update candidate names in `DotmapFonts.resolvePostScriptName`.

## Icon setup
- Icons already synced from Figma into `src/dotmap/Assets.xcassets/icon-*.imageset`.
- Re-sync command:

```bash
./scripts/sync_figma_icons.sh
```

- Runtime behavior in `DotmapIconView`:
1. Load asset catalog icon named `icon-<token-name>`.
2. Fallback to SF Symbol if the asset is missing.
