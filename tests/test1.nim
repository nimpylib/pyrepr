
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

test "hex":
  check toLowerHex(0xABCD'u16) == "abcd"
  check 0x123456.toLowerHex(4) == "3456"
  var s: string
  s.addLowerHex char('A')
  check s == "41"
  check "\x32\x5a\xcb".toLowerHex == "325acb"
