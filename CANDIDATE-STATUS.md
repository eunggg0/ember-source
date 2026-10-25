# Source publication candidate — 2026-10-24

## 2026-10-25 installed-app recheck (supersedes installation status below)

Read-only re-inventory of `/Volumes/SSD/Ember.app` found:

- Stock Wine `lib/wine/x86_64-unix/winemetal.so` SHA-256
  `f787852ab0032aa007659cac6c39b14f19bb5fefb3d63eaef46aad00ef2d78a4`
  exactly matches the replacement candidate recorded below. Its earlier
  **uninstalled** status is historical; this observation does not identify who
  installed it, prove complete source correspondence, or verify game behavior.
- WineCX `lib/wine/x86_64-unix/winemac.so` SHA-256
  `e4c360c040b2d25dd40565b1c10aad1fdd21ad77edf34c0aeb922400961d5b4d`
  differs from the recorded CX candidate
  `8424cafd793230ab389c64eb9ed6d6c9151786ca114250491073d434d2b07ade`.
  Full correspondence for this current file remains unverified.
- `nm` completed for both files and found no named `ember_ane_*` symbols.
  This limited symbol check is not proof of absent static, stripped or inlined
  code. No runtime replacement, build, game test or publication was performed
  by this recheck. Public repository/release accessibility remains unverified.

This local candidate records two uninstalled runtime replacements: CX winemac
without its unused static ANE object, and stock Wine winemetal with an optional
Tone dynamic bridge. Their hashes and runtime-provider limits are in PROVENANCE.md.

All 10 patch series (173 patches) apply to the SHA-256-pinned upstream archives
and match the selected filtered source snapshots file by file. See
verify/series-results.json. All 10 packaged regression tests pass. This verifies
source export and patch application, not clean rebuilding every linked archive
or gameplay. The current recipe records explicitly identify reused build inputs.

No repository push, source upload, site publication, installation, or game run
was performed. Final release-bundle/source correspondence, provider packaging,
and Claude's FEX/Rosetta in-game checks remain pending. These are candidate
records and do not establish licensing compliance or release approval.
