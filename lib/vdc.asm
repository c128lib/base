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
#import "labels/lib/screeneditor.asm"
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
 * @brief Read from Vdc internal memory and write it to Vic screen memory by
 * using coordinates.
 *
 * @param[in] xPos X coord on Vdc screen
 * @param[in] yPos Y coord on Vdc screen
 * @param[in] destination Vic screen memory absolute address
 * @param[in] qty Number of byte to copy
 *
 * @note Use c128lib_ReadFromVdcMemoryByCoordinates in vdc-global.asm
 *
 * @since 1.1.0
 */
.macro ReadFromVdcMemoryByCoordinates(xPos, yPos, destination, qty) {
  .errorif (xPos == -1 && yPos != -1), "xPos and yPos must be -1 at same time"
  .errorif (xPos != -1 && yPos == -1), "xPos and yPos must be -1 at same time"
  .errorif (xPos < -1 || yPos < -1), "xPos and yPos can't be lower than -1"
  .errorif (qty <= 0), "qty must be greater than 0"
  .errorif (qty > 255), "qty must be lower than 256"
  .if (xPos != -1 && yPos != -1) {
    ldx #$12
    lda #>getTextOffset80Col(xPos, yPos)
    jsr ScreenEditor.WRITEREG
    lda #<getTextOffset80Col(xPos, yPos)
    inx
    jsr ScreenEditor.WRITEREG
  }
    ldy #0
  CopyLoop:
    jsr ScreenEditor.READ80
    sta destination, y
    iny
    cpy #qty
    bne CopyLoop
}
.asserterror "ReadFromVdcMemoryByCoordinates(-1, 0, $beef, 100)", { ReadFromVdcMemoryByCoordinates(-1, 0, $beef, 100) }
.asserterror "ReadFromVdcMemoryByCoordinates(0, -1, $beef, 100)", { ReadFromVdcMemoryByCoordinates(0, -1, $beef, 100) }
.asserterror "ReadFromVdcMemoryByCoordinates(-2, 0, $beef, 100)", { ReadFromVdcMemoryByCoordinates(-2, 0, $beef, 100) }
.asserterror "ReadFromVdcMemoryByCoordinates(0, -2, $beef, 100)", { ReadFromVdcMemoryByCoordinates(0, -2, $beef, 100) }
.asserterror "ReadFromVdcMemoryByCoordinates(-2, -2, $beef, 100)", { ReadFromVdcMemoryByCoordinates(-2, -2, $beef, 100) }
.asserterror "ReadFromVdcMemoryByCoordinates(2, 2, $beef, 0)", { ReadFromVdcMemoryByCoordinates(2, 2, $beef, 0) }
.asserterror "ReadFromVdcMemoryByCoordinates(2, 2, $beef, 256)", { ReadFromVdcMemoryByCoordinates(2, 2, $beef, 256) }
.assert "ReadFromVdcMemoryByCoordinates(-1, -1, $beef, 100)", { ReadFromVdcMemoryByCoordinates(-1, -1, $beef, 100) },
{
    ldy #0; jsr $CDD8; sta $beef, y; iny; cpy #100; bne *-9;
}
.assert "ReadFromVdcMemoryByCoordinates(1, 1, $beef, 100)", { ReadFromVdcMemoryByCoordinates(1, 1, $beef, 100) },
{
    ldx #$12; lda #0; jsr $CDCC; lda #81; inx; jsr $CDCC;
    ldy #0; jsr $CDD8; sta $beef, y; iny; cpy #100; bne *-9;
}
.assert "ReadFromVdcMemoryByCoordinates(1, 1, $beef, 255)", { ReadFromVdcMemoryByCoordinates(1, 1, $beef, 255) },
{
    ldx #$12; lda #0; jsr $CDCC; lda #81; inx; jsr $CDCC;
    ldy #0; jsr $CDD8; sta $beef, y; iny; cpy #255; bne *-9;
}

/**
 * @brief Read from Vdc internal memory and write it to Vic screen memory by
 * using source address.
 *
 * @param[in] source Vdc memory absolute address
 * @param[in] destination Vic screen memory absolute address
 * @param[in] qty Number of byte to copy
 *
 * @note Use c128lib_ReadFromVdcMemoryByAddress in vdc-global.asm
 *
 * @since 1.1.0
 */
.macro ReadFromVdcMemoryByAddress(source, destination, qty) {
  .errorif (qty <= 0), "qty must be greater than 0"
  .errorif (qty > 255), "qty must be lower than 256"
    ldx #$12
    lda #>source
    jsr c128lib.ScreenEditor.WRITEREG
    lda #<source
    inx
    jsr c128lib.ScreenEditor.WRITEREG

    ldy #0
  CopyLoop:
    jsr c128lib.ScreenEditor.WRITE80
    sta destination, y
    iny
    cpy #qty
    bne CopyLoop
}
.asserterror "ReadFromVdcMemoryByAddress($beef, $baab, 0)", { ReadFromVdcMemoryByAddress($beef, $baab, 0) }
.asserterror "ReadFromVdcMemoryByAddress($beef, $baab, 256)", { ReadFromVdcMemoryByAddress($beef, $baab, 256) }
.assert "ReadFromVdcMemoryByAddress($beef, $baab, 100)", { ReadFromVdcMemoryByAddress($beef, $baab, 100) },
{
    ldx #$12; lda #$be; jsr $CDCC; lda #$ef; inx; jsr $CDCC;
    ldy #0; jsr $CDCA; sta $baab, y; iny; cpy #100; bne *-9;
}
.assert "ReadFromVdcMemoryByAddress($beef, $baab, 255)", { ReadFromVdcMemoryByAddress($beef, $baab, 255) },
{
    ldx #$12; lda #$be; jsr $CDCC; lda #$ef; inx; jsr $CDCC;
    ldy #0; jsr $CDCA; sta $baab, y; iny; cpy #255; bne *-9;
}

/**
 * @brief Read from Vic screen memory and write it to Vdc internal memory by
 * using coordinates.
 *
 * @param[in] xPos X coord on Vic screen
 * @param[in] yPos Y coord on Vic screen
 * @param[in] destination Vdc internal memory absolute address
 * @param[in] qty Number of byte to copy
 *
 * @note Use c128lib_WriteToVdcMemoryByCoordinates in vdc-global.asm
 *
 * @since 1.1.0
 */
.macro WriteToVdcMemoryByCoordinates(source, xPos, yPos, qty) {
  .errorif (xPos == -1 && yPos != -1), "xPos and yPos must be -1 at same time"
  .errorif (xPos != -1 && yPos == -1), "xPos and yPos must be -1 at same time"
  .errorif (xPos < -1 || yPos < -1), "xPos and yPos can't be lower than -1"
  .errorif (qty <= 0), "qty must be greater than 0"
  .errorif (qty > 255), "qty must be lower than 256"
  .if (xPos != -1 && yPos != -1) {
    ldx #$12
    lda #>getTextOffset80Col(xPos, yPos)
    jsr c128lib.ScreenEditor.WRITEREG
    lda #<getTextOffset80Col(xPos, yPos)
    inx
    jsr c128lib.ScreenEditor.WRITEREG
  }
    ldy #0
  CopyLoop:
    lda source, y
    jsr c128lib.ScreenEditor.WRITE80
    iny
    cpy #qty
    bne CopyLoop
}
.asserterror "WriteToVdcMemoryByCoordinates($beef, -1, 0, 100)", { WriteToVdcMemoryByCoordinates($beef, -1, 0, 100) }
.asserterror "WriteToVdcMemoryByCoordinates($beef, 0, -1, 100)", { WriteToVdcMemoryByCoordinates($beef, 0, -1, 100) }
.asserterror "WriteToVdcMemoryByCoordinates($beef, -2, 0, 100)", { WriteToVdcMemoryByCoordinates($beef, -2, 0, 100) }
.asserterror "WriteToVdcMemoryByCoordinates($beef, 0, -2, 100)", { WriteToVdcMemoryByCoordinates($beef, 0, -2, 100) }
.asserterror "WriteToVdcMemoryByCoordinates($beef, -2, -2, 100)", { WriteToVdcMemoryByCoordinates($beef, -2, -2, 100) }
.asserterror "WriteToVdcMemoryByCoordinates($beef, 2, 2, 0)", { WriteToVdcMemoryByCoordinates($beef, 2, 2, 0) }
.asserterror "WriteToVdcMemoryByCoordinates($beef, 2, 2, 256)", { WriteToVdcMemoryByCoordinates($beef, 2, 2, 256) }
.assert "WriteToVdcMemoryByCoordinates($beef, -1, -1, 100)", { WriteToVdcMemoryByCoordinates($beef, -1, -1, 100) },
{
    ldy #0; lda $beef, y; jsr $CDCA; iny; cpy #100; bne *-9;
}
.assert "WriteToVdcMemoryByCoordinates($beef, 1, 1, 100)", { WriteToVdcMemoryByCoordinates($beef, 1, 1, 100) },
{
    ldx #$12; lda #0; jsr $CDCC; lda #81; inx; jsr $CDCC;
    ldy #0; lda $beef, y; jsr $CDCA; iny; cpy #100; bne *-9;
}
.assert "WriteToVdcMemoryByCoordinates($beef, 1, 1, 255)", { WriteToVdcMemoryByCoordinates($beef, 1, 1, 255) },
{
    ldx #$12; lda #0; jsr $CDCC; lda #81; inx; jsr $CDCC;
    ldy #0; lda $beef, y; jsr $CDCA; iny; cpy #255; bne *-9;
}

/**
 * @brief Read from Vic screen memory and write it to Vdc internal memory by
 * using coordinates.
 *
 * @param[in] source Vdc memory absolute address
 * @param[in] destination Vic screen memory absolute address
 * @param[in] qty Number of byte to copy
 *
 * @note Use c128lib_WriteToVdcMemoryByAddress in vdc-global.asm
 *
 * @since 1.1.0
 */
.macro WriteToVdcMemoryByAddress(source, destination, qty) {
  .errorif (qty <= 0), "qty must be greater than 0"
  .errorif (qty > 255), "qty must be lower than 256"
    ldx #$12
    lda #>destination
    jsr c128lib.ScreenEditor.WRITEREG
    lda #<destination
    inx
    jsr c128lib.ScreenEditor.WRITEREG

    ldy #0
  CopyLoop:
    lda source, y
    jsr c128lib.ScreenEditor.WRITE80
    iny
    cpy #qty
    bne CopyLoop
}
.asserterror "WriteToVdcMemoryByAddress($beef, $baab, 0)", { WriteToVdcMemoryByAddress($beef, $baab, 0) }
.asserterror "WriteToVdcMemoryByAddress($beef, $baab, 256)", { WriteToVdcMemoryByAddress($beef, $baab, 256) }
.assert "WriteToVdcMemoryByAddress($beef, $baab, 100)", { WriteToVdcMemoryByAddress($beef, $baab, 100) },
{
    ldx #$12; lda #$ba; jsr $CDCC; lda #$ab; inx; jsr $CDCC;
    ldy #0; lda $beef, y; jsr $CDCA; iny; cpy #100; bne *-9;
}
.assert "WriteToVdcMemoryByAddress($beef, $baab, 255)", { WriteToVdcMemoryByAddress($beef, $baab, 255) },
{
    ldx #$12; lda #$ba; jsr $CDCC; lda #$ab; inx; jsr $CDCC;
    ldy #0; lda $beef, y; jsr $CDCA; iny; cpy #255; bne *-9;
}

/**
 * @brief Calculates memory offset of text cell specified by given coordinates
 * on 80 cols screen
 *
 * @param[in] xPos X coord on Vdc screen
 * @param[in] yPos Y coord on Vdc screen
 * @return Memory offset of Vdc specified coordinate
 *
 * @note Use c128lib_WriteToVdcMemoryByAddress in vdc-global.asm
 *
 * @since 1.1.0
 */
.function getTextOffset80Col(xPos, yPos) {
  .return xPos + Vdc.TEXT_SCREEN_80_COL_WIDTH * yPos
}
.assert "getTextOffset80Col(0,0) gives 0", getTextOffset80Col(0, 0), 0
.assert "getTextOffset80Col(79,0) gives 79", getTextOffset80Col(79, 0), 79
.assert "getTextOffset80Col(0,1) gives 80", getTextOffset80Col(0, 1), 80
.assert "getTextOffset80Col(19,12) gives 979", getTextOffset80Col(19, 12), 979
.assert "getTextOffset80Col(79,24) gives 1999", getTextOffset80Col(79, 24), 1999

/**
 * @brief Returns the address start of Vdc display memory data. This
 * is stored in Vdc register SCREEN_MEMORY_STARTING_HIGH_ADDRESS and
 * SCREEN_MEMORY_STARTING_LOW_ADDRESS.
 * The 16-bit value is stored in $FB and $FC.
 *
 * @note Use c128lib_GetVdcDisplayStart in vdc-global.asm
 *
 * @since 1.1.0
 */
.macro GetVdcDisplayStart() {
  ldx #Vdc.SCREEN_MEMORY_STARTING_HIGH_ADDRESS
  ReadVdc()

  sta $fb
  inx
  ReadVdc()
  sta $fc
}

/**
 * @brief Set the pointer to the RAM area that is to be updated.
 * The update pointer is stored in Vdc register CURRENT_MEMORY_HIGH_ADDRESS
 * and CURRENT_MEMORY_LOW_ADDRESS.
 *
 * @param[in] address Address of update area
 *
 * @note Use c128lib_SetVdcUpdateAddress in vdc-global.asm
 *
 * @since 1.1.0
 */
.macro SetVdcUpdateAddress(address) {
  ldx #Vdc.CURRENT_MEMORY_HIGH_ADDRESS
  lda #>address
  WriteVdc();

  inx
  .var a1 = <address
  .var a2 = >address
  .if (a1 != a2) {
    lda #<address // include if different from hi-byte.
  }
  WriteVdc()
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
