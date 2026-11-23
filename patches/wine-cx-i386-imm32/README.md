# WineCX/lib/wine/i386-windows/imm32.dll

The i386 imm32.dll was built before the IMM32 Korean input updates in `patches/wine-cx/0034-dlls-imm32.patch` and the imm32 part of `0096-ime-korean-composition.patch` (both were rebuilt only for x86_64). This series returns `dlls/imm32/ime.c`, `imm.c` and `imm_private.h` to the state used for the i386 build. Rebuilding from that state gives the same loaded sections as the shipped file; only DWARF debug sections differ.

i386 imm32.dll 은 `patches/wine-cx/0034-dlls-imm32.patch` 와 `0096-ime-korean-composition.patch` 의 imm32 부분(한글 입력 수정, x86_64 만 다시 빌드) 전에 빌드한 것입니다. 이 series 는 `dlls/imm32/ime.c`·`imm.c`·`imm_private.h` 를 i386 빌드에 쓴 상태로 되돌립니다. 그 상태로 다시 빌드하면 적재 섹션이 출시 파일과 같고 디버그 정보만 다릅니다.

```sh
sh scripts/apply-series.sh patches/wine-cx "$src"
sh scripts/apply-series.sh patches/wine-cx-i386-imm32 "$src"
```
