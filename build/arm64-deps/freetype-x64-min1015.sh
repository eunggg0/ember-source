#!/bin/zsh
# x86_64 Wine/WineCX 런타임의 FreeType 2.13.3 — 예전 빌드(.refs/deps-x64)가 minos 27 이라 같은 구성으로 minos 10.15 다시 빌드 (2026-10-01).
# 구성: zlib(시스템)만, bzip2/png/harfbuzz/brotli 없음 — 이전과 같음(내보내는 기호 동일 확인). 결과는 @rpath/libfreetype.6.dylib, ad-hoc 서명.
set -e
W=$WORK/arm64-deps-min11; mkdir -p $W/build-x64 $W/out-x64 $W/stage-x64; cd $W/build-x64
tar xf $WORK/deps-x64/freetype.tar.xz; cd freetype-2.13.3
export MACOSX_DEPLOYMENT_TARGET=10.15 PKG_CONFIG_LIBDIR=$W/pc PKG_CONFIG_PATH=
./configure --host=x86_64-apple-darwin --prefix=$W/out-x64 --enable-shared --disable-static --without-harfbuzz --without-brotli \
  --without-bzip2 --without-png 'CC=clang -arch x86_64' CFLAGS="-g -O2 -mmacosx-version-min=10.15" \
  LDFLAGS="-mmacosx-version-min=10.15 -Wl,-headerpad_max_install_names"
nice -n 19 make -j4 && make install
cp $W/out-x64/lib/libfreetype.6.dylib $W/stage-x64/; cd $W/stage-x64; chmod 755 libfreetype.6.dylib; strip -x libfreetype.6.dylib
install_name_tool -id @rpath/libfreetype.6.dylib libfreetype.6.dylib; codesign -fs - libfreetype.6.dylib
# 배포: 각 x64 런타임 lib/ 의 libfreetype.6.dylib 와 libfreetype.dylib(같은 파일 두 벌) — .refs/arm64-deps-min11/deploy.sh
