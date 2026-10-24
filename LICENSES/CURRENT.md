# License scope — 2026-10-24 candidate

The existing license texts in this directory are retained. Component/version/archive mappings are in
[../COMPONENTS.md](../COMPONENTS.md), original source URLs and SHA-256 in
[../upstream/SOURCES.tsv](../upstream/SOURCES.tsv), and current build evidence in
[../PROVENANCE.md](../PROVENANCE.md). This file records package scope; it does not certify legal compliance.

- Wine, DXMT, the listed media/runtime libraries and their modified source remain covered by their respective
  licenses. Keep existing upstream copyright and license notices in every source series.
- The original ForgePlay-derived Wine patch notices remain in `patches/forgeplay-origin/`.
- LLVM 15.0.7 is a static winemetal/airconv input; retain Apache-2.0 WITH LLVM-exception and bundled notices.
- FEX (MIT), DXVK (zlib), and other permissive component notices remain unchanged.
- LGPL/GPL dual-license texts and GPL license documents can occur in source archives. Their presence is distinct
  from shipping a GPL-only runtime binary. The release no-GPL check is a filename/configuration/dependency heuristic,
  not a complete license audit or proof of source correspondence.
- Ember app, EmberCore implementations, models and artwork are excluded. The CX winemac candidate is linked with
  `ANE_O=0`, excluding the retired static `ember_neural_ane.o` implementation. LGPL-side dynamic-loading adapters
  remain in source; no EmberCore implementation is included to satisfy the old installed binary. The separate stock
  Wine winemetal candidate replaces a compiled-in worker with a dynamic Tone bridge and preserves the legacy unix-call ABI.
  A compatible Tone provider is required for that optional feature; it is absent from the observed stock Wine directory.

Neither replacement candidate was installed or tested in a game. Existing installed-artifact observations must not be read as
proof that the candidate is already the distributed runtime. Full clean rebuild, final release inventory and runtime
checks remain explicit verification steps. This run did not publish the repository or upload archive assets.

## Reviewed source-export filename exception

`src/dxmt/ember_spark.hpp` was on an older filename denylist. The two current files were reviewed as LGPL-side PE
thunks that use `GetProcAddress` to forward to `EmberFG_call`; they contain no Spark engine implementation. Keeping
these adapters avoids an unresolved include in the public source. The exporter permits only these exact reviewed
SHA-256 values, and fails on another version instead of broadly allowing the filename:

| Series | Adapter SHA-256 |
|---|---|
| `dxmt-d3d11` | `9a1ede7cb04c55aeb41e2679ebd6eea9f546f73048f267e001622b070974df63` |
| `dxmt-d3d12` | `e0f9f32300cc88c0d74daefcc025cb9afbd15a52c911e679af1fd5d40b17d8f6` |

The proprietary Spark implementation remains excluded. This exception concerns these two adapter files only.

## Stock Wine native source scope

The stock Wine winemetal series uses pristine DXMT plus the native candidate/support dependency closure only:
12 candidate files, native include/libs/airconv/IR support and the pre-FG native Meson recipe. Its one patch changes
27 files and makes no `src/dxmt` changes. Using a broad old working tree could carry unrelated private PE changes;
those are excluded. The native candidate binary and command/hash records remain unchanged. This is a source-export
scope correction, not a new clean historical rebuild or a broader publication authorization.
