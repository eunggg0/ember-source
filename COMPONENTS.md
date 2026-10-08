# Components / 구성요소 — Ember 1.0

Every open-source component in Ember.app whose license requires source (LGPL, MPL) is listed here, plus the
modified permissive components whose patches we publish anyway (FEX, DXVK).
The upstream archives are mirrored as assets of the `v1.0` release of this repository; `upstream/SOURCES.tsv`
has the exact URL, size and SHA-256 of every file, and how it was verified (GPG signature or the upstream
checksum file).

LGPL·MPL 처럼 소스 공개 의무가 있는 Ember.app 의 오픈소스 구성요소 전부와, 의무는 없지만 Ember 가 고쳐서 패치를 함께 공개하는
구성요소(FEX, DXVK)입니다. 원본 압축 파일은 이 저장소 `v1.0` 릴리스에 그대로 올려 두었습니다.

## 1. Components Ember modified (source + patches)

| Component | Version / base | In Ember.app | License | Upstream archive (mirrored) | SHA-256 | Ember patches |
|---|---|---|---|---|---|---|
| Wine (WineCX, Rosetta engine) | CrossOver 26.3.0 FOSS source, `sources/wine` (Wine 11.0 + CodeWeavers changes) | `Resources/WineCX` | LGPL-2.1-or-later | https://media.codeweavers.com/pub/crossover/source/crossover-sources-26.3.0.tar.gz | `ac99c8ca4b3848f3e81784135f023df266b61c2345726ea55a50b3e030dd6872` | `patches/wine-cx` — 74 patches, 221 files (11 new) |
| DXVK (CrossOver copy) | 1.10.3, same archive `sources/dxvk` | `Resources/Renderers/dxvk` | zlib | (same archive) | (same) | `patches/dxvk-cx` — 6 patches, 33 files |
| Wine (WineARM64, FEX engine) | Wine 11.18 | `Resources/WineARM64` | LGPL-2.1-or-later | https://dl.winehq.org/wine/source/11.x/wine-11.18.tar.xz | `c6282f6d4daecf11f3ab9f9a2b6c598f67be7e28c363ba2cae8a3c44b611e7a4` | `patches/wine-arm64` — 34 patches, 99 files (4 new) |
| Wine (x86_64, built-in 11.0 + `Renderers/stock`) | Wine 11.0 | `Resources/Wine`, `Resources/Renderers/stock` | LGPL-2.1-or-later | https://dl.winehq.org/wine/source/11.0/wine-11.0.tar.xz | `c07a6857933c1fc60dff5448d79f39c92481c1e9db5aa628db9d0358446e0701` | `patches/wine-x64` — 12 patches, 34 files (1 new) |
| DXMT — d3d11 / d3d10core | 3Shain/dxmt `7c8dee1` (+ submodules nvapi `d08488f`, directx headers `9df86f2`) | `Resources/Renderers/dxmt*` | LGPL-2.1-or-later | git https://github.com/3Shain/dxmt @ 7c8dee1c2d73 → `dxmt-7c8dee1-with-submodules.tar.xz` | `2118ca72c6592cfce8378cf5e671b92321751f588deba33e9368a215c78e57ac` | `patches/dxmt-d3d11` — 7 patches, 93 files |
| DXMT — dxgi | same | `Resources/Renderers/dxmt*` | LGPL-2.1-or-later | same | same | `patches/dxmt-dxgi` — 7 patches, 93 files |
| DXMT — d3d12 | same | `Resources/Renderers/dxmt*` | LGPL-2.1-or-later | same | same | `patches/dxmt-d3d12` — 7 patches, 94 files |
| DXMT — winemetal (.so + PE) | same | `Resources/Wine*/lib/wine/*/winemetal.*` | LGPL-2.1-or-later | same | same | `patches/dxmt-winemetal` — 7 patches, 93 files |
| LLVM (statically linked into DXMT airconv / winemetal) | 15.0.7, unmodified | inside `winemetal.so` | Apache-2.0 WITH LLVM-exception | https://github.com/llvm/llvm-project/releases/download/llvmorg-15.0.7/llvm-project-15.0.7.src.tar.xz | `8b5fcb24b4128cf04df1b0b9410ce8b1a729cb3c544e6da885d234280dedeac6` | — |
| FEX (ARM64EC / WoW64 DLLs) | FEX-Emu/FEX `48d7175` | `Resources/WineARM64/lib/wine/aarch64-*/lib{arm64ec,wow64}fex.*` | MIT | git https://github.com/FEX-Emu/FEX @ 48d7175 → `FEX-48d7175-with-submodules.tar.xz` (test-binary submodules left out) | `02130743e68c9fdece5575636391ad3079a9c1384d72d403ee50482b22f37f3e` | `patches/fex` — 5 patches, 61 files |
| ForgePlay-derived Wine changes (7) | ForgePlay 1.3 bundled Wine 11.12 patches | inside WineCX / WineARM64 / Wine (see `patches/forgeplay-origin/NOTICE.md`) | LGPL-2.1-or-later | originals in `patches/forgeplay-origin/` | — | already contained in the Wine series above |

## 2. Unmodified LGPL / MPL components (source mirrored)

### 2.1 Rosetta engine (x86_64) — `Resources/GStreamer`, `Resources/Wine/lib`, `Resources/WineCX/lib`

| Component | Version | Origin of the binary | License | Upstream archive | SHA-256 |
|---|---|---|---|---|---|
| GStreamer core / base / good / bad / ugly (CrossOver build) | 1.24.4 | copied from CrossOver 26.3 | LGPL-2.1-or-later | CrossOver archive `sources/gstreamer` (above) | (CrossOver archive) |
| GLib / GObject / GIO / GModule | 2.78.0 | copied from CrossOver 26.3 | LGPL-2.1-or-later | CrossOver archive `sources/glib` | (CrossOver archive) |
| proxy-libintl (`libgintl.8.dylib`) | 0.4 (meson wrap of the CrossOver GStreamer/GLib build) | copied from CrossOver 26.3 | LGPL-2.1 | https://github.com/frida/proxy-libintl/archive/refs/tags/0.4.tar.gz | `13ef3eea0a3bc0df55293be368dfbcff5a8dd5f4759280f28e030d1494a5dffb` |
| GStreamer adpcmdec / alaw / mulaw / gst-libav plugins | 1.24.4 | built by Ember, unmodified (`build/gstreamer/gst-plugins-x64-parity.sh`, `gst-libav-x64.sh`) | LGPL-2.1-or-later | https://gstreamer.freedesktop.org/src/ (gstreamer, gst-plugins-base/good/bad, gst-libav 1.24.4) | see `upstream/SOURCES.tsv` |
| FFmpeg (LGPL configuration) | 6.1.2 | built by Ember, unmodified (`build/ffmpeg/ffmpeg-x64-lgpl.sh`) | LGPL-2.1-or-later | https://ffmpeg.org/releases/ffmpeg-6.1.2.tar.xz | `3b624649725ecdc565c903ca6643d41f33bd49239922e45c9b1442c63dca4e38` |
| GnuTLS | 3.8.7 (MacPorts `gnutls-devel` 3.8.7.1 tarball, reports 3.8.7) | Gcenx "Wine Stable 11.0_1" (MacPorts build) | LGPL-2.1-or-later | https://www.gnupg.org/ftp/gcrypt/gnutls/v3.8/gnutls-3.8.7.1.tar.xz (+ 3.8.7) | `9ca0ddaccce28a74fa18d738744190afb3b0daebef74e6ad686bf7bef99abd60` |
| Nettle / Hogweed | 3.10 | Gcenx / MacPorts | LGPL-3.0-or-later (or GPL-2.0-or-later) | https://ftp.gnu.org/gnu/nettle/nettle-3.10.tar.gz | `b4c518adb174e484cb4acea54118f02380c7133771e7e9beb98a0787194ee47c` |
| GMP | 6.3.0 | Gcenx / MacPorts | LGPL-3.0-or-later (or GPL-2.0-or-later) | https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz | `a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898` |
| libtasn1 | 4.20.0 | Gcenx / MacPorts | LGPL-2.1-or-later | https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.20.0.tar.gz | `92e0e3bd4c02d4aeee76036b2ddd83f0c732ba4cda5cb71d583272b23587a76c` |
| libidn2 | 2.3.7 | Gcenx / MacPorts | LGPL-3.0-or-later (or GPL-2.0-or-later) | https://ftp.gnu.org/gnu/libidn/libidn2-2.3.7.tar.gz | `4c21a791b610b9519b9d0e12b8097bf2f359b12f8dd92647611a929e6bfd7d64` |
| libunistring | 1.3 | Gcenx / MacPorts | LGPL-3.0-or-later (or GPL-2.0-or-later) | https://ftp.gnu.org/gnu/libunistring/libunistring-1.3.tar.xz | `f245786c831d25150f3dfb4317cda1acc5e3f79a5da4ad073ddca58886569527` |
| gettext libintl | 0.22.5 | Gcenx / MacPorts | LGPL-2.1-or-later | https://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.xz | `fe10c37353213d78a5b83d48af231e005c4da84db5ce88037d88355938259640` |
| libiconv / libcharset | 1.17 (+ MacPorts `utf8mac` patch) | Gcenx / MacPorts | LGPL-2.1-or-later | https://ftp.gnu.org/gnu/libiconv/libiconv-1.17.tar.gz | `8f74213b56238c85a50a5329f77e06198771e70dd9a739779f4c02f65d971313` |

The MacPorts port definitions and patches for the Gcenx libraries are in `macports/ports/` (snapshot commits in
`macports/REFS.txt`). FreeType 2.13.3 (FTL) for both x86_64 Wines is built by Ember (`build/arm64-deps/freetype-x64-min1015.sh`)
and its archive is mirrored too.

### 2.2 FEX engine (arm64) — `Resources/WineARM64/lib` (all built by Ember from these archives, unmodified; `build/arm64-deps/build-deps.sh`)

| Component | Version | License | Upstream archive | SHA-256 |
|---|---|---|---|---|
| FFmpeg (LGPL configuration, `--disable-autodetect`, no GPL / nonfree) | 9.0.2 | LGPL-2.1-or-later | https://ffmpeg.org/releases/ffmpeg-9.0.2.tar.xz | `8c3850283eb25fa026482078a04051e0be17347b09ef81a0849bec15a96e002e` |
| dav1d (static, inside libavcodec) | 1.5.4 | BSD-2-Clause | https://downloads.videolan.org/pub/videolan/dav1d/1.5.4/dav1d-1.5.4.tar.xz | `686616b7c69eb88d44459391ab25cac13b6647a3b288835c5784e71c1514a5c5` |
| GStreamer core, plugins-base/good/bad/ugly (`-Dgpl=disabled`), gst-libav | 1.28.7 | LGPL-2.1-or-later | https://gstreamer.freedesktop.org/src/ | see `upstream/SOURCES.tsv` |
| GLib / GObject / GIO / GModule | 2.90.0 | LGPL-2.1-or-later | https://download.gnome.org/sources/glib/2.90/glib-2.90.0.tar.xz | `17d15cac2af80a33271127408e0abc2748eb297c595c2a26409e81e14e7d1b8f` |
| GnuTLS (`--without-p11-kit --disable-nls`) | 3.8.12 | LGPL-2.1-or-later | https://www.gnupg.org/ftp/gcrypt/gnutls/v3.8/gnutls-3.8.12.tar.xz | `a7b341421bfd459acf7a374ca4af3b9e06608dcd7bd792b2bf470bea012b8e51` |
| Nettle / Hogweed | 3.10.2 | LGPL-3.0-or-later (or GPL-2.0-or-later) | https://ftp.gnu.org/gnu/nettle/nettle-3.10.2.tar.gz | `fe9ff51cb1f2abb5e65a6b8c10a92da0ab5ab6eaf26e7fc2b675c45f1fb519b5` |
| GMP | 6.3.0 | LGPL-3.0-or-later (or GPL-2.0-or-later) | https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz | `a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898` |
| libtasn1 | 4.21.0 | LGPL-2.1-or-later | https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.21.0.tar.gz | `1d8a444a223cc5464240777346e125de51d8e6abf0b8bac742ac84609167dc87` |
| libidn2 | 2.3.8 | LGPL-3.0-or-later (or GPL-2.0-or-later) | https://ftp.gnu.org/gnu/libidn/libidn2-2.3.8.tar.gz | `f557911bf6171621e1f72ff35f5b1825bb35b52ed45325dcdee931e5d3c0787a` |
| libunistring | 1.4.2 | LGPL-3.0-or-later (or GPL-2.0-or-later) | https://ftp.gnu.org/gnu/libunistring/libunistring-1.4.2.tar.xz | `5b46e74377ed7409c5b75e7a96f95377b095623b689d8522620927964a41499c` |
| gettext libintl | 1.0 | LGPL-2.1-or-later | https://ftp.gnu.org/gnu/gettext/gettext-1.0.tar.xz | `71132a3fb71e68245b8f2ac4e9e97137d3e5c02f415636eb508ae607bc01add7` |
| libusb | 1.0.29 | LGPL-2.1-or-later | https://github.com/libusb/libusb/releases/download/v1.0.29/libusb-1.0.29.tar.bz2 | `5977fc950f8d1395ccea9bd48c06b3f808fd3c2c961b44b0c2e6e29fc3a70a85` |
| FreeType · libpng · PCRE2 · ORC (permissive, mirrored for a complete rebuild) | 2.14.3 · 1.6.58 · 10.48 · 0.4.44 | FTL · libpng-2.0 · BSD-3 · BSD-2 | see `upstream/SOURCES.tsv` | |

### 2.3 Wine add-ons (all engines)

| Component | Version | License | Upstream archive | SHA-256 |
|---|---|---|---|---|
| wine-gecko | 2.47.4 (x86, x86_64) | MPL-2.0 (+ others) | https://dl.winehq.org/wine/wine-gecko/2.47.4/wine-gecko-2.47.4-src.tar.xz | `bf31b6619570ce289f07298bdd670081635cd12104010050f06c16e44ccd153f` |
| wine-mono (WineCX) | 10.4.1 | MIT and per-component (LGPL, MS-PL, …) | https://dl.winehq.org/wine/wine-mono/10.4.1/wine-mono-10.4.1-src.tar.xz | `128e335396689e466dff5e1aa0770a714dbe3d16397fc4ddbb8a80999c67323b` |
| wine-mono (WineARM64) | 11.3.0 | MIT and per-component | https://dl.winehq.org/wine/wine-mono/11.3.0/wine-mono-11.3.0-src.tar.xz | `9f4f03285fbeed484980efbb1eba1c19069244aea401d2ff1585e3990782edf7` |

## 3. Not included here

- Ember's own software (the Ember app, EmberCore libraries `libEmberFG/HUD/GM/Up/Tone`, models, artwork) — proprietary,
  separate libraries that are loaded at run time; not derived from the LGPL components.
- Apple D3DMetal and Metal Shader Converter libraries — not shipped; the user installs them from Apple.
- Permissive components with notice-only duties (MoltenVK, SDL2, ICU, libxml2, zlib, Sparkle, llama.cpp, …) — notices are in
  Ember › Settings › Licenses and on the website's license page.
