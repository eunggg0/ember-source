# Building the open-source components

This package contains source patch series and build records. Begin with the matching archive in
[../upstream/SOURCES.tsv](../upstream/SOURCES.tsv), verify SHA-256, extract to a clean source directory, and apply
`../scripts/apply-series.sh ../patches/<component> <source-directory>` from `build/`, or use equivalent paths from
the repository root. Do not apply multiple DXMT series to one tree.

[Current recipe records](current/README.md) describe the 2026-10-24 candidate and the installed-artifact mappings.
They take precedence over older configure option snapshots where explicitly noted. They include partial rebuild
recipes that reused generated configuration, baseline objects or static libraries. A complete clean replay and
bit-identical rebuild have not been established for every module. Do not equate clean patch application with a
verified source-to-binary rebuild or game compatibility.

| Component | Baseline records | Current supplement |
|---|---|---|
| WineCX / WineARM64 / Wine 11.0 | `wine/configure-wine-*.txt`, `wine/wine.entitlements` | `current/README.md`: CX winemac `ANE_O=0`, ARM64 ntdll/winemac and both coreaudio builds |
| DXMT | `dxmt/meson-options.txt`, `dxmt/build-*.txt` | `current/README.md`, `current/winemetal-*-commands.txt`, `current/winemetal-stock-commands.json` |
| FEX | `fex/cmake-options.txt` | `current/fex-configure.txt` for current r3 options; do not run the historical install helper for a candidate build |
| DXVK | `dxvk-cx/build-*.txt` | Existing series retained |
| GStreamer / FFmpeg | `gstreamer/`, `ffmpeg/` | Use the recorded LGPL configuration; deployment helpers are not required for building |
| Other dependencies | `arm64-deps/`, `../macports/` | Recorded upstream versions and MacPorts commits remain unchanged |

Use macOS/Xcode command-line tools, the recorded LLVM/llvm-mingw toolchains, Meson/Ninja/CMake and the upstream
component dependencies. Set output/temp/module-cache paths explicitly to your own build area. Build into a separate
directory; nothing in this publication pass requires installing candidates or starting Wine, Metal or a game.
Keep native library install names and required relative loader rpaths. Mark Wine PE DLLs builtin and keep winemetal
SO/PE pairs together. Replacement guidance is in the language READMEs; it was not executed in this pass.

## Release no-GPL gate

From the repository root, run the regression tests:

```sh
python3 -m unittest discover -s verify -p 'test_*.py'
```

Inspect the **actual final release app bundle**, after selecting and packaging the intended runtime:

```sh
python3 verify/check-no-gpl.py /path/Ember.app --json /path/release-no-gpl.json
```

The parent directory of the JSON output must already exist. macOS `otool` is required for native dependencies.
The gate reads bundle files and does not run bundled binaries. Any failure needs investigation; a passing report
is evidence for the implemented heuristics, not proof that every license/source obligation is satisfied.

For development diagnostics only, `--project-release` excludes the documented GPTK development artifacts that the
release build is expected to omit. That projected result is **not** the actual final bundle gate and does not replace
building and inspecting the final release app without that flag. This publication pass did not build or install a
final app; its earlier projected development-bundle result must not be described as final-release verification.
