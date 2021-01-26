import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:isapp/common/version.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../default_config_json.dart';
import 'config_models.dart';

const int lifeNum = 2;
const int lessonProblemNum = 5;
const int examProblemNum = 8;
const int diplomaProblemNum = 10;

const domain = 'https://isonschoolmath.web.app/config';

String configUrl() {
  if (Platform.isAndroid) {
    return '$domain/android.json';
  } else if (Platform.isIOS) {
    return '$domain/ios.json';
  } else if (Platform.isLinux) {
    return '$domain/linux.json';
  } else if (Platform.isMacOS) {
    return '$domain/macos.json';
  } else if (Platform.isWindows) {
    return '$domain/windows.json';
  }
  return '$domain/other.json';
}

class Config extends ChangeNotifier {
  final List<Category> categories;
  final List<Notice> notices;
  final String latestVersion;
  final String minVersion;
  final int updated;

  Config({
    this.categories,
    this.notices,
    this.latestVersion,
    this.minVersion,
    this.updated,
  });

  Category getCategoryByCkey(String ckey) =>
      categories.singleWhere((c) => c.ckey == ckey);

  Serie getSerieBySkey(String skey) =>
      categories.expand((c) => c.series).singleWhere((s) => s.skey == skey);

  static Config loadConfig(SharedPreferences pref) {
    Config diff;
    var d = pref.getString('diff');
    if (d != null && d.startsWith('{')) {
      dynamic diffJson;
      try {
        diffJson = jsonDecode(d);
      } catch (e) {
        print('exception in jsonDecode(pref.getString(diff)). $e');
      }
      if (diffJson != null) diff = Config.fromJson(diffJson);
    }
    var j = defaultConfigJson;
    var json = jsonDecode(j);
    var orig = Config.fromJson(json);
    if (diff == null || (diff.updated ?? 0) <= (orig.updated ?? 0)) {
      print(
          'diff is null or original is more recent. returning originalJsonConfig.');
      print(orig.notices);
      return orig;
    }
    orig.notices
      ..clear()
      ..addAll(diff.notices);
    print(orig.notices);
    return orig;
  }

  Config.fromJson(Map<String, dynamic> json)
      : categories = (json['categories'] as Map<String, dynamic>)
                ?.map((k, v) => MapEntry(k, Category.fromJson(k, v)))
                ?.values
                ?.toList() ??
            []
          ..sort((a, b) => a.priority.compareTo(b.priority)),
        notices = (json['notices'] as List)
                ?.map((e) => Notice.fromJson(e))
                ?.toList() ??
            [],
        latestVersion = json['latestVersion'],
        minVersion = json['minVersion'],
        updated = json['updated'] {
    for (var c in categories) {
      for (var s in c.series) {
        s.category = c;
      }
    }
    if (latestVersion != isonSchoolMathVersion) {
      notices.insert(
        0,
        Notice(
          nid: 'versionMessage',
          noticeType: NoticeType.version,
          message: latestVersion,
          localized: {},
          date: null,
        ),
      );
    }
  }

  static Future<Config> fromRemoteConfig(SharedPreferences pref) async {
    var response = await http.get(configUrl());
    print('httpResponse: ${response.body}');
    if (response.statusCode == 200 && response.body.startsWith('{')) {
      var json = jsonDecode(response.body);
      var j = Config.fromJson(json);
      if (satisfiesMinVersion(j.minVersion)) {
        await pref.setString('diff', response.body);
      } else {
        print('this app version is less than minVersion. ${response.body}');
      }
      //print('fromRemoteConfig: ${response.body}');
    }
    return Config.loadConfig(pref);
  }

  @override
  String toString() {
    return 'Config{categories: $categories, notices: $notices, updated: $updated}';
  }
}
