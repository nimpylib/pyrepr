

import std/unicode
import ./radix

func add_hex(s: var string, r: Rune, n: int) =
  s.addLowerHex r.uint32, n

template pyasciiImplFromRunes*(result: var string; us#[: Iterable[Rune] ]#) =
  ## `us` is an iterable of `Rune`s
  bind Rune, add_hex, add, `<=%`, `<%`
  for r in us:
    if r <% Rune 127:
      result.add cast[char](r)
    else:
      result.add '\\'
      if r <=% Rune 0xff:  # is a ascii char
        result.add 'x'
        result.add_hex r, 2
      elif r <=% Rune 0xffff:
        result.add 'u'
        result.add_hex r, 4
      else:
        result.add 'U'
        result.add_hex r, 8

func pyasciiImpl*(us: string): string =
  ## Python's `ascii` impl
  ## 
  ## Note this assumes `us` is already processed
  ##  by `repr`
  ## i.e., this only escape
  ## the non-ASCII characters in `us` using \x, \u, or \U escapes
  ## and doesn't touch ASCII characters.
  result.pyasciiImplFromRunes us.runes
