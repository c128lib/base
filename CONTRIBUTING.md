# Welcome to contributing guide
TBD
## Guide to contributing code
TBD

## Guide to contributing documentation
### File header
Every file should have an header like this:

<pre>
/**
 * @file math.asm
 * @brief Math module
 * @details Simple macros for math operations.
 *
 * @author Raffaele Intorcia <a href="https://github.com/intoinside">@intoinside</a> raffaele.intorcia@gmail.com
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
</pre>

* a @brief keyword with a short description (typically one or two line)
* a @details keyword (optional) with a longer description, with some hint about code used and comparison with similar code
* one or more @author keyword with name, Github profile link and email
* a @date keyword indicating year of creating file

### Subroutine and macro header
Every subroutine and macro should have an header like this:

<pre>
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
 * @note Usage: copyWithRelocation($C000, $C100, 256)  // Copies 256 bytes from memory location $C000 to $C100 with relocation
 * @note Use c128lib_copyWithRelocation in mem-global.asm
 *
 * @since 0.6.0
 */
</pre>

* a @brief keyword with a short description (typically one or two line)
* a @details keyword (optional) with a longer description, with some hint about code used and comparison with similar code
* a @param keyword for every parameter, with [in], [out] or [in,out] attribute to specify if parameter is an input
or output value
* a @remark keyword for indicating if registers or flags are affrected
* a @note keyword for "non-global" macros to suggest to use global macro definition
* a @since keyword to specify from which version this code is available

#### Other keywords under evaluation
* a @example keyword (optional) for pointing to other source code where method is used
* a @note keyword (optional) for a simple usage code