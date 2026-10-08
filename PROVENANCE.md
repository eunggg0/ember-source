# Provenance — which source built which binary

Each patch series in `patches/` was produced by comparing the pristine upstream archive with the source tree the
Ember 1.0 binaries are built from. Before publication every series is checked by extracting the upstream archive
again, applying the series and comparing the result with that tree file by file.

| Series | Binaries in `Ember.app/Contents/Resources` |
|---|---|
| `wine-cx` | `WineCX/**` (Wine part) |
| `dxvk-cx` | `Renderers/dxvk/**` |
| `wine-arm64` | `WineARM64/**` (Wine part) |
| `wine-x64` | `Wine/**`, `Renderers/stock/**` |
| `dxmt-d3d11` | `Renderers/dxmt*/d3d11.dll`, `d3d10core.dll` |
| `dxmt-dxgi` | `Renderers/dxmt*/dxgi.dll` |
| `dxmt-d3d12` | `Renderers/dxmt*/d3d12.dll` |
| `dxmt-winemetal` | `Wine*/lib/wine/*-unix/winemetal.so`, `Wine*/lib/wine/*-windows/winemetal.dll` |
| `fex` | `WineARM64/lib/wine/aarch64-*/lib{arm64ec,wow64}fex.*` |

The DXMT libraries were built from separate working trees, so each DXMT series is a complete DXMT tree for the binaries
listed next to it. Apply it to a clean copy of DXMT 7c8dee1 and build the target you need.

The x86_64 GnuTLS / Nettle / GMP / libtasn1 / libidn2 / libunistring / libintl / libiconv libraries are unmodified copies
from Gcenx's "Wine Stable 11.0_1" package, which is built with MacPorts. `macports/ports` holds the MacPorts port
definitions and patches at the commits matching these versions (`macports/REFS.txt`), next to the upstream archives.
