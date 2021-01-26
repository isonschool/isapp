import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:isapp/models/config_models.dart';
import 'package:yaml/yaml.dart';

List<String> pkeys = [];

void main(List<String> arguments) {
  final parser = ArgParser()
    ..addOption('ckey')
    ..addOption('skey')
    ..addFlag('no-check')
    ..addFlag('update-dart')
    ..addFlag('update-json');
  var results = parser.parse(arguments);
  final argCkey = results['ckey'] as String;
  final argSkey = results['skey'] as String;
  final argUpdateDart = results['update-dart'] as bool;
  final argUpdateJson = results['update-json'] as bool;
  final argNoCheck = results['no-check'] as bool;
  var noData = true;
  var translator =
      Translator(File('config/translation.txt').readAsStringSync());
  final folders = [
    'math-grade1',
    'math-grade4',
    'math-jhs',
    'math-h',
    'math-u',
  ];
  pkeys = [for (var i = 11; i <= 131; i++) 'p${i.toString().padLeft(3, '0')}'];

  var originalConfig = File('config/config.json').readAsStringSync();
  //print(originalConfig);
  var originalJson = jsonDecode(originalConfig) as Map<String, dynamic>;
  for (var folder in folders) {
    if (argCkey != null && argCkey != folder) continue;
    var indexStr = File('config/series/$folder/index.yaml').readAsStringSync();
    if (indexStr.isEmpty) continue;
    var indexDoc = loadYaml(indexStr);
    //print(json.encode(indexDoc));
    List<dynamic> series = [];
    for (var group in indexDoc) {
      final prefix = group['prefix'] as String;
      final name = group['name'] as String;
      var index = 0;
      for (var suffix in group['suffix']) {
        index++;
        final filename = '$prefix-$suffix.yaml';
        final skey = '$prefix-$suffix';
        final sname = '$name $index';
        if (argSkey != null && argSkey != skey) continue;
        noData = false;
        var serieDoc = loadYaml(
            File('config/series/$folder/$filename').readAsStringSync());
        var serie = jsonDecode(jsonEncode(serieDoc));
        serie['skey'] = skey;
        serie['sname'] = sname;
        serie['pkey'] = generatePkeyFromSkey(skey);
        serie['localized'] = translator.translate(sname);
        assert(serie['sampleTex'] != null, serie['skey']);
        series.add(serie);
      }
      ((originalJson['categories'] as Map<String, dynamic>)[folder]
          as Map<String, dynamic>)['series'] = series;
    }
  }
  var noticesStr = File('config/notices.yaml').readAsStringSync();
  print(noticesStr);
  if (noticesStr.trim().isNotEmpty) {
    var noticesDoc = loadYaml(noticesStr);
    originalJson['notices'] = noticesDoc;
  }

  if (noData) throw Exception('noData');
  originalJson['updated'] = DateTime.now().millisecondsSinceEpoch;
  String res = json.encode(originalJson);
  ConfigMock config;
  config = ConfigMock.fromJson(json.decode(res));
  if (!argNoCheck) {
    // check config.
    for (var category in config.categories) {
      for (var serie in category.series) {
        try {
          serie.mth.check();
          serie.mth.makeCalTexs(10);
        } catch (e) {
          print('${serie.skey}');
          rethrow;
        }
      }
    }
  }
  //print(res);
  if (argUpdateDart) {
    File('lib/default_config_json.dart')
        .writeAsStringSync("const defaultConfigJson = r'''$res''';");
    print('output lib/default_config_json.dart');
  }
  if (argUpdateJson) {
    File('../firebase/public/config/android.json').writeAsStringSync(res);
    File('../firebase/public/config/ios.json').writeAsStringSync(res);
    File('../firebase/public/config/windows.json').writeAsStringSync(res);
    File('../firebase/public/config/linux.json').writeAsStringSync(res);
    File('../firebase/public/config/macos.json').writeAsStringSync(res);
    File('../firebase/public/config/other.json').writeAsStringSync(res);
    print('output ../firebase/public/config/*.json');
  }
}

String generatePkeyFromSkey(String skey) {
  int hash = 11;
  for (var i = 0; i < skey.length; i++) {
    hash = ((hash + skey[i].codeUnits.last * 17 + 19) * 13 + 23) % 9999991;
  }
  return pkeys[hash % pkeys.length];
}

class Translator {
  final String str;
  Map<String, Map<String, String>> _map;
  List<String> _langCodes;

  Translator(this.str) {
    var lines = str.trim().split('\n');
    var keys = lines[0].split('\t').map((e) => toUpperFirst(e.trim())).toList();
    if (keys[0] != 'En') {
      throw Exception('first line should be en. ${keys[0]}');
    }
    _map = {};
    for (var key in keys.skip(1)) {
      _map[key] = {'en': key};
    }

    _langCodes = ['en'];

    for (var line in lines.skip(1)) {
      var terms = line.split('\t').map((e) => e.trim()).toList();
      var langCode = terms[0];
      _langCodes.add(langCode);
      for (var i = 1; i < terms.length; i++) {
        var k = keys[i];
        _map[k][langCode] = toUpperFirst(terms[i]);
      }
    }
  }

  Map<String, String> translate(String s) {
    var ret = Map<String, String>();
    for (var langCode in _langCodes) {
      String r = s;
      for (var k in _map.keys) {
        r = r.replaceAll('{$k}', _map[k][langCode]);
      }
      ret[langCode] = r;
      if (r.contains('{') || r.contains('}')) {
        print('$s cannot translate.');
      }
    }
    ret['zh'] = ret['zh_Hans'];
    return ret;
  }
}

String toUpperFirst(String s) {
  StringBuffer buf = StringBuffer();
  buf.write(String.fromCharCode(s.runes.first).toUpperCase());
  for (var rune in s.runes.skip(1)) {
    buf.write(String.fromCharCode(rune));
  }
  return buf.toString();
}
