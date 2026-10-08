#!/bin/zsh
# Rosetta(CX) 런타임용 추가 GStreamer 플러그인(x86_64, 1.24.4 = 크로스오버 묶음과 같은 판) — README §71 의 mpegpsdemux 와 같은 교차 빌드.
#  - gst-plugins-bad: adpcmdec   - gst-plugins-good: law(alaw/mulaw)
# 별도 빌드 폴더(build-parity), 결과는 STAGE. 설치 이름 @rpath, rpath @loader_path/../ 로 고친 뒤 서명.
set -e
W=$WORK/gstx64; STAGE=$WORK/parity-avi/x64-stage
export PATH=/opt/homebrew/opt/bison/bin:/opt/homebrew/opt/flex/bin:$W/venv/bin:$PATH
M=$W/venv/bin/meson
rm -rf $STAGE; mkdir -p $STAGE
cd $W/src
[ -d gst-plugins-good-1.24.4 ] || { [ -f gst-plugins-good-1.24.4.tar.xz ] || curl -sLO https://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-1.24.4.tar.xz; tar xf gst-plugins-good-1.24.4.tar.xz; }
cd $W/src/gst-plugins-bad-1.24.4 && rm -rf build-parity && $M setup build-parity -Dprefix=$W/prefix -Dauto_features=disabled -Dadpcmdec=enabled \
   -Ddoc=disabled -Dtests=disabled -Dexamples=disabled -Dgpl=disabled -Dnls=disabled --cross-file=$W/cross.ini && nice -n 19 ninja -C build-parity
cp build-parity/gst/adpcmdec/libgstadpcmdec.dylib $STAGE/
cd $W/src/gst-plugins-good-1.24.4 && rm -rf build-parity && $M setup build-parity -Dprefix=$W/prefix -Dauto_features=disabled -Dlaw=enabled \
   -Ddoc=disabled -Dtests=disabled -Dexamples=disabled -Dnls=disabled --cross-file=$W/cross.ini && nice -n 19 ninja -C build-parity
cp build-parity/gst/law/libgstalaw.dylib build-parity/gst/law/libgstmulaw.dylib $STAGE/
ls -la $STAGE
