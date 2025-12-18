## .. warning::
##   currently any symbol besides `hex`_ is unstable

const jsNoBigInt64 =
  when defined(js):
    when compiles(compileOption("jsbigint64")):
      not compileOption("jsbigint64")
    else:
      true
  else:
    false

const hexdigits = "0123456789abcdef"  # lowercase

template popHex[T: SomeInteger](n: var T; result; base: int) =
  result[base + 1] = hexdigits[n and 0xF]
  n = n shr 4
  result[base] = hexdigits[n and 0xF]
  n = n shr 4

template setHex[T: uint8|int8](result; c: T, base: int) =
  var n = c
  n.popHex result, base

func addLowerHex*[T: uint8|int8](result: var string, x: T) =
  let L = result.len + 2
  result.setLen L
  # write the two hex characters at the position we just extended to
  result.setHex x, L - 2
func addLowerHex*(result: var string, x: char) =
  result.addLowerHex x.uint8

func addLowerHex(result: var string, x: BiggestUInt, len: Positive, handleNegative: bool) =
  var n = x
  let
    olen = result.len
    nlen = olen + len
  result.setLen nlen
  for i in countdown(nlen - 2, olen, 2):
    n.popHex result, i
    # handle negative overflow
    if n == 0 and handleNegative: n = not(BiggestUInt 0)

template setHex(result; c: char, base: int) =
  result.setHex c.uint8, base

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

func addLowerHex*[T: SomeInteger](result: var string, x: T, len: Positive = strLenInHex(T)) =
  ## Converts `x` to its lower hexadecimal representation and add to `result`.
  ##
  ## The resulting string will be exactly `len` characters long. No prefix like
  ## `0x` is generated. `x` is treated as an unsigned value.
  when jsNoBigInt64:
    result.addLowerHex(cast[BiggestUInt](x), len, x < 0)
  else:
    when T is SomeSignedInt:
      result.addLowerHex(cast[BiggestUInt](BiggestInt(x)), len, x < 0)
    else:
      result.addLowerHex(BiggestUInt(x), len, false)

func toLowerHex*[T: SomeInteger](x: T, len: Positive = strLenInHex(T)): string =
  result.addLowerHex x, len

func hex*[T: SomeInteger](x: T, len: Positive = strLenInHex(T)): string =
  result = "0x"
  if x < 0:
    result.add '-'
  result.addLowerHex x, len
