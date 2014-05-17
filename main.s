@ created by ~ipatix~

    .equ    GAME_BPED, 0
    .equ    GAME_BPEE, 1
    .equ    GAME_BPRE, 2
    .equ    GAME_KWJ6, 3


    .equ    USED_GAME, GAME_BPEE                @ CHOOSE YOUR GAME

    .equ    FRAME_LENGTH_5734, 0x60
    .equ    FRAME_LENGTH_7884, 0x84
    .equ    FRAME_LENGTH_10512, 0xB0
    .equ    FRAME_LENGTH_13379, 0xE0            @ DEFAULT
    .equ    FRAME_LENGTH_15768, 0x108
    .equ    FRAME_LENGTH_18157, 0x130
    .equ    FRAME_LENGTH_21024, 0x160
    .equ    FRAME_LENGTH_26758, 0x1C0
    .equ    FRAME_LENGTH_31536, 0x210
    .equ    FRAME_LENGTH_36314, 0x260
    .equ    FRAME_LENGTH_40137, 0x2A0
    .equ    FRAME_LENGTH_42048, 0x2C0

    .equ    BPED_DELTA_TABLE, 0x08686C5C
    .equ    BPEE_DELTA_TABLE, 0x08675A70
    .equ    BPRE_DELTA_TABLE, 0x084899F8
    .equ    KWJ6_DELTA_TABLE, 0x0807CC0C

    .equ    DECODER_BUFFER_BPE, 0x03001300
    .equ    DECODER_BUFFER_BPR, 0x03002088
    .equ    DECODER_BUFFER_KWJ, 0x03005800

    .equ    FREE_IRAM_BPE, 0x03005100
    .equ    FREE_IRAM_BPR, 0x03004200
    .equ    FREE_IRAM_KWJ, 0x03005840

@*********** IF BPED
.if USED_GAME==GAME_BPED

    .equ    hq_buffer, FREE_IRAM_BPE
    .equ    buffer_spacing, FRAME_LENGTH_13379*2
    .equ    delta_table, BPED_DELTA_TABLE
    .equ    decoder_buffer_target, DECODER_BUFFER_BPE
    .equ    ALLOW_PAUSE, 1

.endif
@*********** IF BPEE
.if USED_GAME==GAME_BPED

    .equ    hq_buffer, FREE_IRAM_BPE
    .equ    buffer_spacing, FRAME_LENGTH_13379*2
    .equ    delta_table, BPEE_DELTA_TABLE
    .equ    decoder_buffer_target, DECODER_BUFFER_BPE
    .equ    ALLOW_PAUSE, 1

.endif
@*********** IF BPRE
.if USED_GAME==GAME_BPRE

    .equ    hq_buffer, FREE_IRAM_BPR
    .equ    buffer_spacing, FRAME_LENGTH_13379*2
    .equ    delta_table, BPRE_DELTA_TABLE
    .equ    decoder_buffer_target, DECODER_BUFFER_BPR
    .equ    ALLOW_PAUSE, 1

.endif
@*********** IF KWJ6
.if USED_GAME==GAME_KWJ6

    .equ    hq_buffer, FREE_IRAM_KWJ
    .equ    buffer_spacing, FRAME_LENGTH_13379*2
    .equ    delta_table, KWJ6_DELTA_TABLE
    .equ    decoder_buffer_target, DECODER_BUFFER_KWJ
    .equ    ALLOW_PAUSE, 0

.endif
@***********

    .equ    CHN_STATUS, 0x0
    .equ    CHN_MODE, 0x1
    .equ    CHN_VOL_1, 0x2
    .equ    CHN_VOL_2, 0x3
    .equ    CHN_ATTACK, 0x4
    .equ    CHN_DECAY, 0x5
    .equ    CHN_SUSTAIN, 0x6
    .equ    CHN_RELEASE, 0x7
    .equ    CHN_ADSR_LEVEL, 0x9
    .equ    CHN_FINAL_VOL_1, 0xA
    .equ    CHN_FINAL_VOL_2, 0xB
    .equ    CHN_ECHO_VOL, 0xC
    .equ    CHN_ECHO_REMAIN, 0xD
    .equ    CHN_POSITION_REL, 0x18                @ RELATIVE FOR COMPRESSED SAMPLES (decrementing)
    .equ    CHN_FINE_POSITION, 0x1C
    .equ    CHN_FREQUENCY, 0x20
    .equ    CHN_WAVE_OFFSET, 0x24
    .equ    CHN_POSITION_ABS, 0x28                @ RELATIVE FOR COMPRESSED SAMPLES (incrementing)
    .equ    CHN_BLOCK_COUNT, 0x3C

    .equ    WAVE_LOOP_FLAG, 0x3
    .equ    WAVE_FREQ, 0x4
    .equ    WAVE_LOOP_START, 0x8
    .equ    WAVE_LENGTH, 0xC

    .equ    ARG_FRAME_LENGTH, 0x0
    .equ    ARG_CHN_LEFT, 0x4
    .equ    ARG_BUFFER_POS, 0x8
    .equ    ARG_ABS_LOOP_OFFSET, 0xC
    .equ    ARG_LOOP_MODE, 0x10
    .equ    ARG_SCAN_LIMIT, 0x14
    .equ    ARG_VAR_AREA, 0x18

    .equ    VAR_REVERB, 0x5
    .equ    VAR_MAX_CHN, 0x6
    .equ    VAR_MASTER_VOL, 0x7
    .equ    VAR_DEF_PITCH_FAC, 0x18
    .equ    VAR_FIRST_CHN, 0x50

    .equ    FLAG_CHN_INIT, 0x80
    .equ    FLAG_CHN_RELEASE, 0x40
    .equ    FLAG_CHN_COMP, 0x20
    .equ    FLAG_CHN_LOOP, 0x10
    .equ    FLAG_CHN_ECHO, 0x4
    .equ    FLAG_CHN_ATTACK, 0x3
    .equ    FLAG_CHN_DECAY, 0x2
    .equ    FLAG_CHN_SUSTAIN, 0x1

    .equ    MODE_COMPRESSED, 0x30
    .equ    MODE_FIXED_FREQ, 0x8
    .equ    MODE_REVERSE, 0x10

    .global    mixer_entry
    .thumb
    .align 2

@********************* ENTRY ************************@
mixer_entry:

LDRB    R3, [R0, #VAR_REVERB]            @ Load Reverb Value from byte #5 given by var area to R3
CMP    R3, #0                    @ 
BEQ    clear_buffer                @ if Reverb == 0 --> just clear the buffer and don't do any reverb

ADR    R1, do_reverb                @ Reverb is enabled --> load reverb handler label to R1
BX    R1                    @ switch to ARM and execute Reverb Handler
@******************* ENTRY END **********************@

    .align 2
    .arm

@******************* DO REVERB **********************@
do_reverb:

CMP    R4, #2                    @ load 2nd reverb source from frame before
ADDEQ    R7, R0, #0x350                @ this resets the position to read data from the frame before the actual work frame
ADDNE    R7, R5, R8                @
MOV    R4, R8                    @ R4 shall be a countdown variable

LDR    R10, hq_buffer_1            @ ### load alternate buffer location
LDR    R11, buffer_spacing_1            @ ### do the same for the buffer spacing


reverb_loop:
LDRSB    R0, [R5, R6]                @ load 2nd buffer sample to R0
LDRSB    R1, [R5], #1                @ ### load 1st buffer sample to R1 --- modified the sample pointer extension
ADD    R0, R0, R1                @ mix samples together
LDRSB    R1, [R7, R6]                @ load 2nd buffer sample from previous frame to R1
ADD    R0, R0, R1                @ mix samples together
LDRSB    R1, [R7], #1                @ load 1st buffer sample from previous frame to R1 and increment sample counter
ADD    R0, R0, R1                @ mix samples together
MUL    R1, R0, R3                @ apply reverb level by multiplication
MOV    R0, R1, ASR#3                @ ### shift down sample from s8 to s16 (changed from ASR#9 to ASR#3) - modified -
TST    R0, #0x3000                @ check if sample is negative
ADDNE    R0, R0, #0x20                @ add #1 to sample if negative - this improves the ASR division for the negative area because the lowest possible negative division result is -1 and not 0
STRH    R0, [R10, R11]                @ write calculated reverb sample to HQ buffer 2
STRH    R0, [R10], #2                @ write calculated reverb sample to HQ buffer 1 and increment buffer counter by two (16 bit samples each)
SUBS    R4, R4, #1                @ decrease buffer counter by 1
BGT    reverb_loop                @ if the counter is > 0 repeat the procedure

ADR    R0, loop_setup+1            @ load next step label to R0
BX    R0                    @ jump and switch back to THUMB
@******************* REVERB END *********************@

    .thumb
    
@******************* BUFF CLEAR *********************@
clear_buffer:

MOV    R0, #0                    @ Copy 0 to R0 to be able to use this register to clear memory
MOV    R1, R8                    @ Copy Buffer length to R1 for calculation
LDR    R5, hq_buffer_1                @ ### override the buffer position with the HQ one
LDR    R6, buffer_spacing_1            @ ### do the same for the buffer spacing
ADD    R6, R6, R5                @ Buffer position + stereo spacing = buffer #2 position
LSR    R1, #2                    @ check for bad buffer alignment and clear the buffer depending on that
                        @ ### changed shift from 3 to 2 (buffer twice as long)

BCC    clear_buffer_align_8

clear_buffer_align_4:                @ if buffer is 4 aligned

STMIA    R5!, {R0}
STMIA    R6!, {R0}

clear_buffer_align_8:                @ if buffer is 8 aligned

LSR    R1, #1
BCC    clear_buffer_align_16

STMIA    R5!, {R0}
STMIA    R6!, {R0}
STMIA    R5!, {R0}
STMIA    R6!, {R0}

clear_buffer_align_16:                @ if buffer is 16 aligned (usual case)

STMIA    R5!, {R0}
STMIA    R6!, {R0}
STMIA    R5!, {R0}
STMIA    R6!, {R0}
STMIA    R5!, {R0}
STMIA    R6!, {R0}
STMIA    R5!, {R0}
STMIA    R6!, {R0}
SUB    R1, #1
BGT    clear_buffer_align_16            @ repeat procedure until buffer is cleared
B    loop_setup
@***************** BUFF CLEAR END *******************@


    .align 2
hq_buffer_1:
    .word    hq_buffer
buffer_spacing_1:
    .word    buffer_spacing

@********************* SETUP ************************@
loop_setup:

LDR    R4, [SP, #ARG_VAR_AREA]            @ load ARG_0x18 (main var area) to R4
LDR    R0, [R4, #VAR_DEF_PITCH_FAC]        @ load samplingrate pitch factor value to R0
MOV    R12, R0                    @ copy factor to R12
LDRB    R0, [R4, #VAR_MAX_CHN]            @ load MAX channels to R0
ADD    R4, #VAR_FIRST_CHN            @ R4 == Base channel Offset (Channel 0)
@******************* END SETUP **********************@

@***************** MAIN CHANNELS ********************@
channel_main_loop:

STR    R0, [SP, #ARG_CHN_LEFT]            @ store Max Channel value to create a count variable
LDR    R3, [R4, #CHN_WAVE_OFFSET]        @ load Wave Data offset to R3
LDR    R0, [SP, #ARG_SCAN_LIMIT]        @ load Scanline limit to R0 (0 = disabled)
CMP    R0, #0                    @ Scanline limit disabled?
BEQ    channel_begin                @ if limit is disabled skip the processing time limiter

LDR    R1, vcount_reg                @ load scanline register offset into R1
LDRB    R1, [R1]                @ load current scanline into R1
CMP    R1, #0xA0                @ is current scanline out of visivle area?
BCS    scanline_vblank

ADD    R1, #0xE4                @ add total amount of lines to R1

scanline_vblank:

CMP    R1, R0                    @ do the scanlines exceed the limit
BCC    channel_begin                @ if it doesn't continue with channel loop
B    mixer_end                @ if it does, end the loop

    .align 2
vcount_reg:
    .word    0x04000006            @ register address to vcount

channel_begin:

LDRB    R6, [R4]                @ load channel byte #0x0 to R6
MOVS    R0, #0xC7                @ load comparison byte into R0
TST    R0, R6                    @ is any of the bytes set?
BNE    channel_status_check            @ if any of 0xC7 bits is set then jump to channel_status_check
B    channel_check_processed_channels    @ if no bit is set go to the channel processing check

channel_status_check:

MOVS    R0, #FLAG_CHN_INIT            @ load "start channel" comparison value into R0
TST    R0, R6                    @ is the associated bit set?
BEQ    channel_envelope_handler        @ if it isn't set go over to TEMP_LABEL

MOVS    R0, #FLAG_CHN_RELEASE            @ load "channel on release" comparison value into R0
TST    R0, R6                    @ is the associated bit set?
BNE    channel_stop_func            @ if it IS set jump to label

                        @ The Routine will continue when the "channel started flag" is set and release is off

MOVS    R6, #FLAG_CHN_ATTACK            @ load channel status ATTACK to R6                - R3 = Wave Data Header Position - R4 = Channel Offset
STRB    R6, [R4]                @ write status to status byte in channel data array
MOVS    R0, R3                    @ load sample pointer to R0
ADD    R0, #0x10                @ extend wave data pointer so it points to the actual beginning of the wave data

@*************** Pokemon Games *****************@
.if ALLOW_PAUSE
LDR    R1, [R4, #CHN_POSITION_REL]        @ load sample position into R1
ADD    R0, R0, R1                @ add it to the base offset
STR    R0, [R4, #CHN_POSITION_ABS]        @ write the current sample position to 0x28 of channel in array
LDR    R0, [R3, #WAVE_LENGTH]            @ load sample length into R0
SUB    R0, R0, R1                @ R0 = Samples left (if it's 0 the end of sample is reached)
STR    R0, [R4, #CHN_POSITION_REL]        @ Write samples left into Relative Channel Position Variable in Channel
.endif
@************* End Pokemon Games ***************@

@**************** Other Games ******************@
.if ALLOW_PAUSE==0
STR    R0, [R4, #CHN_POSITION_ABS]
LDR    R0, [R3, #WAVE_LENGTH]
STR    R0, [R4, #CHN_POSITION_REL]
.endif
@************** End Other Games ****************@

MOVS    R5, #0                    @ Set R5 = 0
STRB    R5, [R4, #CHN_ADSR_LEVEL]        @ Reset Envelope level to #0
STR    R5, [R4, #CHN_FINE_POSITION]        @ Reset Fine Sample Position (UNCONFIRMED!!!)
LDRB    R2, [R3, #WAVE_LOOP_FLAG]        @ Load Loop Flag into R2
MOVS    R0, #0xC0                @ Load Loop Flag comparison value into R0    0x40 PROBABLY POSSIBLE ASWELL???
TST    R0, R2                    @ Loop off --> Equal; Loop on --> Not Equal
BEQ    channel_adsr_attack_handler        @ if the loop is off skip the loop handler

MOV    R0, #0x10                @
ORR    R6, R0                    @ Turn on Bit of channel status 0x10 / B.0001.0000
STRB    R6, [R4]                @ Info: Loop Flag in Channel Status
B    channel_adsr_attack_handler

channel_envelope_handler:
LDRB    R5, [R4, #CHN_ADSR_LEVEL]        @ load channel ADSR LEVEL to R5
MOVS    R0, #FLAG_CHN_ECHO            @ load Echo Flag to R0
TST    R0, R6                    @ is the Echo Flag Set?
BEQ    channel_adsr_no_echo            @ if Echo Flag is clear jump to regular ADSR handler

LDRB    R0, [R4, #CHN_ECHO_REMAIN]        @ load remainung Echo length to R0
SUB    R0, #1                    @ subtract by one
STRB    R0, [R4, #CHN_ECHO_REMAIN]        @ store remainung Echo length
BHI    channel_vol_calc            @ if Echo remain > 1 jump to main MATH --- Else go over to channel_stop

channel_stop_func:

MOVS    R0, #0                    @ load 0 into R0
STRB    R0, [R4]                @ write channel status 0 (STOP COMPLETLEY)
B    channel_check_processed_channels

channel_adsr_no_echo:

MOVS    R0, #FLAG_CHN_RELEASE            @ load Release Flag into R0 for comparison
TST    R0, R6                    @ is Release Flag clear?
BEQ    channel_adsr_no_release            @ Release clear --> goto no_release ; Release set --> continue func

LDRB    R0, [R4, #CHN_RELEASE]            @ load release value into R0 | INFO: R5 = ADSR LEVEL
MUL    R5, R0                    @ Multiplay ADSR Level with Release
LSR    R5, R5, #8                @ Divide ADSR Level by 256 -> new ADSR Level
LDRB    R0, [R4, #CHN_ECHO_VOL]            @ load Echo Volume to R0
CMP    R5, R0                    @ Is ADSR value higher than Echo vol?
BHI    channel_vol_calc            @ go on with main MATH

channel_adsr_check_echo_disabled:

LDRB    R5, [R4, #CHN_ECHO_VOL]            @ load up once again the Echo Vol to R5
CMP    R5, #0                    @ make sure that the Echo Vol is not 0 (to disable echo)
BEQ    channel_stop_func            @ channel got released and no Echo is enabled -> disable channel

MOVS    R0, #FLAG_CHN_ECHO            @ load the Echo Flag to R0
ORR    R6, R0                    @ Set the bit for the Echo flag in the channel status
STRB    R6, [R4]                @ write the Channel Status to memory
B    channel_vol_calc            @ go on with the main math

channel_adsr_no_release:

MOVS    R2, #3                    @ load B11 to R2 (to remove any other bits from the channel status)
AND    R2, R6                    @ cut away other buts from the channel status to R2
CMP    R2, #FLAG_CHN_DECAY            @ Check if the Decay bit is set
BNE    channel_adsr_no_decay

LDRB    R0, [R4, #CHN_DECAY]            @ load Channel Decay to R0
MUL    R5, R0                    @ multiplay ADSR level with decay value
LSR    R5, R5, #8                @ divide by 256 to scale back to 8 bit value
LDRB    R0, [R4, #CHN_SUSTAIN]            @ load Sustain level for comparison to R0
CMP    R5, R0                    @ check if the decayed ADSR level is above Sustain
BHI    channel_vol_calc            @ if Sustain level not reached yet go to main MATH

MOVS    R5, R0                    @ if sustain level is reached copy sustain level to R5
BEQ    channel_adsr_check_echo_disabled    @ if sustain level is 0 check echo first before disabling the channel

SUB    R6, #1                    @ change channel status to Sustain from Decay
STRB    R6, [R4]                @ write status to memory
B    channel_vol_calc            @ head over to the main MATH

channel_adsr_no_decay:

CMP    R2, #FLAG_CHN_ATTACK            @ compare if the channel status is ATTACK
BNE    channel_vol_calc

channel_adsr_attack_handler:
LDRB    R0, [R4, #CHN_ATTACK]            @ load Attack value to R0
ADD    R5, R5, R0                @ add attack value to adsr level
CMP    R5, #0xFF                @ check if adsr reached/overflowed highest value
BCC    channel_vol_calc

MOVS    R5, #0xFF                @ if overflow --> adsr = 0xFF
SUB    R6, #1                    @ change from attack to decay mode
STRB    R6, [R4]                @ save the channel status

channel_vol_calc:

STRB    R5, [R4, #CHN_ADSR_LEVEL]        @ write the current adsr level back to the channel var area
LDR    R0, [SP, #ARG_VAR_AREA]            @ load the main var area to R0
LDRB    R0, [R0, #VAR_MASTER_VOL]        @ load the Master Volume into R0
ADD    R0, #1                    @ Add #1 to master volume, so the range goes from 0-15 to 1-16
MUL    R0, R5                    @ multiply master volume with channel adsr level to calc next vol level
LSR    R5, R0, #4                @ divide the new volume level by 16 to scale doesn the value to 8 bits

LDRB    R0, [R4, #CHN_VOL_1]            @ load Volume 1 (right) into R0
MUL    R0, R5                    @ multiply with previous vol level to R0
LSR    R0, R0, #8                @ scale down back to 8 bits
STRB    R0, [R4, #CHN_FINAL_VOL_1]        @ write final volume 1 to channel vars

LDRB    R0, [R4, #CHN_VOL_2]            @ load Volume 2 (left) into R0
MUL    R0, R5                    @ do the same procedure
LSR    R0, R0, #8                @ shift back to 8 bits
STRB    R0, [R4, #CHN_FINAL_VOL_2]        @ write final volume 2 to channel vars

MOVS    R0, #FLAG_CHN_LOOP            @ write Loop Flag comparison value to R0
AND    R0, R6                    @ seperate the flag bit from the status (R6) -> R0
STR    R0, [SP, #ARG_LOOP_MODE]        @ store the loop flag to Stack ARG
BEQ    channel_setup_mixing            @ skip loop setup procedure

MOVS    R0, R3                    @ copy wave header pointer to R0
ADD    R0, #0x10                @ add 0x10 so it matches the beginning of the actual wave data
LDR    R1, [R3, #WAVE_LOOP_START]        @ load the loop start position into R1 --- R1 = LoopStart (relative)
ADD    R0, R0, R1                @ R0 = absolute pointer of loop start
STR    R0, [SP, #ARG_ABS_LOOP_OFFSET]        @ Write the Result to the Stack
LDR    R0, [R3, #WAVE_LENGTH]            @ load the sample length into R0 --- R0 = Length/End (relative)
SUB    R0, R0, R1                @ calculate the difference from Loop End to Loop Start and store it in R0
STR    R0, [SP, #ARG_LOOP_MODE]        @ store the difference in the WAVE_LOOP_MODE Argument

channel_setup_mixing:

LDR    R5, hq_buffer_2                @ load buffer position to R5
LDR    R2, [R4, #CHN_POSITION_REL]        @ load relative sample position into R2 (samples left)
LDR    R3, [R4, #CHN_POSITION_ABS]        @ load the current position from the samples in ROM to R3
ADR    R0, channel_mixing            @ prepare switch to ARM Mode for mixing
BX    R0                    @ switch to ARM Mode

    .align 2
    
hq_buffer_2:
    .word    hq_buffer
    .arm

channel_mixing:                    @ ---------------------- MIXING STARTS HERE ------------------

STR    R8, [SP, #ARG_FRAME_LENGTH]        @ load some (slower) WRAM work area into R8
LDR    R9, [R4, #CHN_FINE_POSITION]        @ load the fine channel position into R9
LDRB    R10, [R4, #CHN_FINAL_VOL_1]        @ load the renderer volume 1, to R10
LDRB    R11, [R4, #CHN_FINAL_VOL_2]        @ do the same for volume 2 to R11
LDRB    R0, [R4, #CHN_MODE]            @ load the compression Mode Byte into R0
TST    R0, #MODE_COMPRESSED            @ check if the sample is uncompressed (0x20 & 0x30 usually indicate compressed samples and will cause the Z flag to be false)
BEQ    channel_uncompressed_mixing

BL    channel_compressed_mixing        @ load the compression decoder mixer instead of the regular one
B    channel_var_freq_mixing_store_fine_pos    @ end compressed channel mixing and go over to the normal fine position storing

channel_uncompressed_mixing:            @ uncompressed mixing init function

MOV    R10, R10, LSL#8                @ ### expand the volume levels to 24 bits from 8 bits --- changed to 16 bits
MOV    R11, R11, LSL#8
LDRB    R0, [R4, #CHN_MODE]            @ load the channel mode to R0
TST    R0, #MODE_FIXED_FREQ            @ check if the channel mode is not fixed frequency
BEQ    channel_var_freq_mixing            @ jump over to the variable frequency routine --- There is two different routines for fixed (non resampled) rates because Drums usually play with only one pitch and can speed up code execution time if no resampling is enabled

channel_fixed_freq_mixing_loop:

CMP    R2, #2                    @ check if the left sample amount is smaller or equal to 4
BLE    channel_fixed_freq_mixing_fetch_last    @ go down and process last samples if it's 4 or less --- continue if it's more

SUBS    R2, R2, R8                @ subtract the frame length from R2 (left samples)
MOVGT    R9, #0                    @ if there is enough samples to fill the frame, copy 0 to R9
BGT    channel_fixed_freq_mixing_fetch_samples    @ 

MOV    R9, R8                    @ copy frame length to R9
ADD    R2, R2, R8                @ R2 = samples left (subtraced and added R8 (frame length)?)
SUB    R8, R2, #4                @ ################ UNKNOWN; MAYBE SOMETHING BROKEN ??? ################ subtract the left samples by 4 and place the result in R8 --- Edit: Apperantly nothing broken
SUB    R9, R9, R8                @ RESULTS --> R2 = left samples --> R8 = left samples-4 --> R9 = FrameLength-(samplesLeft - 4)
ANDS    R2, R2, #3
MOVEQ    R2, #4

channel_fixed_freq_mixing_fetch_samples:    @ fetch current  4 samples from buffer #1 and #2

LDR    R6, [R5]                @ load the 4 samples from first buffer to R6
LDR    R7, [R5, #buffer_spacing]            @ do the same for buffer #2 and R7

channel_fixed_load_new_samples:

LDRSB    R0, [R3], #1                @ load sample from current position into R0 and increment the abs sample position by #1
MOV    R0, R0, LSL#6
MUL    R1, R10, R0                @ calc the samples level with volume amplification (remember. VOL << 16)
BIC    R1, R1, #0xFF00                @ ### clear the lower unimportant bits --- the level is now something like this: 0x??000000
ADD    R6, R1, R6, ROR#16            @ ### Now add this to the previous level and rotate the bits of the result --> next commands can edit the next sample like the previous one
MUL    R1, R11, R0                @ calculate the next level (vol #2)
BIC    R1, R1, #0xFF00                @ ### clear the bits like before
ADD    R7, R1, R7, ROR#16            @ ### do the same like before for the second buffer
ADDS    R5, R5, #0x80000000            @ ### ABUSE R5 as counting variable. this will cause the loop to repeat until the pointer of the sample buffer overflows to it's original position (i.e. 4 / 3 times) --- changed to 0x80000000 from 0x40000000
BCC    channel_fixed_load_new_samples        @ if the carry bit is not set (no overflow)

STR    R7, [R5, #buffer_spacing]            @ store the new samples to buffer #2
STR    R6, [R5], #4                @ store new samples to buffer #1 and increment buffer pointer
SUBS    R8, R8, #2                @ sample counter of one frame by 4 and check if it's bigger than #0
BGT    channel_fixed_freq_mixing_fetch_samples    @ repeat until the buffer got filled

ADDS    R8, R8, R9                @ R8 = samples left after frame -4
BEQ    channel_mixing_store_pos        @ check if the END/LOOP is reached 

channel_fixed_freq_mixing_fetch_last:

LDR    R6, [R5]                @ fetch the next samples #1 and #2
LDR    R7, [R5, #buffer_spacing]

channel_fixed_load_last_samples:

LDRSB    R0, [R3], #1                @ load next sample from memory with pointer increment
MOV    R0, R0, LSL#6
MUL    R1, R10, R0                @ multiply sample with volume factor #1
BIC    R1, R1, #0xFF00                @ ### cut away unimportant bits#
ADD    R6, R1, R6, ROR#16            @ ### add it to the buffer
MUL    R1, R11, R0                @ do the same thing for volume #2
BIC    R1, R1, #0xFF00                @ ### ...
ADD    R7, R1, R7, ROR#16            @ ### ...
SUBS    R2, R2, #1                @ left samples (1-4)
BEQ    channel_fixed_freq_loop_handler

channel_fixed_freq_count_sample:

ADDS    R5, R5, #0x80000000            @ ### abuse buffer pointer as counter variable --- changed from 0x40000000 to 0x80000000
BCC    channel_fixed_load_last_samples        @ repeat the procedure until the last samples are loaded

STR    R7, [R5, #buffer_spacing]            @ write the samples to the buffer
STR    R6, [R5], #4                @ increment the buffer counter
SUBS    R8, R8, #2                @ ### check if there is still samples to put into the current frame --- reduce the sample countdown to #2 instead of #4
BGT    channel_fixed_freq_mixing_loop        @ go back to the main loop
B    channel_mixing_store_pos        @ go to some end function

channel_var_freq_mixing_loop_handler:

LDR    R0, [SP, #0x18]                @ IMPORTANT: --> =ARG_LOOP_MODE (0x10) due to the moved Stack Pointer from the STMFD command
CMP    R0, #0                    @ is the loop disabled?
BEQ    channel_var_freq_mixing_stop_channel    @ if the loop is disabled, stop the channel

LDR    R3, [SP, #0x14]                @ IMPORTANT: --> =ARG_ABS_LOOP_OFFSET (0xC) due to the moved Stack pointer from the STMFD command
RSB    LR, R2, #0                @ LR = 0 - remaining samples

channel_var_freq_mixing_set_loop:

ADDS    R2, R0, R2                @ R2 = 0x10 + remaining samples
BGT    channel_var_freq_mixing_fetch_next    @ go on with mixing if there is a few left samples (?, not fully understood yet)

SUB    LR, LR, R0                @ - remaining samples - 0x10
B    channel_var_freq_mixing_set_loop

channel_var_freq_mixing_stop_channel:

LDMFD    SP!, {R4, R12}                @ pop registers from stack
MOV    R2, #0                    @ set the remaining samples to #0
B    channel_fixed_freq_stop_mixing        @ use the same handler as the fixed mixing to stop the channel

channel_fixed_freq_loop_handler:

LDR    R2, [SP, #ARG_LOOP_MODE]        @ load the loop flag of the current channel
CMP    R2, #0                    @ check if the loop flag is not set
LDRNE    R3, [SP, #ARG_ABS_LOOP_OFFSET]        @ if it is set, load the loop pointer into R3
BNE    channel_fixed_freq_count_sample        @ go back to the main loop

channel_fixed_freq_stop_mixing:

STRB    R2, [R4]                @ write 0 to the channel status to stop the channel
MOV    R0, R5, LSR#30                @ shoft the two LS Bits to the two MS Bits
BIC    R5, R5, #0xC0000000            @ clear the "counting" bits of the buffer pointer
RSB    R0, R0, #3                @ Subtract the "MS Bits value" from 3 and place the result in R0
MOV    R0, R0, LSL#4                @ ### Multiply R0 by 8 and cut away high bits --- changed from 3 to 4
MOV    R6, R6, ROR R0                @ rotate the last volume level to the final position
MOV    R7, R7, ROR R0                @ as well for volume #2
STR    R7, [R5, #buffer_spacing]        @ write the last samples to the buffer
STR    R6, [R5], #4                @ ...
B    channel_mixing_exit_func        @ go to the exit func to switch back to thumb mode and restart the channel loop

channel_var_freq_mixing:

STMFD    SP!, {R4, R12}                @ push R4 and R12 onto Stack (opposite direction of arguments)
LDR    R1, [R4, #CHN_FREQUENCY]        @ load the channels frequency value into R1
MUL    R4, R12, R1                @ multiply samplingrate pitch factor with the frequency
LDRSB    R0, [R3]                @ load first sample to memory
LDRSB    R1, [R3, #1]!                @ load the following sample into memory and increment sample counter by 1
SUB    R1, R1, R0                @ store sample DELTA to R1 and discard the following sample
MOV    R0, R0, LSL#6                @ ### added

channel_var_freq_mixing_loop:

LDR    R6, [R5]                @ load current samples from buffer to R6 (#1)
LDR    R7, [R5, #buffer_spacing]                @ do the same for buffer #2 with R7

channel_var_freq_mixing_resampling:

MUL    LR, R9, R1                @ multiply Fine Channel position with the delta (linear interpolation)
ADD    LR, R0, LR, ASR#17            @ ### add it to the base sample level to calculate the final level --- ASR#23 to ASR#17
MUL    R12, R10, LR                @ apply the final volume level #1 to R12
BIC    R12, R12, #0xFF00            @ clear garbage bits
ADD    R6, R12, R6, ROR#16            @ add it to the output sample word
MUL    R12, R11, LR                @ do the same for vol #2
BIC    R12, R12, #0xFF00            @ ...
ADD    R7, R12, R7, ROR#16            @ ...
ADD    R9, R9, R4                @ add samplingrate conversion factor to the fine channel position
MOVS    LR, R9, LSR#23                @ check if the fine channel position overflowed a certain range or how much it overflowed the range
BEQ    channel_var_freq_mixing_count

BIC    R9, R9, #0x3F800000            @ clear all "overflow" bits from R9 --> i.e. seperation from the overflow count (LR) and the actual left value (R9)
SUBS    R2, R2, LR                @ remove the overflow count from the left samples
BLE    channel_var_freq_mixing_loop_handler    @ handle the loop end / sample end

SUBS    LR, LR, #1                @ decrease overflow count by one and check if the overflow was fixed
ADDEQ    R0, R1, R0, ASR#6            @ ### if there is no more overflow after decreasing the overflow count calculate the next sample my simply adding the previous DELTA to the actual sample --- added shift

channel_var_freq_mixing_fetch_next:

LDRNESB    R0, [R3, LR]!                @ if the overflow was higher than 1 (skipped more than one sample) load the next ine depending on overflow
LDRSB    R1, [R3, #1]!                @ @ load the following sample to R1 for interpolation
SUB    R1, R1, R0                @ calculate the DELTA to R1
MOV    R0, R0, LSL#6                @ ### added left shift

channel_var_freq_mixing_count:

ADDS    R5, R5, #0x80000000            @ ### abuse sample pointer as counter variable --- changed from 0x40000000 to 0x80000000
BCC    channel_var_freq_mixing_resampling    @ repeat the resampling/mixing process until 4 bytes of samples are filled

STR    R7, [R5, #buffer_spacing]        @ store sample #2
STR    R6, [R5], #4                @ store sample #1  and increment sample counter
SUBS    R8, R8, #2                @ ### decrease samples left from current frame by 4 - changed to #2 samples per loop
BGT    channel_var_freq_mixing_loop        @ if there is still samples to fill repeat the loop for mixing and resampling

SUB    R3, R3, #1                @ decrease current absolute sample position by one (it has been increased by one due to the interpolation)
LDMFD    SP!, {R4, R12}                @ pop 2 registers from the stack

channel_var_freq_mixing_store_fine_pos:        @ store the fine position for non-fixed freq modes (i.e. compressed and/or pitched sounds)

STR    R9, [R4, #CHN_FINE_POSITION]        @ store the fine channel position

channel_mixing_store_pos:

STR    R2, [R4, #CHN_POSITION_REL]        @ store absolute and relative sample position
STR    R3, [R4, #CHN_POSITION_ABS]        @

channel_mixing_exit_func:

LDR    R8, [SP, #ARG_FRAME_LENGTH]        @ reset the frame length
ADR    R0, channel_check_processed_channels+1    @ load the thumb adress | 1 to change to thumb mode
BX    R0

    .thumb

channel_check_processed_channels:
LDR    R0, [SP, #ARG_CHN_LEFT]            @ load Channel counter variable to R0
SUB    R0, #1                    @ decrease channel count by 1
BLE    mixer_end                @ if channel count <= 0 go to end func

ADD    R4, #0x40                @ add 0x40 to channel offset register so the Routine will process the next channel
B    channel_main_loop

mixer_end:                    @ MAIN END HANDLER

ADR    R0, downsampler
BX    R0

downsampler_return:

LDR    R0, [SP, #ARG_VAR_AREA]            @ load the main var area to R0
LDR    R3, mixer_finished_status        @ load some status indication value to R3
STR    R3, [R0]                @ store this value to the main var area
ADD    SP, SP, #0x1C                @ discard the argument variables
POP    {R0-R7}                    @ reload previous registers
MOV    R8, R0                    @ backup some registers into the HIGH registers
MOV    R9, R1                    @ ...
MOV    R10, R2                    @ ...
MOV    R11, R3                    @ ...
POP    {R3}                    @ get the return address from the stack
BX    R3                    @ -------------------------- END THE MIXER AND RETURN TO "m4aMain()" --------------------------------

    .align    2

mixer_finished_status:
    .word    0x68736D53

@*************** MAIN CHANNELS END ******************@

    .arm

@****************** DOWNSAMPLER *********************@

@ ### the complete Downsampler section has been added

downsampler:

LDR    R7, buffer_spacing_2
MOV    R6, R8
LDR    R5, [SP, #ARG_BUFFER_POS]
LDR    R4, hq_buffer_3

downsampler_loop:

LDRSH    R1, [R4, R7]
LDRSH    R0, [R4], #2
LDRSH    R3, [R4, R7]
LDRSH    R2, [R4], #2

MOV    R0, R0, ASR#6
MOV    R1, R1, ASR#6
MOV    R2, R2, ASR#6
MOV    R3, R3, ASR#6

STRB    R1, [R5, #0x630]
STRB    R0, [R5], #1
STRB    R3, [R5, #0x630]
STRB    R2, [R5], #1

SUBS    R6, R6, #2
BGT    downsampler_loop

ADR    R0, downsampler_return+1
BX    R0

@ ###

@**************** DOWNSAMPLER END *******************@

hq_buffer_3:
    .word    hq_buffer
buffer_spacing_2:
    .word    buffer_spacing


@************ DECOMPRESSOR + RESAMPLER **************@

channel_compressed_mixing:

LDR    R6, [R4, #CHN_WAVE_OFFSET]        @ load the wave header offset to R6
LDRB    R0, [R4]                @ load the compression flag into R0
TST    R0, #FLAG_CHN_COMP            @ check if the compression flag is set
BNE    setup_compressed_mixing_frequency    @ if it is set go over to ???

ORR    R0, R0, #0x20                @ set the compression flag
STRB    R0, [R4]                @ write the updated status byte to Channelo
LDRB    R0, [R4, #CHN_MODE]            @ load the channel mode to R0
TST    R0, #MODE_REVERSE            @ check if reverse playback is enabled
BEQ    determine_compression_type

special_compression_setup:

LDR    R1, [R6, #WAVE_LENGTH]            @ R1 = sample length/end
ADD    R1, R1, R6, LSL#1            @ get the absolute end position of the waveform and multiply it by 2 due to the compressed samples only being 4 bits long
ADD    R1, R1, #0x20                @ add 0x20 to match the real *2 beginning of the wave data (header length 0x10 * 2)
SUB    R3, R1, R3                @ subtract the orgignal wave data offset from the calculated value to get the actual beginning of the wave data
STR    R3, [R4, #CHN_POSITION_ABS]

determine_compression_type:

LDRH    R0, [R6]                @ load the wave data type to R6 (0x1 = compressed; 0x0 = pcm)
CMP    R0, #0                    @ check if the sample is uncompressed
BEQ    setup_compressed_mixing_frequency

SUB    R3, R3, R6                @ do some unkown asolute position calculating ??????
SUB    R3, R3, #0x10                @ same here ??????????
STR    R3, [R4, #CHN_POSITION_ABS]

setup_compressed_mixing_frequency:

STMFD    SP!, {R8, R12, LR}            @ save the registers for frame lengthcounter and the actual length in R12--> (SP - 0xC) --- 
MOV    R10, R10, LSL#8                @ ### shift the volume #1 to the 2nd MSB --- changed to 8 from 16
MOV    R11, R11, LSL#8                @ ### shoft the volume #2 to the 2nd MSB --- same here
LDR    R1, [R4, #CHN_FREQUENCY]        @ load the channel frequency to R1
LDRB    R0, [R4, #CHN_MODE]            @ load the channel mode to R0
TST    R0, #MODE_FIXED_FREQ            @ check if fixed frequency mode is enabled
MOVNE    R8, #0x800000                @ load the default pitch factor to R8
MULEQ    R8, R12, R1                @ if pitch is not fixed, mulitply the frequency with the default rate pitch factor
LDRH    R0, [R6]                @ load the sample format from header to R0
CMP    R0, #0                    @ check if the sample is uncompressed
BEQ    uncomressed_mixing_reverse_check    @ if sample is uncompressed check if reverse playback is enabled

MOV    R0, #0xFF000000                @ load some kind of flag to R0 ????????
STR    R0, [R4, #0x3C]                @ store it in the last channel VAR slot
LDRB    R0, [R4, #CHN_MODE]            @ load AGAIN the channel mode to R0
TST    R0, #0x10                @ check the reverse playback flag
BNE    compressed_mixing_reverse_init        @ if the flag is set go to reverse playback init + compressed handler

BL    bdpcm_decoder                @ call the FetchSample() function to return the next sample (new samples are decompressed if necessary)
MOV    R0, R1                    @ copy the result to R0
ADD    R3, R3, #1                @ increment the sample counter by one
BL    bdpcm_decoder                @ fetch next sample for interpolation
SUB    R1, R1, R0                @ write the DELTA to R1
MOV    R0, R0, LSL#6                @ ### added

compressed_mixing_load_samples:

LDR    R6, [R5]                @ load 4 samples from mixing buffer #1
LDR    R7, [R5, #buffer_spacing]            @ load 4 samples from mixing buffer #2

compressed_mixing_loop:

MUL    LR, R9, R1                @ multiply the DELTA with the fine position value
ADD    LR, R0, LR, ASR#17            @ ### add the actual sample but divide after to scale down the value back to and 8 bit sample --- changed from 23 to 17
MUL    R12, R10, LR                @ apply vol #1
BIC    R12, R12, #0xFF00            @ ### clear the lower bits - changed from 0xFF0000 to 0xFF00
ADD    R6, R12, R6, ROR#16            @ ### put the sample into the buffer #1 and rotate
MUL    R12, R11, LR                @ apply vol #2
BIC    R12, R12, #0xFF00            @ ### clear the lower bits - changed from 0xFF0000 to 0xFF00
ADD    R7, R12, R7, ROR#16            @ ### put the sample into buffer #2 and rotate the bytes
ADD    R9, R9, R8                @ add the pitch factor to fine position
MOVS    LR, R9, LSR#23                @ cut of the lower bits to seperate fine and relative stream position
BEQ    compressed_mixing_count_current_sample    @ if the overflow amount is 0 don't care about increasing the integer stream position

BIC    R9, R9, #0x3F800000            @ cut of the lower bits if there is overflow (position increasment)
SUBS    R2, R2, LR                @ remove the coatse sample overflow count from the samples remaining
BLE    compressed_mixing_end_handler        @ if the end is reached call the END/LOOP handler

SUBS    LR, LR, #1                @ remove one from the overflow and check if it's done with that (i.e. = 0)
BNE    compressed_mixing_fetch_next        @ if there is more samples to remove fetch a new sample

ADD    R0, R1, R0, ASR#6            @ ### calculate next sample (if the overflow was only 1 we can directly calculate the next base sample for interpolation because we already read it from ROM before and made the DELTA value --> add previous base sample with DELTA = new base sample) --- added shoft
B    compressed_mixing_fetch_delta        @

compressed_mixing_fetch_next:        

ADD    R3, R3, LR                @ add the (probably negative) rewind position to R3 to calculate new position
BL    bdpcm_decoder                @ fetch new sample
MOV    R0, R1                    @ move the base sample to R0

compressed_mixing_fetch_delta:

ADD    R3, R3, #1                @ increment sample position by #1
BL    bdpcm_decoder                @ fetch sample
SUB    R1, R1, R0                @ calc DELTA
MOV    R0, R0, LSL#6                @ ### added

compressed_mixing_count_current_sample:

ADDS    R5, R5, #0x80000000            @ abuse the buffer pointer as counter var at the higher bits
BCC    compressed_mixing_loop            @ go back to mixing loop #1

STR    R7, [R5, #buffer_spacing]            @ write 4 samples to each of the two buffers
STR    R6, [R5], #4                @ after that increment buffer pointer
LDR    R6, [SP]                @ load frame sample countdown
SUBS    R6, R6, #2                @ ### subtract 4 from sample amount --- changed from #4 to #2
STR    R6, [SP]                @ store the variable again
BGT    compressed_mixing_load_samples        @ redo the mixing loop if there is still samples left

SUB    R3, R3, #1                @ remove #1 from sample count (???)
B    special_mixing_return            @ go to return handler

compressed_mixing_end_handler:

LDR    R0, [SP, #0xC+ARG_LOOP_MODE]        @ add 0xC due to the moved stack pointer
CMP    R0, #0                    @ check if loop is disabled
BEQ    compressed_mixing_stop_and_return    @ if loop is disabled go to STOP sample handler

LDR    R3, [R4, #CHN_WAVE_OFFSET]        @ load the wave data offset to R3
LDR    R3, [R3, #WAVE_LOOP_START]        @ load the loop start position to R3
RSB    LR, R2, #0                @ calc the amount of sample that need to get rewinded for looping

compressed_mixing_loop_handler:

ADDS    R2, R2, R0                @ add loopflag to left samples (???)
BGT    compressed_mixing_fetch_next

SUB    LR, LR, R0                @ do some loop stuff (???)
B    compressed_mixing_loop_handler        @ repeat procedure (???)

compressed_mixing_reverse_init:

SUB    R3, R3, #1                @ remove one from the sample position (reverse, so di not add #1)
BL    bdpcm_decoder                @ fetch the base sample
MOV    R0, R1                    @ move the base sample (returned from R1)
SUB    R3, R3, #1                @ remove one from the sample position
BL    bdpcm_decoder                @ fetch the next sample for DELTA calc
SUB    R1, R1, R0                @ calc delta to R1
MOV    R0, R0, LSL#6                @ ### added

compressed_mixing_reverse_load_samples:

LDR    R6, [R5]                @ load samples from buffer #1
LDR    R7, [R5, #buffer_spacing]            @ load samples from buffer #2

compressed_mixing_reverse_loop:

MUL    LR, R9, R1                @ multiply DELTA with fine position
ADD    LR, R0, LR, ASR#17            @ ### add the downshifted delta to the base sample to calc the interpolated sample
MUL    R12, R10, LR                @ apply the volume factor #1 to the sample
BIC    R12, R12, #0xFF00            @ ### clear bad bits
ADD    R6, R12, R6, ROR#16            @ ### rotate the sample bits by 8 and add the current sample
MUL    R12, R11, LR                @ apply volume factor #2 to the sample
BIC    R12, R12, #0xFF00            @ ### clear bad bits
ADD    R7, R12, R7, ROR#16            @ ### do the same for samples #2
ADD    R9, R9, R8                @ add the pitch factor to the fine position
MOVS    LR, R9, LSR#23                @ cut off the fine position bits and move them to LR
BEQ    compressed_mixing_reverse_count_sample    @ check if there is no new samples (we can use the samples again for interpolation, no overflow)

BIC    R9, R9, #0x3F800000            @ seperate the fine position bits
SUBS    R2, R2, LR                @ subtract the sample overflow from the remaing samples
BLE    compressed_mixing_stop_and_return    @ if end of samples is reached

SUBS    LR, LR, #1                @ remove one from the sample overflow and check if the result is Zero
BNE    compressed_mixing_reverse_fetch_next    @ if it is more samples to reload

ADD    R0, R1, R0, ASR#6            @ ### set the base sample to the delta sample (we can skip reloading a sample here) --- added shift
B    compressed_mixing_reverse_seekback

compressed_mixing_reverse_fetch_next:

SUB    R3, R3, LR                @ seek back as many samples as written in the sample overflow
BL    bdpcm_decoder                @ fetch the next sample
MOV    R0, R1                    @ move to base sample Register (R0)

compressed_mixing_reverse_seekback:

SUB    R3, R3, #1                @ decrease the sample position even further
BL    bdpcm_decoder                @ fetch next DELTA sample
SUB    R1, R1, R0                @ calc delta to base sample
MOV    R0, R0, LSL#6                @ ### added shift

compressed_mixing_reverse_count_sample:

ADDS    R5, R5, #0x80000000            @ abuse sample pointer as counter variable on the higher bits
BCC    compressed_mixing_reverse_loop        @ repeat the mixing loop

STR    R7, [R5, #buffer_spacing]            @ write the 4 samples to buffer #2
STR    R6, [R5], #4                @ do the same for buffer #1 but increase the buffer pointer by 4
LDR    R6, [SP]                @ load the frame sample countdown to R6
SUBS    R6, R6, #2                @ ### remove 4 from the frame counter --- changed from #4 to #2
STR    R6, [SP]                @ store the counter
BGT    compressed_mixing_reverse_load_samples    @ if there is samples left to do, continue with the loop

ADD    R3, R3, #2                @ extend sample position by #2 (???)
B    special_mixing_return            @ go to return function

uncomressed_mixing_reverse_check:

LDRB    R0, [R4, #1]                @ load channel mode to R0
TST    R0, #MODE_REVERSE            @ check if the reverse mode is enabled
BEQ    special_mixing_return                @ if reverse mode is not enabled skip this channel because this routine is not made to do regular mixing

LDRSB    R0, [R3, #-1]!                @ reduce the sample counter by #1 and load is as base offset
LDRSB    R1, [R3, #-1]                @ load the DELTA sample
SUB    R1, R1, R0                @ calculate the DELTA value
MOV    R0, R0, LSL#6                @ added shift

uncompressed_mixing_reverse_load_samples:

LDR    R6, [R5]                @ load samples from buffer #1
LDR    R7, [R5, #buffer_spacing]        @ load samples from buffer #2

uncompressed_mixing_reverse_loop:

MUL    LR, R9, R1                @ do the same mixing procedure as usual
ADD    LR, R0, LR, ASR#17            @ ###
MUL    R12, R10, LR
BIC    R12, R12, #0xFF00            @ ###
ADD    R6, R12, R6, ROR#16            @ ###
MUL    R12, R11, LR
BIC    R12, R12, #0xFF00            @ ###
ADD    R7, R12, R7, ROR#16            @ ###
ADD    R9, R9, R8
MOVS    LR, R9, LSR#23
BEQ    uncompressed_mixing_reverse_count

BIC    R9, R9, #0x3F800000            @ seperate fine position bits
SUBS    R2, R2, LR                @ remove the overflow bits from the position count
BLE    compressed_mixing_stop_and_return    @ stop the channel after finishing

LDRSB    R0, [R3, -LR]!                @ load new base sample
LDRSB    R1, [R3, #-1]                @ load the new DELTA sample
SUB    R1, R1, R0                @ calc DELTA
MOV    R0, R0, LSL#6                @ ###

uncompressed_mixing_reverse_count:

ADDS    R5, R5, #0x80000000            @ ### count sample (abuse as count var)
BCC    uncompressed_mixing_reverse_loop    @ if there is still samples in this block to process, repeat loop

STR    R7, [R5, #buffer_spacing]        @ store samples to buffer #2
STR    R6, [R5], #4                @ do the same for buffer #2 + increment the sample pointer
LDR    R6, [SP]                @ load the frame counter to R6
SUBS    R6, R6, #2                @ ### decrease sample count by 4 (4 per sample block) --- changed from #4 to #2
STR    R6, [SP]                @ store it again
BGT    uncompressed_mixing_reverse_load_samples    @

ADD    R3, R3, #1                @ sample position +1 (???)

special_mixing_return:

LDMFD    SP!, {R8, R12, PC}

compressed_mixing_stop_and_return:

MOV    R2, #0                    @ set channel status indicator to stop in R2
STRB    R2, [R4]                @ store it in the channel variables
MOV    R0, R5, LSR#30                @ get the last samples' index
BIC    R5, R5, #0xC0000000            @ remove the bad bits from the channel pointer
RSB    R0, R0, #3                @ negate the index for correct rotation
MOV    R0, R0, LSL#4                @ ### multiply the bit rotation amount by 8 (so we get byte units)
MOV    R6, R6, ROR R0                @ rotate the last sample in position for buffer #1
MOV    R7, R7, ROR R0                @ do the same for buffer #2
STR    R7, [R5, #buffer_spacing]            @ store buffer #2 samples
STR    R6, [R5], #4                @ do the same for buffer #1 and increment buffer pointer
LDMFD    SP!, {R8, R12, PC}            @ pop registers and return to main channel loop

@*********** END COMPRESSOR + RESAMPLER *************@

@****************** BDPCM DEOCODER ******************@

bdpcm_decoder:

STMFD    SP!, {R0, R2, R5-R7, LR}            @ push registers to make them free to use: R0, R2, R5, R6, R7, LR
MOV    R0, R3, LSR#6                @ shift the relative position over to clip of every but the block offset
LDR    R1, [R4, #CHN_BLOCK_COUNT]        @ check if the current sample position is at the beginning of the current block
CMP    R0, R1
BEQ    bdpcm_decoder_return

STR    R0, [R4, #CHN_BLOCK_COUNT]        @ store the block position to Channel Vars
MOV    R1, #0x21                @ load decoding byte count to R1 (1 Block = 0x21 Bytes)
MUL    R2, R1, R0                @ multiply the block count with the block length to calc actual byte position of current block
LDR    R1, [R4, #CHN_WAVE_OFFSET]        @ load the wave data offset to R1
ADD    R2, R2, R1                @ add the wave data offset and 0x10 to get the actual position in ROM
ADD    R2, R2, #0x10                @ 
LDR    R5, decoder_buffer            @ load the decoder buffer pointer to R5
LDR    R6, delta_lookup_table            @ load the lookup table pointer to R6
MOV    R7, #0x40                @ load the block sample count (0x40) to R7
LDRB    LR, [R2], #1                @ load the first byte & sample from the wave data to LR (each block starts with a signed 8 bit pcm sample) LDRSB not necessary due to the 24 high bits being cut off anyway
STRB    LR, [R5], #1                @ write the sample to the decoder buffer
LDRB    R1, [R2], #1                @ load the next 2 samples to R1 (to get decoded) --- LSBits is decoded first and MSBits last
B    bdpcm_decoder_lsb

bdpcm_decoder_msb:

LDRB    R1, [R2], #1                @ load the next 2 samples to get decoded
MOV    R0, R1, LSR#4                @ seperate the current samples' bits
LDRSB    R0, [R6, R0]                @ load the differential value from the lookup table
ADD    LR, LR, R0                @ add the decoded value to the previous sample value to calc the current samples' level
STRB    LR, [R5], #1                @ write the output sample to the decoder buffer and increment buffer pointer

bdpcm_decoder_lsb:

AND    R0, R1, #0xF                @ seperate the 4 LSBits
LDRSB    R0, [R6, R0]                @ but the 4 bit value into the lookup table and save the result to R0
ADD    LR, LR, R0                @ add the value from the lookup table to the previous value to calc the new one
STRB    LR, [R5], #1                @ store the decoded sample to the decoding buffer
SUBS    R7, R7, #2                @ decrease the block sample counter by 2 (2 samples each byte) and check if it is still above 0
BGT    bdpcm_decoder_msb            @ if there is still samples to decode jump to the MSBits

bdpcm_decoder_return:

LDR    R5, decoder_buffer            @ reload the decompressor buffer offset to R5
AND    R0, R3, #0x3F                @ cut off the main position bits to read data from short buffer
LDRSB    R1, [R5, R0]                @ read the decoded sample from buffer
LDMFD    SP!, {R0, R2, R5-R7, PC}        @ pop registers and return to the compressed sample mixer

@**************** END BDPCM DECODER *****************@

decoder_buffer:
    .word    decoder_buffer_target
delta_lookup_table:
    .word    delta_table

    .end