# Ember 1.0 — corresponding source for the open-source components

This is the 2026-10-24 local candidate source package for Ember 1.0's open-source runtime components.
It contains upstream source references, Ember patch series and build configuration records for Wine, DXMT,
GStreamer, GLib, FFmpeg, GnuTLS, wine-gecko and other listed components. It is not a legal compliance certification.

Ember's app, EmberCore implementations, models and artwork remain proprietary and excluded. The CX winemac target
is a newly built, uninstalled `ANE_O=0` candidate that omits the old static ANE worker object. Other mappings are
observations of existing installed/build artifacts. Stock Wine winemetal also has an uninstalled dynamic Tone bridge
replacement. Its legacy Neural service needs a compatible Tone provider; the observed stock Wine directory has none.
See [PROVENANCE.md](PROVENANCE.md) for the evidence limits.

## What is here

| Path | Contents |
|---|---|
| `COMPONENTS.md` | component inventory: version, bundle location, license, upstream archive and SHA-256, patch-series references |
| `PROVENANCE.md` | source/build-artifact mappings, candidate target and verification limits |
| `patches/<component>/` | Ember's changes as a patch series against the upstream archive (`series` gives the order, `FILES.txt` lists changed files) |
| `patches/forgeplay-origin/` | the seven original ForgePlay Wine patches that Ember's Wine includes, with their notices |
| `build/` | build notes (`BUILD.md`), historical configure / meson / cmake options, plus current recipe evidence in `build/current/` |
| `macports/` | MacPorts port definitions and patches for the x86_64 libraries copied from Gcenx's Wine 11.0 package |
| `LICENSES/` | license texts |
| `scripts/` | `apply-series.sh` (apply a series), `fetch-upstream.sh` (download and verify archives from the configured release mirror) |
| `upstream/SOURCES.tsv` | upstream archive manifest: original URL, SHA-256, size, how the download was verified |

`upstream/SOURCES.tsv` preserves the upstream URLs, SHA-256 values and archive metadata. This run has not
uploaded archives or verified a public mirror. `scripts/fetch-upstream.sh` uses the configured v1.0 release URL;
check availability before using it, or obtain the archives from the recorded original URLs and verify their hashes.

## Rebuilding

```sh
cd ember-source  # use this local source package
scripts/fetch-upstream.sh                         # requires the configured archive mirror to be available
tar xf upstream/wine-arm64/wine-11.18.tar.xz
scripts/apply-series.sh patches/wine-arm64 wine-11.18
```

Then follow [build/BUILD.md](build/BUILD.md) and [build/current/README.md](build/current/README.md).
Patch application/tree comparison, clean source-to-binary rebuilding, loading and game behavior are different checks.
The current recipe records identify reused objects and generated build files; a full clean rebuild was not established
by the installed-artifact audit. See `PROVENANCE.md` for the current verification boundary.

## Replacing an LGPL library in Ember.app (your relinking right)

The listed LGPL runtime libraries are separate bundle files. For a compatible replacement build, use the locations below:

| Component | Files in `Ember.app/Contents/Resources/` | Notes |
|---|---|---|
| Wine (Rosetta engine) | `WineCX/lib/wine/{x86_64,i386}-{unix,windows}/*`, `WineCX/bin/*` | x86_64, deployment target 10.15 |
| Wine (FEX engine) | `WineARM64/lib/wine/{aarch64,i386,x86_64}-{unix,windows}/*`, `WineARM64/bin/*` | arm64 / ARM64EC, target 11.0 |
| Wine 11.0 x86_64 | `Wine/lib/wine/*`, `Renderers/stock/*` | |
| DXMT | `Renderers/dxmt/{x86_64,i386}-windows/*.dll`, `Renderers/dxmt-arm64ec/*.dll`, `Wine*/lib/wine/*/winemetal.{so,dll}` | mark DLLs with `winebuild --builtin`; replace winemetal .so and .dll together |
| GStreamer, GLib, FFmpeg (Rosetta) | `GStreamer/lib/*.dylib`, `GStreamer/lib/gstreamer-1.0/*.dylib` | |
| GStreamer, GLib, FFmpeg, GnuTLS, … (FEX) | `WineARM64/lib/*.dylib`, `WineARM64/lib/gstreamer-1.0/*.dylib` | |
| GnuTLS, Nettle, GMP, … (Rosetta) | `Wine/lib/*.dylib` | |

Steps:

1. Quit Ember. Work on a copy of the app: `ditto /Applications/Ember.app ~/Applications/Ember-custom.app`.
2. Build the library from this source (with your changes). Keep the file name and the install name of the original
   (`otool -D <file>`), e.g. `@rpath/libgnutls.30.dylib`, and the same architecture and deployment target.
   Preserve the required relative LC_RPATH entries; inspect any absolute build-machine paths before use.
3. Copy it over the original file in the app copy and sign only that file: `codesign -s - -f <file>`.
   Loading and runtime compatibility must be verified for the resulting app copy. If you replace a Wine
   executable (`wine`, `wineserver`, `wine-host`), sign it with the entitlements in `build/wine/wine.entitlements`:
   `codesign -s - -f -o runtime --entitlements build/wine/wine.entitlements <file>`.
4. Do **not** re-sign the whole app. Keep the original app executable and signature; verify the resulting app copy before use. Remove the download quarantine from the copy so macOS does not re-check the
   bundle on first launch: `xattr -dr com.apple.quarantine ~/Applications/Ember-custom.app`.
5. Start the copy. An Ember update replaces the app, so apply your change again after updating. Ember's terms of use do not forbid modifying the LGPL components or reverse engineering them to debug
   such modifications.

## Written offer

If you cannot use this repository, write to realnoma@naver.com within three years of receiving Ember 1.0 and we will
send the same source on a physical medium or by download for no more than the cost of providing it. This offer is valid
for anyone who received Ember.

## Questions

realnoma@naver.com
