/**
 * @file vdc-global.asm
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

#import "vdc.asm"

.filenamespace c128lib

/**
 * @brief Go to 40 columns mode
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.1.0
 */
.macro @c128lib_Go40() { Go40() }

/**
 * @brief Go to 80 columns mode
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.1.0
 */
.macro @c128lib_Go80() { Go80() }

/**
 * @brief Set background and foreground color, also disable bit 6 of
 * HORIZONTAL_SMOOTH_SCROLLING register
 *
 * @param[in] background Background color
 * @param[in] foreground Foreground color
 *
 * @remark Register .A and .X will be modified.
 * @remark Flags N, Z and O will be affected.
 *
 * @since 1.1.0
 */
.macro @c128lib_SetBackgroundForegroundColor(background, foreground) { SetBackgroundForegroundColor(background, foreground) }

/**
 * @brief Set background and foreground color, also disable bit 6 of
 * HORIZONTAL_SMOOTH_SCROLLING register. Use vars instead of labels.
 * Warning: high nibble of background must be 0, it's up to developer
 * to check this.
 *
 * @param[in] background Background color address
 * @param[in] foreground Foreground color address
 *
 * @remark Register .A and .X will be modified.
 * @remark Flags N, Z, C and O will be affected.
 *
 * @since 1.1.0
 */
.macro @c128lib_SetBackgroundForegroundColorWithVars(background, foreground) { SetBackgroundForegroundColorWithVars(background, foreground) }

/**
 * @brief Read from Vdc internal memory and write it to Vic screen memory by
 * using coordinates.
 *
 * @param[in] xPos X coord on Vdc screen
 * @param[in] yPos Y coord on Vdc screen
 * @param[in] destination Vic screen memory absolute address
 * @param[in] qty Number of byte to copy
 *
 * @remark Register .A and .X will be modified.
 * @remark Flags N, Z and O will be affected.
 *
 * @since 1.1.0
 */
.macro @c128lib_ReadFromVdcMemoryByCoordinates(xPos, yPos, destination, qty) { ReadFromVdcMemoryByCoordinates(xPos, yPos, destination, qty) }

/**
 * @brief Read from Vdc internal memory and write it to Vic screen memory by
 * using source address.
 *
 * @param[in] source Vdc memory absolute address
 * @param[in] destination Vic screen memory absolute address
 * @param[in] qty Number of byte to copy
 *
 * @remark Register .A, .X and .Y will be modified.
 * @remark Flags N, Z and C will be affected.
 *
 * @since 1.1.0
 */
.macro @c128lib_ReadFromVdcMemoryByAddress(source, destination, qty) { ReadFromVdcMemoryByAddress(source, destination, qty) }

/**
 * @brief Read from Vic screen memory and write it to Vdc internal memory by
 * using coordinates.
 *
 * @param[in] xPos X coord on Vic screen
 * @param[in] yPos Y coord on Vic screen
 * @param[in] destination Vdc internal memory absolute address
 * @param[in] qty Number of byte to copy
 *
 * @remark Register .A, .X and .Y will be modified.
 * @remark Flags N, Z and C will be affected.
 *
 * @since 1.1.0
 */
.macro @c128lib_WriteToVdcMemoryByCoordinates(source, xPos, yPos, qty) { WriteToVdcMemoryByCoordinates(source, xPos, yPos, qty) }

/**
 * @brief Read from Vic screen memory and write it to Vdc internal memory by
 * using coordinates.
 *
 * @param[in] source Vdc memory absolute address
 * @param[in] destination Vic screen memory absolute address
 * @param[in] qty Number of byte to copy
 *
 * @remark Register .A, .X and .Y will be modified.
 * @remark Flags N, Z and C will be affected.
 *
 * @since 1.1.0
 */
.macro @c128lib_WriteToVdcMemoryByAddress(source, destination, qty) { WriteToVdcMemoryByAddress(source, destination, qty) }

/**
 * @brief Calculates memory offset of text cell specified by given coordinates
 * on 80 cols screen
 *
 * @param[in] xPos X coord on Vdc screen
 * @param[in] yPos Y coord on Vdc screen
 * @return Memory offset of Vdc specified coordinate
 *
 * @since 1.2.0
 */
.function c128lib_getTextOffset80Col(xPos, yPos) { .return getTextOffset80Col(xPos, yPos) }

/**
 * @brief Returns the address start of Vdc display memory data. This
 * is stored in Vdc register SCREEN_MEMORY_STARTING_HIGH_ADDRESS and
 * SCREEN_MEMORY_STARTING_LOW_ADDRESS.
 * The 16-bit value is stored in $FB and $FC.
 *
 * @remark Register .A and .X will be modified.
 * @remark Flags N, Z and O will be affected.
 *
 * @since 1.1.0
 */
.macro @c128lib_GetVdcDisplayStart() { GetVdcDisplayStart() }

/**
 * @brief Set the pointer to the RAM area that is to be updated.
 * The update pointer is stored in Vdc register CURRENT_MEMORY_HIGH_ADDRESS
 * and CURRENT_MEMORY_LOW_ADDRESS.
 *
 * @param[in] address Address of update area
 *
 * @remark Register .A and .X will be modified.
 * @remark Flags N, Z and O will be affected.
 *
 * @since 1.1.0
 */
.macro @c128lib_SetVdcUpdateAddress(address) { SetVdcUpdateAddress(address) }

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
 * @since 1.1.0
 */
.macro @c128lib_WriteVdc() { WriteVdc() }

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
 * @since 1.1.0
 */
.macro @c128lib_ReadVdc() { ReadVdc() }
