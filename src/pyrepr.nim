
import ./pyrepr/[
  asciiImpl, reprImpl, radix,
]

export asciiImpl, reprImpl, radix

func ascii*(us: openArray[char]): string =
  pyasciiImpl pyrepr us
