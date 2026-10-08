#!/bin/zsh
# Rosetta(CX) 런타임 GStreamer(크로스오버 1.24.4/glib 2.78, x86_64)에 libav 플러그인을 더한다 — WMV/WMA/그 밖의 코덱.
# 크로스오버 묶음에는 libav 가 없어 WMV 컷신이 "지원하지 않는 형식"(0xc00d36bb)이었다. (2026-09-25)
# 결과물: Vendor/gstreamer/lib/{libavcodec.60,libavformat.60,libavfilter.9,libavutil.58,libswscale.7,libswresample.4}.dylib
#         Vendor/gstreamer/lib/gstreamer-1.0/libgstlibav.dylib   (약 7.4MB, LGPL)
set -e
W=$WORK/gstx64; G=$RUNTIME_SRC/gstreamer/lib
export PATH=/opt/homebrew/opt/bison/bin:/opt/homebrew/opt/flex/bin:$PATH
mkdir -p $W/src $W/pc $W/linklibs $W/intlinc; cd $W
[ -x venv/bin/meson ] || { python3 -m venv venv; venv/bin/pip -q install meson; }
cd src
for u in https://ffmpeg.org/releases/ffmpeg-6.1.2.tar.xz https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-1.24.4.tar.xz \
         https://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-1.24.4.tar.xz https://gstreamer.freedesktop.org/src/gst-libav/gst-libav-1.24.4.tar.xz; do
  [ -f $(basename $u) ] || curl -sLO $u; tar xf $(basename $u)
done
# 1) FFmpeg: 디코더만(LGPL). x86 어셈블리는 끔(nasm 없음).
(cd ffmpeg-6.1.2 && ./configure --prefix=$W/prefix --arch=x86_64 --target-os=darwin --enable-cross-compile \
  --cc="clang -arch x86_64 -mmacosx-version-min=10.15" --extra-ldflags="-arch x86_64 -mmacosx-version-min=10.15" \
  --disable-x86asm --disable-programs --disable-doc --disable-static --enable-shared --disable-autodetect --disable-everything \
  --enable-decoder=wmv1,wmv2,wmv3,wmv3image,vc1,vc1image,wmav1,wmav2,wmapro,wmavoice,wmalossless,h264,hevc,aac,aac_latm,mp1,mp2,mp3,mpeg1video,mpeg2video,mpeg4,msmpeg4v1,msmpeg4v2,msmpeg4v3,h263,theora,vorbis,opus,flac,vp8,vp9,cinepak,indeo3,indeo5,adpcm_ms,adpcm_ima_wav,pcm_s16le,mjpeg,bink,binkaudio_dct,binkaudio_rdft \
  --enable-parser=h264,hevc,aac,aac_latm,mpegaudio,mpeg4video,mpegvideo,vc1,vorbis,opus,flac,vp8,vp9 \
  --enable-avfilter --enable-filter=buffer,buffersink,yadif,format,scale --enable-swscale --enable-swresample --install-name-dir='@rpath' \
  && make -j12 && make install)
# 2) pkg-config: glib 헤더는 Homebrew 것, 라이브러리는 크로스오버 묶음(2.78). 2.80+ 기호를 안 쓰게 버전 상한을 건다.
#    libintl 은 크로스오버의 proxy-libintl(g_libintl_*) — intlinc/libintl.h 가 이름을 잇는다(원본은 README §47).
ln -sf $G/libgintl.8.dylib $W/linklibs/libgintl.dylib
# (pc 파일·cross.ini·intlinc/libintl.h 는 README §47 그대로)
# 3) gstreamer·gst-plugins-base(헤더·링크용, 결과물은 안 씀) → gst-libav
# 4) 설치 이름을 @rpath/<이름> 으로, 빌드 prefix rpath 삭제, 플러그인 rpath @loader_path/../, ffmpeg rpath @loader_path, 서명.
echo "단계 3·4 는 README §47 참고"
