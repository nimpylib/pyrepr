## .. warning::
##   currently any symbol besides `hex`_ , `oct`_, `bin`_, and their toLowerXxx is unstable
## 
## For toLowerXxx such as `toLowerHex`_, they are just like Nim's `strutils.toHex`:
##   - no prefix and sign char will be added
##   - all `x` are treated as unsigned values (i.e., for signed integers,
##     their two's complement representation will be used)

from std/math import ceilDiv

const jsNoBigInt64 =
  when defined(js):
    when compiles(compileOption("jsbigint64")):
      not compileOption("jsbigint64")
    else:
      true
  else:
    false

const digits = "0123456789abcdefghijklmnopqrstuvwxyz"  # lowercase
type
  BB = range[1..5]
  SBB = static BB
template popPowOf2[baseBits: SBB](n: var SomeInteger; result; idx: int;
    loops: static[int]) =
  const
    mask = (1 shl baseBits) - 1
  for i in countdown(loops-1, 0):
    result[idx + i] = digits[n and mask]
    n = n shr baseBits

func calLoops(baseBits: int): int{.compileTime.} = ceilDiv(8, baseBits)

template popPowOf2[baseBits: SBB](n: var SomeInteger; result; idx: int;
) =
  const loops = calLoops baseBits
  popPowOf2[baseBits](n, result, idx, loops)
#[
template popOct(n: var SomeInteger; result; base: int) =
  for i in countdown(2, 0):
    result[base + i] = hexdigits[n and 0o7]
    n = n shr 3
]#
type SomeInt8 = int8|uint8|char

template setOf[baseBits: SBB](result; c: SomeInt8, idx: int; loops) =
  var n = when c is char: c.uint8 else: c
  n.popPowOf2[:baseBits](result, idx, loops)
template setOf[baseBits: SBB](result; c: SomeInt8, idx: int) =
  const loops = calLoops baseBits
  setOf[baseBits](result, c, idx, loops)

template setHex(result; c: SomeInt8, idx: int) = setOf[4](result, c, idx)

func addLower*[baseBits: SBB](result: var string, x: SomeInt8) =
  const loops = calLoops baseBits
  let L = result.len
  result.setLen L + loops
  result.setOf[:baseBits](x, L, loops)

func addLower*[baseBits: SBB](result: var string, x: BiggestUInt, len: Positive, handleNegative: bool) =
  const loops = calLoops baseBits
  var n = x
  let
    olen = result.len
    nlen = olen + len
  result.setLen nlen
  for i in countdown(nlen - loops, olen, loops):
    n.popPowOf2[:baseBits](result, i)
    # handle negative overflow
    if n == 0 and handleNegative: n = not(BiggestUInt 0)

func addLowerHex*(result: var string, x: SomeInt8) = result.addLower[:4](x)

func toLowerHex*(s: openArray[char]): string =
  result = newString(s.len * 2)
  for pos, c in s:
    result.setHex c, 2 * pos

func toLowerHex*(s: openArray[char]; sep: char): string =
  let le = s.len
  if le == 0: return ""
  if le == 1: return s.toLowerHex
  result = newString le * 3 - 1
  result.setHex s[0], 0
  for i in 1..<le:
    let pos = 3 * i
    result[pos-1] = sep
    result.setHex s[i], pos

template strLenInHex(T): untyped = sizeof(T) * 2
func addLower*[baseBits: SBB](result: var string, x: SomeInteger, len: Positive = strLenInHex(typeof(x))) =
  when jsNoBigInt64:
    result.addLower[:baseBits](cast[BiggestUInt](x), len, x < 0)
  else:
    when x is SomeSignedInt:
      result.addLower[:baseBits](cast[BiggestUInt](BiggestInt(x)), len, x < 0)
    else:
      result.addLower[:baseBits](BiggestUInt(x), len, false)

func addLowerHex*[T: SomeInteger](result: var string, x: T, len: Positive = strLenInHex(T)) =
  ## Converts `x` to its lower hexadecimal representation and add to `result`.
  ##
  ## The resulting string will be exactly `len` characters long. No prefix like
  ## `0x` is generated. `x` is treated as an unsigned value.
  addLower[4](result, x, len)

func addWithPre0Trim(s: var string, t: string) =
  ## Add `t` to `s`, but trim leading `0`s in `t`
  var startIdx = 0
  while startIdx < t.len and t[startIdx] == '0':
    inc startIdx
  if startIdx == t.len:
    s.add '0'
  else:
    s.add t[startIdx ..< t.len]

template gen(name, baseBits, prefix){.dirty.} =
  func `toLower name`*[T: SomeInteger](x: T, len: Positive = sizeof(T) * calLoops(baseBits)): string =
    result.addLower[:baseBits](x, len)
  func `name`*[T: SomeInteger](x: T): string =
    when T is SomeSignedInt:
      if x < 0:
        result.add '-'
      let x = abs(x)
    result.add prefix
    let L = sizeof(T) * calLoops(baseBits)
    result.addWithPre0Trim `toLower name`(x, L)
gen hex, 4, "0x"
gen oct, 3, "0o"
gen bin, 1, "0b"

