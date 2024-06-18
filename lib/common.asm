/**
 * @file common.asm
 * @brief Common module
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

.filenamespace c128lib

/**
 * @brief This macro sets up a BASIC program for the Commodore 128.
 *
 * @details The macro sets the program counter to $1c01, which is the start of the BASIC area in C128.
 * It then writes a link address to the end of the BASIC program, a line number, a SYS token,
 * and the address to SYS to in ASCII decimal, followed by a null byte.
 * After that, it writes a zero word to signal the end of the BASIC program and sets the program counter to $1c0e.
 *
 * @param[in] sysAddress The address to which the BASIC program will SYS to start the machine code part.
 *
 * @note Use c128lib_BasicUpstart128 in common-global.asm
 *
 * @since 1.0.0
 */
.macro BasicUpstart128(sysAddress) {
    .pc = $1c01 "C128 Basic"
    .word upstartEnd  // link address
    .word 10   // line num
    .byte $9e  // sys
    .text toIntString(sysAddress)
    .byte 0
upstartEnd:
    .word 0  // empty link signals the end of the program
    .pc = $1c0e "Basic End"
}

.function incArgument(arg) {
  .return CmdArgument(arg.getType(), arg.getValue() + 1)
}

/**
 * @brief This macro provides a far branch if not equal (BNE) operation.
 *
 * @details The 6502 processor's BNE instruction can only jump a limited distance (from -128 to +127 bytes relative to the instruction following BNE).
 * This macro extends that range by using a combination of BNE, BEQ, and JMP instructions.
 *
 * If the label is within the range of a normal BNE, it uses that. If not, it uses a BEQ to skip over a JMP instruction.
 * This works because BNE jumps if the zero flag is clear, and BEQ jumps if the zero flag is set - they are opposites.
 * So if the BNE would not have jumped, the BEQ does, and the JMP is skipped.
 * If the BNE would have jumped, the BEQ does not, and the JMP is executed, jumping to the label.
 *
 * @param[in] label The label to jump to if the zero flag is not set.
 *
 * @note Use c128lib_Fbne in common-global.asm
 *
 * @since 1.0.0
 */
.macro Fbne(label) {
  here: // we have to add 2 to "here", because relative jump is counted right after bne xx, and this instruction takes 2 bytes
    .if (here > label) {
      // jump back
      .if (here + 2 - label <= 128) {
        bne label
      } else {
        beq skip
        jmp label
      skip:
      }
    } else {
      // jump forward
      .if (label - here - 2 <= 127) {
        bne label
      } else {
        beq skip
        jmp label
      skip:
      }
    }
}

/**
 * @brief This macro provides a far branch if minus (BMI) operation.
 *
 * The 6502 processor's BMI instruction can only jump a limited distance (from -128 to +127 bytes relative to the instruction following BMI).
 * This macro extends that range by using a combination of BMI, BPL, BEQ, and JMP instructions.
 *
 * If the label is within the range of a normal BMI, it uses that. If not, it uses a BPL and BEQ to skip over a JMP instruction.
 * This works because BMI jumps if the negative flag is set, and BPL jumps if the negative flag is clear - they are opposites.
 * So if the BMI would not have jumped, the BPL and BEQ do, and the JMP is skipped.
 * If the BMI would have jumped, the BPL and BEQ do not, and the JMP is executed, jumping to the label.
 *
 * @param[in] label The label to jump to if the negative flag is set.
 *
 * @note Use c128lib_Fbmi in common-global.asm
 *
 * @since 1.0.0
 */
 .macro Fbmi(label) {
  here: // we have to add 2 to "here", because relative jump is counted right after bne xx, and this instruction takes 2 bytes
    .if (here > label) {
      // jump back
      .if (here + 2 - label <= 128) {
        bmi label
      } else {
        bpl skip
        beq skip
        jmp label
      skip:
      }
    } else {
      // jump forward
      .if (label - here - 2 <= 127) {
        bmi label
      } else {
        bpl skip
        beq skip
        jmp label
      skip:
      }
    }
}

/**
 * @brief Generates the negative value for the argument
 *
 * @param[in] value Value to negated
 *
 * @since 1.2.0
*/
.function neg(value) {
  .return value ^ $FF
}
.assert "neg($00) gives $FF", neg($00), $FF
.assert "neg($FF) gives $00", neg($FF), $00
.assert "neg(%10101010) gives %01010101", neg(%10101010), %01010101
