import 'dart:math' as math;

import 'mth.dart';

class TexString {
  String tex;
  double width;
}

class FormulaTemplate {
  final String template;
  final _InternalNode root;
  final String skey;

  @override
  String toString() => 'FormulaTemplate{template: $template}';

  FormulaTemplate(String template, {this.skey})
      : template = template ?? '',
        root = parse(template, skey);

  bool get isEmpty => root.children.isEmpty;

  static _InternalNode parse(String t, String skey) {
    try {
      return _parse(t);
    } catch (e) {
      print('$skey $t');
      rethrow;
    }
  }

  static _InternalNode _parse(String t) {
    if (t == null) {
      return _InternalNode(parent: null, children: []);
    }
    t = t.trim();
    var root = _InternalNode(parent: null, children: []);
    var cur = root;
    int lastInd = 0;
    bool isChar = false;
    int depth = 0;
    for (var i = 0; i < t.length; i++) {
      if (t[i] == '\'') {
        if (isChar)
          cur.addChar(t.substring(lastInd, i));
        else
          cur.addLeaf(t.substring(lastInd, i));
        lastInd = i + 1;
        isChar = !isChar;
        continue;
      }
      if (isChar) continue;
      if (t[i] == '(') {
        cur.addLeaf(t.substring(lastInd, i));
        var newNode = _InternalNode(parent: cur, children: []);
        cur.addChild(newNode);
        cur = newNode;
        lastInd = i + 1;
        depth++;
      } else if (t[i] == ')') {
        cur.addLeaf(t.substring(lastInd, i));
        cur = cur.parent;
        lastInd = i + 1;
        depth--;
      } else if (t[i] == ' ') {
        cur.addLeaf(t.substring(lastInd, i));
        lastInd = i + 1;
      }
    }
    if (lastInd < t.length) {
      cur.addLeaf(t.substring(lastInd, t.length));
    }
    if (depth != 0) {
      throw Exception('The numbers of ( and ) are not equal. depth=$depth');
    }
    return root;
  }

  num executeNum(Map<String, num> m) {
    var r = parse(template, skey);
    try {
      r.executeNodes(m);
      return r.executeNum(m);
    } catch (e) {
      print('$skey $template');
      rethrow;
    }
  }

  bool executeBool(Map<String, num> m) {
    if (isEmpty) return false;
    var r = parse(template, skey);
    r.executeNodes(m);
    return r.executeBool(m);
  }

  String executeString(Map<String, num> m) {
    var r = parse(template, skey);
    r.executeNodes(m);
    return r.executeString(m);
  }

  Iterable<String> get usedVarNames => root.usedVarNames;

  checkVarName(List<String> acceptableVarNames) =>
      root.checkVarName(acceptableVarNames);

  checkFunc() => root.checkFunc();
}

abstract class _Node {
  _InternalNode get parent;
  set parent(_InternalNode value);
  num executeNum(Map<String, num> m);
  String executeString(Map<String, num> m);
  bool executeBool(Map<String, num> m);
  void executeNodes(Map<String, num> m);
  Iterable<String> get usedVarNames;
  void checkVarName(List<String> acceptableVarNames);
  void checkFunc();
}

class _InternalNode extends _Node {
  _InternalNode parent;
  final List<_Node> children;

  _InternalNode({this.parent, this.children});

  @override
  String toString() {
    return '{parent: $parent, children: $children}';
  }

  void addChild(_Node child) {
    this.children.add(child);
  }

  void addChar(String s) {
    this.addChild(_Char(s, parent: this));
  }

  void addLeaf(String s) {
    if (s.length == 0) {
      return;
    }
    if (s[0] == '.') {
      this.addChild(_Var(s.substring(1), parent: this));
    } else if (s.startsWith('-') ||
        s.startsWith('+') ||
        (s[0].compareTo('0') >= 0 && s[0].compareTo('9') <= 0)) {
      this.addChild(_Number(num.parse(s), parent: this));
    } else if (s[0].compareTo('a') >= 0 && s[0].compareTo('z') <= 0) {
      this.addChild(_Func(s, parent: this));
    } else if (s[0].compareTo('A') >= 0 && s[0].compareTo('Z') <= 0) {
      this.addChild(_Stringer(s, parent: this));
    } else if (s == '&&' || s == '||' || s == '!') {
      this.addChild(_Booler(s, parent: this));
    } else if (s == '>=' ||
        s == '<=' ||
        s == '==' ||
        s == '!=' ||
        s == '>' ||
        s == '<' ||
        s == '_|_') {
      this.addChild(_NumToBooler(s, parent: this));
    } else if (s == '*') {
      this.addChild(_Noder(s, parent: this));
    } else {
      throw Exception("addLeaf: undefined leaf value: $s, this: $this");
    }
  }

  num executeNum(Map<String, num> m) {
    if (this.children == null || this.children.length == 0) {
      throw Exception(
          'Node should have children. parent:$parent children:$children m:$m');
    }
    if (children.first is _InternalNode) {
      throw Exception('the first child should not be _InternalNode.');
    }
    return children[0].executeNum(m);
  }

  String executeString(Map<String, num> m) {
    if (this.children == null || this.children.length == 0) {
      throw Exception(
          'Node should have children. parent:$parent children:$children m:$m');
    }
    if (children.first is _InternalNode) {
      throw Exception('the first child should not be _InternalNode.');
    }
    return children[0].executeString(m);
  }

  bool executeBool(Map<String, dynamic> m) {
    if (this.children == null || this.children.length == 0) {
      throw Exception(
          'Node should have children. parent:$parent children:$children m:$m');
    }
    if (children.first is _InternalNode) {
      throw Exception('the first child should not be _InternalNode.');
    }
    return children[0].executeBool(m);
  }

  void executeNodes(Map<String, num> m) {
    if (children == null) return;
    for (var i = 0; i < children.length; i++) {
      children[i].executeNodes(m);
    }
  }

  Iterable<String> get usedVarNames sync* {
    if (children == null) return;
    for (var c in children) {
      yield* c.usedVarNames;
    }
  }

  void checkVarName(List<String> acceptableVarNames) {
    if (children == null) return;
    for (var c in children) {
      c.checkVarName(acceptableVarNames);
    }
  }

  void checkFunc() {
    if (children == null) return;
    for (var c in children) {
      c.checkFunc();
    }
  }
}

class _LeafNode extends _Node {
  _InternalNode parent;
  _LeafNode({this.parent});

  @override
  void checkFunc() {}

  @override
  void checkVarName(List<String> acceptableVarNames) {}

  @override
  bool executeBool(Map<String, num> m) {
    throw UnimplementedError();
  }

  @override
  void executeNodes(Map<String, num> m) {}

  @override
  num executeNum(Map<String, num> m) {
    throw UnimplementedError();
  }

  @override
  String executeString(Map<String, num> m) {
    throw UnimplementedError();
  }

  @override
  Iterable<String> get usedVarNames => [];
}

class _Number extends _LeafNode {
  final num value;

  _Number(this.value, {_InternalNode parent}) : super(parent: parent);

  @override
  num executeNum(Map<String, num> m) {
    if (value == null) {
      throw Exception("value is null.");
    }
    if (parent.children.first == this && parent.children.length > 1) {
      throw Exception(
          "_Number $value has arguments.  ${this.parent.toString()}");
    }
    return value;
  }

  @override
  String executeString(Map<String, num> m) => removePointZero(executeNum(m));
}

class _Var extends _LeafNode {
  final String name;

  _Var(this.name, {_InternalNode parent}) : super(parent: parent);

  @override
  num executeNum(Map<String, num> m) {
    if (m[name] == null) {
      throw Exception("_Var: m[$name] is null. $m");
    }
    if (parent.children.first == this && parent.children.length > 1) {
      throw Exception(
          "_Number ${m[name]} has arguments.  ${this.parent.toString()}");
    }
    return m[name];
  }

  @override
  String executeString(Map<String, num> m) => removePointZero(executeNum(m));

  Iterable<String> get usedVarNames sync* {
    yield name;
  }

  checkVarName(List<String> acceptableVarNames) {
    if (!acceptableVarNames.contains(name)) {
      throw Exception(
          '$name is not an acceptable var name. acceptableVarNames: $acceptableVarNames');
    }
  }
}

class _Func extends _LeafNode {
  final String name;

  _Func(this.name, {_InternalNode parent}) : super(parent: parent) {
    if (!funcDirectory.containsKey(name))
      throw Exception('Function $name is not defined.');
  }

  @override
  num executeNum(Map<String, num> m) {
    if (parent.children.first != this) {
      throw Exception(
          "_Func $name must be in the first place. ${this.parent.toString()}");
    }
    var args = parent.children.skip(1).map((e) => e.executeNum(m)).toList();
    if (!funcDirectory.containsKey(name))
      throw Exception('Function $name is not defined.');
    return funcDirectory[name](args);
  }

  @override
  String executeString(Map<String, num> m) => removePointZero(executeNum(m));

  @override
  checkFunc() {
    if (!funcDirectory.containsKey(name))
      throw Exception('Function $name is not defined.');
    if (parent.children.first != this) {
      throw Exception(
          "_Func must be in the first place. $name. ${this.parent.toString()}");
    }
    funcDirectory[name](parent.children.skip(1).map((e) => 1).toList());
  }
}

class _Stringer extends _LeafNode {
  final String name;

  _Stringer(this.name, {_InternalNode parent})
      : assert(stringerDirectory.containsKey(name), name),
        super(parent: parent);

  @override
  num executeNum(Map<String, num> m) =>
      throw Exception('Stringer cannot call executeNum. name:$name, m:$m}');

  @override
  String executeString(Map<String, num> m) {
    if (parent.children.first != this) {
      throw Exception(
          "_Stringer must be in the first place. $name ${this.parent.toString()}");
    }
    var args = parent.children.skip(1).map((e) => e.executeString(m)).toList();
    return stringerDirectory[name](args);
  }

  @override
  checkFunc() {
    if (!stringerDirectory.containsKey(name))
      throw Exception('Function $name is not defined.');
    if (parent.children.first != this) {
      throw Exception(
          "_Stringer must be in the first place. ${this.parent.toString()}");
    }
    stringerDirectory[name](parent.children.skip(1).map((e) => '1').toList());
  }
}

class _Booler extends _LeafNode {
  final String name;

  _Booler(this.name, {_InternalNode parent})
      : assert(boolerDirectory.containsKey(name)),
        super(parent: parent);

  @override
  num executeNum(Map<String, num> m) =>
      throw Exception('_Booler cannot call executeNum. name:$name, m:$m}');

  @override
  bool executeBool(Map<String, dynamic> m) {
    if (parent.children.first != this) {
      throw Exception(
          "_Booler must be in the first place. ${this.parent.toString()}");
    }
    var args = parent.children.skip(1).map((e) => e.executeBool(m)).toList();
    return boolerDirectory[name](args);
  }

  @override
  String executeString(Map<String, num> m) =>
      throw Exception('_Booler cannot call executeString. name:$name, m:$m}');

  @override
  checkFunc() {
    if (parent.children.first != this) {
      throw Exception(
          "_Booler must be in the first place. ${this.parent.toString()}");
    }
    if (!boolerDirectory.containsKey(name))
      throw Exception('Function $name is not defined.');
    boolerDirectory[name](parent.children.skip(1).map((e) => true).toList());
  }
}

class _NumToBooler extends _LeafNode {
  final String name;

  _NumToBooler(this.name, {_InternalNode parent})
      : assert(numToBoolerDirectory.containsKey(name)),
        super(parent: parent);

  @override
  num executeNum(Map<String, num> m) =>
      throw Exception('_NumToBooler cannot call executeNum. name:$name, m:$m}');

  @override
  bool executeBool(Map<String, dynamic> m) {
    if (parent.children.first != this) {
      throw Exception(
          "_NumToBooler must be in the first place. ${this.parent.toString()}");
    }
    var args = parent.children.skip(1).map((e) => e.executeNum(m)).toList();
    return numToBoolerDirectory[name](args);
  }

  @override
  String executeString(Map<String, num> m) => throw Exception(
      '_NumToBooler cannot call executeString. name:$name, m:$m}');

  @override
  checkFunc() {
    if (parent.children.first != this) {
      throw Exception(
          "_NumToBooler must be in the first place. ${this.parent.toString()}");
    }
    if (!numToBoolerDirectory.containsKey(name))
      throw Exception('_NumToBooler function $name is not defined.');
    numToBoolerDirectory[name](parent.children.skip(1).map((e) => 1).toList());
  }
}

class _Noder extends _LeafNode {
  final String name;

  _Noder(this.name, {_InternalNode parent}) : super(parent: parent);

  @override
  num executeNum(Map<String, num> m) =>
      throw Exception('_Noder cannot call executeNum. name:$name, m:$m}');

  @override
  bool executeBool(Map<String, dynamic> m) =>
      throw Exception('_Noder cannot call executeBool. name:$name, m:$m}');

  @override
  String executeString(Map<String, num> m) =>
      throw Exception('_Noder cannot call executeString. name:$name, m:$m}');

  void executeNodes(Map<String, num> m) {
    if (parent.children.first != this) {
      throw Exception(
          "_Noder must be in the first place. ${this.parent.toString()}");
    }
    if (name == '*') {
      if (parent.children.length != 3)
        throw Exception('* repeat only accepts two arguments.');
      var ind = parent.parent.children.indexOf(parent);
      parent.parent.children.remove(parent);
      num repeatNum = parent.children[1].executeNum(m);
      parent.children[2].parent = parent.parent;
      parent.parent.children.insertAll(ind, [
        for (var i = 0; i < repeatNum; i++) parent.children[2],
      ]);
    } else {
      throw Exception('Unknown _Noder name:$name');
    }
  }

  @override
  checkFunc() {
    if (parent.children.first != this) {
      throw Exception(
          "_Noder must be in the first place. ${this.parent.toString()}");
    }
    if (name == '*') {
      if (parent.children.length != 3)
        throw Exception('* repeat only accepts two arguments.');
    } else {
      throw Exception('Unknown _Noder name:$name');
    }
  }
}

class _Char extends _LeafNode {
  final String value;

  _Char(this.value, {_InternalNode parent}) : super(parent: parent);

  @override
  num executeNum(Map<String, num> m) =>
      throw Exception('_Char cannot call executeNum. name:$value, m:$m}');

  @override
  bool executeBool(Map<String, dynamic> m) =>
      throw Exception('Char cannot call executeBool. name:$value, m:$m}');

  @override
  String executeString(Map<String, num> m) => value;

  @override
  void executeNodes(Map<String, num> m) {}

  @override
  void checkFunc() {}
}

typedef B = bool Function(List<bool>);

Map<String, B> boolerDirectory = {
  '&&': and,
  '||': or,
  '!': not,
};

bool and(List<bool> a) {
  if (a.length == 0)
    throw Exception('and should have one or more arguments. $a');
  var ret = a[0];
  for (var b in a.skip(1)) {
    ret = ret && b;
  }
  return ret;
}

bool or(List<bool> a) {
  if (a.length == 0)
    throw Exception('or should have one or more arguments. $a');
  var ret = a[0];
  for (var b in a.skip(1)) {
    ret = ret || b;
  }
  return ret;
}

bool not(List<bool> a) {
  if (a.length != 1) throw Exception('not should have only one argument. $a');
  return !a[0];
}

typedef NB = bool Function(List<num>);

Map<String, NB> numToBoolerDirectory = {
  '==': eq,
  '!=': neq,
  '>': gt,
  '>=': gte,
  '<': lt,
  '<=': lte,
  '_|_': coprime,
};

bool eq(List<num> a) {
  if (a.length != 2) throw Exception('= eq should have two arguments.');
  return numCompareToRelation(a[0], a[1]) == Relation.equal;
}

bool neq(List<num> a) {
  if (a.length != 2) throw Exception('!= neq should have two arguments.');
  return numCompareToRelation(a[0], a[1]) != Relation.equal;
}

bool gt(List<num> a) {
  if (a.length != 2) throw Exception('> gt should have two arguments.');
  return numCompareToRelation(a[0], a[1]) == Relation.greaterThan;
}

bool gte(List<num> a) {
  if (a.length != 2) throw Exception('>= gte should have two arguments.');
  return numCompareToRelation(a[0], a[1]) != Relation.lessThan;
}

bool lt(List<num> a) {
  if (a.length != 2) throw Exception('< lt should have two arguments.');
  return numCompareToRelation(a[0], a[1]) == Relation.lessThan;
}

bool lte(List<num> a) {
  if (a.length != 2) throw Exception('<= lte should have two arguments.');
  return numCompareToRelation(a[0], a[1]) != Relation.greaterThan;
}

bool coprime(List<num> a) {
  if (a.length < 2)
    throw Exception('_|_ coprime should have two or more arguments. $a');
  return gcd(a) == 1;
}

typedef W = double Function(List<String>);

typedef S = String Function(List<String>);

Map<String, S> stringerDirectory = {
  'Raw': sRaw,
  'Add': sAdd,
  'Sub': sSub,
  'Minus': sMinus,
  'SignIfMinus': sSignIfMinus,
  'WithSign': sWithSign,
  'WithPar': sWithPar,
  'WithRemainder': sWithRemainder,
  'Times': sTimes,
  'Cdot': sCdot,
  'Div': sDiv,
  'Frac': sFrac,
  'Sqrt': sSqrt,
  'Abs': sAbs,
  'Min': sMin,
  'Max': sMax,
  'Gcd': sGcd,
  'Lcm': sLcm,
  'Pow': sPow,
  'Mul': sMul,
  'Coeff': sMul,
  'Simul': sSimul,
  'In': sIn,
  'Ni': sNi,
  'Notin': sNotin,
  'Notni': sNotni,
  'Lim': sLim,
  'Infty': sInfty,
  'To': sTo,
  'Equal': sEqual,
  'Equiv': sEquiv,
  'Leftrightarrow': sLeftrightarrow,
  'Acute': sOneFunc(r'\acute'),
  'Bar': sOneFunc(r'\bar'),
  'Breve': sOneFunc(r'\breve'),
  'Check': sOneFunc(r'\check'),
  'Dot': sOneFunc(r'\dot'),
  'Ddot': sOneFunc(r'\ddot'),
  'Grave': sOneFunc(r'\grave'),
  'Hat': sOneFunc(r'\hat'),
  'Widehat': sOneFunc(r'\widehat'),
  'Tilde': sOneFunc(r'\tilde'),
  'Widetilde': sOneFunc(r'\widetilde'),
  'Utilde': sOneFunc(r'\utilde'),
  'Vec': sOneFunc(r'\vec'),
  'Overleftarrow': sOneFunc(r'\overleftarrow'),
  'Underleftarrow': sOneFunc(r'\underleftarrow'),
  'Overleftharpoon': sOneFunc(r'\overleftharpoon'),
  'Overleftrightarrow': sOneFunc(r'\overleftrightarrow'),
  'Underleftrightarrow': sOneFunc(r'\underleftrightarrow'),
  'Overline': sOneFunc(r'\overline'),
  'Underline': sOneFunc(r'\underline'),
  'Widecheck': sOneFunc(r'\widecheck'),
  'Mathring': sOneFunc(r'\mathring'),
  'Overgroup': sOneFunc(r'\overgroup'),
  'Undergroup': sOneFunc(r'\undergroup'),
  'OOverrightarrow': sOneFunc(r'\Overrightarrow'),
  'Overrightarrow': sOneFunc(r'\overrightarrow'),
  'Underrightarrow': sOneFunc(r'\underrightarrow'),
  'Overrightharpoon': sOneFunc(r'\overrightharpoon'),
  'Overbrace': sOneFunc(r'\overbrace'),
  'Underbrace': sOneFunc(r'\underbrace'),
  'Overlinesegment': sOneFunc(r'\overlinesegment'),
  'Underlinesegment': sOneFunc(r'\underlinesegment'),
  'Cancel': sOneFunc(r'\cancel'),
  'Bcancel': sOneFunc(r'\bcancel'),
  'Xcancel': sOneFunc(r'\xcancel'),
  'Sout': sOneFunc(r'\sout'),
  'Boxed': sOneFunc(r'\boxed'),
  'Not': sOneFunc(r'\not'),
  'Text': sOneFunc(r'\text'),
  'Subscript': sOneFunc('_'),
  'Superscript': sOneFunc('^'),
  'Where': sTwoFunc('|'),
  'Restrict': sTwoBraceLastFunc('| _'),
  'And': sAnd,
  'Let': sLet,
  'Ratio': sRatio,
};

S sZeroFunc(String tex) {
  return (List<String> ss) => sZero(tex, ss);
}

S sOneFunc(String tex) {
  return (List<String> ss) => sOne(tex, ss);
}

S sTwoFunc(String tex) {
  return (List<String> ss) => sTwo(tex, ss);
}

S sTwoBraceLastFunc(String tex) {
  return (List<String> ss) => sTwoBraceLast(tex, ss);
}

RegExp _startsWithSignRegExp = RegExp(r'^ *[+\-]');
RegExp _startsWithNumericRegExp = RegExp(r'^ *[0-9]');
RegExp _enclosedWithParRegExp = RegExp(r'^ *\(.*\) *$');
RegExp _zeroRegExp = RegExp(r'^ *0 *$');
RegExp _oneRegExp = RegExp(r'^ *1 *$');
RegExp _minusOneRegExp = RegExp(r'^ *-1 *$');
RegExp _pointRegExp = RegExp(r'^[0-9]+\.[0-9]+$');
RegExp _integerRegExp = RegExp(r'^ *[+\-]?[0-9]+ *$');
RegExp _numberRegExp = RegExp(r'^ *[+\-]?[0-9]+\.?[0-9]* *$');
RegExp _numberWithoutSignRegExp = RegExp(r'^ *[0-9]+\.?[0-9]* *$');
RegExp _minusNumberRegExp = RegExp(r' *-[0-9]+\.?[0-9]* *$');

bool enclosedWithPar(String s) {
  return _enclosedWithParRegExp.hasMatch(s);
}

bool hasMultipleFactorsOrTerms(String s) {
  if (_numberWithoutSignRegExp.hasMatch(s)) return false;
  if (s.trim().length > 1) return true;
  return false;
}

bool needsPar(String s) {
  var depth = 0;
  for (var r in s.runes) {
    if (r == '{'.runes.last || r == '('.runes.last || r == '['.runes.last) {
      depth++;
    } else if (r == '}'.runes.last ||
        r == ')'.runes.last ||
        r == ']'.runes.last) {
      depth--;
    } else if ((r == '+'.runes.last ||
            r == '-'.runes.last ||
            r == ' '.runes.last) &&
        depth == 0) {
      return true;
    }
  }
  return false;
}

bool needsParHead(String s) {
  var t = s.trim();
  if (t.startsWith('+') || t.startsWith('-')) {
    return needsPar(t.substring(1));
  }
  return needsPar(t);
}

bool isZero(String s) {
  return _zeroRegExp.hasMatch(s);
}

bool isOne(String s) {
  return _oneRegExp.hasMatch(s);
}

bool isMinusOne(String s) {
  return _minusOneRegExp.hasMatch(s);
}

bool startsWithSign(String s) {
  return _startsWithSignRegExp.hasMatch(s);
}

bool startsWithNumeric(String s) {
  return _startsWithNumericRegExp.hasMatch(s);
}

bool isInteger(String s) {
  return _integerRegExp.hasMatch(s);
}

bool isNumber(String s) {
  return _numberRegExp.hasMatch(s);
}

bool isMinusNumber(String s) {
  return _minusNumberRegExp.hasMatch(s);
}

RegExp _monomialRegExp = RegExp(r'^[+\-]?([0-9]*\.?[0-9]*)([a-zA-Z\\ ]*)$');

class _Monomial {
  final String str;
  bool isMinus;
  String coeffAbsStr;
  num coeffAbs;
  String chars;

  _Monomial(String s) : str = s.trim() {
    isMinus = str.startsWith('-');
    var match = _monomialRegExp.firstMatch(str);
    coeffAbsStr = match.group(1);
    if (coeffAbsStr.isEmpty)
      coeffAbs = 1;
    else if (coeffAbsStr.contains('.'))
      coeffAbs = double.parse(coeffAbsStr);
    else
      coeffAbs = int.parse(coeffAbsStr);
    chars = match.group(2);
  }

  String get coeffAbsAndChars => '$coeffAbsStr$chars';

  String withCoeff(num coeff) {
    if (coeff == 1 && chars.trim().isNotEmpty) {
      return chars;
    }
    return '$coeff$chars';
  }

  static bool isMonomial(String str) => _monomialRegExp.hasMatch(str.trim());
}

num coeff(String s) {
  s = s.trim();
  if (s.isEmpty) return 0;
  var match = _monomialRegExp.firstMatch(s);
  String m = match.group(1);
  if (m.isEmpty) return 1;
  if (s.contains('.')) {
    return double.parse(m);
  }
  return int.parse(m);
}

RegExp endsWithNinesRegExp = RegExp(r'^([0-9\.]*?)[9\.]{5,}9[0-8]{0,2}$');
RegExp endsWithZerosRegExp = RegExp(r'^[0-9\.]*?[0\.]{5,}0[1-9]{0,2}$');

String _plusOne(String c) {
  switch (c) {
    case '.':
      return '.';
    case '0':
      return '1';
    case '1':
      return '2';
    case '2':
      return '3';
    case '3':
      return '4';
    case '4':
      return '5';
    case '5':
      return '6';
    case '6':
      return '7';
    case '7':
      return '8';
    case '8':
      return '9';
    case '9':
      return '0';
  }
  throw Exception('cannot plusOne. $c');
}

String removePointZero(num n) {
  if (numCompare(n, 0.0) == 0) {
    return '0';
  }
  String ret = _removePointZero(n.toString());
  if (ret == '-0') return '0';
  return ret;
}

String _removePointZero(String s) {
  bool minus = false;
  s = s.trim();
  if (s.startsWith('-')) {
    s = s.substring(1);
    minus = true;
  }
  if (s.contains('.') && endsWithNinesRegExp.hasMatch(s)) {
    StringBuffer buf = StringBuffer();
    var match = endsWithNinesRegExp.firstMatch(s);
    int headLen = match.group(1).length;
    if (headLen == 0)
      buf.write('1');
    else
      headLen--;
    buf.write(s.substring(0, headLen));
    for (var i = headLen; i < s.length - 1; i++) {
      buf.write(_plusOne(s[i]));
    }
    s = buf.toString();
  } else if (s.contains('.') && endsWithZerosRegExp.hasMatch(s)) {
    s = s.substring(0, s.length - 1);
  }
  if (!_pointRegExp.hasMatch(s)) return (minus ? '-' : '') + s;
  for (var i = s.length - 1; i >= 0; i--) {
    if (s[i] == '0') continue;
    if (s[i] == '.') return (minus ? '-' : '') + s.substring(0, i);
    return (minus ? '-' : '') + s.substring(0, i + 1);
  }
  return (minus ? '-' : '') + s;
}

String sRaw(List<String> ss) {
  if (ss.length != 1) throw Exception('Raw only accepts one argument. $ss');
  return '{ ${ss[0]} }';
}

String sAdd(List<String> ss) {
  if (ss.isEmpty) return '';
  StringBuffer buf = StringBuffer();
  if (!isZero(ss[0])) buf.write(ss[0]);
  for (var s in ss.skip(1)) {
    if (isZero(s)) continue;
    if (buf.isNotEmpty && !startsWithSign(s)) buf.write('+');
    buf.write(s);
  }
  return buf.length == 0 ? '0' : buf.toString();
}

String sSub(List<String> ss) {
  if (ss.isEmpty) return '';
  StringBuffer buf = StringBuffer();
  buf.write(ss[0]);
  for (var s in ss.skip(1)) {
    if (needsPar(s))
      buf.write('-($s)');
    else
      buf.write('-$s');
  }
  return buf.toString();
}

String sMinus(List<String> ss) {
  if (ss.isEmpty) return '';
  if (ss.length > 1) throw Exception('Minus only accepts one argument. $ss');
  if (needsPar(ss[0])) return '-(${ss[0]})';
  return '-${ss[0]}';
}

String sSignIfMinus(List<String> ss) {
  if (ss.length != 2)
    throw Exception('SignIfMinus only accepts two arguments. $ss');
  if (!['-1', '1'].contains(ss[0]))
    throw Exception(
        'SignIfMinus only accepts -1, 1 as the first argument. ${ss[0]}');
  if (ss[0] == '-1') {
    if (needsPar(ss[1]))
      return '-(${ss[1]})';
    else
      return '-${ss[1]}';
  }
  return ss[1];
}

String sWithSign(List<String> ss) {
  if (ss.length != 1)
    throw Exception('WithSign only accepts one argument. $ss');
  if (startsWithSign(ss[0])) return ss[0];
  return '+${ss[0]}';
}

String sWithPar(List<String> ss) {
  if (ss.length != 1) throw Exception('WithPar only accepts one argument. $ss');
  if (enclosedWithPar(ss[0])) return ss[0];
  return '(${ss[0]})';
}

String sWithRemainder(List<String> ss) {
  if (ss.length != 2)
    throw Exception('WithRemainder only accepts two arguments. $ss');
  if (isZero(ss[1])) return ss[0];
  return '${ss[0]} \\cdots ${ss[1]}';
}

String _sTimesOrLike(List<String> ss, String command) {
  if (ss.isEmpty) return '';
  StringBuffer buf = StringBuffer();
  if (needsParHead(ss[0]))
    buf.write('(${ss[0]})');
  else
    buf.write(ss[0]);
  for (var s in ss.skip(1)) {
    buf.write(' $command ');
    if (needsPar(s))
      buf.write('($s)');
    else
      buf.write(s);
  }
  return buf.toString();
}

String sTimes(List<String> ss) => _sTimesOrLike(ss, '\\times');

String sCdot(List<String> ss) => _sTimesOrLike(ss, '\\cdot');

String sDiv(List<String> ss) => _sTimesOrLike(ss, '\\div');

String sFracRaw(List<String> ss) {
  if (ss.length != 2) throw Exception('Frac accepts only two arguments. $ss');
  return ' \\frac{ ${ss[0]} }{ ${ss[1]} } ';
}

String sFrac(List<String> ss) {
  if (ss.length != 2) throw Exception('FracR accepts only two arguments. $ss');
  if (_Monomial.isMonomial(ss[0]) && _Monomial.isMonomial(ss[1])) {
    var m0 = _Monomial(ss[0]);
    var m1 = _Monomial(ss[1]);
    String m = m0.isMinus ^ m1.isMinus ? '-' : '';
    if (m1.coeffAbs == 1 && m1.chars.trim().isEmpty) {
      return '$m${m0.coeffAbsAndChars}';
    } else if (m0.coeffAbs is int && m1.coeffAbs is int) {
      int g = gcd2(m0.coeffAbs, m1.coeffAbs);
      int j0 = m0.coeffAbs ~/ g;
      int j1 = m1.coeffAbs ~/ g;
      if (j1 == 1 && m1.chars.trim().isEmpty) {
        return '$m${m0.withCoeff(j0)}';
      }
      return '$m\\frac{ ${m0.withCoeff(j0)} }{ ${m1.withCoeff(j1)} }';
    } else {
      return '$m\\frac{ ${m0.coeffAbsAndChars}{ ${m1.coeffAbsAndChars} }';
    }
  } else if (_Monomial.isMonomial(ss[0]) || _Monomial.isMonomial(ss[1])) {
    var monoInd = _Monomial.isMonomial(ss[0]) ? 0 : 1;
    var mono = _Monomial(ss[monoInd]);
    String m = mono.isMinus ? '-' : '';
    if (monoInd == 1 && (mono.coeffAbs == 1 && mono.chars.trim().isEmpty)) {
      return '$m(${ss[0]})';
    } else if (monoInd == 0) {
      return '$m\\frac{ ${mono.coeffAbsAndChars} }{ ${ss[1]} }';
    } else {
      return '$m\\frac{ ${ss[0]} }{ ${mono.coeffAbsAndChars} }';
    }
  } else {
    return '\\frac{ ${ss[0]} }{ ${ss[1]} }';
  }
}

String sSqrt(List<String> ss) {
  if (ss.length != 1) throw Exception('Sqrt only accepts one argument. $ss');
  return '\\sqrt{ ${ss[0]} }';
}

String sAbs(List<String> ss) {
  if (ss.length != 1) throw Exception('Abs only accepts one argument. $ss');
  return '| ${ss[0]} |';
}

String sMin(List<String> ss) => 'min{ ${ss.join(' , ')} }';

String sMax(List<String> ss) => 'max{ ${ss.join(' , ')} }';

String sGcd(List<String> ss) => 'gcd( ${ss.join(' , ')} )';

String sLcm(List<String> ss) => 'lcm( ${ss.join(' , ')} )';

String sPow(List<String> ss) {
  if (ss.length != 2) throw Exception('Pow only accepts two arguments. $ss');
  String s0 = ss[0];
  String s1 = ss[1];
  if (isOne(s1)) return s0;
  if (hasMultipleFactorsOrTerms(s0) && !enclosedWithPar(s0)) s0 = '($s0)';
  return '{ $s0 }^{ $s1 }';
}

String sZero(String tex, List<String> ss) {
  if (ss.length != 0) throw Exception('$tex does not accept any argument. $ss');
  return tex;
}

String sOne(String tex, List<String> ss) {
  if (ss.length != 1) throw Exception('$tex only accepts one argument. $ss');
  return '$tex{ ${ss[0]} }';
}

String sTwoBraceLast(String tex, List<String> ss) {
  if (ss.length != 2) throw Exception('$tex only accepts two arguments. $ss');
  String s0 = ss[0];
  String s1 = ss[1];
  return '$s0 $tex {$s1}';
}

String sTwo(String tex, List<String> ss) {
  if (ss.length != 2) throw Exception('$tex only accepts two arguments. $ss');
  String s0 = ss[0];
  String s1 = ss[1];
  return '$s0 $tex $s1';
}

String sTwoBraces(String tex, List<String> ss) {
  if (ss.length != 2) throw Exception('$tex only accepts two arguments. $ss');
  String s0 = ss[0];
  String s1 = ss[1];
  return '$tex{ $s0 }{ $s1 }';
}

String sIn(List<String> ss) => sTwo(r'\in', ss);
String sNotin(List<String> ss) => sTwo(r'\notin', ss);
String sNi(List<String> ss) => sTwo(r'\ni', ss);
String sNotni(List<String> ss) => sTwo(r'\notni', ss);

String sMul(List<String> ss) {
  if (ss.length == 0) throw Exception('Mul needs one or more arguments. $ss');
  if (ss.length == 1) return ss[0];
  if (isZero(ss[0])) return ss[0];
  String s0 = ss[0];
  StringBuffer buf = StringBuffer();
  if (isOne(s0))
    buf.write(''); // write empty string.
  else if (isMinusOne(s0))
    buf.write('-');
  else if (needsParHead(s0))
    buf.write('($s0)');
  else
    buf.write(s0);
  for (var s in ss.skip(1)) {
    if (isOne(s)) continue;
    if (needsPar(s))
      buf.write('($s)');
    else if (startsWithNumeric(s) && buf.isNotEmpty)
      buf.write(' \\cdot $s ');
    else
      buf.write(s);
  }
  if (buf.isEmpty) return '1';
  return buf.toString();
}

String sSimul(List<String> ss) {
  return '''\\left\\{
\\begin{array}{l}
${ss.join('\\\\\n')}
\\end{array}
\\right.''';
}

String sLim(List<String> ss) {
  if (ss.length == 0) throw Exception('Lim needs one or more arguments.');
  StringBuffer buf = StringBuffer();
  for (var s in ss.skip(1)) buf.write(s);
  return 'lim${buf.toString()} ${ss[0]}';
}

String sInfty(List<String> ss) => sZero(r'\infty', ss);

String sTo(List<String> ss) => sTwo(r'\to', ss);

String sEqual(List<String> ss) {
  if (ss.length == 0) throw Exception('sEqual: ss.length is zero. $ss');
  StringBuffer buf = StringBuffer();
  buf.write(ss[0]);
  for (var s in ss.skip(1)) {
    buf.write(' = $s');
  }
  return buf.toString();
}

String sEquiv(List<String> ss) {
  if (ss.length == 0) throw Exception('Equiv: ss.length is zero. $ss');
  StringBuffer buf = StringBuffer();
  buf.write(ss[0]);
  for (var s in ss.skip(1)) {
    buf.write(' \\equiv $s');
  }
  return buf.toString();
}

String sLeftrightarrow(List<String> ss) {
  if (ss.length == 0) throw Exception('Leftrightarrow: ss.length is zero. $ss');
  StringBuffer buf = StringBuffer();
  buf.write(ss[0]);
  for (var s in ss.skip(1)) {
    buf.write(' \\Leftrightarrow $s');
  }
  return buf.toString();
}

String sAnd(List<String> ss) {
  return ss.join(' , ');
}

String sLet(List<String> ss) {
  if (ss.length < 2) throw Exception('Let needs two or more arguments. $ss');
  return ss.join(' ,');
}

String sRatio(List<String> ss) {
  if (ss.length < 2) throw Exception('Ratio needs two or more arguments. $ss');
  return ss.join(' : ');
}

Map<String, F> funcDirectory = {
  'add': add,
  'sub': sub,
  'mul': mul,
  'divi': divi,
  'div': divf,
  'divf': divf,
  'mod': mod,
  'pow10': pow10,
  'min': min,
  'max': max,
  'gcd': gcd,
  'lcm': lcm,
  'clcm': clcm,
  'reduce': reduce,
  'abs': abs,
  'pow': pow,
  'sqrt': sqrt,
  'sign': sign,
  'digit': digit,
};

typedef F = num Function(List<num>);

num add(List<num> a) {
  return a.fold(0, (p, e) => p + e);
}

num sub(List<num> a) {
  if (a.length < 1) throw Exception('sub needs at least one argument.');
  return a.skip(1).fold(a[0], (p, e) => p - e);
}

num mul(List<num> a) {
  return a.fold(1, (p, e) => p * e);
}

num divi(List<num> a) {
  if (a.length != 2) throw Exception('divi only accepts two arguments.');
  return a[0] ~/ a[1];
}

num divf(List<num> a) {
  if (a.length != 2) throw Exception('divf only accepts two arguments.');
  return a[0] / a[1];
}

num mod(List<num> a) {
  if (a.length != 2) throw Exception('mod only accepts two arguments.');
  return a[0] % a[1];
}

num pow10(List<num> a) {
  if (a.length != 2) throw Exception('pow10 only accepts two arguments.');
  return a[0] * math.pow(10, a[1]);
}

num min(List<num> a) {
  return a.skip(1).fold(a[0], (p, e) => e < p ? e : p);
}

num max(List<num> a) {
  return a.skip(1).fold(a[0], (p, e) => p < e ? e : p);
}

num gcd(List<num> a) {
  return a.skip(1).fold(a[0], (p, e) => gcd2(p, e));
}

int gcd2(int a, int b) {
  return a.gcd(b);
}

num lcm(List<num> a) {
  return a.skip(1).fold(a[0], (p, e) => lcm2(p, e));
}

int lcm2(int a, int b) {
  var ret = (a * b) ~/ gcd2(a, b);
  return ret < 0 ? -ret : ret;
}

num clcm(List<num> a) {
  return lcm(a) ~/ a[0];
}

num reduce(List<num> a) {
  if (a.length != 2) throw Exception('reduce only accepts two arguments. $a');
  return a[0] ~/ gcd2(a[0], a[1]);
}

num abs(List<num> a) {
  if (a.length != 1) throw Exception('abs only accepts one argument. $a');
  return a[0].abs();
}

num pow(List<num> a) {
  if (a.length != 2) throw Exception('pow only accepts two arguments.');
  return math.pow(a[0], a[1]);
}

num sqrt(List<num> a) {
  if (a.length != 1) throw Exception('sqrt only accepts one argument. $a');
  return math.sqrt(a[0]);
}

// 1 if >=0, -1 otherwise.
num sign(List<num> a) {
  if (a.length != 1) throw Exception('sign only accepts one argument. $a');
  return a[0] >= 0 ? 1 : -1;
}

num digit(List<num> a) {
  if (a.length != 2) throw Exception('digit only accepts two arguments. $a');
  return (a[0] ~/ a[1]) % 10;
}
