/**
 * @file cia.asm
 * @brief Cia module
 * @details Simple macros for Cia.
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

#import "labels/lib/cia.asm"

.filenamespace c128lib

/**
 * @brief Checks if the fire button is pressed on joystick port 1.
 *
 * @details This macro checks if the fire button is pressed on joystick port 1.
 * It loads the data from CIA1's data port B into the accumulator and then performs a bitwise AND operation with the JOY_FIRE constant.
 *
 * @returns If .A is non zero, fire is pressed
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @note Use c128lib_GetFirePressedPort1 in cia-global.asm
 *
 * @since 1.0.0
 */
.macro GetFirePressedPort1() {
  lda Cia.CIA1_DATA_PORT_B
  and #Cia.JOY_FIRE
}

/**
 * @brief Checks if the fire button is pressed on joystick port 2.
 *
 * @details This macro checks if the fire button is pressed on joystick port 2.
 * It loads the data from CIA1's data port A into the accumulator and then performs a bitwise AND operation with the JOY_FIRE constant.
 *
 * @returns If .A is non zero, fire is pressed
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @note Use c128lib_GetFirePressedPort2 in cia-global.asm
 *
 * @since 1.0.0
 */
.macro GetFirePressedPort2() {
  lda Cia.CIA1_DATA_PORT_A
  and #Cia.JOY_FIRE
}

/**
 * @brief Disables the interrupts from both CIA chips.
 *
 * This macro disables the interrupts from both CIA chips on a Commodore 64. It loads the accumulator with the value $7F, which disables all interrupt sources,
 * and then stores this value in the IRQ control registers of both CIA chips. It then reads the IRQ control registers to confirm the changes.
 *
 * @remark Register .A will be modified.
 * @remark Flags N and Z will be affected.
 *
 * @note Use c128lib_GetFirePressedPort2 in cia-global.asm
 *
 * @since 1.1.0
 */
.macro DisableCIAInterrupts() {
  lda #$7f
  sta Cia.CIA1_IRQ_CONTROL
  sta Cia.CIA2_IRQ_CONTROL
  lda Cia.CIA1_IRQ_CONTROL
  lda Cia.CIA2_IRQ_CONTROL
}

/**
 * @brief Configures Vic bank (16K) which is directly addressable by VIC2 chip.
 *
 * @param[in] bank Bank to set
 *
 * @remark Register .A will be modified.
 * @remark Flags N, Z and C will be affected.
 *
 * @note Bank parameter can be filled with Cia.BANK_0, Cia.BANK_1, Cia.BANK_2, Cia.BANK_3
 * @note BANK_0 $0000-$3FFF, BANK_1 $4000-$7FFF, BANK_2 $8000-$BFFF, BANK_3 $C000-$FFFF
 *
 * @note Use c128lib_SetVicBank in cia-global.asm
 *
 * @since 1.2.0
 */
.macro SetVicBank(bank) {
  lda Cia.CIA2_DATA_PORT_A
  and #%11111100
  ora #[bank & %00000011]
  sta Cia.CIA2_DATA_PORT_A
}
.assert "SetVicBank(BANK_0) sets 11", { SetVicBank(Cia.BANK_0) }, {
  lda $DD00
  and #%11111100
  ora #%00000011
  sta $DD00
}
.assert "SetVicBank(BANK_3) sets 00", { SetVicBank(Cia.BANK_3) }, {
  lda $DD00
  and #%11111100
  ora #%00000000
  sta $DD00
}
