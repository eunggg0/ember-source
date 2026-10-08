#!/bin/sh
# FEX DLL 설치: 실행 중인 프로세스가 매핑한 파일을 제자리에서 덮어쓰면(cp) 그 프로세스가 죽는다.
# 새 파일을 옆에 쓰고 mv 로 바꿔치기하면 기존 매핑은 옛 inode 를 계속 쓴다.
set -e
SRC=${1:-$WORK/FEX-mingw/build-ec/Bin/libarm64ecfex.dll}
for t in $RUNTIME_SRC/wine-arm64/lib/wine/aarch64-windows \
         $EMBER_APP/Contents/Resources/WineARM64/lib/wine/aarch64-windows \
         $WORK/wine-ec-install/usr/local/lib/wine/aarch64-windows \
         $BOTTLES/*/drive_c/windows/system32; do
  [ -d "$t" ] || continue
  [ -e "$t/libarm64ecfex.dll" ] || continue
  cp "$SRC" "$t/libarm64ecfex.dll.new" && mv -f "$t/libarm64ecfex.dll.new" "$t/libarm64ecfex.dll" && echo "설치: $t"
done
