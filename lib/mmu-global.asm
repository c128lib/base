/**
 * @file mmu-global.asm
 * @brief Mmu module
 * @details Simple macros for the Commodore 128.
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

#import "mmu.asm"

.filenamespace c128lib

/**
 * @brief Macro for Mmu configuration.
 *
 * I/O block selection
 *
 * - Mmu.IO_ROM set I/O block visible on $D000-$DFFF
 * - Mmu.IO_RAM set area on $D000-$DFFF dependant from Mmu.ROM_HI selection
 *
 * If omitted, Mmu.IO_ROM will be used.
 *
 * Low-ram selection
 *
 * - Mmu.ROM_LOW_ROM set rom active for low BASIC ($4000-$7FFF)
 * - Mmu.ROM_LOW_RAM set ram active on $4000-$7FFF
 *
 * If omitted, Mmu.ROM_LOW_ROM will be used.
 *
 * Mid-ram selection
 *
 * - Mmu.ROM_MID_RAM set ram active on $8000-$AFFF and $B000-$BFFF
 * - Mmu.ROM_MID_EXT set external function ROM
 * - Mmu.ROM_MID_INT set internal function ROM
 * - Mmu.ROM_MID_ROM set rom active for BASIC ($8000-$AFFF) and monitor ($B000-$BFFF)
 *
 * If omitted, Mmu.ROM_MID_ROM will be used.
 *
 * Hi-ram selection
 *
 * - Mmu.ROM_HI_RAM set ram active on $C000-$CFFF, $D000-$DFFF and $E000-$FFFF
 * - Mmu.ROM_HI_EXT set external function ROM
 * - Mmu.ROM_HI_INT set internal function ROM
 * - Mmu.ROM_HI set rom active for Screen editor ($C000-$CFFF), character ($D000-$DFFF), Kernal ($E000-$FFFF)
 *
 * If omitted, Mmu.ROM_HI will be used.
 *
 * Bank selection
 *
 * - Mmu.RAM0 or Mmu.RAM1 can be used to set ram bank 0 or 1. If omitted, bank 0 will be selected.
 *
 * @param[in] config Values for Mmu confiuration
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.1.0
 */
.macro @c128lib_SetMMUConfiguration(config) { SetMMUConfiguration(config) }

/**
 * @brief Macro for Mmu configuration. Uses $FF00 instead of $D500.
 *
 * I/O block selection
 *
 * - Mmu.IO_ROM set I/O block visible on $D000-$DFFF
 * - Mmu.IO_RAM set area on $D000-$DFFF dependant from Mmu.ROM_HI selection
 *
 * If omitted, Mmu.IO_ROM will be used.
 *
 * Low-ram selection
 *
 * - Mmu.ROM_LOW_ROM set rom active for low BASIC ($4000-$7FFF)
 * - Mmu.ROM_LOW_RAM set ram active on $4000-$7FFF
 *
 * If omitted, Mmu.ROM_LOW_ROM will be used.
 *
 * Mid-ram selection
 *
 * - Mmu.ROM_MID_RAM set ram active on $8000-$AFFF and $B000-$BFFF
 * - Mmu.ROM_MID_EXT set external function ROM
 * - Mmu.ROM_MID_INT set internal function ROM
 * - Mmu.ROM_MID_ROM set rom active for BASIC ($8000-$AFFF) and monitor ($B000-$BFFF)
 *
 * If omitted, Mmu.ROM_MID_ROM will be used.
 *
 * Hi-ram selection
 *
 * - Mmu.ROM_HI_RAM set ram active on $C000-$CFFF, $D000-$DFFF and $E000-$FFFF
 * - Mmu.ROM_HI_EXT set external function ROM
 * - Mmu.ROM_HI_INT set internal function ROM
 * - Mmu.ROM_HI set rom active for Screen editor ($C000-$CFFF), character ($D000-$DFFF), Kernal ($E000-$FFFF)
 *
 * If omitted, Mmu.ROM_HI will be used.
 *
 * Bank selection
 *
 * - Mmu.RAM0 or Mmu.RAM1 can be used to set ram bank 0 or 1. If omitted, bank 0 will be selected.
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @note Use SetMMULoadConfiguration in mmu-global.asm
 *
 * @since 1.1.0
 */
.macro @c128lib_SetMMULoadConfiguration(config) { SetMMULoadConfiguration(config) }
