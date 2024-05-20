/**
 * @file mmu.asm
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

#import "labels/lib/mmu.asm"

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
 * @note Use c128lib_SetMMUConfiguration in mmu-global.asm
 *
 * @since 1.1.0
 */
.macro SetMMUConfiguration(config) {
    lda #config
    sta Mmu.CONFIGURATION
}
.assert "SetMMUConfiguration(RAM1 | ROM_HI_RAM | ROM_MID_RAM | ROM_LOW_RAM | IO_RAM) sets accumulator to 7f", { SetMMUConfiguration(Mmu.RAM1 | Mmu.ROM_HI_RAM | Mmu.ROM_MID_RAM | Mmu.ROM_LOW_RAM | Mmu.IO_RAM) }, {
  lda #%01111111; sta $d500
}

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
 * @param[in] config Values for Mmu confiuration
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @note Use SetMMULoadConfiguration in mmu-global.asm
 *
 * @since 1.1.0
 */
.macro SetMMULoadConfiguration(config) {
    lda #config
    sta Mmu.LOAD_CONFIGURATION
}
.assert "SetMMULoadConfiguration(RAM1 | ROM_HI_RAM | ROM_MID_RAM | ROM_LOW_RAM | IO_RAM) sets accumulator to 7f", { SetMMULoadConfiguration(Mmu.RAM1 | Mmu.ROM_HI_RAM | Mmu.ROM_MID_RAM | Mmu.ROM_LOW_RAM | Mmu.IO_RAM) }, {
  lda #%01111111; sta $ff00
}

/**
 * @brief Set banking. Only main banking are available.
 *
 * @param[in] config Values for Mmu confiuration
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @note Use Basic banking, see reference https://c128lib.github.io/Reference/MemoryMap
 * Only banking 0, 1, 4, 5, 12, 13, 14 and 15 are supported.
 *
 * @note Use c128lib_SetBankConfiguration in mmu-global.asm
 *
 * @since 1.2.0
 */
.macro SetBankConfiguration(id) {
    .if (id==0) {
      SetMMULoadConfiguration(Mmu.RAM0 | Mmu.ROM_HI_RAM | Mmu.ROM_MID_RAM | Mmu.ROM_LOW_RAM | Mmu.IO_RAM)
    }
    .if (id==1) {
      SetMMULoadConfiguration(Mmu.RAM1 | Mmu.ROM_HI_RAM | Mmu.ROM_MID_RAM | Mmu.ROM_LOW_RAM | Mmu.IO_RAM)
    }
    .if (id==4) {
      SetMMULoadConfiguration(Mmu.RAM0 | Mmu.ROM_HI_INT | Mmu.ROM_MID_INT | Mmu.ROM_LOW_RAM | Mmu.IO_ROM)
    }
    .if (id==5) {
      SetMMULoadConfiguration(Mmu.RAM1 | Mmu.ROM_HI_INT | Mmu.ROM_MID_INT | Mmu.ROM_LOW_RAM | Mmu.IO_ROM)
    }
    .if (id==12) {
      SetMMULoadConfiguration(Mmu.RAM0 | Mmu.ROM_HI | Mmu.ROM_MID_INT | Mmu.ROM_LOW_RAM | Mmu.IO_ROM)
    }
    .if (id==13) {
      SetMMULoadConfiguration(Mmu.RAM0 | Mmu.ROM_HI | Mmu.ROM_MID_EXT | Mmu.ROM_LOW_RAM | Mmu.IO_ROM)
    }
    .if (id==14) {
      SetMMULoadConfiguration(Mmu.RAM0 | Mmu.ROM_HI | Mmu.ROM_MID_ROM | Mmu.ROM_LOW_ROM | Mmu.IO_RAM)
    }
    .if (id==15) {
      SetMMULoadConfiguration(Mmu.RAM0 | Mmu.ROM_HI | Mmu.ROM_MID_ROM | Mmu.ROM_LOW_ROM | Mmu.IO_ROM)
    }
}
.assert "SetBankConfiguration(0)", { SetBankConfiguration(0) }, {
  lda #%00111111; sta $ff00
}
.assert "SetBankConfiguration(1)", { SetBankConfiguration(1) }, {
  lda #%01111111; sta $ff00
}
.assert "SetBankConfiguration(4)", { SetBankConfiguration(4) }, {
  lda #%00010110; sta $ff00
}
.assert "SetBankConfiguration(5)", { SetBankConfiguration(5) }, {
  lda #%01010110; sta $ff00
}
.assert "SetBankConfiguration(12)", { SetBankConfiguration(12) }, {
  lda #%00000110; sta $ff00
}
.assert "SetBankConfiguration(13)", { SetBankConfiguration(13) }, {
  lda #%00001010; sta $ff00
}
.assert "SetBankConfiguration(14)", { SetBankConfiguration(14) }, {
  lda #%00000001; sta $ff00
}
.assert "SetBankConfiguration(15)", { SetBankConfiguration(15) }, {
  lda #%00000000; sta $ff00
}

/**
 * @brief Set mode configuration register.
 *
 * @param[in] config Values for configuration register
 *
 * @note Config parameter can be filled with Mmu.CPU_*, Mmu.FASTSERIAL*, Mmu.GAME_*, Mmu.EXROM_*, Mmu.KERNAL_*, Mmu.COLS_*
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @note Use c128lib_SetModeConfig in mmu-global.asm
 *
 * @since 1.2.0
 */
.macro SetModeConfig(config) {
    lda #config
    sta Mmu.MODE_CONFIG
}
.assert "SetModeConfig(CPU_8502 | FASTSERIALOUTPUT | GAME_HI | EXROM_HI | KERNAL_64 | COLS_40) sets accumulator to 0f", {
    SetModeConfig(Mmu.CPU_8502 | Mmu.FASTSERIALOUTPUT | Mmu.GAME_HI | Mmu.EXROM_HI | Mmu.KERNAL_64 | Mmu.COLS_40)
}, {
  lda #%11111001; sta $d505
}

/**
 * @brief Configure common RAM amount.
 *
 * RAM Bank 0 is always the visible RAM bank.
 * Valid values are 1,4,8 and 16.
 * For ex. if you choose 4K common ram at top and bottom
 * you'll have 4K up and 4K bottom.
 *
 * @param[in] config Values for common ram configuration
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @note Config parameter can be filled with Mmu.COMMON_RAM_*
 *
 * @note Use c128lib_SetCommonRAM in mmu-global.asm
 *
 * @since 1.2.0
 */
.macro SetCommonRAM(config) {
    lda #config
    sta Mmu.RAM_CONFIG
}
.assert "SetCommonRAM(COMMON_RAM_16K | COMMON_RAM_BOTH) sets accumulator to 0f", { SetCommonRAM(Mmu.COMMON_RAM_16K | Mmu.COMMON_RAM_BOTH) }, {
  lda #%00001111; sta $d506
}
