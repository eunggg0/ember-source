# GLib 2.90.0 for WineARM64 (libglib, libgio)

Apply to a fresh `glib-2.90.0` source tree from `upstream/SOURCES.tsv`, then build as described in `build/arm64-libs/BUILD.txt`.
The patch changes only the Darwin `pipe2` configure check in `meson.build`, so GLib uses its existing `pipe()`+`fcntl()` code on macOS 14–26.
Target binaries in Ember 1.0.1.3: `WineARM64/lib/libglib-2.0.0.dylib`, `WineARM64/lib/libgio-2.0.0.dylib`.

GLib 2.90.0 원본 새 사본에 적용한 뒤 `build/arm64-libs/BUILD.txt` 대로 빌드합니다. `meson.build` 의 다윈 `pipe2` 검사만 바꿉니다.

```sh
sh scripts/apply-series.sh patches/arm64-glib "$glib_src"
```
