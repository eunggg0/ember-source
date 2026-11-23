# WineARM64/lib/wine/aarch64-windows/mshtml.dll

The aarch64 mshtml.dll was built before `patches/wine-arm64/0014-dlls-mshtml.patch`; the i386 mshtml.dll includes it. This series removes 0014 again, so `dlls/mshtml/htmlnode.c`, `mutation.c` and `omnavigator.c` are the unmodified Wine 11.18 files used for the aarch64 build (none of the strings added by 0014 are in the shipped aarch64 file).

aarch64 mshtml.dll 은 `patches/wine-arm64/0014-dlls-mshtml.patch` 전에 빌드한 것입니다(i386 mshtml.dll 에는 들어 있음). 이 series 는 0014 를 다시 빼서 `dlls/mshtml/htmlnode.c`·`mutation.c`·`omnavigator.c` 를 aarch64 빌드에 쓴 Wine 11.18 원본으로 되돌립니다(0014 가 더한 문자열은 출시 aarch64 파일에 하나도 없음).

```sh
sh scripts/apply-series.sh patches/wine-arm64 "$src"
sh scripts/apply-series.sh patches/wine-arm64-aarch64-mshtml "$src"
```
