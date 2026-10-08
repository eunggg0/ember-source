#!/bin/sh
# apply-series.sh <patch-dir> <source-dir>
# Applies an Ember patch series (patches/<component>/series) to an extracted upstream source tree.
# Uses "git apply" so that binary hunks and new/deleted files are handled; works outside a git repository.
set -e
P=$(cd "$1" && pwd); D=$2
[ -f "$P/series" ] || { echo "no series in $P" >&2; exit 1; }
cd "$D"
# do not let git pick up an enclosing repository (it would silently skip paths outside it)
GIT_CEILING_DIRECTORIES=$(dirname "$(pwd)"); export GIT_CEILING_DIRECTORIES
while read -r p; do
  [ -n "$p" ] || continue
  echo "applying $p"
  git apply --whitespace=nowarn -p1 --verbose "$P/$p" >/dev/null
done < "$P/series"
