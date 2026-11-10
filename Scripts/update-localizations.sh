#!/bin/sh
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
generated=$(mktemp -d)
trap 'rm -rf "$generated"' EXIT

xcrun xcstringstool compile --output-directory "$generated" "$root/Localization/Localizable.xcstrings"
for strings in "$generated"/*.lproj/Localizable.strings; do
    plutil -lint "$strings" >/dev/null
done

destination="$root/Sources/SwiftUtilityKit/Resources/Localization"
if [ "${1:-}" = "--check" ]; then
    diff -ru "$destination" "$generated"
else
    mkdir -p "$destination"
    rsync -a --delete "$generated/" "$destination/"
fi
