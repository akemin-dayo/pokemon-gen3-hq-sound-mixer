.DEFAULT_GOAL := bpee
ifdef MAKECMDGOALS
CURRENT_GOAL = $(MAKECMDGOALS)
else
CURRENT_GOAL = $(.DEFAULT_GOAL)
endif

BPEEpointer = $(shell printf "%d" 0x2E00F0)
BPEDpointer = $(shell printf "%d" 0x2F5E30)
BPREpointer = $(shell printf "%d" 0x1DD0B4)
BPGEpointer = $(shell printf "%d" 0x1DD090)

PATH := /opt/devkitpro/devkitARM/bin:$(PATH)
OPTS := -fauto-inc-dec -fcompare-elim -fcprop-registers -fdce -fdefer-pop -fdelayed-branch -fdse -fguess-branch-probability -fif-conversion2 -fif-conversion -fipa-pure-const -fipa-profile -fipa-reference -fmerge-constants -fsplit-wide-types -ftree-bit-ccp -ftree-builtin-call-dce -ftree-ccp -ftree-ch -ftree-copyrename -ftree-dce -ftree-dominator-opts -ftree-dse -ftree-forwprop -ftree-fre -ftree-phiprop -ftree-sra -ftree-pta -ftree-ter -funit-at-a-time -fomit-frame-pointer -fthread-jumps -falign-functions -falign-jumps -falign-loops -falign-labels -fcaller-saves -fcrossjumping -fcse-follow-jumps  -fcse-skip-blocks -fdelete-null-pointer-checks -fdevirtualize -fexpensive-optimizations -fgcse -fgcse-lm -finline-small-functions -findirect-inlining -fipa-sra -foptimize-sibling-calls -fpartial-inlining -fpeephole2 -fregmove -freorder-blocks -freorder-functions -frerun-cse-after-loop -fsched-interblock -fsched-spec -fschedule-insns -fschedule-insns2 -fstrict-aliasing -fstrict-overflow -ftree-switch-conversion -ftree-tail-merge -ftree-pre -ftree-vrp -finline-functions -funswitch-loops -fpredictive-commoning -fgcse-after-reload -ftree-slp-vectorize -fvect-cost-model -fipa-cp-clone -ffast-math -fno-protect-parens -fstack-arrays -fforward-propagate -finline-functions-called-once -fmerge-all-constants -fmodulo-sched -fmodulo-sched-allow-regmoves -fgcse-sm -fgcse-las -funsafe-loop-optimizations -fconserve-stack

%::
	@sed 's/^        rom     : ORIGIN = 0x08XXXXXX, LENGTH = 32M$$/        rom     : ORIGIN = 0x08$(offset), LENGTH = 32M/' linker_base.lsc > linker.lsc
	@sed 's/^    .equ    USED_GAME, GAME_SELECTION/    .equ    USED_GAME, GAME_$(shell echo $@ | tr a-z A-Z)/' main.s > main-$@.s
	@arm-none-eabi-gcc ${OPTS} -mthumb -mthumb-interwork -Dengine=1 -g -c -w -o main-$@.out main-$@.s
	@arm-none-eabi-ld -o main-$@.o -T linker.lsc main-$@.out
	@arm-none-eabi-objcopy -O binary main-$@.o main-$@.bin
	@rm main-$@.{s,o,out} linker.lsc

#Auto-Insert into the ROM
ifndef rom
	@echo -e "File location not found!\nDid you forget to define 'rom'?\nEx: make <game id> rom=<game.gba> offset=<offset in hex>"
else # rom is defined
ifndef offset
	@echo -e "Injection location not found!\nDid you forget to define 'offset'?\nEx: make <game id> rom=<game.gba> offset=<offset in hex>"
else # offset is defined
	@dd if=main-$@.bin of="$(rom)" conv=notrunc seek=$(shell printf "%d" 0x$(offset)) bs=1
ifneq ($(CURRENT_GOAL),kwj6) # goal is bpee, bped, bpeg or bpre
	@printf '$(shell sed -e 's/\(..\)\(..\)\(..\)/\\\x\3\\\x\2\\\x\1/' <<< "$(offset)")\x08' | dd of="$(rom)" conv=notrunc seek=$($(shell echo $@ | tr a-z A-Z)pointer) bs=1
else # goal is kwj6
	@echo -e "Pointer location for build target $@ is unknown, it cannot be automatically patched.\nPlease change the pointer manually."
endif
endif
endif
