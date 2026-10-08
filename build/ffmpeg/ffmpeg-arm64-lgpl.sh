#!/bin/zsh
# ARM64(FEX) 런타임용 FFmpeg 9.0.2 — LGPL-2.1+ 구성(--enable-gpl/--enable-nonfree/x264/x265/openssl 없음). 2026-10-01
# Homebrew ffmpeg 9.0.2(GPLv3 구성)를 대체한다. 소비자: lib/gstreamer-1.0/libgstlibav.dylib(gst-libav 1.28.7),
# lib/wine/aarch64-unix/winedmo.so(Wine 11.18). 같은 메이저(avcodec 63/avformat 63/avfilter 12/avutil 61/swscale 10/swresample 7)라
# 소비자 재빌드 없이 파일만 바꾼다. AV1 은 dav1d 1.5.4(BSD-2) 정적 링크, H.264/HEVC/VP9/AV1/MPEG 은 VideoToolbox hwaccel.
# 결과: <런타임>/lib/lib{avcodec.63,avformat.63,avfilter.12,avutil.61,swresample.7,swscale.10}.1.102.dylib + 소네임 심볼릭 링크.
#  - minos 11.0 (호스트 기본 minos 27 금지 — README "wine-macos-minos")
#  - 설치 이름 @rpath/<파일>, 서로는 @loader_path/<파일>, LC_RPATH 없음, ad-hoc 서명
set -e
W=$WORK/ffmpeg-lgpl; mkdir -p $W/src; cd $W/src
[ -f ffmpeg-9.0.2.tar.xz ] || curl -sSLO https://ffmpeg.org/releases/ffmpeg-9.0.2.tar.xz       # sha256 8c3850283eb25fa026482078a04051e0be17347b09ef81a0849bec15a96e002e
[ -f dav1d-1.5.4.tar.xz ]  || curl -sSLO https://downloads.videolan.org/pub/videolan/dav1d/1.5.4/dav1d-1.5.4.tar.xz  # sha256 686616b7c69eb88d44459391ab25cac13b6647a3b288835c5784e71c1514a5c5
tar xf ffmpeg-9.0.2.tar.xz; tar xf dav1d-1.5.4.tar.xz
export MACOSX_DEPLOYMENT_TARGET=11.0
# 1) dav1d 정적 (meson 은 .refs/gstx64/venv 것)
(cd dav1d-1.5.4 && CFLAGS=-mmacosx-version-min=11.0 LDFLAGS=-mmacosx-version-min=11.0 \
  meson setup build --prefix=$W/dav1d-prefix --default-library=static --buildtype=release \
  -Denable_tools=false -Denable_tests=false -Denable_examples=false && ninja -C build install)
# 2) FFmpeg — --disable-autodetect 로 Homebrew 라이브러리(openssl·x264·…)를 절대 끌어오지 않게 하고 필요한 것만 켠다
export PKG_CONFIG_LIBDIR=$W/dav1d-prefix/lib/pkgconfig PKG_CONFIG_PATH=
(cd ffmpeg-9.0.2 && ./configure --prefix=$W/prefix \
  --cc="clang -arch arm64 -mmacosx-version-min=11.0" --extra-ldflags="-arch arm64 -mmacosx-version-min=11.0" --extra-libs=-liconv \
  --enable-shared --disable-static --disable-doc --disable-avdevice --disable-autodetect \
  --enable-pthreads --enable-zlib --enable-bzlib --enable-iconv --enable-videotoolbox --enable-audiotoolbox \
  --enable-libdav1d --install-name-dir='@rpath' --extra-version=Ember-LGPL \
  && nice -n 19 make -j4 && make install)
# 3) 이름 정리·서명 → stage
ST=$W/stage; rm -rf $ST; mkdir -p $ST; cd $W/prefix/lib
for f in lib*.*.*.*.dylib; do cp $f $ST/; done; cd $ST; chmod 755 *.dylib
for f in *.dylib; do
  args=(-id @rpath/$f)
  for ref in $(otool -L $f | tail -n +2 | awk '{print $1}' | grep '^@rpath/'); do
    short=${ref#@rpath/}; base=${short%%.*}; full=$(ls ${base}.*.*.*.dylib)
    [ "$full" = "$f" ] && continue
    args+=(-change $ref @loader_path/$full)
  done
  strip -x $f; install_name_tool "${args[@]}" $f; codesign -f -s - $f
done
# 4) 배포는 .refs/ffmpeg-lgpl/deploy.sh (Vendor/wine-arm64/lib + 앱 WineARM64/lib, .new+mv, 백업 Vendor/.bak-20261001-ffmpeglgpl)
#    소네임 링크: libavcodec.63.dylib → libavcodec.63.1.102.dylib 등(winedmo.so 가 짧은 이름을 참조).
#    확인: avcodec_license() == "LGPL version 2.1 or later", otool -L 에 x264/x265/openssl 없음.
