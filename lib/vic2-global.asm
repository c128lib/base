/**
 * @file vic2-global.asm
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

#import "vic2.asm"

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
 * @since 1.0.0
 */
.macro @c128lib_SetBorderAndBackgroundColor(borderColor, backgroundColor) { SetBorderAndBackgroundColor(borderColor, backgroundColor) }

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
 * @since 1.0.0
 */
.macro @c128lib_SetBorderColor(borderColor) { SetBorderColor(borderColor) }

/**
 * @brief Sets the background color.
 *
 * @details This macro sets the background color of the Vic2. It loads the background color into the accumulator and stores it in Vic2.BG_COL_0.
 *
 * @param[in] backgroundColor The color to set the background to.
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.0.0
 */
.macro @c128lib_SetBackgroundColor(backgroundColor) { SetBackgroundColor(backgroundColor) }

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
.function @c128lib_getTextOffset(xPos, yPos) { .return getTextOffset(xPos, yPos) }

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
 * @since 1.0.0
 */
.macro @c128lib_SetScreenAndCharacterMemoryWithShadow(config) { SetScreenAndCharacterMemoryWithShadow(config) }

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
 * @since 1.0.0
 */
.macro @c128lib_SetScreenMemoryAndBitmapPointer(config) { SetScreenMemoryAndBitmapPointer(config) }

/**
 * @brief Sets X position of given sprite (uses sprite MSB register if necessary)
 *
 * @param[in] spriteNo Number of the sprite to move
 * @param[in] x X position of sprite
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro @c128lib_SetSpriteXPosition(spriteNo, x) { SetSpriteXPosition(spriteNo, x) }

/**
 * @brief Sets X position of given sprite (uses sprite MSB register if necessary)
 * using shadow registers
 *
 * @param[in] spriteNo Number of the sprite to move
 * @param[in] x X position of sprite
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro @c128lib_SetSpriteXPositionWithShadow(spriteNo, x) { SetSpriteXPositionWithShadow(spriteNo, x) }

/**
 * @brief Sets y position of given sprite
 *
 * @param[in] spriteNo Number of the sprite to move
 * @param[in] y Y position of sprite
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro @c128lib_SetSpriteYPosition(spriteNo, y) { SetSpriteYPosition(spriteNo, y) }

/**
 * @brief Sets y position of given sprite using shadow registers
 *
 * @param[in] spriteNo Number of the sprite to move
 * @param[in] y Y position of sprite
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro @c128lib_SetSpriteYPositionWithShadow(spriteNo, y) { SetSpriteYPositionWithShadow(spriteNo, y) }

/**
 * @brief Sets x and y position of given sprite
 *
 * @param[in] spriteNo Number of the sprite to move
 * @param[in] x X position of sprite
 * @param[in] y Y position of sprite
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro @c128lib_SetSpritePosition(spriteNo, x, y) { SetSpritePosition(spriteNo, x, y) }

/**
 * @brief Sets x and y position of given sprite using shadow registers
 *
 * @param[in] spriteNo Number of the sprite to move
 * @param[in] x X position of sprite
 * @param[in] y Y position of sprite
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro @c128lib_SetSpritePositionWithShadow(spriteNo, x, y) { SetSpritePositionWithShadow(spriteNo, x, y) }

/**
 * @brief Define sprite movement
 *
 * @param[in] spriteNo Number of the sprite to set movement
 * @param[in] speed Speed of sprite
 * @param[in] quadrant Determines main direction of sprite (use SPRITE_MAIN_DIR_* labels)
 * @param[in] deltaX move sprite on X each interrupt
 * @param[in] deltaY move sprite on Y each interrupt
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro @c128lib_SpriteMove(spriteNo, speed, quadrant, deltaX, deltaY) { SpriteMove(spriteNo, speed, quadrant, deltaX, deltaY) }

/**
 * @brief Enable one or more sprite, preserving status of other sprites.
 *
 * @param[in] mask Sprite mask
 * (use SPRITE_MASK_* eventually with | to enable more sprite at once)
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro @c128lib_SpriteEnable(mask) { SpriteEnable(mask) }

/**
 * @brief Disable one or more sprite, preserving status of other sprites.
 *
 * @param[in] mask Sprite mask
 * (use SPRITE_MASK_* eventually with | to disable more sprite at once)
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro @c128lib_SpriteDisable(mask) { SpriteDisable(mask) }

/**
 * @brief Enable multicolor setting for one or more sprite, preserving status of other sprites.
 *
 * @param[in] mask Sprite mask
 * (use SPRITE_MASK_* eventually with | to set multicolor on more sprite at once)
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro @c128lib_SpriteEnableMulticolor(mask) { SpriteEnableMulticolor(mask) }

/**
 * @brief Disable multicolor setting for one or more sprite, preserving status of other sprites.
 *
 * @param[in] mask Sprite mask
 * (use SPRITE_MASK_* eventually with | to unset multicolor on more sprite at once)
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro @c128lib_SpriteDisableMulticolor(mask) { SpriteDisableMulticolor(mask) }

/**
 * @brief Disable multicolor setting for one or more sprite.
 *
 * @param[in] spriteNo Number of the sprite to set movement
 * @param[in] color Color to set
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro @c128lib_SpriteColor(spriteNo, color) { SpriteColor(spriteNo, color) }

/**
 * @brief Set sprite multi color 0
 *
 * @param[in] color Color to set
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro @c128lib_SpriteMultiColor0(color) { SpriteMultiColor0(color) }

/**
 * @brief Set sprite multi color 1
 *
 * @param[in] color Color to set
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @since 1.2.0
 */
.macro @c128lib_SpriteMultiColor1(color) { SpriteMultiColor1(color) }
