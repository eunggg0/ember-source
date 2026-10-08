# Ember 1.0 — corresponding source for the open-source components

Ember is a macOS launcher for Windows games. It ships modified and unmodified open-source components under the GNU
Lesser General Public License (Wine, DXMT, GStreamer, GLib, FFmpeg, GnuTLS, …), the Mozilla Public License
(wine-gecko) and permissive licenses. This repository is the complete corresponding source for those components in
**Ember 1.0**, as required by LGPL-2.1 §6 / LGPL-3.0 §4 and MPL-2.0 §3.2.

Ember's own software (the app and the EmberCore libraries) is proprietary and is not part of this repository; it is a
separate program that uses the LGPL libraries as shared libraries.

## What is here

| Path | Contents |
|---|---|
| `COMPONENTS.md` | every component: version, where it is in Ember.app, license, upstream archive and SHA-256, patch count |
| `PROVENANCE.md` | which source tree each shipped binary was built from, and how that was checked |
| `patches/<component>/` | Ember's changes as a patch series against the upstream archive (`series` gives the order, `FILES.txt` lists changed files) |
| `patches/forgeplay-origin/` | the seven original ForgePlay Wine patches that Ember's Wine includes, with their notices |
| `build/` | build notes (`BUILD.md`), the exact configure / meson / cmake options and the build scripts used |
| `macports/` | MacPorts port definitions and patches for the x86_64 libraries copied from Gcenx's Wine 11.0 package |
| `LICENSES/` | license texts |
| `scripts/` | `apply-series.sh` (apply a series), `fetch-upstream.sh` (download and verify the mirrored archives) |
| `upstream/SOURCES.tsv` | list of the mirrored upstream archives: original URL, SHA-256, size, how the download was verified |

The upstream archives themselves (about 1.3 GB) are attached to the **v1.0 release** of this repository:
https://github.com/eunggg0/ember-source/releases/tag/v1.0 . `scripts/fetch-upstream.sh` downloads them into `upstream/`
and checks every SHA-256.

## Rebuilding

```sh
git clone https://github.com/eunggg0/ember-source && cd ember-source
scripts/fetch-upstream.sh                         # or only the archives you need: scripts/fetch-upstream.sh wine-11.18.tar.xz
tar xf upstream/wine-arm64/wine-11.18.tar.xz
scripts/apply-series.sh patches/wine-arm64 wine-11.18
```

Then follow `build/BUILD.md` for the component. Every series applies cleanly to the matching archive (this is checked
before each publication).

## Replacing an LGPL library in Ember.app (your relinking right)

All LGPL components are separate files inside the app bundle and can be replaced with your own build:

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
   Remove absolute LC_RPATH entries.
3. Copy it over the original file in the app copy and sign only that file: `codesign -s - -f <file>`.
   The Wine processes run with library validation disabled, so a locally signed library loads. If you replace a Wine
   executable (`wine`, `wineserver`, `wine-host`), sign it with the entitlements in `build/wine/wine.entitlements`:
   `codesign -s - -f -o runtime --entitlements build/wine/wine.entitlements <file>`.
4. Do **not** re-sign the whole app. Ember checks the signature of its own executable, which stays valid when only
   files under `Contents/Resources` change. Remove the download quarantine from the copy so macOS does not re-check the
   bundle on first launch: `xattr -dr com.apple.quarantine ~/Applications/Ember-custom.app`.
5. Start the copy. An Ember update replaces the app, so apply your change again after updating. Ember's terms of use do not forbid modifying the LGPL components or reverse engineering them to debug
   such modifications.

## Written offer

If you cannot use this repository, write to realnoma@naver.com within three years of receiving Ember 1.0 and we will
send the same source on a physical medium or by download for no more than the cost of providing it. This offer is valid
for anyone who received Ember.

## Questions

realnoma@naver.com
