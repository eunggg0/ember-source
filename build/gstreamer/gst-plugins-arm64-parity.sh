#!/bin/zsh
# ARM64(FEX) 런타임용 추가 GStreamer 플러그인을 1.28.7 소스(.refs/arm64-deps-min11/build)에서 따로 빌드(minos 11.0, 공유 _b 는 안 건드림).
#  - gst-plugins-bad: adpcmdec (MS/IMA ADPCM — gst-libav avdec_adpcm_ima_wav 는 bits_per_coded_sample 이 없어 열기 실패)
#  - gst-plugins-good: law (A-law/μ-law; gst-libav 는 PCM 계열을 등록 안 함)
# 결과: $OUT/lib/gstreamer-1.0/*.dylib (DESTDIR 스테이지)
set -e
W=$WORK/arm64-deps-min11; P=$W/out; B=$W/build; OUT=$WORK/parity-avi/arm64-stage
export HOMEBREW_NO_INSTALL_UPGRADE=1 HOMEBREW_NO_AUTO_UPDATE=1 MACOSX_DEPLOYMENT_TARGET=11.0
export PATH=$W/venv/bin:/opt/homebrew/opt/bison/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin
export CC="clang -arch arm64" CXX="clang++ -arch arm64" OBJC="clang -arch arm64"
export CFLAGS="-O2 -mmacosx-version-min=11.0" CXXFLAGS="-O2 -mmacosx-version-min=11.0" OBJCFLAGS="-O2 -mmacosx-version-min=11.0"
export CPPFLAGS="-I$P/include" LDFLAGS="-mmacosx-version-min=11.0 -L$P/lib -Wl,-headerpad_max_install_names"
export PKG_CONFIG_LIBDIR=$P/lib/pkgconfig:$W/pc PKG_CONFIG_PATH=
MS=(--prefix=$P --libdir=lib --buildtype=release --default-library=shared -Db_ndebug=if-release)
GSTO=(-Dexamples=disabled -Dtests=disabled -Dnls=enabled -Ddoc=disabled -Dintrospection=disabled)
GOOD=(-Dexamples=disabled -Dtests=disabled -Dnls=enabled -Ddoc=disabled)
rm -rf $OUT
cd $B/gst-plugins-bad-1.28.7 && rm -rf _b-parity && meson setup _b-parity $MS $GSTO --auto-features=disabled --wrap-mode=nofallback -Dadpcmdec=enabled -Dgpl=disabled \
  && nice -n 19 ninja -C _b-parity && DESTDIR=$OUT meson install -C _b-parity --no-rebuild
cd $B/gst-plugins-good-1.28.7 && rm -rf _b-parity && meson setup _b-parity $MS $GOOD --auto-features=disabled --wrap-mode=nofallback -Dlaw=enabled \
  && nice -n 19 ninja -C _b-parity && DESTDIR=$OUT meson install -C _b-parity --no-rebuild
find $OUT -name '*.dylib' -path '*gstreamer-1.0*'
