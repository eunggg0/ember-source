# WineARM64의 i386 DLL 세 개

Wine 11.18 원본에 `wine-arm64`와 이 series를 차례로 적용한다. 대상은 Ember 1.0.1.2의 `WineARM64/lib/wine/i386-windows/{kernelbase,ntdll,wmp}.dll`이다. 다른 Wine 모듈은 기존 series로 빌드한다.

```sh
sh scripts/apply-series.sh patches/wine-arm64 "$wine_src"
sh scripts/apply-series.sh patches/wine-arm64-i386-release "$wine_src"
```

i386를 활성화한 Wine 빌드 디렉터리에서 다음 세 타깃을 빌드할 수 있다.

```sh
make dlls/kernelbase/i386-windows/kernelbase.dll \
     dlls/ntdll/i386-windows/ntdll.dll \
     dlls/wmp/i386-windows/wmp.dll
```

출시 DLL에는 서로 다른 llvm-mingw 버전으로 컴파일한 오브젝트가 함께 들어 있다. 바이트 대조에는 macOS의 `dwarfdump`, llvm-mingw 20250920(Clang 21.1.0) 및 20260908(Clang 23.1.1), 출시 당시 구성의 Wine 11.18 빌드 디렉터리가 필요하다. 다음 명령은 그 디렉터리에서 생성 헤더, 링크 도구, 리소스와 라이브러리를 읽고 세 DLL의 직접 오브젝트를 임시 디렉터리에 모두 새로 컴파일한다. 출시 파일에서 원래 DWARF 경로와 링크 시각을 읽어 링커에 지정하고 최종 SHA-256을 비교한다.

```sh
python3 verify/rebuild-wine-i386.py --source "$wine_src" \
    --prepared-build "$prepared_build" --release-dir "$release_i386_dir" \
    --clang21-bin "$llvm_mingw_20250920/bin" --clang23-bin "$llvm_mingw_20260908/bin" \
    --work-dir "$scratch"
```
