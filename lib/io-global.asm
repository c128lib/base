/**
 * @file io.asm
 * @brief Io module
 * @details Simple macros for Io.
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

#import "io.asm"

.filenamespace c128lib

/**
 * @brief Opens an I/O channel.
 *
 * @details This macro opens an I/O channel with the specified file number, device number, and secondary address. 
 * It loads the parameters into the appropriate registers and then calls the SETLFS routine in the C128 Kernal.
 *
 * @param[in] filenumber The file number for the I/O channel.
 * @param[in] devicenumber The device number for the I/O channel.
 * @param[in] secondary The secondary address for the I/O channel.
 * @remark Register .A, .X and .Y will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 0.1.0
 */
.macro c128lib_OpenIOChannel(filenumber, devicenumber, secondary) { OpenIOChannel(filenumber, devicenumber, secondary) }

/**
 * @brief Sets the name for I/O operations.
 *
 * @details This macro sets the name for I/O operations. It loads the length of the name and the address of the name into the appropriate registers, 
 * then calls the Kernal.JSETNAM routine.
 *
 * @param[in] length The length of the name.
 * @param[in] address The address where the name is stored.
 * @remark Register .A, .X and .Y will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 0.1.0
 */
.macro c128lib_SetIOName(length, address) { SetIOName(length, address) }

/**
 * @brief Sets the input channel.
 *
 * @details This macro sets the input channel for subsequent I/O operations. It loads the file number into the X register and then calls the CHKIN routine in the C128 Kernal.
 *
 * @param[in] filenumber The file number for the input channel.
 * @remark Register .X will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @note Use c128lib_SetInputChannel in io-global.asm
 *
 * @since 0.1.0
 */
.macro c128lib_SetInputChannel(filenumber) { SetInputChannel(filenumber) }

/**
 * @brief Sets the output channel.
 *
 * @details This macro sets the output channel for subsequent I/O operations. It loads the file number into the X register and then calls the Kernal.JCHKOUT routine.
 *
 * @param[in] filenumber The file number for the output channel.
 * @remark Register .X will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 0.1.0
 */
.macro c128lib_SetOutputChannel(filenumber) { SetOutputChannel(filenumber) }

/**
 * @brief Opens a file for I/O operations.
 *
 * @details This macro opens a file for I/O operations. It sets the name for I/O operations, opens an I/O channel with the specified file number, device number, and secondary address, 
 * calls the OPEN routine in the C128 Kernal, and sets the input channel for subsequent I/O operations.
 *
 * @param[in] length The length of the name.
 * @param[in] address The address where the name is stored.
 * @param[in] filenumber The file number for the I/O channel.
 * @param[in] devicenumber The device number for the I/O channel.
 * @param[in] secondary The secondary address for the I/O channel.
 *
 * @since 0.1.0
 */
.macro c128lib_OpenFile(length, address, filenumber, devicenumber, secondary) { OpenFile(length, address, filenumber, devicenumber, secondary) }
