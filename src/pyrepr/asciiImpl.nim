

import std/[strutils, unicode]

template toHex(r: Rune, n): string =
  r.uint32.toHex n

template pyasciiImpl(result: var string; us#[: Iterable[Rune] ]#) =
  for r in us:
    if r <% Rune 127:
      result.add cast[char](r)
    elif r <=% Rune 0xff:  # is a ascii char
      result.add r"\x" & r.toHex(2).toLowerAscii
    elif r <=% Rune 0xffff:
      result.add r"\u" & r.toHex(4).toLowerAscii
    else:
      result.add r"\U" & r.toHex(8).toLowerAscii

func pyasciiImpl*(us: string): string =
  ## Python's `ascii` impl
  ## 
  ## Note this assumes `us` is already processed
  ##  by `repr`
  ## i.e., this only escape
  ## the non-ASCII characters in `us` using \x, \u, or \U escapes
  ## and doesn't touch ASCII characters.
  result.pyasciiImpl us.runes
