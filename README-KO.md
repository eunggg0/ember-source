# Ember 1.0 — 오픈소스 구성요소 소스 공개

이 저장소는 2026-10-24 기준 Ember 1.0 오픈소스 런타임의 로컬 소스 묶음 후보입니다.
Wine·DXMT·GStreamer·GLib·FFmpeg·GnuTLS·wine-gecko 등의 원본 소스 주소, 수정 패치와 빌드 설정 기록을 담았습니다.
법적 적합성을 확정하는 문서는 아닙니다.

Ember 앱·EmberCore 구현·모델·그림은 독점 소프트웨어로 제외합니다. CX winemac 대상은 옛 ANE 워커 객체를
정적으로 링크하지 않은 `ANE_O=0` 후보이며 아직 설치하지 않았습니다. 나머지 설치본·빌드 산출물 대조 결과와
검증 범위는 [PROVENANCE.md](PROVENANCE.md)에 기록했습니다. stock Wine winemetal도 정적 워커를 동적 Tone
연결부로 바꾼 미설치 후보입니다. 기존 stock Wine 폴더에는 Tone 라이브러리가 없어 별도 경로 설정이나 제공 없이는
이 후보의 옛 Neural 기능이 꺼집니다.

## 들어 있는 것

| 위치 | 내용 |
|---|---|
| `COMPONENTS.md` | 구성요소마다 버전, Ember.app 안 위치, 라이선스, 원본 압축 파일 주소와 SHA-256, 패치 시리즈 위치 |
| `PROVENANCE.md` | 소스·빌드 산출물의 대응 관계, 후보 대상과 검증 한계 |
| `patches/<구성요소>/` | 원본 압축 파일에 대한 Ember 수정(패치 시리즈). 순서는 `series`, 바뀐 파일 목록은 `FILES.txt` |
| `patches/forgeplay-origin/` | Ember 의 Wine 에 들어간 ForgePlay Wine 패치 7건 원본과 고지 |
| `build/` | 빌드 안내(`BUILD.md`), 기존 configure·meson·cmake 기록과 `build/current/`의 현재 레시피 근거 |
| `macports/` | Gcenx Wine 11.0 묶음에서 가져온 x86_64 라이브러리의 MacPorts 포트 정의와 패치 |
| `LICENSES/` | 라이선스 전문 |
| `scripts/` | `apply-series.sh`(패치 시리즈 적용), `fetch-upstream.sh`(원본 압축 파일 받기·검사) |
| `upstream/SOURCES.tsv` | 원본 압축 파일 기록: 원래 주소, SHA-256, 크기, 받을 때 확인한 방법 |

원본 URL·SHA-256·크기는 `upstream/SOURCES.tsv`에 보존했습니다. 이번 작업에서는 압축 파일을 업로드하지
않았으며 공개 미러의 이용 가능 여부도 확인하지 않았습니다. `fetch-upstream.sh`는 설정된 v1.0 릴리스 주소를
사용하므로 먼저 공개 상태를 확인하거나, 기록된 원본 URL에서 받아 해시를 대조해야 합니다.

## 다시 빌드하기

```sh
cd ember-source  # 이 로컬 소스 묶음 사용
scripts/fetch-upstream.sh                         # 설정된 압축 파일 미러가 공개되어 있어야 함
tar xf upstream/wine-arm64/wine-11.18.tar.xz
scripts/apply-series.sh patches/wine-arm64 wine-11.18
```

그다음 [build/BUILD.md](build/BUILD.md)와 [현재 빌드 기록](build/current/README.md)을 확인합니다.
패치 적용·트리 비교와 전체 소스 재빌드·로딩·게임 동작 검증은 별도입니다. 기존 객체와 생성된 빌드 파일을 재사용한
레시피도 있어, 설치 산출물 대조만으로 전체 재현을 입증하지는 못했습니다.

## Ember.app 의 LGPL 라이브러리를 직접 만든 것으로 바꾸기

아래 LGPL 런타임 라이브러리는 번들 안의 별도 파일입니다. 호환되는 대체 빌드는 다음 위치를 사용합니다.

| 구성요소 | `Ember.app/Contents/Resources/` 안 파일 | 참고 |
|---|---|---|
| Wine (Rosetta 엔진) | `WineCX/lib/wine/{x86_64,i386}-{unix,windows}/*`, `WineCX/bin/*` | x86_64, 최소 macOS 10.15 |
| Wine (FEX 엔진) | `WineARM64/lib/wine/{aarch64,i386,x86_64}-{unix,windows}/*`, `WineARM64/bin/*` | arm64·ARM64EC, 최소 11.0 |
| Wine 11.0 x86_64 | `Wine/lib/wine/*`, `Renderers/stock/*` | |
| DXMT | `Renderers/dxmt/{x86_64,i386}-windows/*.dll`, `Renderers/dxmt-arm64ec/*.dll`, `Wine*/lib/wine/*/winemetal.{so,dll}` | DLL 은 `winebuild --builtin` 표시, winemetal 의 .so 와 .dll 은 함께 바꿀 것 |
| GStreamer·GLib·FFmpeg (Rosetta) | `GStreamer/lib/*.dylib`, `GStreamer/lib/gstreamer-1.0/*.dylib` | |
| GStreamer·GLib·FFmpeg·GnuTLS 등 (FEX) | `WineARM64/lib/*.dylib`, `WineARM64/lib/gstreamer-1.0/*.dylib` | |
| GnuTLS·Nettle·GMP 등 (Rosetta) | `Wine/lib/*.dylib` | |

순서:

1. Ember 를 끄고 앱 사본에서 작업합니다: `ditto /Applications/Ember.app ~/Applications/Ember-custom.app`
2. 이 소스로(고친 내용을 넣어) 라이브러리를 빌드합니다. 원래 파일과 같은 파일 이름·설치 이름(`otool -D <파일>`, 예:
   `@rpath/libgnutls.30.dylib`)·아키텍처·최소 macOS 버전으로 만들고, 필요한 상대 LC_RPATH 는 보존하고 빌드 머신의 절대 경로가 남았는지 점검합니다.
3. 사본 안의 원래 파일 위에 복사하고 그 파일만 서명합니다: `codesign -s - -f <파일>`.
   바꾼 앱 사본에서 실제 로딩과 동작 호환성을 확인해야 합니다. Wine 실행 파일
   (`wine`, `wineserver`, `wine-host`)을 바꿀 때는 `build/wine/wine.entitlements` 권한을 붙여 서명합니다:
   `codesign -s - -f -o runtime --entitlements build/wine/wine.entitlements <파일>`.
4. 앱 전체를 다시 서명하지 **마세요**. 원래 앱 실행 파일과 서명을 보존하고 바꾼 앱 사본을 검증합니다. 첫 실행 때 macOS 가 번들을 다시 검사하지 않도록 사본의 다운로드 격리 표시를
   지웁니다: `xattr -dr com.apple.quarantine ~/Applications/Ember-custom.app`
5. 사본을 실행합니다. Ember 를 업데이트하면 앱이 새로 바뀌므로 바꾼 파일을 다시 넣어야 합니다. Ember 이용 약관은 LGPL
   구성요소를 고치는 것이나, 고친 것을 디버깅하려고 역분석하는 것을 막지 않습니다.

## 서면 제안

이 저장소를 쓸 수 없으면 Ember 1.0 을 받은 날부터 3년 안에 realnoma@naver.com 으로 요청해 주세요. 같은 소스를
매체나 내려받기로, 보내는 데 드는 비용 이상은 받지 않고 보내 드립니다. 이 제안은 Ember 를 받은 누구에게나 유효합니다.

## 문의

realnoma@naver.com
