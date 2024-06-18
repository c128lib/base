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

#import "common.asm"
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
 * @since 1.0.0
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
 * @since 1.0.0
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
 * @since 1.0.0
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
 * @brief Calculates memory offset of text cell specified by given coordinates
 * on 40 cols screen
 *
 * @param[in] xPos X coord on Vdc screen
 * @param[in] yPos Y coord on Vdc screen
 * @return Memory offset of Vic2 specified coordinate
 *
 * @since 1.1.0
 */
.function getTextOffset(xPos, yPos) {
  .return xPos + Vic2.TEXT_SCREEN_WIDTH * yPos
}
.assert "getTextOffset(0,0) gives 0", getTextOffset(0, 0), 0
.assert "getTextOffset(39,0) gives 39", getTextOffset(39, 0), 39
.assert "getTextOffset(0,1) gives 40", getTextOffset(0, 1), 40
.assert "getTextOffset(19,12) gives 499", getTextOffset(19, 12), 499
.assert "getTextOffset(39,24) gives 999", getTextOffset(39, 24), 999

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
 * @note Use c128lib_SetScreenAndCharacterMemoryWithShadow in vic2-global.asm
 *
 * @since 1.0.0
 */
.macro SetScreenAndCharacterMemoryWithShadow(config) {
    lda #config
    sta Vic2.VIC_SCREEN_CHAR_SHADOW
}
.assert "SetScreenAndCharacterMemoryWithShadow(Vic2.CHAR_MEM_3800 | Vic2.SCREEN_MEM_3C00) sets char to $3800 and Screen to $3c00 in shadow MEMORY_CONTROL",  { SetScreenAndCharacterMemoryWithShadow(Vic2.CHAR_MEM_3800 | Vic2.SCREEN_MEM_3C00) }, {
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
 * @since 1.0.0
 */
.macro SetScreenMemoryAndBitmapPointer(config) {
    lda #config
    sta Vic2.VIC_BITMAP_VIDEO_SHADOW
}
.assert "SetScreenMemoryAndBitmapPointer(Vic2.BITMAP_MEM_2000 | Vic2.SCREEN_MEM_3C00) sets bitmap to $2000 and Screen to $3c00 in shadow MEMORY_CONTROL",  { SetScreenMemoryAndBitmapPointer(Vic2.BITMAP_MEM_2000 | Vic2.SCREEN_MEM_3C00) }, {
  lda #%11111000; sta $0A2D
}

/**
 * @brief Calculates sprite X position register address
 *
 * @param[in] spriteNo Number of the sprite x-coordinate to get
 *
 * @since 1.2.0
 */
.function spriteXReg(spriteNo) {
  .return Vic2.VIC2 + spriteNo * 2
}
.assert "Reg address for sprite0 X pos", spriteXReg(0), $d000
.assert "Reg address for sprite7 X pos", spriteXReg(7), $d00e

/**
 * @brief Calculates sprite X position shadow register address
 *
 * @param[in] spriteNo Number of the sprite x-coordinate to get
 *
 * @since 1.2.0
 */
.function spriteShadowXReg(spriteNo) {
  .return Vic2.SHADOW_VIC2 + spriteNo * 2
}
.assert "Shadow reg address for sprite0 X pos", spriteShadowXReg(0), $11d6
.assert "Shadow reg address for sprite7 X pos", spriteShadowXReg(7), $11e4

/**
 * @brief Calculates sprite Y position register address
 *
 * @param[in] spriteNo Number of the sprite x-coordinate to get
 *
 * @since 1.2.0
 */
.function spriteYReg(spriteNo) {
  .return spriteXReg(spriteNo) + 1
}
.assert "Reg address for sprite0 Y pos", spriteYReg(0), $d001
.assert "Reg address for sprite7 Y pos", spriteYReg(7), $d00f

/**
 * @brief Calculates sprite Y position shadow register address
 *
 * @param[in] spriteNo Number of the sprite x-coordinate to get
 *
 * @since 1.2.0
 */
.function spriteShadowYReg(spriteNo) {
  .return spriteShadowXReg(spriteNo) + 1
}
.assert "Shadow reg address for sprite0 Y pos", spriteShadowYReg(0), $11d7
.assert "Shadow reg address for sprite7 Y pos", spriteShadowYReg(7), $11e5

/**
 * @brief Generates a mask for a specific sprite
 *
 * @param[in] spriteNo Number of the sprite for mask generation
 *
 * @since 1.2.0
 */
.function spriteMask(spriteNo) {
  .return pow(2, spriteNo)
}
.assert "Bit mask for sprite 0", spriteMask(0), %00000001
.assert "Bit mask for sprite 7", spriteMask(7), %10000000

/**
 * @brief Calculate sprite color register address
 *
 * @param[in] spriteNo Number of the sprite color address
 *
 * @since 1.2.0
 */
.function spriteColorReg(spriteNo) {
  .return Vic2.SPRITE_0_COLOR + spriteNo
}
.assert "Reg address for sprite0 color", spriteColorReg(0), $d027
.assert "Reg address for sprite7 color", spriteColorReg(7), $d02e

/**
 * @brief Sets X position of given sprite (uses sprite MSB register if necessary)
 *
 * @param[in] spriteNo Number of the sprite to move
 * @param[in] x X position of sprite
 *
 * @note Use c128lib_SetSpriteXPosition in vic2-global.asm
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro SetSpriteXPosition(spriteNo, x) {
  .errorif (spriteNo < 0 || spriteNo > 7), "spriteNo must be from 0 to 7"
  .if (x > 255) {
    lda #<x
    sta spriteXReg(spriteNo)
    lda Vic2.SPRITE_MSB_X
    ora #spriteMask(spriteNo)
    sta Vic2.SPRITE_MSB_X
  } else {
    lda #x
    sta spriteXReg(spriteNo)
  }
}
.asserterror "SetSpriteXPosition(-1, 10)", { SetSpriteXPosition(-1, 10) }
.asserterror "SetSpriteXPosition(8, 10)", { SetSpriteXPosition(8, 10) }
.assert "SetSpriteXPosition stores X in SPRITE_X reg", { SetSpriteXPosition(3, 5) }, {
  lda #$05
  sta $d006
}
.assert "SetSpriteXPosition stores X in SPRITE_X and MSB regs", { SetSpriteXPosition(3, 257) },  {
  lda #$01
  sta $d006
  lda $d010
  ora #%00001000
  sta $d010
}

/**
 * @brief Sets X position of given sprite (uses sprite MSB register if necessary)
 * using shadow registers
 *
 * @param[in] spriteNo Number of the sprite to move
 * @param[in] x X position of sprite
 *
 * @note Use c128lib_SetSpriteXPositionWithShadow in vic2-global.asm
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro SetSpriteXPositionWithShadow(spriteNo, x) {
  .errorif (spriteNo < 0 || spriteNo > 7), "spriteNo must be from 0 to 7"
  .if (x > 255) {
    lda #<x
    sta spriteShadowXReg(spriteNo)
    lda Vic2.SHADOW_SPRITE_MSB_X
    ora #spriteMask(spriteNo)
    sta Vic2.SHADOW_SPRITE_MSB_X
  } else {
    lda #x
    sta spriteShadowXReg(spriteNo)
  }
}
.asserterror "SetSpriteXPositionWithShadow(-1, 10)", { SetSpriteXPositionWithShadow(-1, 10) }
.asserterror "SetSpriteXPositionWithShadow(8, 10)", { SetSpriteXPositionWithShadow(8, 10) }
.assert "SetSpriteXPositionWithShadow stores X in SPRITE_X reg", { SetSpriteXPositionWithShadow(3, 5) }, {
  lda #$05
  sta $11dc
}
.assert "SetSpriteXPositionWithShadow stores X in SPRITE_X and MSB regs", { SetSpriteXPositionWithShadow(3, 257) },  {
  lda #$01
  sta $11dc
  lda $11e6
  ora #%00001000
  sta $11e6
}

/**
 * @brief Sets y position of given sprite
 *
 * @param[in] spriteNo Number of the sprite to move
 * @param[in] y Y position of sprite
 *
 * @note Use c128lib_SetSpriteYPosition in vic2-global.asm
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro SetSpriteYPosition(spriteNo, y) {
  .errorif (spriteNo < 0 || spriteNo > 7), "spriteNo must be from 0 to 7"
  lda #y
  sta spriteYReg(spriteNo)
}
.asserterror "SetSpriteYPosition(-1, 10)", { SetSpriteYPosition(-1, 10) }
.asserterror "SetSpriteYPosition(8, 10)", { SetSpriteYPosition(8, 10) }
.assert "SetSpriteYPosition stores Y in SPRITE_Y reg", { SetSpriteYPosition(3, 5) },  {
  lda #$05
  sta $D007
}

/**
 * @brief Sets y position of given sprite using shadow registers
 *
 * @param[in] spriteNo Number of the sprite to move
 * @param[in] y Y position of sprite
 *
 * @note Use c128lib_SetSpriteYPositionWithShadow in vic2-global.asm
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro SetSpriteYPositionWithShadow(spriteNo, y) {
  .errorif (spriteNo < 0 || spriteNo > 7), "spriteNo must be from 0 to 7"
  lda #y
  sta spriteShadowYReg(spriteNo)
}
.asserterror "SetSpriteYPositionWithShadow(-1, 10)", { SetSpriteYPositionWithShadow(-1, 10) }
.asserterror "SetSpriteYPositionWithShadow(8, 10)", { SetSpriteYPositionWithShadow(8, 10) }
.assert "SetSpriteYPositionWithShadow stores Y in SPRITE_Y reg", { SetSpriteYPositionWithShadow(3, 5) },  {
  lda #$05
  sta $11dd
}

/**
 * @brief Sets x and y position of given sprite
 *
 * @param[in] spriteNo Number of the sprite to move
 * @param[in] x X position of sprite
 * @param[in] y Y position of sprite
 *
 * @note Use c128lib_SetSpritePosition in vic2-global.asm
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro SetSpritePosition(spriteNo, x, y) {
  .errorif (spriteNo < 0 || spriteNo > 7), "spriteNo must be from 0 to 7"
  .if (x <= 255) {
    lda #x
    sta spriteXReg(spriteNo)
    .if (x != y) {
      lda #y
    }
    sta spriteYReg(spriteNo)
  } else {
    lda #<x
    sta spriteXReg(spriteNo)
    lda Vic2.SPRITE_MSB_X
    ora #spriteMask(spriteNo)
    sta Vic2.SPRITE_MSB_X
    lda #y
    sta spriteYReg(spriteNo)
  }
}
.asserterror "SetSpritePosition(-1, 10, 10)", { SetSpritePosition(-1, 10, 10) }
.asserterror "SetSpritePosition(8, 10, 10)", { SetSpritePosition(8, 10, 10) }
.assert "SetSpritePosition stores position in SPRITE_* reg (x and y equals)", { SetSpritePosition(3, 5, 5) }, {
  lda #$05
  sta $d006
  sta $d007
}
.assert "SetSpritePosition stores position in SPRITE_* reg (x and y not equals)", { SetSpritePosition(3, 5, 15) }, {
  lda #$05
  sta $d006
  lda #15
  sta $d007
}
.assert "SetSpritePosition stores position in SPRITE_* and MSB regs", { SetSpritePosition(3, 300, 15) },  {
  lda #44
  sta $d006
  lda $d010
  ora #%00001000
  sta $d010
  lda #15
  sta $d007
}

/**
 * @brief Sets x and y position of given sprite using shadow registers
 *
 * @param[in] spriteNo Number of the sprite to move
 * @param[in] x X position of sprite
 * @param[in] y Y position of sprite
 *
 * @note Use c128lib_SetSpritePositionWithShadow in vic2-global.asm
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro SetSpritePositionWithShadow(spriteNo, x, y) {
  .errorif (spriteNo < 0 || spriteNo > 7), "spriteNo must be from 0 to 7"
  .if (x <= 255) {
    lda #x
    sta spriteShadowXReg(spriteNo)
    .if (x != y) {
      lda #y
    }
    sta spriteShadowYReg(spriteNo)
  } else {
    lda #<x
    sta spriteShadowXReg(spriteNo)
    lda Vic2.SHADOW_SPRITE_MSB_X
    ora #spriteMask(spriteNo)
    sta Vic2.SHADOW_SPRITE_MSB_X
    lda #y
    sta spriteShadowYReg(spriteNo)
  }
}
.asserterror "SetSpritePositionWithShadow(-1, 10, 10)", { SetSpritePositionWithShadow(-1, 10, 10) }
.asserterror "SetSpritePositionWithShadow(8, 10, 10)", { SetSpritePositionWithShadow(8, 10, 10) }
.assert "SetSpritePositionWithShadow stores position in SPRITE_* reg (x and y equals)", { SetSpritePositionWithShadow(3, 5, 5) }, {
  lda #$05
  sta $11dc
  sta $11dd
}
.assert "SetSpritePositionWithShadow stores position in SPRITE_* reg (x and y not equals)", { SetSpritePositionWithShadow(3, 5, 15) }, {
  lda #$05
  sta $11dc
  lda #15
  sta $11dd
}
.assert "SetSpritePositionWithShadow stores position in SPRITE_* and MSB regs", { SetSpritePositionWithShadow(3, 300, 15) },  {
  lda #44
  sta $11dc
  lda $11e6
  ora #%00001000
  sta $11e6
  lda #15
  sta $11dd
}

/**
 * @brief Get starting address for sprite movement to use
 * with @sa SpriteMove
 *
 * @param[in] spriteNo Number of the sprite to move
 *
 * @since 1.2.0
 */
.function getSpriteMovementStartingAddress(spriteNo) {
  .return Vic2.SPRITE_MOTION_0 + (Vic2.SPRITE_MOTION_OFFSET * spriteNo);
}

/**
 * @brief Define sprite movement
 *
 * @param[in] spriteNo Number of the sprite to set movement
 * @param[in] speed Speed of sprite
 * @param[in] quadrant Determines main direction of sprite (use SPRITE_MAIN_DIR_* labels)
 * @param[in] deltaX move sprite on X each interrupt
 * @param[in] deltaY move sprite on Y each interrupt
 *
 * @note Use c128lib_SpriteMove in vic2-global.asm
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro SpriteMove(spriteNo, speed, quadrant, deltaX, deltaY) {
  .errorif (spriteNo < 0 || spriteNo > 7), "spriteNo must be from 0 to 7"
  .errorif (speed < 0 || speed > 255), "speed must be from 0 to 255"
  .errorif (quadrant < Vic2.SPRITE_MAIN_DIR_UP || quadrant > Vic2.SPRITE_MAIN_DIR_LEFT), "quadrant must be from SPRITE_MAIN_DIR_UP to SPRITE_MAIN_DIR_LEFT"
    lda #speed
    sta getSpriteMovementStartingAddress(spriteNo)
    lda #quadrant
    sta getSpriteMovementStartingAddress(spriteNo) + 2
    lda #(<deltaX)
    sta getSpriteMovementStartingAddress(spriteNo) + 3
    lda #(>deltaX)
    sta getSpriteMovementStartingAddress(spriteNo) + 4
    lda #(<deltaY)
    sta getSpriteMovementStartingAddress(spriteNo) + 5
    lda #(>deltaY)
    sta getSpriteMovementStartingAddress(spriteNo) + 6
    lda #0
    sta getSpriteMovementStartingAddress(spriteNo) + 1
    sta getSpriteMovementStartingAddress(spriteNo) + 7
    sta getSpriteMovementStartingAddress(spriteNo) + 8
    sta getSpriteMovementStartingAddress(spriteNo) + 9
    sta getSpriteMovementStartingAddress(spriteNo) + 10
}
.asserterror "SpriteMove(-1, 1, SPRITE_MAIN_DIR_UP, $1234, $beef)", { SpriteMove(-1, 1, Vic2.SPRITE_MAIN_DIR_UP, $1234, $beef) }
.asserterror "SpriteMove(8, 1, SPRITE_MAIN_DIR_UP, $1234, $beef)", { SpriteMove(8, 1, Vic2.SPRITE_MAIN_DIR_UP, $1234, $beef) }
.asserterror "SpriteMove(0, -1, SPRITE_MAIN_DIR_UP, $1234, $beef)", { SpriteMove(0, -1, Vic2.SPRITE_MAIN_DIR_UP, $1234, $beef) }
.asserterror "SpriteMove(0, 256, SPRITE_MAIN_DIR_UP, $1234, $beef)", { SpriteMove(0, 256, Vic2.SPRITE_MAIN_DIR_UP, $1234, $beef) }
.asserterror "SpriteMove(0, 0, -1, $1234, $beef)", { SpriteMove(0, 0, -1, $1234, $beef) }
.asserterror "SpriteMove(0, 0, 4, $1234, $beef)", { SpriteMove(0, 0, 4, $1234, $beef) }
.assert "SpriteMove(0, 1, SPRITE_MAIN_DIR_UP, $1234, $beef)", { SpriteMove(0, 1, Vic2.SPRITE_MAIN_DIR_UP, $1234, $beef) }, {
  lda #1; sta $117E; lda #0; sta $1180; lda #$34; sta $1181; lda #$12; sta $1182; lda #$ef; sta $1183; lda #$be; sta $1184;
  lda #0; sta $117F; sta $1185; sta $1186; sta $1187; sta $1188
}

/**
 * @brief Enable one or more sprite, preserving status of other sprites.
 *
 * @param[in] mask Sprite mask
 * (use SPRITE_MASK_* eventually with | to enable more sprite at once)
 *
 * @note Use c128lib_SpriteEnable in vic2-global.asm
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro SpriteEnable(mask) {
    lda Vic2.SPRITE_ENABLE
    ora #mask
    sta Vic2.SPRITE_ENABLE
}
.assert "SpriteEnable(Vic2.SPRITE_MASK_0 | Vic2.SPRITE_MASK_3 | Vic2.SPRITE_MASK_7)", { SpriteEnable(Vic2.SPRITE_MASK_0 | Vic2.SPRITE_MASK_3 | Vic2.SPRITE_MASK_7) }, {
  lda $D015; ora #%10001001; sta $D015
}

/**
 * @brief Disable one or more sprite, preserving status of other sprites.
 *
 * @param[in] mask Sprite mask
 * (use SPRITE_MASK_* eventually with | to disable more sprite at once)
 *
 * @note Use c128lib_SpriteDisable in vic2-global.asm
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro SpriteDisable(mask) {
    lda Vic2.SPRITE_ENABLE
    and #neg(mask)
    sta Vic2.SPRITE_ENABLE
}
.assert "SpriteDisable(Vic2.SPRITE_MASK_0 | Vic2.SPRITE_MASK_3 | Vic2.SPRITE_MASK_7)", { SpriteDisable(Vic2.SPRITE_MASK_0 | Vic2.SPRITE_MASK_3 | Vic2.SPRITE_MASK_7) }, {
  lda $D015; and #%01110110; sta $D015
}

/**
 * @brief Enable multicolor setting for one or more sprite, preserving status of other sprites.
 *
 * @param[in] mask Sprite mask
 * (use SPRITE_MASK_* eventually with | to set multicolor on more sprite at once)
 *
 * @note Use c128lib_SpriteEnableMulticolor in vic2-global.asm
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro SpriteEnableMulticolor(mask) {
    lda Vic2.SPRITE_COL_MODE
    ora #mask
    sta Vic2.SPRITE_COL_MODE
}
.assert "SpriteEnableMulticolor(Vic2.SPRITE_MASK_0 | Vic2.SPRITE_MASK_3 | Vic2.SPRITE_MASK_7)", { SpriteEnableMulticolor(Vic2.SPRITE_MASK_0 | Vic2.SPRITE_MASK_3 | Vic2.SPRITE_MASK_7) }, {
  lda $D01C; ora #%10001001; sta $D01C
}

/**
 * @brief Disable multicolor setting for one or more sprite, preserving status of other sprites.
 *
 * @param[in] mask Sprite mask
 * (use SPRITE_MASK_* eventually with | to unset multicolor on more sprite at once)
 *
 * @note Use c128lib_SpriteDisableMulticolor in vic2-global.asm
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro SpriteDisableMulticolor(mask) {
    lda Vic2.SPRITE_COL_MODE
    and #neg(mask)
    sta Vic2.SPRITE_COL_MODE
}
.assert "SpriteDisableMulticolor(Vic2.SPRITE_MASK_0 | Vic2.SPRITE_MASK_3 | Vic2.SPRITE_MASK_7)", { SpriteDisableMulticolor(Vic2.SPRITE_MASK_0 | Vic2.SPRITE_MASK_3 | Vic2.SPRITE_MASK_7) }, {
  lda $D01C; and #%01110110; sta $D01C
}

/**
 * @brief Disable multicolor setting for one or more sprite.
 *
 * @param[in] spriteNo Number of the sprite to set movement
 * @param[in] color Color to set
 *
 * @note Use c128lib_SpriteColor in vic2-global.asm
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro SpriteColor(spriteNo, color) {
    .errorif (spriteNo < 0 || spriteNo > 7), "spriteNo must be from 0 to 7"
    lda #color
    sta Vic2.SPRITE_0_COLOR + spriteNo
}
.asserterror "SpriteColor(-1, 10)", { SpriteColor(-1, 10) }
.asserterror "SpriteColor(8, 10)", { SpriteColor(8, 10) }
.assert "SpriteColor(2, WHITE)", { SpriteColor(2, WHITE) }, {
  lda #1; sta $D029
}

/**
 * @brief Set sprite multi color 0
 *
 * @param[in] color Color to set
 *
 * @note Use c128lib_SpriteMultiColor0 in vic2-global.asm
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro SpriteMultiColor0(color) {
    lda #color
    sta Vic2.SPRITE_COL_0
}
.assert "SpriteMultiColor0(WHITE)", { SpriteMultiColor0(WHITE) }, {
  lda #1; sta $D025
}

/**
 * @brief Set sprite multi color 1
 *
 * @param[in] color Color to set
 *
 * @note Use c128lib_SpriteMultiColor1 in vic2-global.asm
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro SpriteMultiColor1(color) {
    lda #color
    sta Vic2.SPRITE_COL_1
}
.assert "SpriteMultiColor1(WHITE)", { SpriteMultiColor1(WHITE) }, {
  lda #1; sta $D026
}
