enum _StrType {
  space,
  number,
  sign,
  func,
  par,
  backslash,
  argStart,
  argEnd,
  char,
}

class Token {
  _StrType strType;
  String str;
  _Func func;
  double _width;
  double get width => _width ?? 0.0;
  Token(String s, bool isLiteral) {
    if (isLiteral) {
      str = s;
      strType = _StrType.char;
      if (_sizeMap.containsKey(s))
        _width = _sizeMap[s];
      else
        print('_sizeMap does not contain $s');
    } else if (s == '{') {
      str = null;
      strType = _StrType.argStart;
    } else if (s == '}') {
      str = null;
      strType = _StrType.argEnd;
    } else if (_funcMap.containsKey(s)) {
      func = _funcMap[s];
      strType = _StrType.func;
    } else {
      str = s;
      strType = _StrType.char;
      if (_sizeMap.containsKey(s))
        _width = _sizeMap[s];
      else
        print('_sizeMap does not contain $s');
    }
  }

  bool get isNextSignMonoOperator {
    return ['(', '{', '[', '=', ':'].contains(str);
  }

  bool get isSign {
    return ['+', '-'].contains(str);
  }

  bool get isFunc => func != null;

  bool get isArgStart => strType == _StrType.argStart;
  bool get isArgEnd => strType == _StrType.argEnd;
}

_StrType _strTypeFromString(String s) {
  var c = s.codeUnits.last;
  if (s == '.' ||
      (c >= '0'.codeUnits.last && c <= '9'.codeUnits.last) ||
      ['\\'].contains(s) ||
      (c >= 'A'.codeUnits.last && c <= 'Z'.codeUnits.last) ||
      (c >= 'a'.codeUnits.last && c <= 'z'.codeUnits.last)) {
    return _StrType.number;
  } else if (['^', '_'].contains(s)) {
    return _StrType.func;
  } else if (s == '+' || s == '-') {
    return _StrType.sign;
  } else if (s == ' ') {
    return _StrType.space;
  } else if (s == '{') {
    return _StrType.argStart;
  } else if (s == '}') {
    return _StrType.argEnd;
  } else if (['|', '(', ')', '[', ']', ':', ',', '='].contains(s)) {
    return _StrType.par;
  } else if (s == '\\') {
    return _StrType.backslash;
  }
  throw 'Unknown char. $s';
}

bool isChar(String s) {
  var c = s.codeUnits.last;
  return (c >= 'A'.codeUnits.last && c <= 'Z'.codeUnits.last) ||
      (c >= 'a'.codeUnits.last && c <= 'z'.codeUnits.last);
}

bool isNum(String s) {
  var c = s.codeUnits.last;
  return c >= '0'.codeUnits.last && c <= '9'.codeUnits.last;
}

bool startPar(String s) {
  return ['(', '{', '['].contains(s);
}

const _spaceWidth = 4.0;

class FuncResult {
  final _Func func;
  final List<double> args = [];
  FuncResult(this.func);

  double get width {
    double ret = 0;
    for (var arg in args) {
      ret = arg > ret ? arg : ret;
    }
    ret = ret * func.factor;
    ret += func.size;
    return ret;
  }
}

class SizeSpeculator {
  final String tex;
  final List<FuncResult> _funcStack = [];
  final List<Token> tokens = [];
  int tokenInd = 0;

  SizeSpeculator(this.tex);

  double size() {
    parseToTokens();
    tokenInd = 0;
    return this._size();
  }

  parseToTokens() {
    var i = 0;
    while (i < tex.length) {
      if (tex[i] == '\\') {
        if (isChar(tex[i + 1])) {
          var backslashStr = StringBuffer();
          backslashStr.write(tex[i]);
          i++;
          while (i < tex.length && isChar(tex[i])) {
            backslashStr.write(tex[i]);
            i++;
          }
          tokens.add(Token(backslashStr.toString(), false));
        } else {
          i++;
          tokens.add(Token(tex[i], true));
          i++;
        }
      } else {
        tokens.add(Token(tex[i], false));
        i++;
      }
    }
  }

  double _size() {
    double ret = 0.0;
    bool backslash = false;
    String backslashStr = '';
    _StrType lastStrType = _StrType.space;
    _StrType currentStrType = _StrType.space;
    String lastStr = ' ';
    String currentStr = ' ';

    while (tokenInd < tokens.length) {
      var token = tokens[tokenInd];
      ret += token.width;
      if (token.isFunc) {
        _funcStack.add(FuncResult(token.func));
      } else if (token.isArgStart) {
        _funcStack.last.args.add(_size());
        if (_funcStack.last.args.length == _funcStack.last.func.numArgs) {
          ret += _funcStack.last.width;
          _funcStack.removeLast();
        }
      } else if (token.isArgEnd) {
        return ret - _spaceWidth;
      } else {
        ret += token.width;
      }
      tokenInd++;
    }

    return ret - _spaceWidth;
  }
}

class _Func {
  final double size;
  final double factor;
  final int numArgs;
  const _Func({this.size, this.factor, this.numArgs});
}

const Map<String, _Func> _funcMap = {
  r'\sqrt': _Func(size: 10, factor: 1, numArgs: 1),
  r'\frac': _Func(size: 0, factor: 1, numArgs: 2),
  r'^': _Func(size: 0, factor: 0.5, numArgs: 1),
  r'_': _Func(size: 0, factor: 0.5, numArgs: 1),
};

double calBasicTexWidth(String s) {
  var ret = 0.0;
  for (var i = 0; i < s.length; i++) {
    var u = s[i];
    if (_sizeMap.containsKey(u)) {
      ret += _sizeMap[u];
    } else {
      print('Not in _sizeMap. $u , $s');
    }
  }
  return ret;
}

const Map<String, double> _sizeMap = {
  r'=': 14,
  r'0': 9,
  r'1': 9,
  r'2': 9,
  r'3': 9,
  r'4': 9,
  r'5': 9,
  r'6': 9,
  r'7': 9,
  r'8': 9,
  r'9': 9,
  r'.': 5,
  r'-': 14,
  r'+': 14,
  r':': 5,
  r'a': 9,
  r'b': 8,
  r'c': 8,
  r'd': 9,
  r'e': 8,
  r'f': 10.82988,
  r'g': 9.609960000000001,
  r'h': 10,
  r'i': 6,
  r'j': 7.9730799999999995,
  r'k': 9.53516,
  r'l': 6.33456,
  r'm': 15,
  r'n': 11,
  r'o': 9,
  r'p': 9,
  r'q': 8.609960000000001,
  r'r': 8.47226,
  r's': 8,
  r't': 7,
  r'u': 10,
  r'v': 9.609960000000001,
  r'w': 13.45747,
  r'x': 10,
  r'y': 9.609960000000001,
  r'z': 8.74766,
  r'A': 13,
  r'B': 13.85289,
  r'C': 14.21601,
  r'D': 15.47226,
  r'E': 13.97988,
  r'F': 13.36113,
  r'G': 14,
  r'H': 16.38125,
  r'I': 9.33399,
  r'J': 11.63506,
  r'K': 16.21601,
  r'L': 12,
  r'M': 18.85351,
  r'N': 15.85351,
  r'O': 13.47226,
  r'P': 13.36113,
  r'Q': 14,
  r'R': 13.13141,
  r'S': 11.97988,
  r'T': 12.36113,
  r'U': 13.85351,
  r'V': 13.77774,
  r'W': 19.36113,
  r'X': 16.33399,
  r'Y': 13.77774,
  r'Z': 13.21601,
  r'|': 5,
  r',': 5,
  r'(': 7,
  r')': 7,
  r'{': 9,
  r'}': 9,
  r'[': 5,
  r']': 5,
  r'\ldots': 20,
  r'\cdots': 20,
  r'\to': 17,
  r'\in': 12,
  r'\notin': 12,
  r'\ni': 12,
  r'\cdot': 5,
  r'\times': 14,
  r'\div': 14,
  r'\infty': 17,
  r'\equiv': 14,
  r'\Leftrightarrow': 17,
};
