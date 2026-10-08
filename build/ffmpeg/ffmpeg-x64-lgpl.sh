#!/bin/zsh
# Rosetta(CX) GStreamer 묶음의 FFmpeg 6.1.2(LGPL, 디코더만)를 옛 게임 AVI 코덱을 더해 다시 빌드(2026-10-02 parity-avi).
# 기존 배포본 구성(--disable-everything + 디코더 목록) 그대로 + 추가분, zlib(시스템 libz) 켬(ZMBV·TSCC·LCL/ZLIB 가 필요).
# 원본 트리(.refs/gstx64/src/ffmpeg-6.1.2)는 in-tree 구성이라 새로 풀어 따로 빌드한다. 결과: $PFX/lib
set -e
W=$WORK/gstx64; S=$W/src/ffmpeg-6.1.2-parity; PFX=$W/prefix-parity
[ -d $S ] || { mkdir -p $S && tar xf $W/src/ffmpeg-6.1.2.tar.xz -C $S --strip-components=1; }
OLD='wmv1,wmv2,wmv3,wmv3image,vc1,vc1image,wmav1,wmav2,wmapro,wmavoice,wmalossless,h264,hevc,aac,aac_latm,mp1,mp2,mp3,mp1float,mp2float,mp3float,mpeg1video,mpeg2video,mpeg4,msmpeg4v1,msmpeg4v2,msmpeg4v3,h263,h263p,theora,vorbis,opus,flac,vp8,vp9,cinepak,indeo2,indeo3,indeo4,indeo5,adpcm_ms,adpcm_ima_wav,adpcm_ima_qt,adpcm_ima_dk3,adpcm_ima_dk4,adpcm_yamaha,adpcm_ct,pcm_s16le,pcm_u8,pcm_s24le,pcm_f32le,pcm_alaw,pcm_mulaw,gsm_ms,truespeech,mjpeg,mjpegb,bink,binkaudio_dct,binkaudio_rdft,smacker,smackaud,msvideo1,msrle,huffyuv,rawvideo,qtrle,svq1,svq3,vp6,vp6a,vp6f,flv,truemotion1,truemotion2,tscc,cscd,zmbv,fraps,ulti,aura,asv1,roq,roq_dpcm,interplay_video,interplay_dpcm,vqa,ws_snd1,xan_wc3,xan_dpcm,vmdvideo,vmdaudio,idcin,thp,eacmv,dsicinvideo'
# 추가: Intel H.263(I263)·Indeo 오디오(IMC/IAC)·AC-3·LCL(MSZH/ZLIB)·8BPS·AASC·CYUV·VCR1·DV·VP5·QPEG·H.261·KMVC·FFVHuff·WNV1·TSCC2·MSS1/2·G.726·DSICIN 오디오
NEW='h263i,imc,iac,ac3,ac3_fixed,eac3,mszh,zlib,8bps,aasc,cyuv,vcr1,dvvideo,vp5,qpeg,h261,kmvc,ffvhuff,wnv1,tscc2,mss1,mss2,adpcm_g726,dsicinaudio,msa1,mts2,cllc,vp7,wmv3image'
cd $S
./configure --prefix=$PFX --arch=x86_64 --target-os=darwin --enable-cross-compile \
  --cc='clang -arch x86_64 -mmacosx-version-min=10.15' --cxx='clang++ -arch x86_64' --extra-ldflags='-arch x86_64 -mmacosx-version-min=10.15' \
  --disable-x86asm --disable-programs --disable-doc --disable-static --enable-shared --disable-autodetect --disable-everything \
  --enable-zlib \
  --enable-decoder="$OLD,$NEW" \
  --enable-parser='h264,hevc,aac,aac_latm,mpegaudio,mpeg4video,mpegvideo,vc1,vorbis,opus,flac,vp8,vp9,h263,mjpeg,ac3,h261,dvdsub' \
  --enable-avfilter --enable-filter='buffer,buffersink,yadif,format,scale' --enable-swscale --enable-swresample --install-name-dir='@rpath'
nice -n 19 make -j6 && make install
grep -o 'LGPL version[^"]*' $PFX/lib/pkgconfig/libavcodec.pc 2>/dev/null; grep -c . /dev/null
