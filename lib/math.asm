/**
 * @file math.asm
 * @brief Math module
 * @details Simple macros for math operations.
 *
 * @author Raffaele Intorcia raffaele.intorcia@gmail.com
 * @author John Palermo
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

#import "common.asm"

.filenamespace c128lib

/**
 * @brief This macro performs a 16-bit addition operation.
 *
 * @details The macro uses the 6502 processor's ADC (Add with Carry) instruction to perform the addition.
 * It first clears the carry flag with CLC, then adds the low byte of the value to the low byte at the destination,
 * and stores the result back in the low byte at the destination.
 * It then adds the high byte of the value to the high byte at the destination, taking into account any carry from the low byte addition,
 * and stores the result back in the high byte at the destination.
 *
 * @param[in] value The 16-bit value to add.
 * @param[in,out] dest The memory location of the other 16-bit value.
 * @returns Result is returned in dest memory location.
 *
 * @note Use c128lib_Add16 in math-global.asm
 *
 * @since 0.1.0
 */
 .macro Add16(value, dest) {
  clc
  lda dest
  adc #<value
  sta dest
  lda dest + 1
  adc #>value
  sta dest + 1
}
.assert "Add16($0102, $A000) ", { Add16($0102, $A000) }, {
  clc; lda $A000; adc #$02; sta $A000
  lda $A001; adc #$01; sta $A001
}

/**
 * @brief This macro performs a 16-bit subtraction operation.
 *
 * The macro uses the 6502 processor's SBC (Subtract with Carry) instruction to perform the subtraction.
 * It first sets the carry flag with SEC, then subtracts the low byte of the value from the low byte at the destination,
 * and stores the result back in the low byte at the destination.
 * It then subtracts the high byte of the value from the high byte at the destination, taking into account any borrow from the low byte subtraction,
 * and stores the result back in the high byte at the destination.
 *
 * @param[in] value The 16-bit value to subtract.
 * @param[in,out] dest The memory location of the other 16-bit value.
 * @returns Result is returned in dest memory location.
 *
 * @note Use c128lib_Sub16 in math-global.asm
 *
 * @since 0.1.0
 */
.macro Sub16(value, dest) {
  sec
  lda dest
  sbc #<value
  sta dest
  lda dest + 1
  sbc #>value
  sta dest + 1
}
.assert "Sub16($0102, $A000)", { Sub16($0102, $A000) }, {
  sec; lda $A000; sbc #$02; sta $A000
  lda $A001; sbc #$01; sta $A001
}
.assert "Sub16(256, $A000)", { Sub16(256, $A000) }, {
  sec; lda $A000; sbc #0; sta $A000
  lda $A001; sbc #1; sta $A001
}

/**
 * @brief This macro performs a 16-bit arithmetic shift left (ASL) operation.
 *
 * @details The macro uses the 6502 processor's ASL (Arithmetic Shift Left) instruction to perform the shift.
 * It first shifts the low byte at the value location left, then shifts the high byte at the value location left,
 * taking into account any carry from the low byte shift.
 *
 * @param[in,out] address The memory location of the 16-bit value to shift left.
 * @returns Result is returned in address memory location.
 *
 * @note Use c128lib_Asl16 in math-global.asm
 *
 * @since 0.1.0
 */
.macro Asl16(address) {
  asl16 address
}

.pseudocommand asl16 low {
  clc
  asl low
  bcc !+
  lda incArgument(low)
  asl
  ora #%1
  sta incArgument(low)
!:
}

/**
 * @brief This macro performs a 16-bit increment operation.
 *
 * @details The macro uses the 6502 processor's INC (INCrement memory) instruction to perform the decrement.
 * It first increments the low byte at the destination. If this results is zero,
 * it then increments the high byte at the destination.
 *
 * @param[in,out] address The memory location of the 16-bit value to increment.
 * @returns Result is returned in address memory location.
 *
 * @note Use c128lib_Inc16 in math-global.asm
 *
 * @since 0.1.0
 */
.macro Inc16(address) {
  inc16 address
}

.pseudocommand inc16 address {
  inc address
  bne !+
  inc incArgument(address)
!:
}

/**
 * @brief This macro performs a 16-bit decrement operation.
 *
 * @details The macro uses the 6502 processor's DEC (DECrement memory) instruction to perform the decrement.
 * It first decrements the low byte at the destination. If this results in a borrow (i.e., the low byte was 0 and becomes 0xFF),
 * it then decrements the high byte at the destination.
 *
 * @param[in,out] address The memory location of the 16-bit value to decrement.
 * @returns Result is returned in address memory location.
 *
 * @note Use c128lib_Dec16 in math-global.asm
 *
 * @since 0.1.0
 */
.macro Dec16(address) {
  dec16 address
}

.pseudocommand dec16 address {
  dec address
  lda address
  cmp #$ff
  bne !+
  dec incArgument(address)
!:
}

/**
 * @brief Divides a 16 bit number by a 16 bit number
 *
 * @details Divides the two-byte number dividend by the two-byte number divisor,
 * leaving the quotient in dividend and the remainder in remainder.
 * Addressing mode of 16-bit numbers uses little endian. 
 *
 * @param[in,out] dividend dividend and also quotient
 * @param[in] divisor divisor
 * @param[out] remainder remainder (wide as divisor)
 * @remark Registers .A, .X and .Y will be modified.
 * Flags N, Z and C will be affected.
 *
 * @note Use c128lib_div16By16 in math-global.asm
 *
 * @since 0.1.0
 */
.macro Div16By16(dividend, divisor, remainder) {
    lda #0          
    sta remainder     // Initialize remainder to 0.
    sta remainder+1
    ldx #16           // There are 16 bits in the dividend

  loop1:
    /* Shift the hi bit of dividend into remainder */
    asl dividend     
    rol dividend+1   
    rol remainder    
    rol remainder+1

    /* Trial subtraction */  
    lda remainder
    sec
    sbc divisor
    tay
    lda remainder+1
    sbc divisor+1

    /* Check subtraction */
    bcc loop2             // Did subtraction succeed?
    sta remainder+1       // If yes, save it, else loop2
    sty remainder
    inc dividend          // and record a 1 in the quotient

  loop2:
    dex
    bne loop1
}

/**
 * @brief Divides a 16 bit number by a 8 bit number
 *
 * @details Divides the two-byte number dividend by the one-byte number divisor,
 * leaving the quotient in dividend and the remainder in remainder.
 * Addressing mode of 16-bit numbers uses little endian.
 *
 * @param[in,out] dividend dividend and also quotient
 * @param[in] divisor divisor
 * @param[out] remainder remainder (wide as divisor)
 * @remark Registers .A, .X and .Y will be modified.
 * @remark Flags N, Z and C will be affected.
 *
 * @note Use c128lib_Div16By8 in math-global.asm
 *
 * @since 0.1.0
 */
.macro Div16By8(dividend, divisor, remainder) {
    lda #0          
    sta remainder     // Initialize remainder to 0.
    ldx #16           // There are 16 bits in the dividend
  loop1:
    /* Shift the hi bit of dividend into remainder */
    asl dividend     
    rol dividend+1   
    rol remainder    

    /* Trial subtraction */  
    lda remainder
    sec
    sbc divisor

    /* Check subtraction */
    bcc loop2             // Did subtraction succeed?
    sta remainder         // If yes, save it, else loop2
    inc dividend          // and record a 1 in the quotient

  loop2:
    dex
    bne loop1
}
