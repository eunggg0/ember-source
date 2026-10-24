# Current build recipe records — 2026-10-24 candidate

These records supplement the older configure/Meson/CMake snapshots under `build/`. They describe the recipes
associated with the observed artifacts and the uninstalled CX winemac replacement candidate. Only recipe text and
command records are included here; no implementation source, generated object, proprietary library or game data is copied.
They are evidence for rebuilding work, not a claim that a clean public-package rebuild has reproduced all binaries.

`recipe-provenance.json` hashes nine inspected original recipe scripts. Its historical path IDs identify evidence
within the original development workspace, not files promised in this package. `binary-mappings.json` preserves the
2026-10-24 observations and clearly separates the new CX candidate. App paths are relative to `Ember.app/`.

Command records use `${WORKSPACE}` instead of the original absolute checkout location. This is an explicit path token,
including inside JSON; it must be substituted when adapting a recorded command. The original workspace build layout
and prebuilt inputs are not bundled. Do not execute these records unchanged or treat them as a standalone build system.
Use a separate output directory and preserve relative loader paths.

## Wine CX winemac

Apply `patches/wine-cx` to CrossOver 26.3.0 `sources/wine`; use the published LGPL-side adapter source. The current
candidate was linked using the inspected fgnight recipe with **`ANE_O=0`**, excluding `ember_neural_ane.o`.
The source already resolves optional services through `dlopen`/`dlsym`; no new source patch was needed for the exclusion.
Do not restore the retired worker implementation to reproduce the old installed file.

The recipe compiles `ember_framegen.m`, `ember_neural.m`, `ember_upscale.m`, `window.c`, `cocoa_window.m` with Clang,
`-arch x86_64 -mmacosx-version-min=10.15 -m64 -O2 -g`, Wine generated configuration/include paths,
`-DIS_WOW64_BUILD -DWINE_UNIX_LIB -D__WINESRC__ -fvisibility=hidden -fPIC -fno-stack-protector
-fno-strict-aliasing -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0`. It links the other winemac objects from the configured
CrossOver Wine build, plus `ntdll.so` and `win32u.so`, with `-dynamiclib -install_name @rpath/winemac.so
-Wl,-rpath,@loader_path/`. Frameworks: AppKit, Carbon, CoreML, CoreVideo, Foundation, IOKit, IOSurface, Metal,
OpenGL, QuartzCore, Security; MetalFX is weak-linked. The output is ad-hoc signed and checked for absolute build rpaths.

This is a partial object-reuse recipe. Rebuilding every reused Wine object from the public source and demonstrating
loading/game behavior remain separate checks. Candidate hashes are in `binary-mappings.json` and `PROVENANCE.md`.

## Wine ARM64 ntdll

Apply `patches/wine-arm64` to Wine 11.18. `arm64-ntdll-commands.json` preserves the recorded baseline and candidate
compile/link command vectors. The candidate uses the fex32d generated Wine configuration/Makefile, compiles the later
`dlls/ntdll/unix/virtual.c`, and links all other archived ntdll objects. It separately recompiles the data-only
`version.c` (`const char wine_build[] = "wine-11.18";`) using `gcc -std=gnu23 -mmacosx-version-min=11.0 -g -O2
-fvisibility=hidden` because the old `version.o` carried a later minimum OS version. Outputs are ad-hoc signed.
The full baseline objects, their dependency sources, and generated configuration must be rebuilt for a clean replay;
shipping only `virtual.c` would not describe the complete ntdll build.

## Wine ARM64 winemac

The fex32d `fex32` recipe uses Wine 11.18 base winemac sources with the eafex versions of `window.c`, `cocoa_window.m`
and `macdrv_cocoa.h`; these overrides are in `patches/wine-arm64`. It compiles all 22 units below with Clang
`-arch arm64 -mmacosx-version-min=11.0 -O2 -g -DWINE_UNIX_LIB -D__WINESRC__ -fvisibility=hidden -fPIC
-fno-stack-protector -fno-strict-aliasing -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=0` and configured Wine include paths:

```text
clipboard cocoa_app cocoa_clipboard cocoa_cursorclipping cocoa_display cocoa_event
cocoa_main cocoa_opengl cocoa_status_item cocoa_window display event gdi image
keyboard macdrv_main mouse opengl surface systray vulkan window
```

It links against fex32d `ntdll.so`/`win32u.so`, using `-dynamiclib -install_name @rpath/winemac.so
-Wl,-rpath,@loader_path/` and AppKit, Carbon, Foundation, IOKit, Metal, OpenGL, QuartzCore, Security frameworks;
then ad-hoc signs and verifies the file. The `fex32` mode uses the normal Wine headers, unlike the older `holes`
mode's extra shipped-header override. No rebuild of this module occurred in this source-publication pass.

## Wine coreaudio — both architectures

`winecoreaudio-commands.json` preserves both command lists and historical ntdll inputs. Apply the matching Wine
series: it includes the micwedge2 `coreaudio.c`/`coremidi.c`, `authorization.m` and capture adapter/job headers.
Compile coreaudio/coremidi and the Objective-C authorization unit (`-fblocks`), then link the three objects with
`ntdll.so`. x86_64 uses minimum macOS 10.15, `-std=gnu11 -DIS_WOW64_BUILD`; arm64 uses minimum 11.0,
`-std=gnu2x`. Both use `-O2 -g -fvisibility=hidden -fPIC`, the corresponding Wine generated headers,
`-dynamiclib -install_name @rpath/winecoreaudio.so -Wl,-rpath,@loader_path/` and CoreFoundation, CoreAudio,
AudioUnit, AudioToolbox, CoreMIDI, Foundation, AVFoundation. The recipe ad-hoc signs outputs. Both source variants
are included in their Wine series; the shared header copies must not be omitted.

## DXMT — separate trees and targets

Each DXMT series applies to a fresh copy of the same upstream archive. Never combine the series in one source tree.
The older `build/dxmt/meson-options.txt` and cross files are baseline configuration records, not proof of a new clean setup.

| Series | Inspected current recipe | Requirements and limits |
|---|---|---|
| `dxmt-d3d11` | bneck `tree`, `build-{x64,ec}`, target `src/d3d11/d3d11.dll` | Rewrites existing Ninja source paths to the snapshot, preserves generated `version.h`, places ARM64EC `ec_thunk_order.cpp` first in the link list, then marks the DLL builtin and checks EC thunks. Uses llvm-mingw 20260908. |
| `dxmt-d3d12` | tess `tree12`, `build-{x64,ec}`, target `src/d3d12/d3d12.dll` | Rewrites the existing Ninja recipe, preserves generated version metadata and existing EC thunk ordering. The recipe checks PE architecture and writes the 32-byte Wine builtin marker at offsets 64–95. |
| `dxmt-winemetal` | tess `wm`, per-architecture native command manifests | `winemetal-{x64,ec}-commands.txt` retains compile/link commands. The generated include/library context comes from compat2. Compile the selected native units; link airconv, DXBCParser, Wine and LLVM inputs shown in the manifests, then ad-hoc sign. Preserve the companion PE DLL from the same version. |
| `dxmt-dxgi` | earlier emberfg build retained | The existing x64/EC/x86 build artifacts differ from observed installed files only in the 32-byte DOS-stub builtin marker. No new rebuild or change of source lineage is inferred. |

The manifests retain references to prebuilt libraries and Wine modules. They do not establish those inputs from a
fresh extraction. Preserve LLVM 15.0.7 and its exception notices and all DXMT bundled notices when rebuilding.

## FEX

Apply `patches/fex` to the recorded FEX 48d7175 archive with submodules. The r3 DCB opt-in source changes are included.
Use [fex-configure.txt](fex-configure.txt) for the inspected current configuration, with llvm-mingw
20250920 and separate EC/WOW build directories. EC uses `arm64ec-w64-mingw32`, target `Bin/libarm64ecfex.dll`;
WOW uses `aarch64-w64-mingw32`, target `Bin/libwow64fex.dll`. Both use `ENABLE_LTO=False` and
`ENABLE_CCACHE=OFF`; these override differences in the older `build/fex/cmake-options.txt` record.
The recipe uses `ninja -j1`. No FEX build, install or game execution was performed by this documentation update.

## Stock Wine winemetal replacement — separate baseline

The stock `Wine/lib/wine/x86_64-unix/winemetal.so` is distinct from the current WineCX/WineARM64 winemetal pair.
Its observed MD5 `cc9acca136f52abe57218c183f2b9eac` matches the archived signed minos27 native artifact. Source recovery
uses the earlier `winemetal_unix.c.pre-emberfg` and `ember_dxil_unix.m.pre-d12perf4` plus cache/header sources from the
old DXMT native inputs. The public `patches/dxmt-winemetal-wine11` starts from pristine upstream DXMT and overlays
only the 12 copied native candidate files, native support include/libs/airconv/IR closure and pre-FG native Meson
recipe. It changes 27 files in one patch and does not modify `src/dxmt`. It is a separate series; do not apply it after
`dxmt-winemetal`. The broad old working tree is not the public baseline. This scope correction excludes unrelated
private PE changes; it does not change the candidate binary or the recorded compile/link commands and hashes.

The replacement uses the existing LGPL Tone forwarding adapter with a local loader instead of compiling the old ANE
worker implementation. It preserves the seven legacy unix-call entries 146–152. The loader accepts `EMBER_TONE_LIB`
or a sibling `libEmberTone.dylib`, checks ABI major 1, and resolves the eight `ember_tone_ane_*` functions dynamically.
Missing/incompatible provider or incomplete API leaves the optional old Neural feature off. The observed stock Wine
directory has no sibling Tone provider, so deployment must resolve that wiring if the feature is required.

`winemetal-stock-commands.json` records the exact candidate command vectors and inspected source-input hashes with
the same `${WORKSPACE}` token. It compiles the four native units, links the existing airconv/DXBCParser/LLVM/Wine inputs,
and ad-hoc signs the output; the recipes are not run by this documentation update. The module-audit build removed the
12 legacy `ember_ane_*` implementation exports without adding exports and passed strict codesign verification.
The recovered source recipe is not an exact historical source-to-object replay. Neither loading nor games were tested.

## Verified source transformation

`series-verification.json` records all ten pinned-archive and patch-application/tree-parity checks. Every series
passed. These checks replay source changes only; they do not rerun the historical native/PE compile or link steps.
The public `verify/` suite has ten passing regression cases (nine no-GPL checks plus inherited-Git-environment
patch application). Use the actual final release app for the bundle gate as described in `../BUILD.md`.

`winemetal-stock-verification.json` preserves candidate compile dependency closure, static/link input hashes and
export/signature checks. Rebuilding the recovered old baseline did not reproduce the original historical artifact;
only the separate candidate's four-unit compile/link correspondence is established. Dependencies in that record
remain build inputs to reconstruct, not files supplied merely by recording their hashes.
