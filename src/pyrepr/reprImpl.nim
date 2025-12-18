
import ./hex
const
  q = '\''
  Q = '"'
  Qq = {Q, q}


func Py_addEscapedChar(result: var string, c: char,
    escapeQuotationMark: static[set[char]] = Qq) =
  ## snippet from CPython-3.14.0-alpha/Objects/bytesobject.c
  ## PyBytes_Repr
  template slash(c: char) =
    result.add '\\'
    result.add c
  template push(c: char) =
    result.add c
  case c
  of '\\': slash '\\'
  of '\t': slash 't'
  of '\n': slash 'n'
  of '\r': slash 'r'
  of escapeQuotationMark:
    slash c
  elif c < ' ' or c > '\x7f':
    slash 'x'
    result.addLowerHex c
  else:
    when defined(useNimCharEsc):
      if c == '\e': result.add "\\x1b"
      else: push c
    else: push c

func raw_repr(us: openArray[char]
  ,escapeQuotationMark: static[set[char]] = Qq
  ,escape127: static[bool] = false # if to escape char greater than `\127`
): string =
  template addMayEscape(s: string, c: char) =
    result.Py_addEscapedChar c, escapeQuotationMark
  for c in us:
    template addEscaped =
      result.addMayEscape c
    when escape127:
      addEscaped
    else:
      if c > '\127':
        result.add c  # add non-ASCII utf-8 AS-IS
      else:
        addEscaped

template implWith(us; rawImpl; arg_escape127: bool): untyped =
  when defined(singQuotedStr):
    q & rawImpl(us, escape127=arg_escape127) & q
  else:
    if us.contains Q:
      q & rawImpl(us, escapeQuotationMark={q}, escape127=arg_escape127) & q
    elif us.contains q:
      Q & rawImpl(us, escapeQuotationMark={Q}, escape127=arg_escape127) & Q
    else: # neither ' nor "
      q & rawImpl(us, escape127=arg_escape127) & q

func pyrepr*(s: openArray[char], escape127: static[bool] = false): string =
  ## Python's `repr`
  ## but returns Nim's string.
  ##
  ##   nim's Escape Char feature can be enabled via `-d:useNimCharEsc`,
  ##     in which '\e' (i.e.'\x1B' in Nim) will be replaced by "\\e"
  ## 
  runnableExamples:
    # NOTE: string literal's `repr` is `system.repr`, as following. 
    assert repr("\"") == "\"\\\"\""   # string literal of "\""
    # use pyrepr for any StringLike and returns a PyStr
    assert pyrepr("\"") == "'\"'"
  implWith(s, raw_repr, escape127)

func pyreprb*(s: openArray[char]): string =
  'b' & s.pyrepr(true)
