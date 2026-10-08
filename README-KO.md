# Ember 1.0 — 오픈소스 구성요소 소스 공개

Ember 는 맥에서 윈도우 게임을 돌리는 런처입니다. Ember 에는 GNU LGPL 을 따르는 구성요소(Wine, DXMT, GStreamer, GLib,
FFmpeg, GnuTLS 등)와 MPL 을 따르는 wine-gecko, 그 밖의 오픈소스가 들어 있고, 그중 일부는 Ember 가 고쳐서 넣었습니다.
이 저장소는 **Ember 1.0** 에 들어간 이 구성요소들의 전체 소스입니다(LGPL-2.1 §6, LGPL-3.0 §4, MPL-2.0 §3.2).

Ember 앱과 EmberCore 라이브러리는 Ember 의 독점 소프트웨어라 여기에 없습니다. 이들은 LGPL 라이브러리를 공유 라이브러리로
불러 쓰는 별도 프로그램입니다.

## 들어 있는 것

| 위치 | 내용 |
|---|---|
| `COMPONENTS.md` | 구성요소마다 버전, Ember.app 안 위치, 라이선스, 원본 압축 파일 주소와 SHA-256, 패치 수 |
| `PROVENANCE.md` | 배포한 바이너리를 어떤 소스 트리로 만들었는지, 어떻게 확인했는지 |
| `patches/<구성요소>/` | 원본 압축 파일에 대한 Ember 수정(패치 시리즈). 순서는 `series`, 바뀐 파일 목록은 `FILES.txt` |
| `patches/forgeplay-origin/` | Ember 의 Wine 에 들어간 ForgePlay Wine 패치 7건 원본과 고지 |
| `build/` | 빌드 안내(`BUILD.md`), 실제로 쓴 configure·meson·cmake 옵션과 빌드 스크립트 |
| `macports/` | Gcenx Wine 11.0 묶음에서 가져온 x86_64 라이브러리의 MacPorts 포트 정의와 패치 |
| `LICENSES/` | 라이선스 전문 |
| `scripts/` | `apply-series.sh`(패치 시리즈 적용), `fetch-upstream.sh`(원본 압축 파일 받기·검사) |
| `upstream/SOURCES.tsv` | 미러한 원본 압축 파일 목록: 원래 주소, SHA-256, 크기, 받을 때 확인한 방법 |

원본 압축 파일(약 1.3GB)은 이 저장소의 **v1.0 릴리스**에 그대로 올려 두었습니다:
https://github.com/eunggg0/ember-source/releases/tag/v1.0 . `scripts/fetch-upstream.sh` 가 이것을 `upstream/` 에 받고
SHA-256 을 하나하나 확인합니다.

## 다시 빌드하기

```sh
git clone https://github.com/eunggg0/ember-source && cd ember-source
scripts/fetch-upstream.sh                         # 필요한 것만: scripts/fetch-upstream.sh wine-11.18.tar.xz
tar xf upstream/wine-arm64/wine-11.18.tar.xz
scripts/apply-series.sh patches/wine-arm64 wine-11.18
```

그다음은 `build/BUILD.md` 의 해당 구성요소 안내를 따르면 됩니다. 패치 시리즈는 올리기 전에 원본에 그대로 붙는지 확인합니다.

## Ember.app 의 LGPL 라이브러리를 직접 만든 것으로 바꾸기

LGPL 구성요소는 모두 앱 번들 안의 별도 파일이라 직접 빌드한 것으로 바꿀 수 있습니다.

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
   `@rpath/libgnutls.30.dylib`)·아키텍처·최소 macOS 버전으로 만들고, 절대 경로 LC_RPATH 는 지웁니다.
3. 사본 안의 원래 파일 위에 복사하고 그 파일만 서명합니다: `codesign -s - -f <파일>`.
   Wine 프로세스는 라이브러리 검증을 끈 채 돌기 때문에 직접 서명한 라이브러리도 올라갑니다. Wine 실행 파일
   (`wine`, `wineserver`, `wine-host`)을 바꿀 때는 `build/wine/wine.entitlements` 권한을 붙여 서명합니다:
   `codesign -s - -f -o runtime --entitlements build/wine/wine.entitlements <파일>`.
4. 앱 전체를 다시 서명하지 **마세요**. Ember 는 자기 실행 파일의 서명을 확인하는데, `Contents/Resources` 아래 파일만
   바꾸면 그 서명은 그대로 유효합니다. 첫 실행 때 macOS 가 번들을 다시 검사하지 않도록 사본의 다운로드 격리 표시를
   지웁니다: `xattr -dr com.apple.quarantine ~/Applications/Ember-custom.app`
5. 사본을 실행합니다. Ember 를 업데이트하면 앱이 새로 바뀌므로 바꾼 파일을 다시 넣어야 합니다. Ember 이용 약관은 LGPL
   구성요소를 고치는 것이나, 고친 것을 디버깅하려고 역분석하는 것을 막지 않습니다.

## 서면 제안

이 저장소를 쓸 수 없으면 Ember 1.0 을 받은 날부터 3년 안에 realnoma@naver.com 으로 요청해 주세요. 같은 소스를
매체나 내려받기로, 보내는 데 드는 비용 이상은 받지 않고 보내 드립니다. 이 제안은 Ember 를 받은 누구에게나 유효합니다.

## 문의

realnoma@naver.com
