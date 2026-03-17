#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ASSET_CATALOG="$ROOT_DIR/src/dotmap/Assets.xcassets"

if [[ ! -d "$ASSET_CATALOG" ]]; then
  echo "Asset catalog not found: $ASSET_CATALOG" >&2
  exit 1
fi

sanitize_svg() {
  local icon_file="$1"
  # Normalize unresolved CSS var() values so Xcode template tint rendering works.
  perl -0pi -e 's/var\(--[^),]+(?:,\s*([^)]+))?\)/defined $1 ? $1 : "currentColor"/ge' "$icon_file"
}

ICONS=(
  "icon-panelToggle|https://www.figma.com/api/mcp/asset/57cfb04f-36bd-4732-8697-a86939f12a26"
  "icon-close|https://www.figma.com/api/mcp/asset/dc052896-a55a-46f2-9337-819b545ba21f"
  "icon-search|https://www.figma.com/api/mcp/asset/936ffa56-d9ed-42a7-86ff-27f6e570410e"
  "icon-command|https://www.figma.com/api/mcp/asset/2bdfded4-3a0b-461e-b8a7-ae7ef45e96c7"

  "icon-home|https://www.figma.com/api/mcp/asset/caa557a0-98ac-4dcb-9b8e-9e7dde725196"
  "icon-healthChecks|https://www.figma.com/api/mcp/asset/3b5c36a3-77d8-4b6c-95a4-3dc2196297d4"
  "icon-aliases|https://www.figma.com/api/mcp/asset/fd1464a0-727d-4da5-a459-a155dcd151dd"
  "icon-variables|https://www.figma.com/api/mcp/asset/a956c4dd-74a8-4168-8c1b-d7f683e5df3f"
  "icon-paths|https://www.figma.com/api/mcp/asset/bde4cc2b-460e-4139-a9f0-46cfd094f817"
  "icon-functions|https://www.figma.com/api/mcp/asset/8048deb9-24c7-4871-bc53-a0672b7f96e9"
  "icon-configFile|https://www.figma.com/api/mcp/asset/6edb53a2-cca9-44ec-82e4-d8f3d41b460d"
  "icon-settings|https://www.figma.com/api/mcp/asset/bd87317a-2db0-4555-9a92-5fbd3b92367c"

  "icon-sectionHealthSummary|https://www.figma.com/api/mcp/asset/eaaedc33-ad8d-4907-8064-fef0417da48e"
  "icon-sectionRecentlyChanged|https://www.figma.com/api/mcp/asset/069e1e47-f89e-4926-af69-439c088b4fa9"
  "icon-sectionEnvironment|https://www.figma.com/api/mcp/asset/054a84e0-b7b8-4ce4-817c-be6c3f75528e"
  "icon-sectionLoadOrder|https://www.figma.com/api/mcp/asset/a189bb74-54f1-4054-99f5-b3359be85610"

  "icon-performance|https://www.figma.com/api/mcp/asset/962188ac-d418-4ec9-9e03-68823fa4cfd9"
  "icon-sources|https://www.figma.com/api/mcp/asset/0b4d2dd4-9e7f-4e1f-8b51-71231a4ad242"

  "icon-checkCircle|https://www.figma.com/api/mcp/asset/7798c225-bb52-468a-92c7-18042f911f0e"
  "icon-chevronRight|https://www.figma.com/api/mcp/asset/53d48581-4255-476b-b30b-ca309055c167"
  "icon-chevronDown|https://www.figma.com/api/mcp/asset/dddc2d25-47c0-4cf3-9c1b-923618a95afd"
  "icon-chevronUp|https://www.figma.com/api/mcp/asset/54e74763-9b55-4edd-b9cf-e3713b3635f7"
  "icon-configCaret|https://www.figma.com/api/mcp/asset/cce477a1-186b-41fc-be17-75258b909ae1"
)

for item in "${ICONS[@]}"; do
  icon_name="${item%%|*}"
  icon_url="${item#*|}"

  imageset_dir="$ASSET_CATALOG/${icon_name}.imageset"
  icon_file="$imageset_dir/${icon_name}.svg"

  mkdir -p "$imageset_dir"
  curl -L --fail --silent --show-error "$icon_url" -o "$icon_file"
  sanitize_svg "$icon_file"

  cat > "$imageset_dir/Contents.json" <<JSON
{
  "images" : [
    {
      "filename" : "${icon_name}.svg",
      "idiom" : "universal",
      "scale" : "1x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  },
  "properties" : {
    "template-rendering-intent" : "template"
  }
}
JSON

done

echo "Synced ${#ICONS[@]} Figma icons into $ASSET_CATALOG"
