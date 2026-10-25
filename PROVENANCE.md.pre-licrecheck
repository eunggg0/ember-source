# Provenance — 2026-10-24 local source-package candidate

This refresh retains upstream archive identifiers/hashes and updates the selected source overlays and recipe evidence.
CX winemac and stock Wine winemetal have new **uninstalled** replacement candidates; other rows below describe archived build artifacts
compared with the installed runtime at the recorded observation time. These are separate evidence sets. No candidate
was installed or run in a game by this source-publication pass. This document is not a legal compliance certification.

## Candidate overrides

| Target | MD5 | SHA-256 | Status |
|---|---|---|---|
| CX x86_64 winemac.so, `ANE_O=0` | `05ba79216e3ce273686f9f7cf4e431a6` | `8424cafd793230ab389c64eb9ed6d6c9151786ca114250491073d434d2b07ade` | Built; symbol inspection found no defined or undefined `ember_ane_*`; not installed or game-tested |
| Stock Wine x86_64 winemetal.so, dynamic Tone bridge | `5a4355e06af866b2a14ae9b0c1cf8d5a` | `f787852ab0032aa007659cac6c39b14f19bb5fefb3d63eaef46aad00ef2d78a4` | Built; strict codesign passes; 12 worker exports removed, no new exports; not installed or game-tested |

The CX candidate omits `ember_neural_ane.o`. Existing LGPL-side adapters already dynamically resolve services from
libEmberFG/libEmberTone, so no new source change was necessary for this exclusion. Missing optional services must
remain disabled through the existing loader behavior. Preserving FEX ANE/LLFI and Rosetta interpolation behavior
requires a later in-game check; a successful build and symbol scan do not establish it.

The stock Wine winemetal target is a second affected module. Its observed installed MD5
`cc9acca136f52abe57218c183f2b9eac` exactly matches an archived signed minos27 artifact. The replacement source uses the
native pre-FG/MSC-3 candidate sources plus an LGPL Tone forwarding adapter and local dynamic loader; legacy unix-call entries
146–152 remain. This recovery is not a proven exact replay of the old artifact's source recipe.
The loader uses `EMBER_TONE_LIB` or sibling `libEmberTone.dylib`, checks ABI major 1 and resolves the optional ANE API.
The observed stock Wine directory has no sibling Tone library: without a compatible provider the candidate explicitly
turns the legacy Neural feature off. Release wiring and actual feature continuity remain to be verified.
The dynamic bridge passed four CPU-only mock-provider scenarios (missing provider, ABI mismatch, partial API, full
provider forwarding). The harness compiled the adapter; it did not execute native winemetal, Metal or a game.

A symbol scan only finds named definitions/references. Absence of `ember_ane_*` symbols does not rule out stripped,
inlined or renamed implementations, embedded shaders, or unrecognized code. The refined census covered 10,881
Wine/WineCX/WineARM64 inventory entries: 396 Mach-O and 10,485 PE-labeled records. All 396 native modules and 10,335 PE
modules returned nm success, but 15 native and 5,677 PE tables were empty. The other 150 records were .fon NE-font
containers misclassified as PE, with no unexpected module failures. The 5,692 successfully inspected empty tables
remain unproven; these coverage limits prevent treating the scan as proof that every module is implementation-free. Provider exports and LGPL adapter symbols are
reported separately. Source exclusion and recipe inspection complement the scan; none constitutes a legal certification.

## Installed-artifact observations

Observation: `2026-10-24T09:29:45.549276+00:00`. Sixteen targeted mappings had exact full-byte matches; three DXGI mappings
matched only after normalizing the 32-byte Wine builtin DOS-stub marker at offsets 64–95. No new source-to-object replay
was performed for these historical mappings. Full SHA-256 values, recipe/source IDs and per-file limits are retained in
[build/current/binary-mappings.json](build/current/binary-mappings.json).

| Component | Observed installed MD5 | Artifact comparison |
|---|---|---|
| Wine ARM64 ntdll thread mmap | `9f9b171788a2d3374d5e0dbbf33ccc86` | exact bytes |
| Wine CX ntdll | `17d68bee49dde2d725fb9fed52a381df` | exact bytes |
| Wine CX winemac | `df91cb88178629c25aa3dd3772b79c17` | exact bytes |
| Wine ARM64 winemac | `9bd79f0069aacc937a546f4d4e194edb` | exact bytes |
| Wine coreaudio x86_64 | `f757ba44d2748be78450618c92bdf84f` | exact bytes |
| Wine coreaudio arm64 | `a197b0b9835bb8d656e4b4ad9afc3842` | exact bytes |
| FEX libarm64ecfex | `945fd8c4498787c5548cca38cb7447cf` | exact bytes |
| FEX libwow64fex | `cdf5e988da48c0d7c72be303088313c7` | exact bytes |
| DXMT d3d11 x64 | `f2fcdeb6052c3f209f04c7f72aab3d72` | exact bytes |
| DXMT d3d12 x64 | `7dc436e4933e4e82df40fae0a6c729b7` | exact bytes |
| DXMT winemetal.so x64 | `a3034c3d49ee0c185e5c9b4b86fc07e0` | exact bytes |
| DXMT winemetal.dll x64 | `05971588d17cabe1f112b4dd33e53fd1` | exact bytes |
| DXMT d3d11 ec | `5ade8d50d3937829679dc776f34e3f47` | exact bytes |
| DXMT d3d12 ec | `09411f5f83b58ea22ed407151e1287fd` | exact bytes |
| DXMT winemetal.so ec | `abe1da03428d9920bde1b812d1f49acb` | exact bytes |
| DXMT winemetal.dll ec | `ba0d543579154ddfe9c30984130ffb71` | exact bytes |
| DXMT dxgi x64 | `4c02d922b373e00a26fc2866470d39e7` | builtin-marker normalization only |
| DXMT dxgi ec | `aff73f796502d91d16377b338cb3ab70` | builtin-marker normalization only |
| DXMT dxgi x86 | `c41686b7d777409b7a8743a3125acf06` | builtin-marker normalization only |

The earlier fex32d stage covered 854 members, 849 of which still matched that original stage. Later overrides are
required for ntdll, opengl32, winecoreaudio, winegstreamer and the later FEX DLLs; do not infer current sources solely
from the old stage directory. The fex32d source directory contains symlinks; an exported source snapshot must contain
the resolved file contents. CX ntdll was matched to an archived staged artifact; a clean replay was not established.

## Source series

| Series | Bundle targets / refreshed source lineage |
|---|---|
| `wine-cx` | CX Wine; fgnight CX winemac adapter sources without static ANE worker, launcher window overrides, micwedge2 x86_64 coreaudio |
| `wine-arm64` | Wine 11.18; eafex window/header overrides, fex32load ntdll virtual.c, micwedge2 arm64 coreaudio |
| `wine-x64` | Wine 11.0 and stock renderer Wine modules; retained lineage |
| `dxvk-cx` | CrossOver DXVK; retained lineage |
| `dxmt-d3d11` | bneck d4 source snapshot; do not substitute a later DXMT tree |
| `dxmt-d3d12` | tess tree12 snapshot |
| `dxmt-winemetal` | compat2 base plus tess native winemetal/cache overrides for WineCX/WineARM64 |
| `dxmt-winemetal-wine11` | pristine DXMT base plus only native candidate sources/support closure and dynamic Tone adapter for the separate stock Wine candidate; no `src/dxmt` changes |
| `dxmt-dxgi` | earlier emberfg lineage retained; normalized-marker comparison only |
| `fex` | fexnight r3 DCB opt-in source snapshot based on FEX 48d7175 |

Each DXMT series describes a separate complete tree against the same upstream base. Apply only the series for the
target being rebuilt. `series` and `FILES.txt` in each directory are the current patch/file lists. Original URLs and
archive SHA-256 values remain in `upstream/SOURCES.tsv` and `COMPONENTS.md`. The x86_64 MacPorts libraries retain their
existing origin/version records in `macports/REFS.txt`.

## Source-series verification completed

All ten series passed pinned upstream archive SHA-256 validation, application through the packaged
`scripts/apply-series.sh`, and exact exported-source snapshot comparison (contents, symlinks and executable bits).
This verifies the source transformation, not a complete clean binary rebuild. The portable record is
[build/current/series-verification.json](build/current/series-verification.json).

| Series | Patches | Changed source files | Snapshot parity |
|---|---|---|---|
| `wine-cx` | 74 | 242 | PASS |
| `wine-arm64` | 36 | 109 | PASS |
| `wine-x64` | 12 | 34 | PASS |
| `dxmt-d3d11` | 12 | 122 | PASS |
| `dxmt-d3d12` | 10 | 118 | PASS |
| `dxmt-winemetal` | 10 | 111 | PASS |
| `dxmt-dxgi` | 7 | 93 | PASS |
| `dxvk-cx` | 6 | 33 | PASS |
| `dxmt-winemetal-wine11` | 1 | 27 | PASS |
| `fex` | 5 | 66 | PASS |

The final ten series contain 173 patches. The Wine11 series was narrowed to the pristine DXMT base with only the
12 copied native candidate files, native support include/libs/airconv/IR dependencies and pre-FG native Meson recipe.
It has one patch touching 27 source files and does not modify `src/dxmt`. This scope correction prevents unrelated
old PE implementation changes from entering the source package. The candidate binary, command records and binary
hashes are unchanged. The narrowed series passed the pinned-archive application and snapshot-parity check again.

The package regression suite passed 10 tests: nine no-GPL gate cases and one apply-series inherited-Git-environment
regression. The latter verifies that `GIT_DIR`, `GIT_WORK_TREE` and `GIT_INDEX_FILE` cannot redirect patch application.
Final release no-GPL bundle inspection is still separate; see [build/BUILD.md](build/BUILD.md).

## Verification boundary

[build/current/README.md](build/current/README.md) explains the inspected recipes, full recorded command vectors and
reused build inputs. Existing artifact equality, patch application/tree comparison, independent clean rebuilding,
runtime loading and game behavior are distinct checks. The recipe records do not demonstrate a complete clean rebuild
of every reused object, generated header, Wine module, static library or dependency. This package does not include
EmberCore implementation or private models. Retired implementation files stay excluded.

This run has not uploaded upstream archives, pushed a source repository or verified public mirror availability. The
archive manifest preserves the original records; the downloader's configured release URL is not evidence of publication.
Final-release inventory/no-GPL checks and Claude's in-game candidate checks must be completed against the selected release
runtime before describing it as a verified shipped replacement.
