
import unittest

import pyrepr

test "repr":
  check pyrepr.pyrepr("Hello, World!") == "'Hello, World!'"
  check pyrepr.pyrepr("Line1\nLine2") == r"'Line1\nLine2'"
  check pyrepr.pyrepr("Tab\tCharacter") == r"'Tab\tCharacter'"
  check pyrepr.pyrepr("Quote'\"Test") == r"""'Quote\'"Test'"""
  check pyrepr.pyrepr("Non-ASCII: ñ") == "'Non-ASCII: ñ'"
  check pyrepr.pyreprb("Bytes\x80\xFF") == r"b'Bytes\x80\xff'"

test "ascii":
  check pyrepr.pyasciiImpl("Hello, ñ") == r"Hello, \xf1"
  check pyrepr.pyasciiImpl("Emoji: 😊") == r"Emoji: \U0001f60a"

  when true:
    check ascii("𐀀") == r"'\U00010000'"
    check ascii("đ") == r"'\u0111'"
    check ascii("和") == r"'\u548c'"
    let s = ascii("v我\n\e")
    when not defined(useNimCharEsc):
      let rs = r"'v\u6211\n\x1b'"
    else:
      let rs = r"'v\u6211\n\e'"
    check s == rs
    check ascii("\"") == "'\"'"
    check ascii("\"'") == "'\"\\''"
    let s2 = ascii("'")
    when not defined(singQuotedStr):
      let rs2 = "\"'\""
    else:
      let rs2 = r"'\''"
    check s2 == rs2

test "hex":
  check toLowerHex(0xABCD'u16) == "abcd"
  check 0x123456.toLowerHex(4) == "3456"
  var s: string
  s.addLowerHex char('A')
  check s == "41"
  check "\x32\x5a\xcb".toLowerHex == "325acb"

test "bin":
  check toLowerBin(0b01100010u8) == "01100010"
test "oct":
  check toLowerOct(0o123u8) == "123"

