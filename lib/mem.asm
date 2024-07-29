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
#import "labels/lib/zeropage.asm"

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
 * @par Usage
 * @code{.asm}
 * // Copies 256 bytes from memory location $C000 to $C100
 * c128lib_CopyFast($C000, $C100, 256)
 * @endcode
 *
 * @since 1.3.0
 */
.macro @c128lib_CopyFast(source, destination, count) {
  .for(var i = 0; i < count; i++) {
    lda source + i
    sta destination + i
  }
}
.assert "c128lib_CopyFast($A000, $B000, 0) copies nothing", { c128lib_CopyFast($A000, $B000, 0) }, {}
.assert "c128lib_CopyFast($A000, $B000, 1) copies one byte", { c128lib_CopyFast($A000, $B000, 1) }, {
  lda $A000; sta $B000
}
.assert "c128lib_CopyFast($A000, $B000, 2) copies two bytes", { c128lib_CopyFast($A000, $B000, 2) }, {
  lda $A000; sta $B000
  lda $A001; sta $B001
}

/**
 * @brief This macro copies a block of memory from one location to another using page relocation.
 *
 * @details This macro also handles the page relocation of the memory block during the copy operation.
 * It's slower than @sa c128lib_CopyFast but it uses much less memory, especially for large memory blocks copy.
 *
 * @param[in] source The starting address of the memory block to be copied.
 * @param[in] destination The starting address of the location where the memory block will be copied to.
 *
 * @remark Registers .A and .X will be modified.
 * @remark Flags N and Z will be affected.
 * @remark Zeropage location $FE will be used.
 * @remark During copy, interrupts are disabled.
 *
 * @par Usage
 * @code{.asm}
 * // Copies 256 bytes from memory location $C000 to $C100 with relocation
 * c128lib_CopyWithRelocation($C000, $C100, 256)
 * @endcode
 *
 * @note The number of bytes that can be copied is always 256.
 * @note Source and destination less significant byte should be $00. Any
 * different value will be ignored.
 *
 * @since 1.3.0
 */
.macro @c128lib_CopyWithRelocation(source, destination) {
    sei
    ldx #>source  // Preparing self mod code
    stx !+ + 2
    tsx           // Save current stack pointer
    stx Zeropage.FE
    ldx #>destination
    stx Mmu.PAGE1_PAGE_POINTER

    ldx #0
    txs
!:  lda $FF00,x   // Placeholder for self mod code
    pha
    dex
    bne !-

    // .X contains 0 because bne didn't jump to the start of the loop
    inx           // Setting back stack page to 1
    stx Mmu.PAGE1_PAGE_POINTER
    ldx Zeropage.FE
    txs           // Setting stack pointer to previous value
    cli
}

/**
 * @brief This macro copies a block of memory from one location to another using page relocation
 * with bank selection.
 *
 * @details This macro also handles the page relocation of the memory block during the copy operation.
 * It's slower than @sa CopyFast but it uses much less memory, especially for large memory blocks copy.
 * This version allows to specify the bank for source and destination memory locations.
 *
 * @param[in] source The starting address of the memory block to be copied.
 * @param[in] sourceBank Bank of the starting address.
 * @param[in] destination The starting address of the location where the memory block will be copied to.
 * @param[in] destinationBank Bank of the destination address.
 *
 * @remark Registers .A and .X will be modified.
 * @remark Flags N and Z will be affected.
 * @remark Zeropage location $FE will be used.
 * @remark During copy, interrupts are disabled.
 *
 * @par Usage
 * @code{.asm}
 * // Copies 256 bytes from memory location $C000 in bank 0 to $C100 in bank 1 with relocation
 * c128lib_CopyWithRelocationWithBank($C000, 0, $C100, 1)
 * @endcode
 *
 * @note The number of bytes that can be copied is always 256.
 * @note Source and destination less significant byte should be $00. Any
 * different value will be ignored.
 *
 * @since 1.3.0
 */
.macro @c128lib_CopyWithRelocationWithBank(source, sourceBank, destination, destinationBank) {
    sei
    ldx #>source  // Preparing self mod code
    stx !+ + 2
    tsx           // Save current stack pointer

    lda Mmu.PAGE0_BLOCK_POINTER
    pha
    lda sourceBank
    sta Mmu.PAGE0_BLOCK_POINTER

    lda Mmu.PAGE1_BLOCK_POINTER
    pha
    lda destinationBank
    sta Mmu.PAGE1_BLOCK_POINTER

    stx Zeropage.FE
    ldx #>destination
    stx Mmu.PAGE1_PAGE_POINTER
    
    ldx #0
    txs
!:  lda $FF00,x   // Placeholder for self mod code
    pha
    dex
    bne !-

    // .X contains 0 because bne didn't jump to the start of the loop
    inx           // Setting back stack page to 1
    stx Mmu.PAGE1_PAGE_POINTER
    ldx Zeropage.FE
    txs           // Setting stack pointer to previous value

    pla
    sta Mmu.PAGE1_BLOCK_POINTER

    pla
    sta Mmu.PAGE0_BLOCK_POINTER

    cli
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
 * @par Usage
 * @code{.asm}
 * // Fills 50 bytes in memory starting from memory location $0400 with the value $E0
 * c128lib_FillMemory($0400, 50, $E0)
 * @endcode
 *
 * @note Minimum length is set to 5 because it's not convenient to use this
 * macro for lower values.
 *
 * @since 1.3.0
 */
.macro @c128lib_FillMemory(address, length, value) {
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
.asserterror "c128lib_FillMemory($A000, 4, 10)", { c128lib_FillMemory($A000, 4, 10) }
.asserterror "c128lib_FillMemory($A000, 256, 10)", { c128lib_FillMemory($A000, 256, 10) }
.asserterror "c128lib_FillMemory($A000, 10, -1)", { c128lib_FillMemory($A000, 10, -1) }
.asserterror "c128lib_FillMemory($A000, 10, 256)", { c128lib_FillMemory($A000, 10, 256) }
.assert "c128lib_FillMemory($A000, 10, 10) fill 10 byte with optimization", { c128lib_FillMemory($A000, 10, 10) }, {
    ldx #0
    ldy #10
    tya
    sta $a000, x
    inx
    dey
    bne *-5
}
.assert "c128lib_FillMemory($A000, 5, 24) fill 5 byte", { c128lib_FillMemory($A000, 5, 24) }, {
    ldx #0
    ldy #5
    lda #24
    sta $a000, x
    inx
    dey
    bne *-5
}
.assert "c128lib_FillMemory($B000, 16, 24) fill 16 bytes", { c128lib_FillMemory($B000, 16, 24) }, {
    ldx #0
    ldy #16
    lda #24
    sta $B000, x
    inx
    dey
    bne *-5
}

/**
 * @brief This macro compares a 16-bit value with a 16-bit memory location.
 * 
 * @details The macro first compares the low byte of the value with the low byte of the memory location, 
 * and if they are equal, it then compares the high byte of the value with the high byte of the memory location.
 *
 * @param value The 16-bit value to be compared.
 * @param address The starting address of the 16-bit memory location to be compared with.
 * @return Flag C is set if value is greater than or equal to the value of the
 * memory location, otherwise it is cleared.
 *
 * @remark Register .A will be modified.
 * @remark Flags N, Z and C will be affected.
 *
 * @par Usage
 * @code{.asm}
 * // Compares the 16-bit value $1234 with the 16-bit memory location starting at $C000
 * c128lib_Cmp16($1234, $C000)
 * @endcode
 *
 * @since 1.3.0
 */
.macro @c128lib_Cmp16(value, address) {
  lda #<value
  cmp address
  bne end
  lda #>value
  cmp address + 1
end:
}

/**
 * @brief Fills one-byte located in memory address "mem" with byte "value".
 *
 * @param[in] value value to set on specified address
 * @param[in] address address to set
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.3.0
 */
.macro @c128lib_Set8(value, address) {
  set8 #value : address
}
.assert "c128lib_Set8($34, $A000) stores $34 under $A000", { c128lib_Set8($34, $A000) }, {
  lda #$34
  sta $A000
}

.pseudocommand set8 value : address {
  lda value
  sta address
}

/**
 * @brief Fills two-byte located in memory address "mem" with byte "value".
 *
 * @param[in] value value to set on specified address
 * @param[in] address address to set
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.3.0
 */
.macro @c128lib_Set16(value, address) {
  c128lib_Set8(<value, address)
  c128lib_Set8(>value, address + 1)
}
.assert "c128lib_Set16($1234, $A000) stores $34 under $A000 and $12 under $A001", { c128lib_Set16($3412, $A000) }, {
  lda #$12
  sta $A000
  lda #$34
  sta $A001
}
