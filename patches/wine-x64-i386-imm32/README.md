# Wine/lib/wine/i386-windows/imm32.dll

The i386 imm32.dll in Ember 1.0.1.x was built before the IMM32 Korean input update in `patches/wine-x64/0004-dlls-imm32.patch` (that update was rebuilt only for x86_64). This series returns `dlls/imm32/ime.c` and `imm.c` to the state used for the i386 build. Rebuilding the i386 DLL from that state gives the same .text, .rdata, .data, .edata, .idata, .reloc and .rsrc sections as the shipped file; only DWARF debug sections (build paths) differ.

Ember 1.0.1.x 의 i386 imm32.dll 은 `patches/wine-x64/0004-dlls-imm32.patch` 의 IMM32 한글 입력 수정 전에 빌드한 것입니다(그 수정은 x86_64 만 다시 빌드). 이 series 는 `dlls/imm32/ime.c`·`imm.c` 를 i386 빌드에 쓴 상태로 되돌립니다. 그 상태로 i386 DLL 을 다시 빌드하면 출시 파일과 .text·.rdata·.data·.edata·.idata·.reloc·.rsrc 섹션이 같고, 디버그 정보(빌드 경로)만 다릅니다.

```sh
sh scripts/apply-series.sh patches/wine-x64 "$src"
sh scripts/apply-series.sh patches/wine-x64-i386-imm32 "$src"
```
