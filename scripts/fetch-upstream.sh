#!/bin/sh
# fetch-upstream.sh [file ...]
# Downloads the mirrored upstream archives (assets of the v1.0 release) into upstream/<group>/ and checks each SHA-256
# against upstream/SOURCES.tsv. With arguments, fetches only the named files. Set BASE to use another mirror.
set -e
cd "$(dirname "$0")/.."
BASE=${BASE:-https://github.com/eunggg0/ember-source/releases/download/v1.0}
fail=0
while IFS="$(printf '\t')" read -r group file url sha bytes how; do
  case "$group" in ''|\#*) continue ;; esac
  if [ $# -gt 0 ]; then
    want=0; for a in "$@"; do [ "$a" = "$file" ] && want=1; done
    [ $want = 1 ] || continue
  fi
  mkdir -p "upstream/$group"
  out="upstream/$group/$file"
  if [ ! -f "$out" ] || [ "$(shasum -a 256 "$out" | cut -d' ' -f1)" != "$sha" ]; then
    echo "downloading $file"
    if ! curl -fL --retry 3 -o "$out.part" "$BASE/$file"; then
      echo "download failed: $file" >&2
      fail=1
      continue
    fi
    mv "$out.part" "$out"
  fi
  got=$(shasum -a 256 "$out" | cut -d' ' -f1)
  if [ "$got" = "$sha" ]; then echo "ok  $group/$file"; else echo "BAD $group/$file ($got)"; fail=1; fi
done < upstream/SOURCES.tsv
exit $fail
