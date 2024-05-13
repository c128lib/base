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
 * @note Usage: c128lib_copyFast($C000, $C100, 256)  // Copies 256 bytes from memory location $C000 to $C100
 *
 * @since 0.1.0
 */
.macro c128lib_copyFast(source, destination, count) { copyFast(source, destination, count) }

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
 * @note Usage: c128lib_copyWithRelocation($C000, $C100, 256)  // Copies 256 bytes from memory location $C000 to $C100 with relocation
 * @note Minimum length is set to 5 because it's not convenient to use this
 * macro for lower values.
 *
 * @since 0.1.0
 */
.macro c128lib_copyWithRelocation(source, destination, count) { copyWithRelocation(source, destination, count) }

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
 * @note Usage: c128lib_fillMemory($0400, $E0)  // Fills the screen starting from memory location $0400 with the value $E0
 *
 * @since 0.1.0
 */
.macro c128lib_fillMemory(address, length, value) { fillMemory(address, length, value) }
