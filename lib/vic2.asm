/**
 * @file vic2.asm
 * @brief Vic2 module
 * @details Simple macros for Vic2.
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

#import "labels/lib/vic2.asm"

.filenamespace c128lib

/**
 * @brief Sets the border and background color.
 *
 * @details This macro sets the border and background color of the Vic2. If the border color and background color are not the same,
 * it loads the background color into the accumulator and stores it in Vic2.BG_COL_0.
 *
 * @param[in] borderColor The color to set the border to.
 * @param[in] backgroundColor The color to set the background to.
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @note Use c128lib_SetBorderAndBackgroundColor in vic2-global.asm
 *
 * @since 0.1.0
 */
.macro SetBorderAndBackgroundColor(borderColor, backgroundColor) {
  .errorif (borderColor < 0 || borderColor > 15), "borderColor must be from 0 to 15"
  .errorif (backgroundColor < 0 || backgroundColor > 15), "backgroundColor must be from 0 to 15"
  lda #borderColor
  sta Vic2.BORDER_COL
  .if (borderColor != backgroundColor) {
    lda #backgroundColor
  }
  sta Vic2.BG_COL_0
}
.asserterror "SetBorderAndBackgroundColor(-1, 1)", { SetBorderAndBackgroundColor(-1, 1) }
.asserterror "SetBorderAndBackgroundColor(1, -1)", { SetBorderAndBackgroundColor(1, -1) }
.asserterror "SetBorderAndBackgroundColor(16, 1)", { SetBorderAndBackgroundColor(16, 1) }
.asserterror "SetBorderAndBackgroundColor(1, 16)", { SetBorderAndBackgroundColor(1, 16) }
.assert "SetBorderAndBackgroundColor(borderColor, backgroundColor) different color",  { SetBorderAndBackgroundColor(1, 2) }, {
  lda #1; sta $D020; lda #2; sta $D021
}
.assert "SetBorderAndBackgroundColor(borderColor, backgroundColor) same color",  { SetBorderAndBackgroundColor(3, 3) }, {
  lda #3; sta $D020; sta $D021
}

/**
 * @brief Sets the border color.
 *
 * @details This macro sets the border color of the Vic2. It loads the border color into
 * the accumulator and stores it in Vic2.BORDER_COL.
 *
 * @param[in] borderColor The color to set the border to.
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @note Use c128lib_SetBorderColor in vic2-global.asm
 *
 * @since 0.1.0
 */
.macro SetBorderColor(borderColor) {
  .errorif (borderColor < 0 || borderColor > 15), "borderColor must be from 0 to 15"
  lda #borderColor
  sta Vic2.BORDER_COL
}
.asserterror "SetBorderColor(-1)", { SetBorderColor(-1) }
.asserterror "SetBorderColor(16)", { SetBorderColor(16) }
.assert "SetBorderColor(borderColor)",  { SetBorderColor(1) }, {
  lda #1; sta $D020
}

/**
 * @brief Sets the background color.
 *
 * @details This macro sets the background color of the Vic2. It loads the background color into the accumulator and stores it in Vic2.BG_COL_0.
 *
 * @param[in] backgroundColor The color to set the background to.
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @note Use c128lib_SetBackgroundColor in vic2-global.asm
 *
 * @since 0.1.0
 */
.macro SetBackgroundColor(backgroundColor) {
  .errorif (backgroundColor < 0 || backgroundColor > 15), "backgroundColor must be from 0 to 15"
  lda #backgroundColor
  sta Vic2.BG_COL_0
}
.asserterror "SetBackgroundColor(-1)", { SetBackgroundColor(-1) }
.asserterror "SetBackgroundColor(16)", { SetBackgroundColor(16) }
.assert "SetBackgroundColor(backgroundColor)",  { SetBackgroundColor(1) }, {
  lda #1; sta $D021
}

/**
 * @brief Set screen memory and charset memory position
 *
 * @details Set screen memory and charset memory position by
 * using shadow register.
 *
 * Character memory selection
 *
 * - Vic2.CHAR_MEM_0000 Character memory on $0000
 * - Vic2.CHAR_MEM_0800 Character memory on $0800
 * - Vic2.CHAR_MEM_1000 Character memory on $1000
 * - Vic2.CHAR_MEM_1800 Character memory on $1800
 * - Vic2.CHAR_MEM_2000 Character memory on $2000
 * - Vic2.CHAR_MEM_2800 Character memory on $2800
 * - Vic2.CHAR_MEM_3000 Character memory on $3000
 * - Vic2.CHAR_MEM_3800 Character memory on $3800
 *
 * If omitted, Vic2.CHAR_MEM_0000 will be used.
 *
 * Character memory offset must be added to current bank selected.
 * For ex. if Vic bank 1 ($4000) is selected, CHAR_MEM_0800 will point to $4000 + $0800
 *
 * Screen memory selection
 *
 * - Vic2.SCREEN_MEM_0000 Screen memory on $0000
 * - Vic2.SCREEN_MEM_0400 Screen memory on $0400
 * - Vic2.SCREEN_MEM_0800 Screen memory on $0800
 * - Vic2.SCREEN_MEM_0C00 Screen memory on $0c00
 * - Vic2.SCREEN_MEM_1000 Screen memory on $1000
 * - Vic2.SCREEN_MEM_1400 Screen memory on $1400
 * - Vic2.SCREEN_MEM_1800 Screen memory on $1800
 * - Vic2.SCREEN_MEM_1C00 Screen memory on $1c00
 * - Vic2.SCREEN_MEM_2000 Screen memory on $2000
 * - Vic2.SCREEN_MEM_2400 Screen memory on $2400
 * - Vic2.SCREEN_MEM_2800 Screen memory on $2800
 * - Vic2.SCREEN_MEM_2C00 Screen memory on $2c00
 * - Vic2.SCREEN_MEM_3000 Screen memory on $3000
 * - Vic2.SCREEN_MEM_3400 Screen memory on $3400
 * - Vic2.SCREEN_MEM_3800 Screen memory on $3800
 * - Vic2.SCREEN_MEM_3C00 Screen memory on $3c00
 *
 * If omitted, Vic2.SCREEN_MEM_0000 will be used.
 *
 * Screen memory offset must be added to current bank selected.
 * For ex. if Vic bank 1 ($4000) is selected, SCREEN_MEM_0C00 will point to $4000 + $0c00
 *
 * @param[in] config Screen memory and/or char memory configuration.
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @note Use c128lib_SetScreenAndCharacterMemory in vic2-global.asm
 *
 * @since 0.1.0
 */
.macro SetScreenAndCharacterMemory(config) {
    lda #config
    sta Vic2.VIC_SCREEN_CHAR_SHADOW
}
.assert "SetScreenAndCharacterMemory(Vic2.CHAR_MEM_3800 | Vic2.SCREEN_MEM_3C00) sets char to $3800 and Screen to $3c00 in shadow MEMORY_CONTROL",  { SetScreenAndCharacterMemory(Vic2.CHAR_MEM_3800 | Vic2.SCREEN_MEM_3C00) }, {
  lda #%11111110; sta $0A2C
}

/**
 * @brief Set screen memory and bitmap memory pointer
 *
 * @details Set screen memory and bitmap memory pointer by
 * using shadow register.
 *
 * @param[in] config Screen memory and/or bitmap memory configuration.
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 * @remark Labels Vic2.CHAR* and Vic2.SCREEN_MEM* can be used to compose.
 *
 * @note Use c128lib_SetScreenMemoryAndBitmapPointer in vic2-global.asm
 *
 * @since 0.1.0
 */
.macro SetScreenMemoryAndBitmapPointer(config) {
    lda #config
    sta Vic2.VIC_BITMAP_VIDEO_SHADOW
}
.assert "SetScreenMemoryAndBitmapPointer(Vic2.BITMAP_MEM_2000 | Vic2.SCREEN_MEM_3C00) sets bitmap to $2000 and Screen to $3c00 in shadow MEMORY_CONTROL",  { SetScreenMemoryAndBitmapPointer(Vic2.BITMAP_MEM_2000 | Vic2.SCREEN_MEM_3C00) }, {
  lda #%11111000; sta $0A2D
}
