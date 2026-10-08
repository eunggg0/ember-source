#!/bin/zsh
# ARM64 런타임의 GPL FFmpeg(Homebrew 9.0.2 + x264/x265 …) → LGPL FFmpeg 9.0.2(직접 빌드) 교체. 2026-10-01
set -e
ST=$WORK/ffmpeg-lgpl/stage
BK=$RUNTIME_SRC/.bak-20261001-ffmpeglgpl
NEW=(libavcodec.63.1.102 libavformat.63.1.102 libavfilter.12.1.102 libavutil.61.1.102 libswresample.7.1.102 libswscale.10.1.102)
LINKS=(libavcodec.63:libavcodec.63.1.102 libavformat.63:libavformat.63.1.102 libavutil.61:libavutil.61.1.102
       libswresample.7:libswresample.7.1.102 libavfilter.12:libavfilter.12.1.102 libswscale.10:libswscale.10.1.102)
GONE=(libx264.165 libx265.217 libSvtAv1Enc.4 libSvtAv1Enc.4.2.0 libvmaf.3 libssl.3 libcrypto.3 libdav1d.7 libmp3lame.0 libopus.0 libvpx.12 liblzma.5)
if ps -axo command | grep -E '(WineARM64|wine-arm64)/' | grep -v grep >/dev/null; then echo "FEX Wine 실행 중 — 중단"; exit 1; fi
for pair in vendor:$RUNTIME_SRC/wine-arm64/lib app:$EMBER_APP/Contents/Resources/WineARM64/lib; do
  tag=${pair%%:*}; L=${pair#*:}
  mkdir -p $BK/$tag
  for n in $NEW ${LINKS%%:*} $GONE; do [ -e $L/$n.dylib -o -L $L/$n.dylib ] && [ ! -e $BK/$tag/$n.dylib ] && cp -a $L/$n.dylib $BK/$tag/; done
  for n in $NEW; do cp $ST/$n.dylib $L/$n.dylib.new; chmod 755 $L/$n.dylib.new; mv -f $L/$n.dylib.new $L/$n.dylib; done
  for p in $LINKS; do ln -sfn ${p#*:}.dylib $L/${p%%:*}.dylib.new; mv -f $L/${p%%:*}.dylib.new $L/${p%%:*}.dylib; done
  for n in $GONE; do rm -f $L/$n.dylib; done
  echo "$tag 완료: $L"
done
