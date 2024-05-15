/**
 * @file vdc.asm
 * @brief Vdc module
 * @details Simple macros for Vdc.
 *
 * @author Raffaele Intorcia raffaele.intorcia@gmail.com
 *
 * @copyright MIT License
 * Copyright (c) 2024 c128lib - https://github.com/c128lib
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * @date 2024
 */

#importonce

#import "labels/lib/kernal.asm"
#import "labels/lib/vdc.asm"

.filenamespace c128lib

.namespace Vdc {
#if VDC_FILLSCREEN
#define VDC_MOVESCREENPOINTERTO00
#define VDC_WRITEBYTE
#define VDC_REPEATBYTE
FillScreen:
    pha
    jsr MoveScreenPointerTo00
    pla
    jsr WriteByte
    lda #249
    jsr RepeatByte
    lda #250
    ldy #7
  !:
    jsr RepeatByte
    dey
    bne !-
    rts
#endif

#if VDC_FILLATTRIBUTE
#define VDC_MOVEATTRIBUTEPOINTERTO00
#define VDC_REPEATBYTE
#define VDC_WRITEBYTE
FillAttribute: {
    pha
    jsr MoveAttributePointerTo00
    pla
    jsr WriteByte
    lda #249
    jsr RepeatByte
    lda #250
    ldy #7
  !:
    jsr RepeatByte
    dey
    bne !-
    rts
}
#endif

#if VDC_MOVESCREENPOINTERTO00
MoveScreenPointerTo00: {
    lda vdcram
    ldx #CURRENT_MEMORY_LOW_ADDRESS
    WriteVdc()
    dex
    lda vdcram+1
    WriteVdc()
    rts
}
#endif

#if VDC_MOVEATTRIBUTEPOINTERTO00
MoveAttributePointerTo00: {
    lda vdcattr
    ldx #CURRENT_MEMORY_LOW_ADDRESS
    WriteVdc()
    dex
    lda vdcattr+1
    WriteVdc()
    rts
}
#endif

#if VDC_PRINTCHARATPOSITION
#define VDC_POSITIONXY
#define VDC_WRITEBYTE
PrintCharAtPosition: {
    pha
    jsr PositionXy
    pla
    jsr WriteByte
    rts
}
#endif

#if VDC_POSITIONXY
PositionXy: {
    lda #0
    sta high
    sty low
    asl low
    asl low           // Y times 4
    tya
    clc
    adc low
    sta low           // Y times 5
    ldy #4
  !:
    asl low
    rol high
    dey
    bne !-              // Y times 80 in low/high
    txa
    clc
    adc low
    sta low
    bcc !+
    inc high          // added X offset across screen
  !:
    lda vdcram
    clc
    adc low
    sta low
    lda vdcram+1
    adc high
    sta high          // added offset for start of screen RAM
    ldx #CURRENT_MEMORY_HIGH_ADDRESS
    lda high
    WriteVdc()
    inx
    lda low
    WriteVdc()
    rts
}
#endif

#if VDC_POSITIONATTRXY
PositionAttrXy: {
    lda #0
    sta high
    sty low
    asl low
    asl low           // Y times 4
    tya
    clc
    adc low
    sta low           // Y times 5
    ldy #4
  !:
    asl low
    rol high
    dey
    bne !-              // Y times 80 in low/high
    txa
    clc
    adc low
    sta low
    bcc !+
    inc high          // added X offset across screen
  !:
    lda vdcattr
    clc
    adc low
    sta low
    lda vdcattr+1
    adc high
    sta high          // added offset for start of attribute RAM
    ldx #CURRENT_MEMORY_HIGH_ADDRESS
    lda high
    WriteVdc()
    inx
    lda low
    WriteVdc()
    rts
}
#endif

#if VDC_REPEATBYTE
RepeatByte: {
    pha
    ldx #VERTICAL_SMOOTH_SCROLLING
    ReadVdc()
    and #$7f
    WriteVdc()
    pla
    ldx #NUMBER_OF_BYTES_FOR_BLOCK_WRITE_OR_COPY
    WriteVdc()
    rts
}
#endif

#if VDC_WRITEBYTE
WriteByte: {
    ldx #MEMORY_READ_WRITE
    WriteVdc()
    rts
}
#endif

#if VDC_SETRAMPOINTER
SetRamPointer: {
    ldx #CURRENT_MEMORY_LOW_ADDRESS
    WriteVdc()
    tya
    dex
    WriteVdc()
    rts
}
#endif

#if VDC_INITTEXT
InitText: {
    ldx #HORIZONTAL_SMOOTH_SCROLLING
    ReadVdc()
    and #$7f
    WriteVdc()              // set text mode
    ldx #SCREEN_MEMORY_STARTING_HIGH_ADDRESS
    ReadVdc()
    sta vdcram+1
    inx
    ReadVdc()
    sta vdcram            // save screen RAM address
    ldx #ATTRIBUTE_MEMORY_HIGH_ADDRESS
    ReadVdc()
    sta vdcattr+1
    inx
    ReadVdc()
    sta vdcattr           // save attribute RAM address

    rts
}
#endif

#if VDC_MOVESCREENPOINTERTO00 || VDC_MOVEATTRIBUTEPOINTERTO00 || VDC_POSITIONXY || VDC_POSITIONATTRXY || VDC_INITTEXT
  count:      .byte $fa
  high:       .byte $fc
  low:        .byte $fb
  str:        .byte $fd

  vdcram:     .word $0000
  vdcattr:    .word $0800
#endif

} // end namespace

/**
 * @brief Go to 40 columns mode
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @note Use c128lib_Go40 in vdc-global.asm
 *
 * @since 1.1.0
 */
.macro Go40() {
  lda Vdc.MODE                // are we in 40 columns mode?
  bpl !+                      // bit 7 clear? then yes
  jsr Kernal.JSWAPPER         // swap mode to 40 columns
!:
}
.assert "Go40()", { Go40() },
{
  lda $d7; bpl *+5; jsr $FF5F
}

/**
 * @brief Go to 80 columns mode
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @note Use c128lib_Go80 in vdc-global.asm
 *
 * @since 1.1.0
 */
.macro Go80() {
  lda Vdc.MODE                // are we in 80 columns mode?
  bmi !+                      // bit 7 set? then yes
  jsr Kernal.JSWAPPER         // swap mode to 80 columns
!:
}
.assert "Go80()", { Go80() },
{
  lda $d7; bmi *+5; jsr $FF5F
}

/**
 * @brief Calculate byte with hi nibble to foreground color and low nibble
 * to background color.
 *
 * @param[in] background Background color
 * @param[in] foreground Foreground color
 * @return Byte with foreground and background color combined
 *
 * @since 1.1.0
 */
.function CalculateBackgroundAndForeground(background, foreground) {
  .return ((foreground << 4) + background)
}

/**
 * @brief Set background and foreground color, also disable bit 6 of
 * HORIZONTAL_SMOOTH_SCROLLING register
 *
 * @param[in] background Background color
 * @param[in] foreground Foreground color
 *
 * @note Use c128lib_SetBackgroundForegroundColor in vdc-global.asm
 *
 * @since 1.1.0
 */
.macro SetBackgroundForegroundColor(background, foreground) {
    lda #0
    ldx #Vdc.HORIZONTAL_SMOOTH_SCROLLING
    ReadVdc()

    and #%10111111
    WriteVdc()

    lda #CalculateBackgroundAndForeground(background, foreground)
    ldx #Vdc.FOREGROUND_BACKGROUND_COLOR
    WriteVdc()
}
.assert "SetBackgroundForegroundColor(background, foreground)", {
    SetBackgroundForegroundColor(Vdc.VDC_DARK_GREEN, Vdc.VDC_LIGHT_GREEN)
  }, {
    lda #0; ldx #$19;
    stx $d600; bit $d600; bpl *-3; lda $d601
    and #%10111111;
    stx $d600; bit $d600; bpl *-3; sta $d601
    lda #$54
    ldx #$1A
    stx $d600; bit $d600; bpl *-3; sta $d601
}

/**
 * @brief Set background and foreground color, also disable bit 6 of
 * HORIZONTAL_SMOOTH_SCROLLING register. Use vars instead of labels.
 * Warning: high nibble of background must be 0, it's up to developer
 * to check this.
 *
 * @param[in] background Background color address
 * @param[in] foreground Foreground color address
 *
 * @note Use c128lib_SetBackgroundForegroundColorWithVars in vdc-global.asm
 *
 * @since 1.1.0
 */
.macro SetBackgroundForegroundColorWithVars(background, foreground) {
    lda #0
    ldx #Vdc.HORIZONTAL_SMOOTH_SCROLLING
    ReadVdc()

    and #%10111111
    WriteVdc()

    lda foreground
    asl
    asl
    asl
    asl
    ora background
    ldx #Vdc.FOREGROUND_BACKGROUND_COLOR
    WriteVdc()
}
.assert "SetBackgroundForegroundColorWithVars(background, foreground)", {
    SetBackgroundForegroundColorWithVars($beef, $baab)
  }, {
    lda #0; ldx #$19;
    stx $d600; bit $d600; bpl *-3; lda $d601
    and #%10111111;
    stx $d600; bit $d600; bpl *-3; sta $d601
    lda $baab;
    asl; asl; asl; asl;
    ora $beef;
    ldx #$1A;
    stx $d600; bit $d600; bpl *-3; sta $d601
}

/**
 * @brief Write a value into Vdc register without using kernal
 * routine instead of pure instruction. It needs register
 * number in X and value to write in A.
 * It costs 11 bytes and 14 cycles.
 *
 * @pre Register .X must be filled with internal Vdc register
 * to write on.
 * @pre Register .A must be filled with the value that will be
 * written to internal Vdc register.
 * @remark Flags N, Z and O will be affected.
 *
 * @note Use c128lib_WriteVdc in vdc-global.asm
 *
 * @since 1.1.0
 */
.macro WriteVdc() {
    stx Vdc.VDCADR
!:  bit Vdc.VDCADR
    bpl !-
    sta Vdc.VDCDAT
}
.assert "WriteVdc()", { WriteVdc() }, {
  stx $d600; bit $d600; bpl *-3; sta $d601
}

/**
 * @brief Read a value from Vdc register without using kernal
 * routine instead of pure instruction. It needs register
 * number in X and value is written in A.
 * It costs 11 bytes and 14 cycles.
 *
 * @pre Register .X must be filled with internal Vdc register
 * to read from.
 * @remark Register .A will be modified.
 * @remark Flags N, Z and O will be affected.
 * @post Register .A will contain the value read from internal
 * Vdc register.
 *
 * @note Use c128lib_ReadVdc in vdc-global.asm
 *
 * @since 1.1.0
 */
.macro ReadVdc() {
    stx Vdc.VDCADR
!:  bit Vdc.VDCADR
    bpl !-
    lda Vdc.VDCDAT
}
.assert "ReadVdc()", { ReadVdc() }, {
  stx $d600; bit $d600; bpl *-3; lda $d601
}
