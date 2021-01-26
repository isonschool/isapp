import 'dart:math' as math;

import 'parser.dart';

var rand = math.Random(DateTime.now().millisecondsSinceEpoch);

bool ordered(String p) => p.contains('o');

bool reversed(String p) => p.contains('r');

String changeVar(String p) {
  var ind = p.indexOf('-');
  if (ind < 0) {
    return p;
  }
  return p.substring(0, ind);
}

int numCompare(num a, num b) =>
    math.max(a, b) - math.min(a, b) < 0.000001 ? 0 : (a > b ? 1 : -1);

Relation numCompareToRelation(num a, num b) {
  switch (numCompare(a, b)) {
    case 0:
      return Relation.equal;
    case 1:
      return Relation.greaterThan;
    default:
      return Relation.lessThan;
  }
}

int calcsCompare(List<num> a, List<num> b) {
  if (a.length != 1 || b.length != 1) {
    throw Exception("length should be 1. a: $a, b: $b");
  }
  return numCompare(a[0], b[0]);
}

Relation calcsCompareToRelation(List<num> a, List<num> b) {
  if (a.length != 1 || b.length != 1) {
    throw Exception("length should be 1. a: $a, b: $b");
  }
  return numCompareToRelation(a[0], b[0]);
}

bool calcsEqual(List<num> a, List<num> b) {
  for (var i = 0; i < a.length; i++) {
    if (numCompare(a[i], b[i]) != 0) {
      return false;
    }
  }
  return true;
}

class Mth {
  final String skey;
  final String relationTex;
  final Map<String, Generator> generators;
  Prob generatorProb;

  Mth({
    this.skey,
    this.relationTex,
    this.generators,
  }) : generatorProb = Prob(generators.keys) {
    Map<String, Generator> newGenerators = {};
    for (var gkey in generators.keys) {
      if (gkey.contains("'")) {
        var baseGkey = gkey.replaceAll("'", "");
        newGenerators[gkey] = generators[baseGkey]
            .copyWith(gkey, generators[gkey].expressions.first.constraints);
      }
    }
    for (var gkey in newGenerators.keys) {
      generators[gkey] = newGenerators[gkey];
    }
  }

  Mth.fromJson(String skey, Map<String, dynamic> json)
      : this(
          skey: skey,
          relationTex: json['relationTex'],
          generators: (json['generators'] as Map<String, dynamic>)
              .map((k, v) => MapEntry(k, Generator.fromJson(skey, k, v))),
        );

  //@override
  //String toString() =>
  //    'Mth{generators: $generators, generatorProb: $generatorProb}';

  void check() {
    for (var g in generators.values) {
      List<String> acceptableVarNames = [];
      for (var c in g.expressions.first.constraints) {
        c.calTemplate.checkVarName(acceptableVarNames);
        c.calTemplate.checkFunc();
        c.choiceTemplates.forEach((element) {
          element.checkVarName(acceptableVarNames);
          element.checkFunc();
        });
        c.exceptTemplates.forEach((element) {
          element.checkVarName(acceptableVarNames);
          element.checkFunc();
        });
        c.maxTemplate.checkVarName(acceptableVarNames);
        c.minTemplate.checkFunc();
        acceptableVarNames.add(c.varName);
      }
      g.expressions.first.ignore.checkVarName(acceptableVarNames);
      g.expressions.first.ignore.checkFunc();
      var currentVarNames =
          g.expressions.first.constraints.map((c) => c.varName).toList();
      g.expressions.first.templates
          .forEach((t) => t.checkVarName(currentVarNames));
      g.expressions.first.templates.forEach((t) => t.checkFunc());
      g.expressions.first.calcs.forEach((c) => c.checkVarName(currentVarNames));
      g.expressions.first.calcs.forEach((c) => c.checkFunc());
      for (var e in g.expressions.skip(1)) {
        var currentVarNames = e.constraints.map((c) => c.varName).toList();
        e.templates.forEach((t) => t.checkVarName(currentVarNames));
        e.templates.forEach((t) => t.checkFunc());
        e.calcs.forEach((c) => c.checkVarName(currentVarNames));
        e.calcs.forEach((c) => c.checkFunc());
        List<String> vns = [];
        for (var c in e.constraints) {
          c.calTemplate.checkVarName(acceptableVarNames);
          c.calTemplate.checkFunc();
          c.wrongCalTemplates.forEach((e) {
            e.checkVarName(acceptableVarNames);
            e.checkFunc();
          });
          c.choiceTemplates.forEach((e) {
            e.checkVarName(acceptableVarNames);
            e.checkFunc();
          });
          c.exceptTemplates.forEach((e) {
            e.checkVarName([...vns, ...acceptableVarNames]);
            e.checkFunc();
          });
          c.maxTemplate.checkVarName(acceptableVarNames);
          c.maxTemplate.checkFunc();
          c.minTemplate.checkVarName(acceptableVarNames);
          c.minTemplate.checkFunc();
          vns.add(c.varName);
        }
        e.ignore.checkVarName([
          ...acceptableVarNames,
          ...e.constraints.map((c) => c.varName),
        ]);
        e.ignore.checkFunc();
        acceptableVarNames = e.constraints.map((c) => c.varName).toList();
      }
    }

    for (var g in generators.values) {
      g.checkGenerateTex();
    }

    int lessonOK = 0;
    int examOK = 0;
    int diplomaOK = 0;
    const int tryNum = 1000;
    const num okProp = 0.99;
    for (var i = 0; i < tryNum; i++) {
      var g = generators[generatorProb.choose()];
      var lessonTex = g.generateLessonTex();
      if (lessonTex != null) {
        lessonOK++;
      }
      var examTex = g.generateExamTex();
      if (examTex != null) {
        examOK++;
      }
      var diplomaTex = g.generateDiplomaTex();
      if (diplomaTex != null) {
        diplomaOK++;
      }
    }
    if (lessonOK < tryNum * okProp)
      throw Exception('hard to make lesson $lessonOK, $this');
    if (examOK < tryNum * okProp)
      throw Exception('hard to make exam $examOK, $this');
    if (diplomaOK < tryNum * okProp)
      throw Exception('hard to make diploma $diplomaOK, $this');
  }

  String makeSampleTex() {
    var g = generators[generatorProb.choose()];
    for (var j = 0; j < 1000; j++) {
      var t = g.generateSampleTex();
      if (t != null) {
        var relationTex = relationTexConvert(g.relationTex ?? this.relationTex);
        return '${t.problemTex} $relationTex ${t.answerTex}';
      }
    }
    throw 'cannot make sample tex. $this';
  }

  List<String> makeCalTexs(int n) {
    List<String> ret = [];
    for (var i = 0; i < n; i++) {
      List<String> tmp = [];
      var g = generators[generatorProb.choose()];
      for (var j = 0; j < 1000; j++) {
        var eq = g.generateCalTex();
        if (eq != null) {
          var relationTex =
              relationTexConvert(g.relationTex ?? this.relationTex);
          for (var i = 1; i < eq.length; i++) {
            eq[i] = '$relationTex ${eq[i]}';
          }
          if (tmp.isEmpty) {
            tmp.addAll(eq);
          } else {
            for (var i = 0; i < eq.length; i++) {
              if (tmp[i].length < eq[i].length) {
                tmp[i] = eq[i];
              }
            }
          }
        }
      }
      ret.addAll(tmp);
    }
    return ret;
  }

  List<LessonTex> makeLessonTexs(int n) {
    List<LessonTex> ret = [];
    for (var i = 0; i < n * 10; i++) {
      var g = generators[generatorProb.choose()];
      var eq = g.generateLessonTex();
      if (eq != null) {
        eq.relationTex = relationTexConvert(g.relationTex ?? this.relationTex);
        ret.add(eq);
        if (ret.length == n) {
          return ret;
        }
      }
    }
    print("makeLessonTexs: Cannot make required number of equations.");
    return null;
  }

  List<ExamTex> makeExamTexs(int n) {
    print('makeExamTexs n:$n');
    List<ExamTex> ret = [];
    for (var i = 0; i < n * 10; i++) {
      var g = generators[generatorProb.choose()];
      var eq = g.generateExamTex();
      print(eq);
      if (eq != null) {
        eq.relationTex = relationTexConvert(g.relationTex ?? relationTex);
        ret.add(eq);
        if (ret.length == n) {
          print('makeExamTexs return ret:$ret');
          return ret;
        }
      }
    }
    print("makeExamTexs: Cannot make required number of equations.");
    return null;
  }

  List<DiplomaTex> makeDiplomaTexs(int n) {
    List<DiplomaTex> ret = [];
    for (var i = 0; i < n * 10; i++) {
      var g = generators[generatorProb.choose()];
      var eq = g.generateDiplomaTex();
      if (eq != null) {
        eq.relationTex = relationTexConvert(g.relationTex ?? relationTex);
        ret.add(eq);
        if (ret.length == n) {
          return ret;
        }
      }
    }
    print("makeDiplomaTexs: Cannot make required number of equations.");
    return null;
  }
}

class Expression {
  final String skey;
  final String gkey;
  final List<FormulaTemplate> templates;
  final List<Constraint> constraints;
  final List<FormulaTemplate> calcs;
  final FormulaTemplate ignore;
  final Prob prob;

  Expression({
    this.skey,
    this.gkey,
    this.templates,
    this.constraints,
    this.calcs,
    this.ignore,
  }) : prob = Prob(constraints
            .where((c) => c.wrongCalTemplates.isNotEmpty)
            .map((c) => c.varName)) {
    if (!gkey.contains("'") && templates.isEmpty)
      throw Exception('$skey, $gkey has empty template.');
  }

  Expression.fromJson(String skey, String gkey, Map<String, dynamic> json,
      Map<String, dynamic> lastJson)
      : this(
            gkey: gkey,
            skey: skey,
            templates: (json['template'] as String ?? '')
                .split(';')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .map((e) => FormulaTemplate(e, skey: skey))
                .toList(),
            constraints: (json['constraints'] as List)
                .map((e) => Constraint.fromJson(
                    skey,
                    gkey,
                    e,
                    lastJson == null
                        ? []
                        : (lastJson['constraints'] as List)
                            .map((l) => l['var'] as String)
                            .toList(),
                    json['wrongCals']))
                .toList(),
            calcs: (json['calcs'] as String ?? '')
                .split(';')
                .where((e) => e.isNotEmpty)
                .map((e) => FormulaTemplate(e, skey: skey))
                .toList(),
            ignore: FormulaTemplate(json['ignore'], skey: skey));

  @override
  String toString() {
    return 'Expression{templates: $templates, constraints: $constraints, calcs: $calcs}';
  }

  FormulaTemplate templateAt(int i) => templates[i % templates.length];
}

String relationTexConvert(String s) {
  if (s == null)
    return ' = ';
  else if (s == 'Equiv')
    return '\\Leftrightarrow';
  else if (s == 'Equal') return ' = ';
  return s;
}

class _WithLast {
  Map<String, dynamic> last;
  Map<String, dynamic> current;
  _WithLast(this.last, this.current);
}

class Generator {
  final String skey;
  final String gkey;
  final String relationTex;
  final List<Expression> expressions;
  final Prob _prob;
  final int _maxTemplatesLength;
  ProbN _templateProbN;
  Map<String, dynamic> json;

  @override
  String toString() => 'Generator{expressions: $expressions}';

  Generator({
    this.skey,
    this.gkey,
    this.relationTex,
    this.expressions,
    this.json,
  })  : _prob = Prob(expressions
            .skip(1)
            .expand((e) => e.constraints)
            .where((c) => c.wrongCalTemplates.isNotEmpty)
            .map((c) => c.varName)),
        _maxTemplatesLength = expressions
            .map((e) => e.templates.length)
            .reduce((v, e) => v > e ? v : e) {
    _templateProbN = ProbN(_maxTemplatesLength);
  }

  Generator.fromJson(
    String skey,
    String gkey,
    Map<String, dynamic> json,
  ) : this(
          skey: skey,
          gkey: gkey,
          relationTex: json['relationTex'],
          expressions: (json['expressions'] as List)
              .fold(
                  <_WithLast>[],
                  (List<_WithLast> previousValue, e) => <_WithLast>[
                        ...previousValue,
                        _WithLast(
                            previousValue.isEmpty
                                ? null
                                : previousValue.last.current,
                            e)
                      ])
              .map((e) => Expression.fromJson(skey, gkey, e.current, e.last))
              .toList(),
          json: json,
        );

  Generator copyWith(String gkey, List<Constraint> constraints) {
    var g = Generator.fromJson(skey, gkey, json);
    g.expressions.first.constraints
      ..clear()
      ..addAll(constraints);
    return g;
  }

  Map<String, num> getCorrectValueMap() {
    for (var i = 0; i < 10; i++) {
      Map<String, num> m = {};
      bool ok = true;
      for (var e in expressions) {
        for (var c in e.constraints) {
          try {
            var v = c.getCorrectValue(m);
            if (v == null) {
              return null;
            }
            m[c.varName] = v;
          } catch (ex) {
            print(c);
            rethrow;
          }
        }
        if (e.ignore.executeBool(m)) {
          //print('${e.ignore.template} is true.');
          ok = false;
          break;
        }
      }
      if (ok) return m;
    }
    print('$skey, $gkey, ignore is true for 10 times consecutive.');
    return null;
  }

  void checkGenerateTex() {
    Map<String, num> m;
    for (var i = 0; i < 10; i++) {
      m = getCorrectValueMap();
      if (m != null) break;
    }
    if (m == null) throw Exception('hard to make correctValueMap. $this');
    var firstCalcs =
        expressions.first.calcs.map((e) => e.executeNum(m)).toList();
    for (var e in expressions.skip(1)) {
      var c = e.calcs.map((e) => e.executeNum(m)).toList();
      if (!calcsEqual(firstCalcs, c))
        throw Exception(
            '$skey, $gkey, not equal calcs. $firstCalcs, $c, ${e.templates.first.template}, $m');
    }
  }

  List<String> generateCalTex() {
    int templateIndex = _templateProbN.choose();
    var m = getCorrectValueMap();
    if (m == null) {
      return null;
    }
    Map<String, num> wrongValues = {};
    Map<String, String> wrongVarNames = {};
    for (var e in expressions.skip(1)) {
      var n = e.prob.choose();
      wrongVarNames[e.templateAt(templateIndex).template] = n;
      bool ok = false;
      for (var k = 0; k < 10; k++) {
        for (var f in e.constraints) {
          if (f.varName == n) {
            var wrongValue = f.getWrongValue(m[n], m);
            if (wrongValue == null) return null;
            wrongValues[n] = wrongValue;
          }
        }
        if (!e.ignore.executeBool(
            m.map((k, v) => MapEntry(k, k == n ? wrongValues[n] : v)))) {
          ok = true;
          break;
        }
      }
      if (!ok) {
        print(
            '$skey, $gkey, ignore 10 times true. wrongVarName: $n, wrongValue: ${wrongValues[n]}, $m');
        return null;
      }
    }
    var mw = m.map(
        (k, v) => MapEntry(k, wrongValues.containsKey(k) ? wrongValues[k] : v));

    var correctTex = expressions
        .map((e) => e.templateAt(templateIndex).executeString(m))
        .toList();
    var wrongTex = expressions
        .map((e) => e.templateAt(templateIndex).executeString(mw))
        .toList();

    List<String> lines = [];
    for (var i = 0; i < correctTex.length; i++) {
      lines.add(correctTex[i].length > wrongTex[i].length
          ? correctTex[i]
          : wrongTex[i]);
    }
    return lines;
  }

  LessonTex generateLessonTex() {
    int templateIndex = _templateProbN.choose();
    var m = getCorrectValueMap();
    if (m == null) {
      return null;
    }
    Map<String, num> wrongValues = {};
    Map<String, String> wrongVarNames = {};
    for (var e in expressions.skip(1)) {
      var n = e.prob.choose();
      wrongVarNames[e.templateAt(templateIndex).template] = n;
      bool ok = false;
      for (var k = 0; k < 10; k++) {
        for (var f in e.constraints) {
          if (f.varName == n) {
            var wrongValue = f.getWrongValue(m[n], m);
            if (wrongValue == null) return null;
            wrongValues[n] = wrongValue;
          }
        }
        if (!e.ignore.executeBool(
            m.map((k, v) => MapEntry(k, k == n ? wrongValues[n] : v)))) {
          ok = true;
          break;
        }
      }
      if (!ok) {
        print(
            '$skey, $gkey, ignore 10 times true. wrongVarName: $n, wrongValue: ${wrongValues[n]}, $m');
        return null;
      }
    }
    var mw = m.map(
        (k, v) => MapEntry(k, wrongValues.containsKey(k) ? wrongValues[k] : v));

    for (var e in expressions.skip(1)) {
      var correctCalcsResult = e.calcs.map((e) => e.executeNum(m)).toList();
      var wrongCalcsResult = e.calcs.map((e) => e.executeNum(mw)).toList();
      // 間違いの式の答も計算結果が同じなら，この問題は成り立たない。
      if (calcsEqual(correctCalcsResult, wrongCalcsResult)) {
        print(
            '$skey, $gkey, calcsEqual ${wrongVarNames[e.templateAt(templateIndex).template]}, correctCalcsResult: $correctCalcsResult, wrongCalcsResult: $wrongCalcsResult, correct: ${m[wrongVarNames[e.templateAt(templateIndex).template]]} wrong: ${mw[wrongVarNames[e.templateAt(templateIndex).template]]} m:$m, mw:$mw');
        return null;
      }
    }

    var correctTex = expressions
        .map((e) => e.templateAt(templateIndex).executeString(m))
        .toList();
    var wrongTex = expressions
        .map((e) => e.templateAt(templateIndex).executeString(mw))
        .toList();

    List<TexLine> lines = [];
    for (var i = 0; i < correctTex.length; i++) {
      if (i > 0 &&
          i < correctTex.length - 1 &&
          correctTex[i + 1] == correctTex[i]) continue;
      lines.add(TexLine(
        correctTex: correctTex[i],
        wrongTex: wrongTex[i],
        isCorrectFirst: rand.nextBool(),
      ));
    }
    return LessonTex(lines: lines);
  }

  // 正解と，間違いの選択肢
  ExamTex generateExamTex() {
    int templateIndex = _templateProbN.choose();
    String wrongVarName = _prob.choose();
    Map<String, num> m;
    Map<String, num> mw;
    int wrongLineNo;
    bool ok;
    for (var n = 0; n < 10; n++) {
      m = {};
      mw = {};
      wrongLineNo = 0;
      ok = true;
      for (var i = 0; i < expressions.length; i++) {
        var e = expressions[i];
        for (var c in e.constraints) {
          var v = c.getCorrectValue(m);
          if (v == null) {
            print('cannot make correctValueMap');
            return null;
          }
          var vw = v;
          if (c.varName == wrongVarName) {
            vw = c.getWrongValue(v, m);
            wrongLineNo = i;
          } else if (wrongLineNo > 0) {
            vw = c.getCorrectValue(mw);
          }
          if (vw == null) {
            //print('cannot make wrongValueMap');
            return null;
          }
          m[c.varName] = v;
          mw[c.varName] = vw;
        }
        if (e.ignore.executeBool(m) || e.ignore.executeBool(mw)) {
          ok = false;
          break;
        }
      }
      if (ok) break;
    }
    if (!ok) {
      print('$skey, $gkey, ignore occurs 10 times consecutive. $m');
      return null;
    }

    var correctCalcsResult =
        expressions.last.calcs.map((e) => e.executeNum(m)).toList();
    var wrongCalcsResult =
        expressions.last.calcs.map((e) => e.executeNum(mw)).toList();
    // 間違いの式の答も計算結果が同じなら，この問題は成り立たない。
    if (calcsEqual(correctCalcsResult, wrongCalcsResult)) {
      print(
          '$skey, $gkey, calcsEqual wrongVarName: $wrongVarName m:${m[wrongVarName]} $correctCalcsResult, mw:${mw[wrongVarName]} $wrongCalcsResult, $m');
      return null;
    }

    List<int> questionLineNos = [0, expressions.length - 1];
    if (!questionLineNos.contains(wrongLineNo))
      questionLineNos.add(wrongLineNo);
    while (questionLineNos.length < 5 &&
        questionLineNos.length < expressions.length) {
      var k = rand.nextInt(expressions.length);
      if (!questionLineNos.contains(k)) {
        questionLineNos.add(k);
      }
    }
    questionLineNos.sort();
    for (var i = 1; i < questionLineNos.length - 1; i++) {
      var sameWithNext = (expressions[questionLineNos[i]]
                  .templateAt(templateIndex)
                  .executeString(m) ==
              expressions[questionLineNos[i + 1]]
                  .templateAt(templateIndex)
                  .executeString(m)) ||
          (expressions[questionLineNos[i]]
                  .templateAt(templateIndex)
                  .executeString(mw) ==
              expressions[questionLineNos[i + 1]]
                  .templateAt(templateIndex)
                  .executeString(mw));
      if (questionLineNos[i] == wrongLineNo) {
        if (sameWithNext) {
          questionLineNos.remove(wrongLineNo);
          wrongLineNo++;
          if (!questionLineNos.contains(wrongLineNo)) {
            questionLineNos.insert(i, wrongLineNo);
            i--;
          }
        }
        continue;
      }
      if (sameWithNext) {
        questionLineNos.removeAt(i);
        i--;
      }
    }

    List<String> correctTex = [];
    List<String> wrongTex = [];
    for (var i = 0; i < expressions.length; i++) {
      if (!questionLineNos.contains(i)) continue;
      correctTex.add(expressions[i].templateAt(templateIndex).executeString(m));
      wrongTex.add(expressions[i].templateAt(templateIndex).executeString(mw));
    }
    var isCorrect = rand.nextBool();

    var wrongNoDraft = questionLineNos.indexOf(wrongLineNo);
    assert(wrongNoDraft > 0);
    return ExamTex(
      tex: isCorrect ? correctTex : wrongTex,
      correctTex: correctTex,
      wrongNo: isCorrect ? -1 : wrongNoDraft,
    );
  }

  Map<String, num> copyMap(Map<String, num> m) {
    Map<String, num> ret = {};
    for (var k in m.keys) {
      ret[k] = m[k];
    }
    return ret;
  }

  DiplomaTex generateDiplomaTex() {
    int templateIndex = _templateProbN.choose();
    const int listLength = 20;

    List<String> wrongVarNames = [null];
    for (var i = 1; i < listLength; i++) {
      wrongVarNames.add(_prob.choose());
    }

    Map<String, num> _m = getCorrectValueMap();
    if (_m == null) return null;
    List<Map<String, num>> ms = [_m];
    for (var i = 1; i < listLength; i++) {
      ms.add(copyMap(_m));
    }
    var ignoreInds = List<bool>.filled(listLength, false);
    for (var i = 1; i < expressions.length; i++) {
      var e = expressions[i];
      for (var c in e.constraints) {
        for (var k = 0; k < listLength; k++) {
          if (ignoreInds[k]) continue;
          var v = c.getCorrectValue(ms[k]);
          if (c.varName == wrongVarNames[k]) {
            v = c.getWrongValue(v, ms[k]);
          }
          if (v == null) {
            //print(
            //    'returned null in getCorrectValue or getWrongValue. ${ms[k]}');
            return null;
          }
          ms[k][c.varName] = v;
        }
      }
      for (var k = 0; k < listLength; k++) {
        if (ignoreInds[k] == false && e.ignore.executeBool(ms[k])) {
          ignoreInds[k] = true;
        }
      }
    }
    if (ignoreInds[0]) return null;
    List<List<num>> calcsResult = [];
    for (var k = 0; k < listLength; k++) {
      if (ignoreInds[k])
        calcsResult.add(null);
      else
        calcsResult.add(
            expressions.last.calcs.map((e) => e.executeNum(ms[k])).toList());
    }
    var inds = [0];
    for (var i = 1; i < listLength; i++) {
      if (calcsResult[i] == null) continue;
      bool ok = true;
      for (var ind in inds) {
        if (calcsEqual(calcsResult[ind], calcsResult[i])) {
          ok = false;
          break;
        }
      }
      if (ok) {
        inds.add(i);
      }
    }

    var texs = inds
        .map((i) => expressions
            .map((e) => e.templateAt(templateIndex).executeString(ms[i]))
            .toList())
        .take(4)
        .toList();

    if (texs.length < 3) {
      print('$skey, $gkey, cannot make 2 wrong answers. $texs');
      return null;
    }

    var correctTex = texs[0].last;
    var problemTex = texs[0][0];
    var answerTexs = texs.map((t) => t.last).toList()..shuffle(rand);
    var correctAnswerNo = answerTexs.indexOf(correctTex);
    assert(correctAnswerNo >= 0);
    return DiplomaTex(
      problemTex: problemTex,
      answerTexs: answerTexs,
      correctAnswerNo: correctAnswerNo,
    );
  }

  SampleTex generateSampleTex() {
    int templateIndex = _templateProbN.choose();

    Map<String, num> _m = getCorrectValueMap();
    if (_m == null) return null;
    for (var i = 1; i < expressions.length; i++) {
      var e = expressions[i];
      for (var c in e.constraints) {
        var v = c.getCorrectValue(_m);
        if (v == null) return null;
        _m[c.varName] = v;
      }
    }
    var texs = expressions
        .map((e) => e.templateAt(templateIndex).executeString(_m))
        .toList();

    return SampleTex(
      problemTex: texs.first,
      answerTex: texs.last,
    );
  }
}

class Prob {
  final List<String> keys;
  final List<String> _notUsedKeys;

  @override
  String toString() {
    return 'Prob{keys: $keys, _notUsedKeys: $_notUsedKeys}';
  }

  Prob(Iterable<String> keys)
      : keys = keys.toList(),
        _notUsedKeys = keys.toList();

  String choose() {
    if (_notUsedKeys.isEmpty) {
      _notUsedKeys.addAll(keys);
    }
    var r = rand.nextInt(_notUsedKeys.length);
    return _notUsedKeys.removeAt(r);
  }

  String chooseRandom() {
    return keys[rand.nextInt(keys.length)];
  }
}

class ProbN {
  final int maxN;
  final List<int> _notUsedNs;

  @override
  String toString() {
    return 'ProbN{maxN: $maxN, _notUsedNs: $_notUsedNs}';
  }

  ProbN(this.maxN) : _notUsedNs = [] {
    for (var i = 0; i < maxN; i++) _notUsedNs.add(i);
  }

  int choose() {
    if (_notUsedNs.isEmpty) {
      for (var i = 0; i < maxN; i++) _notUsedNs.add(i);
    }
    var r = rand.nextInt(_notUsedNs.length);
    return _notUsedNs.removeAt(r);
  }

  int chooseRandom() {
    return rand.nextInt(maxN);
  }
}

class TexLine {
  final String correctTex;
  final String wrongTex;
  final bool isCorrectFirst;

  TexLine({this.correctTex, this.wrongTex, this.isCorrectFirst});

  @override
  String toString() {
    return 'TexLine{correctTex: $correctTex, wrongTex: $wrongTex, isCorrectFirst: $isCorrectFirst}';
  }

  String choice(int i) => isCorrectFirst == (i == 0) ? correctTex : wrongTex;
  bool isCorrect(int i) => isCorrectFirst == (i == 0);
}

class LessonTex {
  final List<TexLine> lines;
  String relationTex;

  LessonTex({this.lines, this.relationTex});

  @override
  String toString() {
    return 'LessonTex{lines: $lines, relationTex: $relationTex}';
  }
}

class ExamTex {
  final List<String> tex;
  final List<String> correctTex;
  final int wrongNo;
  String relationTex;

  ExamTex({
    this.tex,
    this.correctTex,
    this.wrongNo,
    this.relationTex,
  });

  @override
  String toString() {
    return 'ExamTex{tex: $tex, correctTex: $correctTex, wrongNo: $wrongNo, relationTex: $relationTex}';
  }
}

class DiplomaTex {
  final String problemTex;
  final List<String> answerTexs;
  final int correctAnswerNo;
  String relationTex;

  DiplomaTex({
    this.problemTex,
    this.answerTexs,
    this.correctAnswerNo,
    this.relationTex,
  });

  @override
  String toString() {
    return 'DiplomaTex{problemTex: $problemTex, answerTexs: $answerTexs, correctAnswerNo: $correctAnswerNo, relationTex: $relationTex}';
  }
}

class SampleTex {
  final String problemTex;
  final String answerTex;
  String relationTex;

  SampleTex({
    this.problemTex,
    this.answerTex,
    this.relationTex,
  });

  @override
  String toString() {
    return 'SampleTex{problemTex: $problemTex, answerTex: $answerTex, relationTex: $relationTex}';
  }
}

class Pair {
  final num m;
  final num n;
  Pair(this.m, this.n);
}

var coprimes = [
  Pair(1, 2),
  Pair(1, 3),
  Pair(1, 4),
  Pair(1, 5),
  Pair(1, 6),
  Pair(1, 7),
  Pair(1, 8),
  Pair(1, 9),
  Pair(1, 10),
  Pair(2, 3),
  Pair(2, 5),
  Pair(2, 7),
  Pair(2, 9),
  Pair(3, 4),
  Pair(3, 5),
  Pair(3, 7),
  Pair(3, 8),
  Pair(3, 10),
  Pair(4, 5),
  Pair(4, 7),
  Pair(4, 9),
  Pair(5, 6),
  Pair(5, 7),
  Pair(5, 8),
  Pair(5, 9),
  Pair(6, 7),
  Pair(7, 8),
  Pair(7, 9),
  Pair(7, 10),
  Pair(8, 9),
  Pair(9, 10)
];

class Constraint {
  final String skey;
  final String gkey;
  final String varName;
  final FormulaTemplate minTemplate;
  final FormulaTemplate maxTemplate;
  final List<FormulaTemplate> exceptTemplates;
  final FormulaTemplate calTemplate;
  final List<FormulaTemplate> choiceTemplates;
  final List<FormulaTemplate> wrongCalTemplates;
  final FormulaTemplate predTemplate;
  int wrongCalTemplatesIndex = 0;
  int choiceTemplatesIndex = 0;

  @override
  String toString() =>
      'Constraint{varName: $varName, minTemplate: $minTemplate, maxTemplate: $maxTemplate, exceptTemplates: $exceptTemplates, calTemplate: $calTemplate, choiceTemplates: $choiceTemplates, wrongCalTemplates: $wrongCalTemplates}';

  Constraint({
    this.skey,
    this.gkey,
    this.varName,
    String min,
    String max,
    String excepts,
    String cal,
    String choices,
    String wrongCals,
    String pred,
    List<String> lastVarNames,
  })  : minTemplate = FormulaTemplate(min, skey: skey),
        maxTemplate = FormulaTemplate(max, skey: skey),
        exceptTemplates = excepts
                ?.split(';')
                ?.where((e) => e.trim().isNotEmpty)
                ?.map((e) => FormulaTemplate(e, skey: skey))
                ?.toList() ??
            [],
        calTemplate = FormulaTemplate(cal, skey: skey),
        choiceTemplates = choices
                ?.split(';')
                ?.where((e) => e.trim().isNotEmpty)
                ?.map((e) => FormulaTemplate(e, skey: skey))
                ?.toList() ??
            [],
        wrongCalTemplates = (wrongCals ?? '')
            .split(';')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .where((e) => e != cal.trim())
            .map((e) => e.replaceAll(r'$cal',
                cal.trim().contains(' ') ? '(${cal.trim()})' : cal.trim()))
            .expand((e) => e.contains(r'$varss')
                ? lastVarNames
                    .map((l) => e.replaceAll(r'$varss', '.$l'))
                    .toList()
                : [e])
            .expand((e) => e.contains(r'$vars')
                ? lastVarNames
                    .map((l) => e.replaceAll(r'$vars', '.$l'))
                    .toList()
                : [e])
            .map((e) => FormulaTemplate(e, skey: skey))
            .toList()
              ..shuffle(rand),
        predTemplate = FormulaTemplate(pred, skey: skey);

  Constraint.fromJson(String skey, String gkey, Map<String, dynamic> json,
      List<String> lastVarNames, String baseWrongCals)
      : this(
          skey: skey,
          gkey: gkey,
          varName: json['var'],
          min: "${json['min'] ?? ''}",
          max: "${json['max'] ?? ''}",
          excepts: "${json['excepts'] ?? ''}",
          cal: "${json['cal'] ?? ''}",
          choices: "${json['choices'] ?? ''}",
          wrongCals: "${json['wrongCals'] ?? baseWrongCals ?? ''}",
          pred: json['pred'],
          lastVarNames: lastVarNames,
        );

  num getCorrectValue(Map<String, num> m) {
    if (!calTemplate.isEmpty) {
      num val = calTemplate.executeNum(m);
      if (!isIn(val, m)) {
        print(
            '$skey, $gkey, $varName, getCorrectValue: calTemplate を使ったが， isIn ではなかった。 val: $val, calTemplate: ${calTemplate.toString()}, m: $m');
        return null;
      }
      return val;
    } else if (choiceTemplates.isNotEmpty) {
      choiceTemplates.shuffle(rand);
      for (var i = 0; i < choiceTemplates.length; i++) {
        var val =
            choiceTemplates[(choiceTemplatesIndex + i) % choiceTemplates.length]
                .executeNum(m);
        if (isIn(val, m)) {
          choiceTemplatesIndex =
              (choiceTemplatesIndex + i + 1) % choiceTemplates.length;
          return val;
        }
      }
      print(
          'choiceTemplates を使ったが，どれも isIn ではなかった。 choiceTemplates: ${choiceTemplates.toString()}, m: $m');
      return null;
    }
    num min = minTemplate.executeNum(m);
    num max = maxTemplate.executeNum(m);
    var a = [];
    for (var i = min; i <= max; i++) {
      a.add(i);
    }
    a.shuffle(rand);
    for (var val in a) {
      if (isIn(val, m)) {
        return val;
      }
    }
    print('min, max を使ったが，どれも isIn ではなかった。 min: $min, max: $max, m: $m');
    return null;
  }

  num getWrongValue(num correctVal, Map<String, num> m, {num except}) {
    wrongCalTemplates.shuffle(rand);
    for (var i = 0; i < wrongCalTemplates.length; i++) {
      num r = wrongCalTemplates[i].executeNum(m);
      if (numCompare(r, correctVal) != 0 &&
          (except == null || numCompare(except, r) != 0) &&
          isIn(r, m)) {
        return r;
      }
    }
    print(
        '$skey, $gkey, cannot getWrongValue. varName: $varName, correctVal:$correctVal, m:$m, except:$except');
    return null;
  }

  bool isIn(num n, Map<String, num> m) {
    if (!predTemplate.isEmpty) {
      m['this'] = n;
      if (!predTemplate.executeBool(m)) {
        m.remove('this');
        return false;
      }
      m.remove('this');
    }
    for (var e in exceptTemplates) {
      if (numCompare(e.executeNum(m), n) == 0) {
        return false;
      }
    }
    return (minTemplate.isEmpty || minTemplate.executeNum(m) <= n) &&
        (maxTemplate.isEmpty || n <= maxTemplate.executeNum(m));
  }
}

enum Relation { equal, greaterThan, lessThan }
