/**
 * @file math-global.asm
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

#import "math.asm"

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
 * @since 1.0.0
 */
.macro @c128lib_Add16(value, dest) { Add16(value, dest) }

/**
 * @brief This macro performs a 16-bit subtraction operation.
 *
 * @details The macro uses the 6502 processor's SBC (Subtract with Carry) instruction to perform the subtraction.
 * It first sets the carry flag with SEC, then subtracts the low byte of the value from the low byte at the destination,
 * and stores the result back in the low byte at the destination.
 * It then subtracts the high byte of the value from the high byte at the destination, taking into account any borrow from the low byte subtraction,
 * and stores the result back in the high byte at the destination.
 *
 * @param[in] value The 16-bit value to subtract.
 * @param[in,out] dest The memory location of the other 16-bit value.
 * @returns Result is returned in dest memory location.
 * @remark Register .A will be modified.
 * @remark Flags N, O, Z and C will be affected.
 *
 * @since 1.0.0
 */
.macro @c128lib_Sub16(value, dest) { Sub16(value, dest) }

/**
 * @brief This macro performs a 16-bit arithmetic shift left (ASL) operation.
 *
 * @details The macro uses the 6502 processor's ASL (Arithmetic Shift Left) instruction to perform the shift.
 * It first shifts the low byte at the value location left, then shifts the high byte at the value location left,
 * taking into account any carry from the low byte shift.
 *
 * @param[in,out] address The memory location of the 16-bit value to shift left.
 * @returns Result is returned in address memory location.
 * @remark Register .A will be modified.
 * @remark Flags N, Z and C will be affected.
 *
 * @since 1.0.0
 */
.macro @c128lib_Asl16(address) { Asl16(address) }

/**
 * @brief This macro performs a 16-bit increment operation.
 *
 * @details The macro uses the 6502 processor's INC (INCrement memory) instruction to perform the decrement.
 * It first increments the low byte at the destination. If this results is zero,
 * it then increments the high byte at the destination.
 *
 * @param[in,out] address The memory location of the 16-bit value to increment.
 * @returns Result is returned in address memory location.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.0.0
 */
.macro @c128lib_Inc16(address) { Inc16(address) }

/**
 * @brief This macro performs a 16-bit decrement operation.
 *
 * @details The macro uses the 6502 processor's DEC (DECrement memory) instruction to perform the decrement.
 * It first decrements the low byte at the destination. If this results in a borrow (i.e., the low byte was 0 and becomes 0xFF),
 * it then decrements the high byte at the destination.
 *
 * @param[in,out] address The memory location of the 16-bit value to decrement.
 * @returns Result is returned in address memory location.
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.0.0
 */
.macro @c128lib_Dec16(address) { Dec16(address) }

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
 * @remark Flags N, O, Z and C will be affected.
 *
 * @since 1.0.0
 */
.macro @c128lib_Div16By16(dividend, divisor, remainder) { Div16By16(dividend, divisor, remainder) }

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
 * @remark Registers .A and .X will be modified.
 * @remark Flags N, O, Z and C will be affected.
 *
 * @since 1.0.0
 */
.macro @c128lib_Div16By8(dividend, divisor, remainder) { Div16By8(dividend, divisor, remainder) }
