Pokémon Gen III HQ Sound Mixer
==============================

ipatix' high quality sound mixer for the Generation III Pokemon games. See [this](http://www.pokecommunity.com/showthread.php?t=324673) PokéCommunity thread for more information.

YouTube video demonstration: [Pokemon High Quality Sound (Custom ASM Routine)](http://www.youtube.com/watch?v=xvUpR0w5hZI)

[![Pokemon High Quality Sound (Custom ASM Routine)](http://img.youtube.com/vi/xvUpR0w5hZI/0.jpg)](http://www.youtube.com/watch?v=xvUpR0w5hZI)

Assembling and Injecting
------------------------

You'll need devkitARM from http://sourceforge.net/projects/devkitpro/.

To assemble and inject into a ROM, run `make <game id> rom=<game.gba> offset=<offset in hex>`. Omit the `0x`, you don't need that.

The Makefile targets BPEE by default, valid `<game id>` arguments are `bpee`, `bped`, `bpre,` and `kwj6`.

The assembled binary, `main.bin`, should be 1952 (`0x7A0`) bytes long.

To find a suitable offset for injection, open up your ROM in a hex editor and look for an address that has at least 1952 (`0x7A0`) bytes of continous `00`'s.

In a clean BPEE ROM, one such address would be `0xDE4020`.

The location of the injected binary doesn't really matter, since this routine is loaded to IRAM before execution automatically anyway. It just has to be in free space.

After injection is complete, you need to modify the pointer, since we're replacing an already-existing routine. Make sure you attach a `0x08` to the beginning of the pointer!

Pointer addresses:

* BPEE: `0x2E00F0`
* BPED: `0x2F5E30`
* BPRE: `0x1DD0B4`

For example, for BPEE, open a hex editor, jump to the address `0x2E00F0`. Assuming you injected the binary into address `0xDE4020` as described above, you would change the pointer to `2040DE08`.

An example bash script is provided, `make-bpee.sh` will automatically assemble the code and inject the assembled binary into a clean BPEE ROM named `bpee.gba` at the address `0xDE4020`. You will still need to manually hex edit the pointer at `0x2E00F0`.

Introduction to the HQ Sound Mixer
----------------------------------

This is a pretty easy to do mod which could be used by any hack regardless of the use of music hacks. It also improves the vanilla music quality at no cost.

As you might already know from the project name, this is a new Sound Mixing Routine for GBA Pokemon games that ipatix developed.

But what is the Sound Mixer? To understand what it does you need to know how digital sound is produced and what hardware ability the AGB has.

For a basic explanation: The AGB only has 2 hardware channels for sound playback (usually one for the left and one for the right speaker).

With these 2 channels we could only play 1 stereo sound at one of the 12 samplingrates the AGB hardware supports. This is where the mixer and a resampler comes in handy. The mixer "mixes" together a few sounds and produces one output sound.

Using this we can play back more sound at the same time and if we use this in combination with a resampler we can playback any sound at any given samplingrate (--> variable pitch) at the same time.

All of this is done by Nintendo's (with some mods done by Game Freak) Sound Engine which comes with their SDK. Sounds cool, doesn't it?

There is one major flaw with the design of the Mixer though:

The Sound Mixer produces a short period of sound each frame (~ 1/60 s) which gets placed in a buffer in memory. This data is then transferred by hardware timers and DMAs to the sound circuit for playback.

Since the AGB only supports 8 bit resoultion of the audio samples this buffer must have an 8 bit depth. Because Nintendo wanted to make their code use less System ressources and RAM they also use this output buffer as work area for the actual mixing.

This might not sound very problematic, but the issues we are getting is that a Sound that has an 8 bit resolution has audible quantization noise.

This quantization noise is pretty low, however, each time the mixer adds another sound from a virtual channel (these are also called Direct Sound channels although they have nothing to do with Microsoft's DirectSound) it adds quantization noise to the buffer due to the volume scaling that is always done (we can't play all channels at a fixed volume).

Because the quantization noise is applied once per channel it get's really loud and is really annoying (even in some commercial titles, not Pokemon though). In Pokemon games this is mostly not noticeable due to an untrained ear and the limited virtual Direct Sound channels of 5.

5 Direct Sound channels aren't much though (if you have ever done Music Hacking) and ipatix has done the 12 channel hack already for quite a long time. This makes the noise worse though and it did make the music sound really bad sometimes.

The solution to this problem:

Let's use a work area with a higher bit depth (e.g. commonly used 16 bits, or 14 bits in my Routine) to eliminate quantization noise during the mixing process and only add the noise once for the final downscaling to the main output buffer.

The only problem we're getting is that we need an additional "work buffer" in IRAM. We need to use IRAM and not regular WRAM due to the execution performance we need.

This also why the mixing routine is really complicated and very annoying to read to get the best performance possible (although there still are some improvments possible).

The other thing that is necessary to run things as fast is possible is that the mixing routine is placed in IRAM as well for faster code loading and the ability to use the ARM instruction set with no performance cost but with the ability to reduce the overall amount of instructions.