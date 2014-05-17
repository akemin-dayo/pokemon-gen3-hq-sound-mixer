Pokémon Gen III HQ Sound Mixer
==============================

ipatix' high quality sound mixer for the Generation III Pokemon games. See [this](http://www.pokecommunity.com/showthread.php?t=324673) PokéCommunity thread for more information.

YouTube video demonstration: [Pokemon High Quality Sound (Custom ASM Routine)](http://www.youtube.com/watch?v=xvUpR0w5hZI)

[![Pokemon High Quality Sound (Custom ASM Routine)](http://img.youtube.com/vi/xvUpR0w5hZI/0.jpg)](http://www.youtube.com/watch?v=xvUpR0w5hZI)

Assembling and Injecting
------------------------

You'll need devkitARM from http://sourceforge.net/projects/devkitpro/.

To assemble and inject into a ROM, run `make rom=<game.gba> offset=<offset in hex>`. Omit the `0x`, you don't need that.

The code targets BPEE by default, change `.equ    USED_GAME, GAME_BPEE` to `GAME_BPED`, `GAME_BPRE`, or `GAME_KWJ6` as you desire.

The assembled binary, `main.bin`, should be 1952 (0x7A0) bytes long.

To find a suitable offset for injection, open up your ROM in a hex editor and look for an address that has at least 1952 (0x7A0) bytes of continous 00's.

In a clean BPEE ROM, one such address would be `0xDE4020`.

The location of the injected binary doesn't really matter, since this routine is loaded to IRAM before execution automatically anyway. It just has to be in free space.

After injection is complete, you need to modify the pointer, since we're replacing an already-existing routine. Make sure you attach a `0x08` to the beginning of the pointer!

Pointer addresses:

* BPEE: `0x2E00F0`
* BPED: `0x2F5E30`
* BPRE: `0x1DD0B4`

For example, for BPEE, open a hex editor, jump to the address 0x2E00F0. Assuming you injected the binary into address `0xDE4020` as described above, you would change the pointer to `2040DE08`.

An example bash script is provided, `make-bpee.sh` will automatically assemble the code and inject the assembled binary into a clean BPEE ROM named `bpee.gba`.