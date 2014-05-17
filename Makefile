default_target: main
.PHONY : default_target

TARGET = $@

ifdef offset
INSERT=$(shell printf "%d" 0x$(offset))
endif

PATH      := /opt/devkitpro/devkitARM/bin:$(PATH)
OPTS := -fauto-inc-dec -fcompare-elim -fcprop-registers -fdce -fdefer-pop -fdelayed-branch -fdse -fguess-branch-probability -fif-conversion2 -fif-conversion -fipa-pure-const -fipa-profile -fipa-reference -fmerge-constants -fsplit-wide-types -ftree-bit-ccp -ftree-builtin-call-dce -ftree-ccp -ftree-ch -ftree-copyrename -ftree-dce -ftree-dominator-opts -ftree-dse -ftree-forwprop -ftree-fre -ftree-phiprop -ftree-sra -ftree-pta -ftree-ter -funit-at-a-time -fomit-frame-pointer -fthread-jumps -falign-functions -falign-jumps -falign-loops  -falign-labels -fcaller-saves -fcrossjumping -fcse-follow-jumps  -fcse-skip-blocks -fdelete-null-pointer-checks -fdevirtualize -fexpensive-optimizations -fgcse -fgcse-lm -finline-small-functions -findirect-inlining -fipa-sra -foptimize-sibling-calls -fpartial-inlining -fpeephole2 -fregmove -freorder-blocks -freorder-functions -frerun-cse-after-loop -fsched-interblock -fsched-spec -fschedule-insns -fschedule-insns2 -fstrict-aliasing -fstrict-overflow -ftree-switch-conversion -ftree-tail-merge -ftree-pre -ftree-vrp -finline-functions -funswitch-loops -fpredictive-commoning -fgcse-after-reload -ftree-slp-vectorize -fvect-cost-model -fipa-cp-clone -ffast-math -fno-protect-parens -fstack-arrays -fforward-propagate -finline-functions-called-once -fmerge-all-constants -fmodulo-sched -fmodulo-sched-allow-regmoves -fgcse-sm -fgcse-las -funsafe-loop-optimizations -fconserve-stack

main : 
	sed 's/^        rom     : ORIGIN = 0x08XXXXXX, LENGTH = 32M$$/        rom     : ORIGIN = 0x08$(offset), LENGTH = 32M/' linker_base.lsc > linker.lsc
	arm-none-eabi-gcc ${OPTS} -mthumb -mthumb-interwork -Dengine=1 -g -c -w -o main.out main.s
	arm-none-eabi-ld -o main.o -T linker.lsc main.out
	arm-none-eabi-objcopy -O binary main.o main.bin
	rm main.o
	rm main.out
	rm linker.lsc

#Auto-Insert into the ROM
ifdef rom
ifdef INSERT
	dd if=main.bin of="$(rom)" conv=notrunc seek=$(INSERT) bs=1
else
	@echo "Insertion location not found!"
	@echo "Did you forget to define 'offset'?"
	@echo "Ex: make rom=<game.gba> offset=<offset in hex>"
endif
else
	@echo "File location not found!"
	@echo "Did you forget to define 'rom'?"
	@echo "Ex: make rom=<game.gba> offset=<offset in hex>"
endif

.PHONY : main