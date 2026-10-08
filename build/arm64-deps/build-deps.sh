#!/bin/zsh
# ARM64(FEX) Wine 런타임의 제3자 dylib 를 minos 11.0 으로 소스 빌드한다 (2026-10-01).
# Homebrew 병은 minos 26/27 이라 (1) macOS 26 미만에서 로드 불가 (2) Wine 프로세스 안 xzone malloc 문제(README wine-macos-minos)와 얽힌다.
# 버전은 이전 Homebrew 묶음과 같게 맞췄다(소비자 winegstreamer.so·secur32.so·crypt32.so·dwrite.so·win32u.so·wineusb.so 재빌드 불필요).
#   zsh build-deps.sh [패키지...]   (인자 없으면 전부, 완료 표시 .done-<이름> 이 있으면 건너뜀)
# Homebrew 는 도구(ninja·pkg-config·cmake)로만 쓰고 라이브러리는 절대 끌어오지 않는다: PKG_CONFIG_LIBDIR 를 우리 prefix 로 고정.
set -e
W=$WORK/arm64-deps-min11; P=$W/out; B=$W/build
export HOMEBREW_NO_INSTALL_UPGRADE=1 HOMEBREW_NO_AUTO_UPDATE=1
export MACOSX_DEPLOYMENT_TARGET=11.0
export PATH=$W/venv/bin:/opt/homebrew/opt/bison/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin
export CC="clang -arch arm64" CXX="clang++ -arch arm64" OBJC="clang -arch arm64"
export CFLAGS="-O2 -mmacosx-version-min=11.0" CXXFLAGS="-O2 -mmacosx-version-min=11.0" OBJCFLAGS="-O2 -mmacosx-version-min=11.0"
export CPPFLAGS="-I$P/include" LDFLAGS="-mmacosx-version-min=11.0 -L$P/lib -Wl,-headerpad_max_install_names"
export PKG_CONFIG_LIBDIR=$P/lib/pkgconfig:$W/pc PKG_CONFIG_PATH=
J="nice -n 19 make -j4"; N="nice -n 19 ninja -j4"
AC=(--prefix=$P --enable-shared --disable-static --host=aarch64-apple-darwin --build=aarch64-apple-darwin)
MS=(--prefix=$P --libdir=lib --buildtype=release --default-library=shared -Db_ndebug=if-release)

step() { [ -f $W/.done-$1 ] && { echo "== $1 (건너뜀)"; return 1; }; echo "== $1"; return 0; }
ok() { touch $W/.done-$1; }

want() { [ $# -eq 0 ] || [[ " $ARGS " == *" $1 "* ]]; }
ARGS="$*"
pkgs=(libunistring gettext pcre2 glib orc libpng freetype gmp nettle libtasn1 libidn2 gnutls libusb gstreamer gst-plugins-base gst-plugins-good gst-plugins-bad gst-plugins-ugly gst-libav)

build_libunistring() { cd $B/libunistring-1.4.2 && ./configure $AC --disable-dependency-tracking && ${=J} && make install; }
build_gettext() { cd $B/gettext-1.0/gettext-runtime && ./configure $AC --disable-dependency-tracking --disable-java --disable-csharp \
    --disable-libasprintf --enable-threads=posix --with-included-libintl --without-emacs --without-git --without-cvs --without-xz --disable-silent-rules \
  && ${=J} && make install; }
build_pcre2() { cd $B/pcre2-10.48 && ./configure $AC --disable-dependency-tracking --enable-pcre2-8 --disable-pcre2-16 --disable-pcre2-32 \
    --enable-unicode --disable-jit --disable-pcre2grep-libz --disable-pcre2grep-libbz2 --disable-pcre2test-libedit --disable-pcre2test-libreadline \
  && ${=J} && make install; }
build_glib() { cd $B/glib-2.90.0 && rm -rf _b && meson setup _b $MS -Dtests=false -Dintrospection=disabled -Dman-pages=disabled \
    -Ddocumentation=false -Dsysprof=disabled -Dlibelf=disabled -Dselinux=disabled -Dxattr=false -Dnls=enabled \
    -Dglib_debug=disabled -Dglib_assert=true -Dglib_checks=true -Dgio_module_dir=/var/empty/gio-modules --wrap-mode=nofallback && ${=N} -C _b && rm -rf $W/dd-glib && DESTDIR=$W/dd-glib meson install -C _b && rsync -a $W/dd-glib$P/ $P/; }  # gio_module_dir 는 /var/empty 아래(개발 맥 Homebrew/빌드 prefix 의 GIO 모듈이 Wine 에 섞이지 않게) — DESTDIR 로 설치
build_orc() { cd $B/orc-0.4.44 && rm -rf _b && meson setup _b $MS -Dorc-test=disabled -Dtests=disabled -Dexamples=disabled \
    -Dhotdoc=disabled -Dbenchmarks=disabled -Dtools=enabled && ${=N} -C _b && meson install -C _b; }
build_libpng() { cd $B/libpng-1.6.58 && ./configure $AC --disable-dependency-tracking --disable-tools && ${=J} && make install; }
build_freetype() { cd $B/freetype-2.14.3 && ./configure $AC --with-png=yes --with-zlib=yes --with-bzip2=yes --with-harfbuzz=no \
    --with-brotli=no --enable-freetype-config && ${=J} && make install; }
build_gmp() { cd $B/gmp-6.3.0 && ./configure --prefix=$P --enable-shared --disable-static --with-pic \
    --build=aarch64-apple-darwin$(uname -r) --host=aarch64-apple-darwin$(uname -r) && ${=J} && make install; }
build_nettle() { cd $B/nettle-3.10.2 && ./configure $AC --disable-dependency-tracking --disable-documentation --enable-shared \
    --with-include-path=$P/include --with-lib-path=$P/lib && ${=J} && make install; }
build_libtasn1() { cd $B/libtasn1-4.21.0 && ./configure $AC --disable-dependency-tracking --disable-doc && ${=J} && make install; }
build_libidn2() { cd $B/libidn2-2.3.8 && ./configure $AC --disable-dependency-tracking --disable-doc --disable-nls \
    --with-libunistring-prefix=$P --without-libiconv-prefix && ${=J} && make install; }
build_gnutls() { cd $B/gnutls-3.8.12 && ./configure $AC --disable-dependency-tracking --disable-doc --disable-manpages --disable-tests \
    --disable-tools --disable-cxx --disable-nls --without-p11-kit --without-tpm --without-tpm2 --without-zstd --without-brotli \
    --without-zlib --without-leancrypto --disable-heartbeat-support --with-included-unistring=no --sysconfdir=/etc \
    --disable-guile --disable-silent-rules && ${=J} && make install; }
build_libusb() { cd $B/libusb-1.0.29 && ./configure $AC --disable-dependency-tracking --disable-examples-build --disable-tests-build \
  && ${=J} && make install; }
GSTO=(-Dexamples=disabled -Dtests=disabled -Dnls=enabled -Ddoc=disabled -Dintrospection=disabled)
GOOD=(-Dexamples=disabled -Dtests=disabled -Dnls=enabled -Ddoc=disabled)
UGLY=(-Dtests=disabled -Dnls=enabled -Ddoc=disabled)
build_gstreamer() { cd $B/gstreamer-1.28.7 && rm -rf _b && meson setup _b $MS $GSTO -Dgst_debug=true -Dbenchmarks=disabled \
    -Dtools=enabled -Dcheck=enabled -Dlibunwind=disabled -Dlibdw=disabled -Dbash-completion=disabled -Dptp-helper=disabled \
    --wrap-mode=nofallback && ${=N} -C _b && meson install -C _b; }
build_gst-plugins-base() { cd $B/gst-plugins-base-1.28.7 && rm -rf _b && meson setup _b $MS $GSTO --auto-features=disabled --wrap-mode=nofallback \
    -Dorc=enabled -Dgl=enabled -Dgl_api=opengl -Dgl_platform=cgl -Dgl_winsys=cocoa -Dx11=disabled -Dgl-graphene=disabled -Dgl-png=disabled -Dgl-jpeg=disabled \
    -Dapp=enabled -Daudioconvert=enabled -Daudioresample=enabled -Dplayback=enabled -Dtypefind=enabled -Dvideoconvertscale=enabled \
    -Dtools=disabled \
    && ${=N} -C _b && meson install -C _b; }
build_gst-plugins-good() { cd $B/gst-plugins-good-1.28.7 && rm -rf _b && meson setup _b $MS $GOOD --auto-features=disabled --wrap-mode=nofallback \
    -Dorc=enabled -Disomp4=enabled -Davi=enabled -Dwavparse=enabled -Did3demux=enabled -Ddeinterlace=enabled -Daudioparsers=enabled -Dvideofilter=enabled -Dlaw=enabled \
    && ${=N} -C _b && meson install -C _b; }
build_gst-plugins-bad() { cd $B/gst-plugins-bad-1.28.7 && rm -rf _b && meson setup _b $MS $GSTO --auto-features=disabled --wrap-mode=nofallback \
    -Dorc=enabled -Dvideoparsers=enabled -Dmpegdemux=enabled -Dapplemedia=enabled -Dgl=enabled -Dgpl=disabled -Dadpcmdec=enabled \
    && ${=N} -C _b && meson install -C _b; }
build_gst-plugins-ugly() { cd $B/gst-plugins-ugly-1.28.7 && rm -rf _b && meson setup _b $MS $UGLY --auto-features=disabled --wrap-mode=nofallback \
    -Dgpl=disabled -Dasfdemux=enabled && ${=N} -C _b && meson install -C _b; }
build_gst-libav() { cd $B/gst-libav-1.28.7 && rm -rf _b && \
    PKG_CONFIG_LIBDIR=$P/lib/pkgconfig:$W/pc:$WORK/ffmpeg-lgpl/prefix/lib/pkgconfig \
    meson setup _b $MS -Ddoc=disabled -Dtests=disabled --wrap-mode=nofallback && ${=N} -C _b && meson install -C _b; }

for p in $pkgs; do
  want $p || continue
  step $p || continue
  ( build_$p ) > $W/log-$p.txt 2>&1 || { echo "실패: $p (log-$p.txt)"; tail -30 $W/log-$p.txt; exit 1; }
  ok $p
done
echo 끝
