# Ember 1.0.1.3 — corresponding source for LGPL components / LGPL 구성요소 대응 소스

This package contains the source changes for the GPL- and LGPL-licensed components bundled in Ember 1.0.1.3
(Wine runtimes and their GLib/libusb libraries, DXMT, and the Windows virtual machine components: QEMU, GLib and the VM renderer libraries). Each component is provided as *upstream source + Ember patch series*.
`BINARIES.tsv` maps listed app binaries to their MD5 and corresponding source series.

이 묶음은 Ember 1.0.1.3에 들어 있는 GPL·LGPL 구성요소(Wine 런타임 3종과 그 GLib·libusb 라이브러리, DXMT, 가상 머신 구성요소인 QEMU·GLib·VM 렌더러 라이브러리)의 소스 변경분입니다.
각 구성요소는 *업스트림 원본 소스 + Ember 패치 series* 로 제공됩니다. `BINARIES.tsv`에는 목록에 등재한 바이너리의 MD5와 대응 소스 series를 적었습니다.

Source for Ember 1.0 is kept at the [v1.0 tag](https://github.com/eunggg0/ember-source/tree/v1.0). / Ember 1.0 의 소스는 [v1.0 태그](https://github.com/eunggg0/ember-source/tree/v1.0)에 있습니다.
Questions about this source: realnoma@naver.com / 소스 문의: realnoma@naver.com

## Series / 패치 묶음

| Series | Upstream base | Binaries in Ember.app |
|---|---|---|
| `patches/wine-cx` | CrossOver 26.3.0 FOSS source, `sources/wine` | `Resources/WineCX` (Wine modules, `wine`, `wineserver`) |
| `patches/wine-x64` | Wine 11.0 | `Resources/Wine`, `Resources/Renderers/stock` |
| `patches/wine-arm64` | Wine 11.18 | `Resources/WineARM64` |
| `patches/dxmt-d3d12` | 3Shain/dxmt `7c8dee1` (+ submodules) | `Renderers/dxmt/x86_64-windows/d3d12.dll`, `Renderers/dxmt-arm64ec/d3d12.dll`, `WineARM64/…/aarch64-unix/winemetal.so` |
| `patches/dxmt-winemetal-cx` | same | `WineCX/…/x86_64-unix/winemetal.so` |
| `patches/dxmt-d3d11` | same | `Renderers/dxmt/x86_64-windows/d3d11.dll`, `Renderers/dxmt-arm64ec/d3d11.dll` |
| `patches/dxmt-d3d11-i386` | same | `Renderers/dxmt/i386-windows/d3d11.dll` |
| `patches/dxmt-dxgi` + `patches/dxmt-dxgi-release` | same | `dxgi.dll` (x86_64, i386, arm64ec) |
| `patches/dxmt-winemetal-pe` | same | `winemetal.dll` (x86_64, i386, arm64ec) |
| `patches/dxmt-winemetal-wine11` | same | `Wine/…/x86_64-unix/winemetal.so` |
| `patches/dxmt-nvext-d3d10core` | same | `Renderers/dxmt-nvext/*` (`nvapi64.dll`, `nvngx.dll`), `d3d10core.dll` |
| `patches/vm-qemu` | utmapp/qemu `v10.0.12-utm` release tarball (+ dtc subproject `b6910bec`) | `VM/host/vmaudio-1031/out/qemu-system-aarch64-*`, `VM/host/vmaudio-1031/share/qemu/*` (unmodified) |
| `patches/vm-qemu-img` | QEMU 11.1.2 | `VM/host/vm-1025/qemu/prefix/bin/qemu-img` |
| `patches/vm-dxmt-native` | utmapp/dxmt `66e27f37` | `VM/host/vmdxp-1031/stage2/lib/libdxmt-native.dylib` |
| `patches/vm-dxmt-d3d12` | 3Shain/dxmt `7c8dee1` (+ submodules) | `VM/host/vmd12fix-1105/out5/libember-d3d12-native.dylib` |
| `patches/vm-glib` | GLib 2.90.0 | `VM/host/vmdist-1025/prefix/lib/libglib-2.0.0.dylib`, `libgio`, `libgobject`, `libgmodule` |
| `patches/arm64-glib` | GLib 2.90.0 | `WineARM64/lib/libglib-2.0.0.dylib`, `WineARM64/lib/libgio-2.0.0.dylib` (build: `build/arm64-libs/BUILD.txt`) |
| `patches/forgeplay-origin/NOTICE.md` | — | attribution for Wine changes that originate from ForgePlay (already contained in the Wine series) |

Each series folder has `series` (apply order) and `FILES.txt` (changed files; `A` = new file, `M` = modified).

## v1.0.1.3

Ember 1.0.1.3 changes three libraries of the WineARM64 runtime. `libglib-2.0.0.dylib` and `libgio-2.0.0.dylib` are GLib 2.90.0
with `patches/arm64-glib`; `libusb-1.0.0.dylib` is unmodified libusb 1.0.29 built with `ac_cv_func_pipe2=no`.
The build options, generated `config.h` files and staging steps are in `build/arm64-libs/`. All other components are the same as 1.0.1.2.

Ember 1.0.1.3 은 WineARM64 런타임의 라이브러리 3개를 바꿨습니다. `libglib-2.0.0.dylib`·`libgio-2.0.0.dylib` 는 GLib 2.90.0 에
`patches/arm64-glib` 를 적용한 것이고, `libusb-1.0.0.dylib` 는 수정하지 않은 libusb 1.0.29 를 `ac_cv_func_pipe2=no` 로 빌드한 것입니다.
빌드 옵션·생성된 `config.h`·런타임에 넣는 절차는 `build/arm64-libs/` 에 있습니다. 나머지 구성요소는 1.0.1.2 와 같습니다.

```sh
sh scripts/apply-series.sh patches/arm64-glib "$glib_src"
```

## v1.0.1.2 소스 보완

`BINARIES.tsv`의 series 열에서 `+`는 왼쪽부터 같은 소스 디렉터리에 차례로 적용한다는 뜻입니다.
DXGI 세 아키텍처는 DXMT `7c8dee1`에서 다음 두 명령을 실행합니다.

```sh
sh scripts/apply-series.sh patches/dxmt-dxgi "$dxmt_src"
sh scripts/apply-series.sh patches/dxmt-dxgi-release "$dxmt_src"
```

d3d10core 세 아키텍처는 기본 DXMT 소스의 새 사본에 `dxmt-nvext-d3d10core`를 적용합니다.
WineARM64의 i386 `kernelbase.dll`, `ntdll.dll`, `wmp.dll`은 Wine 11.18의 새 사본에 다음 순서로 적용합니다.
다른 WineARM64 모듈은 해당 행의 series를 따릅니다.

```sh
sh scripts/apply-series.sh patches/wine-arm64 "$wine_src"
sh scripts/apply-series.sh patches/wine-arm64-i386-release "$wine_src"
```

## Rebuild / 다시 빌드

1. Get the upstream archives listed in `upstream/SOURCES.tsv` (`scripts/fetch-upstream.sh`).
2. Extract and apply a series: `sh scripts/apply-series.sh patches/<series> <extracted source dir>`.
3. Build with the upstream build system (Wine: `configure` + `make`; DXMT: `meson` + `ninja`). DXMT Metal shaders target
   macOS 14 (`-std=metal3.1 --target=air64-apple-macos14.0`, already in `src/dxmt/meson.build` of the series).
   Third-party libraries used by the runtimes are listed in `upstream/SOURCES.tsv` and `macports/`.

The VM libraries gettext (`libintl`) 1.0 and JSON-GLib 1.10.8 are included without changes; their upstream archives are
listed in `upstream/SOURCES.tsv`.
Archives in the `vm` group are attached to the v1.0.1 release of this repository; the others are attached to v1.0.
MD5 values in `BINARIES.tsv` are taken before code signing (signing changes the file bytes).

Licenses: `LICENSES/`. Unmodified third-party LGPL libraries (GnuTLS, GStreamer, FFmpeg, libusb, …; the WineARM64 GLib is patched, see above) are listed with their
upstream archives in `upstream/SOURCES.tsv`.

가상 머신용 gettext(`libintl`) 1.0 과 JSON-GLib 1.10.8 은 수정 없이 넣었고, 원본은 `upstream/SOURCES.tsv` 에 있습니다. `vm` 묶음의 원본 압축 파일은 이 저장소의 v1.0.1 릴리스에, 나머지는 v1.0 릴리스에 있습니다.
`BINARIES.tsv` 의 MD5 는 코드 서명 전 값입니다(서명하면 파일 바이트가 바뀝니다).

라이선스 전문은 `LICENSES/` 에 있습니다. 수정 없이 넣은 LGPL 라이브러리(GnuTLS·GStreamer·FFmpeg·libusb 등. WineARM64 의 GLib 는 위 패치 적용)의 원본 압축 파일은
`upstream/SOURCES.tsv` 에 있습니다.
