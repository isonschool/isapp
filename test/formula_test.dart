import 'package:isapp/formula/parser.dart';
import 'package:test/test.dart';

void main() {
  test('', () async {
    expect(() => FormulaTemplate('(2 3)').executeString({}), throwsException);
    expect(() => FormulaTemplate('(Mul 2 3) (Mul 1 3)').executeString({}),
        throwsException);
    expect(() => FormulaTemplate('(.a0 1)').executeString({'a0': 1}),
        throwsException);
    expect(FormulaTemplate('Add (* 2 3)').executeString({}), equals('3+3'));
    expect(FormulaTemplate('WithPar (WithPar (Add 2 3))').executeString({}),
        equals('(2+3)'));
    expect(FormulaTemplate('!= 1 2').executeBool({}), equals(true));
    expect(FormulaTemplate('!= 1 (gcd 2 4)').executeBool({}), equals(true));
    expect(removePointZero(0.99999999991), equals('1'));
    expect(removePointZero(-0.99999999991), equals('-1'));
    expect(removePointZero(9.99999999992), equals('10'));
    expect(removePointZero(-9.99999999992), equals('-10'));
    expect(removePointZero(1.99199999990), equals('1.992'));
    expect(removePointZero(-1.99199999990), equals('-1.992'));
    expect(removePointZero(0.00999999993), equals('0.01'));
    expect(removePointZero(-0.00999999993), equals('-0.01'));
    expect(removePointZero(2390.00999999993), equals('2390.01'));
    expect(removePointZero(-2390.00999999993), equals('-2390.01'));
    expect(removePointZero(5299.99999999990), equals('5300'));
    expect(removePointZero(-5299.99999999990), equals('-5300'));
    expect(removePointZero(0.000000001), equals('0'));
    expect(removePointZero(-0.000000001), equals('0'));
    expect(removePointZero(1200.00000002), equals('1200'));
    expect(removePointZero(-1200.00000002), equals('-1200'));
    expect(removePointZero(3.030020000000001), equals('3.03002'));
    expect(removePointZero(-3.030020000000001), equals('-3.03002'));
    expect(removePointZero(0.0010000001), equals('0.001'));
    expect(removePointZero(-0.0010000001), equals('-0.001'));
    expect(removePointZero(1000000000000000000), equals('1000000000000000000'));
    expect(FormulaTemplate('Mul 2 \'x\'').executeString({}), equals('2x'));
    expect(FormulaTemplate('Mul -2 \'x\'').executeString({}), equals('-2x'));
    expect(FormulaTemplate('Mul \'-2+3\' \'x\'').executeString({}),
        equals('(-2+3)x'));
    expect(FormulaTemplate('Mul (Add 3 4) \'x\'').executeString({}),
        equals('(3+4)x'));
    expect(FormulaTemplate('Mul (Pow 2 (Add 3 4)) \'x\'').executeString({}),
        equals('{ 2 }^{ 3+4 }x'));
    expect(FormulaTemplate(r"Mul 1 'x'").executeString({}), equals('x'));
    expect(FormulaTemplate(r"Mul -1 'x'").executeString({}), equals('-x'));
    expect(FormulaTemplate(r'Mul 2 -3').executeString({}), equals(r'2(-3)'));
    expect(FormulaTemplate(r'Pow -2 3').executeString({}),
        equals('{ (-2) }^{ 3 }'));
    expect(FormulaTemplate(r'Pow 2 (Add 3 4)').executeString({}),
        equals(r'{ 2 }^{ 3+4 }'));
    expect(FormulaTemplate(r"Sub 1 (Pow -3 2)").executeString({}),
        equals('1-{ (-3) }^{ 2 }'));
    expect(FormulaTemplate(r"Pow (Mul 8 'x') 2").executeString({}),
        equals('{ (8x) }^{ 2 }'));
    expect(FormulaTemplate(r"Div 3 (Times 1 2)").executeString({}),
        equals(r'3 \div (1 \times 2)'));
    expect(
        FormulaTemplate(r"Pow 10 2").executeString({}), equals('{ 10 }^{ 2 }'));
    expect(FormulaTemplate(r"Pow 10 (Add 2 3)").executeString({}),
        equals('{ 10 }^{ 2+3 }'));
    expect(FormulaTemplate(r"Pow (WithPar 10) 2").executeString({}),
        equals('{ (10) }^{ 2 }'));
    expect(
        FormulaTemplate(r".a0").executeString({'a0': 0.0000009}), equals('0'));
    expect(
        FormulaTemplate(r".a0").executeString({'a0': -0.0000009}), equals('0'));
    expect(FormulaTemplate(r"Frac 2 -3").executeString({}),
        equals(r'-\frac{ 2 }{ 3 }'));
    expect(FormulaTemplate(r"Frac 2 -4").executeString({}),
        equals(r'-\frac{ 1 }{ 2 }'));
    expect(FormulaTemplate(r"Frac -2 -4").executeString({}),
        equals(r'\frac{ 1 }{ 2 }'));
    expect(FormulaTemplate(r"Frac -4 -2").executeString({}), equals(r'2'));
    expect(FormulaTemplate(r"Frac 4 -2").executeString({}), equals(r'-2'));
    expect(FormulaTemplate(r"Frac (Mul 'a' 'b') -2").executeString({}),
        equals(r'-\frac{ ab }{ 2 }'));
    expect(
        FormulaTemplate(r"Frac (Mul 'a' 'b') (Mul -2 'x')").executeString({}),
        equals(r'-\frac{ ab }{ 2x }'));
    expect(FormulaTemplate(r"Frac (Mul 'a' 'b') 2").executeString({}),
        equals(r'\frac{ ab }{ 2 }'));
    expect(FormulaTemplate(r"Frac (Mul 'a' 'b') -1").executeString({}),
        equals(r'-ab'));
    expect(FormulaTemplate(r"Frac (Mul 'a' 'b') 1").executeString({}),
        equals(r'ab'));
    expect(
        FormulaTemplate(r"Frac (Mul 3 'a' 'b') (Mul -2 'x')").executeString({}),
        equals(r'-\frac{ 3ab }{ 2x }'));
    expect(
        FormulaTemplate(r"Frac (Mul 4 'a' 'b') (Mul -2 'x')").executeString({}),
        equals(r'-\frac{ 2ab }{ x }'));
    expect(
        FormulaTemplate(r"Frac (Mul 2 'a' 'b') (Mul -4 'x')").executeString({}),
        equals(r'-\frac{ ab }{ 2x }'));
    expect(
        FormulaTemplate(r"Frac (Add (Mul 2 'a' 'b') 3) (Mul -4 'x')")
            .executeString({}),
        equals(r'-\frac{ 2ab+3 }{ 4x }'));
    expect(
        FormulaTemplate(r"Frac (Add (Mul -2 'a' 'b') 3) (Add (Mul -4 'x') 4)")
            .executeString({}),
        equals(r'\frac{ -2ab+3 }{ -4x+4 }'));
    expect(FormulaTemplate(r"Frac 2 'x'").executeString({}),
        equals(r'\frac{ 2 }{ x }'));
    expect(FormulaTemplate(r".a0").executeString({'a0': -0.02000000000000001}),
        equals(r'-0.02'));
  });
}

num min(num a, num b) {
  return a < b ? a : b;
}
