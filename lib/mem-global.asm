/**
 * @file mem-global.asm
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

#import "mem.asm"

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
 * @note Usage: c128lib_CopyFast($C000, $C100, 256)  // Copies 256 bytes from memory location $C000 to $C100
 *
 * @since 1.0.0
 */
.macro @c128lib_CopyFast(source, destination, count) { CopyFast(source, destination, count) }

/**
 * @brief This macro copies a block of memory from one location to another using page relocation.
 *
 * @details This macro also handles the page relocation of the memory block during the copy operation.
 * It's slower than @sa CopyFast but it uses much less memory, especially for large memory blocks copy.
 *
 * @param[in] source The starting address of the memory block to be copied.
 * @param[in] destination The starting address of the location where the memory block will be copied to.
 *
 * @remark Registers .A and .X will be modified.
 * @remark Flags N and Z will be affected.
 * @remark Zeropage location $fe will be used.
 * @remark During copy, interrupts are disabled.
 *
 * @note Usage: c128lib_CopyWithRelocation($C000, $C100)  // Copies 256 bytes from memory location $C000 to $C100 with relocation
 * @note The number of bytes that can be copied is always 256.
 * @note Source and destination less significant byte should be $00. Any
 * different value will be ignored.
 *
 * @since 1.0.0
 */
.macro @c128lib_CopyWithRelocation(source, destination) { CopyWithRelocation(source, destination) }

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
 * @note The number of bytes that can be copied is always 256.
 * @note Source and destination less significant byte should be $00. Any
 * different value will be ignored.
 *
 * @since 1.2.0
 */
.macro @c128lib_CopyWithRelocationWithBank(source, sourceBank, destination, destinationBank) { CopyWithRelocationWithBank(source, sourceBank, destination, destinationBank) }

/**
 * @brief This macro fills memory with a specified value.
 * 
 * @details This macro fills memory starting from the specified address with the given value.
 *
 * @param[in] address The starting address of the screen memory.
 * @param[in] value The value to be filled on the screen.
 * 
 * @remark Registers .A and .X will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @note Usage: c128lib_FillMemory($0400, $E0)  // Fills the screen starting from memory location $0400 with the value $E0
 *
 * @since 1.0.0
 */
.macro @c128lib_FillMemory(address, length, value) { FillMemory(address, length, value) }

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
 * @note Usage: c128lib_Cmp16($1234, $C000)  // Compares the 16-bit value $1234 with the 16-bit memory location starting at $C000
 *
 * @since 1.0.0
 */
.macro @c128lib_Cmp16(value, address) { Cmp16(value, address) }

/**
 * @brief Fills two-byte located in memory address "mem" with byte "value".
 *
 * @param[in] value value to set on specified address
 * @param[in] address address to set
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.0.0
*/
.macro @c128lib_Set16(value, address) { Set16(value, address) }
