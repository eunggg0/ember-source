# v1.0.1.2 DXGI 빌드 입력

`upstream/SOURCES.tsv`의 DXMT `7c8dee1` 압축 파일을 풉니다. 같은 소스 디렉터리에 다음 두 series를 순서대로 적용합니다. 두 번째 series는 DXGI가 링크하는 정적 라이브러리의 소스·헤더 네 개를 출시 입력으로 되돌리고 생성 헤더 세 개를 복원합니다.

```sh
sh scripts/apply-series.sh patches/dxmt-dxgi "$DXGI_SRC"
sh scripts/apply-series.sh patches/dxmt-dxgi-release "$DXGI_SRC"
```

d3d10core는 같은 압축 파일을 별도 디렉터리에 풀어 기존 series 하나를 적용합니다.

```sh
sh scripts/apply-series.sh patches/dxmt-nvext-d3d10core "$D3D10_SRC"
```

세 아키텍처 모두 Meson `release`, DXMT 버전 문자열 `v0.1`, UCRT용 llvm-mingw 20260908과 Wine의 `winebuild --builtin`을 사용합니다. DXGI에는 Wine의 winemetal 빌드 의존성과 macOS용 Metal 컴파일러가 필요합니다. Meson 대상은 `src/dxgi/dxgi.dll`과 `src/d3d10/d3d10core.dll`입니다.

출시본의 전체 파일 SHA256을 대조하려면 각 DLL의 마지막 링크에 `-Wl,--Xlink=/timestamp:<값>`을 주고, 링크한 DLL에 `winebuild --builtin <DLL>`을 실행합니다. 타임스탬프는 PE/COFF 헤더에 들어 있는 초 단위 정수입니다.

| 아키텍처 | Meson cross file | dxgi.dll | d3d10core.dll |
|---|---|---:|---:|
| x86_64 | `build-win64.txt` | 1790948189 | 1790865143 |
| i386 | `build-win32.txt` | 1790948196 | 1790865221 |
| arm64ec | `build-arm64ec.txt` | 1790948208 | 1790865248 |
