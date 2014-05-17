default_target: bpee
.PHONY : default_target

TARGET = $@

ifdef offset
INSERT=$(shell printf "%d" 0x$(offset))
endif

PATH      := /opt/devkitpro/devkitARM/bin:$(PATH)
OPTS := -fauto-inc-dec -fcompare-elim -fcprop-registers -fdce -fdefer-pop -fdelayed-branch -fdse -fguess-branch-probability -fif-conversion2 -fif-conversion -fipa-pure-const -fipa-profile -fipa-reference -fmerge-constants -fsplit-wide-types -ftree-bit-ccp -ftree-builtin-call-dce -ftree-ccp -ftree-ch -ftree-copyrename -ftree-dce -ftree-dominator-opts -ftree-dse -ftree-forwprop -ftree-fre -ftree-phiprop -ftree-sra -ftree-pta -ftree-ter -funit-at-a-time -fomit-frame-pointer -fthread-jumps -falign-functions -falign-jumps -falign-loops  -falign-labels -fcaller-saves -fcrossjumping -fcse-follow-jumps  -fcse-skip-blocks -fdelete-null-pointer-checks -fdevirtualize -fexpensive-optimizations -fgcse -fgcse-lm -finline-small-functions -findirect-inlining -fipa-sra -foptimize-sibling-calls -fpartial-inlining -fpeephole2 -fregmove -freorder-blocks -freorder-functions -frerun-cse-after-loop -fsched-interblock -fsched-spec -fschedule-insns -fschedule-insns2 -fstrict-aliasing -fstrict-overflow -ftree-switch-conversion -ftree-tail-merge -ftree-pre -ftree-vrp -finline-functions -funswitch-loops -fpredictive-commoning -fgcse-after-reload -ftree-slp-vectorize -fvect-cost-model -fipa-cp-clone -ffast-math -fno-protect-parens -fstack-arrays -fforward-propagate -finline-functions-called-once -fmerge-all-constants -fmodulo-sched -fmodulo-sched-allow-regmoves -fgcse-sm -fgcse-las -funsafe-loop-optimizations -fconserve-stack

bpee : 
	sed 's/^        rom     : ORIGIN = 0x08XXXXXX, LENGTH = 32M$$/        rom     : ORIGIN = 0x08$(offset), LENGTH = 32M/' linker_base.lsc > linker.lsc
	cp main.s main-bpee.s
	arm-none-eabi-gcc ${OPTS} -mthumb -mthumb-interwork -Dengine=1 -g -c -w -o main-bpee.out main-bpee.s
	arm-none-eabi-ld -o main-bpee.o -T linker.lsc main-bpee.out
	arm-none-eabi-objcopy -O binary main-bpee.o main-bpee.bin
	rm main-bpee.s
	rm main-bpee.o
	rm main-bpee.out
	rm linker.lsc

#Auto-Insert into the ROM
ifdef rom
ifdef INSERT
	dd if=main-bpee.bin of="$(rom)" conv=notrunc seek=$(INSERT) bs=1
else
	@echo "Injection location not found!"
	@echo "Did you forget to define 'offset'?"
	@echo "Ex: make <game id> rom=<game.gba> offset=<offset in hex>"
endif
else
	@echo "File location not found!"
	@echo "Did you forget to define 'rom'?"
	@echo "Ex: make <game id> rom=<game.gba> offset=<offset in hex>"
endif

.PHONY : bped

bped : 
	sed 's/^        rom     : ORIGIN = 0x08XXXXXX, LENGTH = 32M$$/        rom     : ORIGIN = 0x08$(offset), LENGTH = 32M/' linker_base.lsc > linker.lsc
	sed 's/^    .equ    USED_GAME, GAME_BPEE/    .equ    USED_GAME, GAME_BPED/' main.s > main-bped.s
	arm-none-eabi-gcc ${OPTS} -mthumb -mthumb-interwork -Dengine=1 -g -c -w -o main-bped.out main-bped.s
	arm-none-eabi-ld -o main-bped.o -T linker.lsc main-bped.out
	arm-none-eabi-objcopy -O binary main-bped.o main-bped.bin
	rm main-bped.s
	rm main-bped.o
	rm main-bped.out
	rm linker.lsc

#Auto-Insert into the ROM
ifdef rom
ifdef INSERT
	dd if=main-bped.bin of="$(rom)" conv=notrunc seek=$(INSERT) bs=1
else
	@echo "Injection location not found!"
	@echo "Did you forget to define 'offset'?"
	@echo "Ex: make <game id> rom=<game.gba> offset=<offset in hex>"
endif
else
	@echo "File location not found!"
	@echo "Did you forget to define 'rom'?"
	@echo "Ex: make <game id> rom=<game.gba> offset=<offset in hex>"
endif

.PHONY : bped

bpre : 
	sed 's/^        rom     : ORIGIN = 0x08XXXXXX, LENGTH = 32M$$/        rom     : ORIGIN = 0x08$(offset), LENGTH = 32M/' linker_base.lsc > linker.lsc
	sed 's/^    .equ    USED_GAME, GAME_BPEE/    .equ    USED_GAME, GAME_BPRE/' main.s > main-bpre.s
	arm-none-eabi-gcc ${OPTS} -mthumb -mthumb-interwork -Dengine=1 -g -c -w -o main-bpre.out main-bpre.s
	arm-none-eabi-ld -o main-bpre.o -T linker.lsc main-bpre.out
	arm-none-eabi-objcopy -O binary main-bpre.o main-bpre.bin
	rm main-bpre.s
	rm main-bpre.o
	rm main-bpre.out
	rm linker.lsc

#Auto-Insert into the ROM
ifdef rom
ifdef INSERT
	dd if=main-bpre.bin of="$(rom)" conv=notrunc seek=$(INSERT) bs=1
else
	@echo "Injection location not found!"
	@echo "Did you forget to define 'offset'?"
	@echo "Ex: make <game id> rom=<game.gba> offset=<offset in hex>"
endif
else
	@echo "File location not found!"
	@echo "Did you forget to define 'rom'?"
	@echo "Ex: make <game id> rom=<game.gba> offset=<offset in hex>"
endif

.PHONY : bpre

kwj6 : 
	sed 's/^        rom     : ORIGIN = 0x08XXXXXX, LENGTH = 32M$$/        rom     : ORIGIN = 0x08$(offset), LENGTH = 32M/' linker_base.lsc > linker.lsc
	sed 's/^    .equ    USED_GAME, GAME_BPEE/    .equ    USED_GAME, GAME_BPRE/' main.s > main-kwj6.s
	arm-none-eabi-gcc ${OPTS} -mthumb -mthumb-interwork -Dengine=1 -g -c -w -o main-kwj6.out main-kwj6.s
	arm-none-eabi-ld -o main-kwj6.o -T linker.lsc main-kwj6.out
	arm-none-eabi-objcopy -O binary main-kwj6.o main-kwj6.bin
	rm main-kwj6.s
	rm main-kwj6.o
	rm main-kwj6.out
	rm linker.lsc

#Auto-Insert into the ROM
ifdef rom
ifdef INSERT
	dd if=main-kwj6.bin of="$(rom)" conv=notrunc seek=$(INSERT) bs=1
else
	@echo "Injection location not found!"
	@echo "Did you forget to define 'offset'?"
	@echo "Ex: make <game id> rom=<game.gba> offset=<offset in hex>"
endif
else
	@echo "File location not found!"
	@echo "Did you forget to define 'rom'?"
	@echo "Ex: make <game id> rom=<game.gba> offset=<offset in hex>"
endif

.PHONY : kwj6