/**
 * @file mem.asm
 * @brief Mem module
 * @details Simple macros for memory operations.
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

#import "labels/lib/mmu.asm"

.filenamespace c128lib

/**
 * @brief This macro copies a block of memory from one location to another in a fast manner.
 *
 * @details It uses the 6502 assembly instructions 'lda' (load accumulator) and 'sta' (store accumulator)
 * to perform the copy operation. This macro does not check for memory overlap between the source and
 * destination. If the source and destination overlap, the behavior is undefined.
 *
 * @param[in] source The starting address of the memory block to be copied.
 * @param[in] destination The starting address of the location where the memory block will be copied to.
 * @param[in] count The number of bytes to be copied.
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @note Usage: copyFast($C000, $C100, 256)  // Copies 256 bytes from memory location $C000 to $C100
 * @note Use c128lib_copyFast in mem-global.asm
 *
 * @since 0.1.0
 */
.macro copyFast(source, destination, count) {
  .for(var i = 0; i < count; i++) {
    lda source + i
    sta destination + i
  }
}
.assert "copyFast($A000, $B000, 0) copies nothing", { copyFast($A000, $B000, 0) }, {}
.assert "copyFast($A000, $B000, 1) copies one byte", { copyFast($A000, $B000, 1) }, {
  lda $A000; sta $B000
}
.assert "copyFast($A000, $B000, 2) copies two bytes", { copyFast($A000, $B000, 2) }, {
  lda $A000; sta $B000
  lda $A001; sta $B001
}

/**
 * @brief This macro copies a block of memory from one location to another using page relocation.
 *
 * @details This macro also handles the page relocation of the memory block during the copy operation.
 * It's slower than @sa copyFast but it uses much less memory, especially for large memory blocks copy.
 *
 * @param[in] source The starting address of the memory block to be copied.
 * @param[in] destination The starting address of the location where the memory block will be copied to.
 * @param[in] count The number of bytes to be copied.
 *
 * @remark Registers .A, .X, and .Y will be modified.
 * @remark Flags N and Z will be affected.
 * @remark Zeropage location $fe will be used.
 *
 * @note Usage: copyWithRelocation($C000, $C100, 256)  // Copies 256 bytes from memory location $C000 to $C100 with relocation
 * @note Use c128lib_copyWithRelocation in mem-global.asm
 *
 * @since 0.1.0
 */
.macro copyWithRelocation(source, destination, count) {
    .label TEMP = $fe
    sei
    stx !+ + 2
    tsx
    stx TEMP
    sty Mmu.PAGE1_PAGE_POINTER

    ldx #0
    txs
!:  lda Mmu.LOAD_CONFIGURATION,x
    pha
    dex
    bne !-

    ldx #1
    stx Mmu.PAGE1_PAGE_POINTER
    ldx TEMP
    txs
    cli
    rts
}

/**
 * @brief This macro fills memory with a specified value.
 *
 * @details This macro fills memory starting from the specified address with the given value.
 *
 * @param[in] address The starting address of memory.
 * @param[in] length The memory length to be filled.
 * @param[in] value The value to be filled on memory.
 *
 * @remark Registers .A and .X will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @note Usage: fillMemory($0400, 50, $E0)  // Fills 50 bytes in memory starting from memory location $0400 with the value $E0
 * @note Use c128lib_fillMemory in mem-global.asm
 * @note Minimum length is set to 5 because it's not convenient to use this
 * macro for lower values.
 *
 * @since 0.1.0
 */
.macro fillMemory(address, length, value) {
  .errorif (length < 5 || length > 255), "length must be from 5 to 255"
  .errorif (value < 0 || value > 255), "value must be from 0 to 255"
  ldx #0
  ldy #length
  .if (length==value) {
    tya
  } else {
    lda #value
  }
!:
  sta address, x
  inx
  dey
  bne !-
}
.asserterror "fillMemory($A000, 4, 10)", { fillMemory($A000, 4, 10) }
.asserterror "fillMemory($A000, 256, 10)", { fillMemory($A000, 256, 10) }
.asserterror "fillMemory($A000, 10, -1)", { fillMemory($A000, 10, -1) }
.asserterror "fillMemory($A000, 10, 256)", { fillMemory($A000, 10, 256) }
.assert "fillMemory($A000, 10, 10) fill 10 byte with optimization", { fillMemory($A000, 10, 10) }, {
    ldx #0
    ldy #10
    tya
    sta $a000, x
    inx
    dey
    bne *-5
}
.assert "fillMemory($A000, 5, 24) fill 5 byte", { fillMemory($A000, 5, 24) }, {
    ldx #0
    ldy #5
    lda #24
    sta $a000, x
    inx
    dey
    bne *-5
}
.assert "fillMemory($B000, 16, 24) fill 16 bytes", { fillMemory($B000, 16, 24) }, {
    ldx #0
    ldy #16
    lda #24
    sta $B000, x
    inx
    dey
    bne *-5
}
