import 'dart:convert';
import 'dart:io';

void main() {
  parseIntl();
}

void parseIntl() {
  var txt = File('config/intl.txt').readAsStringSync();
  var lines = txt.split('\n');
  var keys = lines[0].split('\t').map((e) => e.trim()).toList();
  for (var line in lines.skip(1)) {
    var terms = line.split('\t').map((e) => e.trim()).toList();
    var langCode = terms[0];
    if (langCode == 'en') continue;
    var m = Map<String, dynamic>();
    m["@@locale"] = langCode;
    for (var i = 1; i < terms.length; i++) {
      if (keys[i].isEmpty) continue;
      m[keys[i]] = toUpperFirst(terms[i]);
      m["@" + keys[i]] = {};
    }
    var j = jsonEncode(m);
    File('lib/l10n/app_$langCode.arb').writeAsStringSync(j);
  }
  var hans = File('lib/l10n/app_zh_Hans.arb').readAsStringSync();
  var zh = hans.replaceFirst('"zh_Hans"', '"zh"');
  File('lib/l10n/app_zh.arb').writeAsStringSync(zh);
}

String toUpperFirst(String s) {
  StringBuffer buf = StringBuffer();
  buf.write(String.fromCharCode(s.runes.first).toUpperCase());
  for (var rune in s.runes.skip(1)) {
    buf.write(String.fromCharCode(rune));
  }
  return buf.toString();
}
