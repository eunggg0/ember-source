# Wine changes taken from ForgePlay / ForgePlay에서 가져온 Wine 수정

Seven Wine changes in Ember's Wine builds come from the Wine 11.12 patches distributed with ForgePlay 1.3
(https://github.com/Facta-Leopard/ForgePlay). They modify Wine and are therefore licensed under the
GNU Lesser General Public License 2.1 or later, like Wine itself. The original patch files are kept here unchanged,
with their original notices. Their code is already part of the Ember patch series in `patches/wine-cx`,
`patches/wine-arm64` and `patches/wine-x64`; these copies are for attribution and comparison.

Ember의 Wine 에는 ForgePlay 1.3 에 함께 배포된 Wine 11.12 패치에서 가져온 수정 7건이 들어 있습니다. Wine 을 고친 것이므로
Wine 과 같은 LGPL-2.1-or-later 를 따릅니다. 원본 패치 파일을 원래 고지 그대로 여기에 둡니다. 같은 코드는 이미
`patches/wine-*` 시리즈에 들어 있고, 이 사본은 출처 표기와 비교를 위한 것입니다.

| ForgePlay patch | Used in | Notes |
|---|---|---|
| `wine-11.12-forgeplay-xbox-iohid-normalization.patch` | WineCX, WineARM64 | adds `dlls/winebus.sys/forgeplay_xbox_iohid.h` — "ForgePlay Xbox Series Bluetooth IOHID input normalization. Copyright 2026 JEAHOON BANG. SPDX-License-Identifier: LGPL-2.1-or-later" (header kept as is) |
| `wine-11.12-xinput-capability-resolution.patch` | WineCX, WineARM64 | |
| `wine-11.12-media-foundation-video-output-negotiation.patch` | WineCX | winegstreamer |
| `wine-11.12-wined3d-legacy-vertex-interface.patch` | WineCX | |
| `wine-11.12-wined3d-vulkan-reset-shader-metadata.patch` | WineCX | |
| `wine-11.12-wow64-vulkan-host-memory-ownership.patch` | WineCX | win32u/vulkan.c |
| `wine-11.12-dynamic-unwind-registration-cache.patch` | all three Wines | idea extended in Ember's ntdll/unwind.c |

ForgePlay's Game Mode code (GPL-3.0-only) is **not** used in Ember. ForgePlay is a project of Facta-Leopard; Ember is not
affiliated with or endorsed by ForgePlay.

ForgePlay 의 Game Mode 코드(GPL-3.0-only)는 Ember 에 들어 있지 않습니다. Ember 는 ForgePlay 의 공식 판이 아니며 보증을 받지 않았습니다.
