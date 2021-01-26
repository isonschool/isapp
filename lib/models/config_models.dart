import 'package:isapp/formula/mth.dart';

enum Challenge { lesson, exam, diploma }

class Category {
  final String ckey;
  final String cname;
  final int priority;
  final Map<String, String> localized;
  final List<Serie> series;

  Category(this.ckey, this.cname, this.priority, this.localized, this.series);

  Category.fromJson(this.ckey, Map<String, dynamic> json)
      : cname = json['cname'] ?? '???',
        priority = json['priority'] ?? 10000,
        localized = (json['localized'] as Map<String, dynamic>)
                ?.map((key, value) => MapEntry(key, value.toString())) ??
            {},
        series = (json['series'] as List<dynamic>)
                ?.map((e) => Serie.fromJson(e))
                ?.toList() ??
            [];

  @override
  String toString() =>
      'Category{ckey: $ckey, cname: $cname, priority: $priority, localized: $localized, series: $series}';
}

class Serie {
  final String skey;
  final String sname;
  String sampleTex;
  final List<String> sampleExplanationTexs;
  final String longestTex;
  final Map<String, String> localized;
  final Mth mth;
  final String pkey;
  Category category;

  Serie({
    this.skey,
    this.sname,
    this.sampleTex,
    this.sampleExplanationTexs,
    this.longestTex,
    this.localized,
    this.mth,
    this.pkey,
  });

  Serie.fromJson(Map<String, dynamic> json)
      : skey = json['skey'],
        sname = json['sname'] ?? '???',
        sampleTex = json['sampleTex'] ?? '???',
        sampleExplanationTexs = ((json['sampleExplanationTex'] ?? '') as String)
            .split(';')
            .where((t) => t.isNotEmpty)
            .toList(),
        longestTex = json['longestTex'] ?? '???',
        localized = (json['localized'] as Map<String, dynamic>)
                ?.map((key, value) => MapEntry(key, value.toString())) ??
            {},
        mth = Mth.fromJson(json['skey'], json['mth']),
        pkey = json['pkey'] {
    sampleTex = mth.makeSampleTex();
  }

  @override
  String toString() =>
      'Serie{skey: $skey, sname: $sname, sampleTex: $sampleTex, longestTex: $longestTex, localized: $localized, mth: $mth, pkey: $pkey}';
}

class ConfigMock {
  final List<Category> categories;
  final int updated;

  ConfigMock({
    this.categories,
    this.updated,
  });

  ConfigMock.fromJson(Map<String, dynamic> json)
      : categories = (json['categories'] as Map<String, dynamic>)
                ?.map((k, v) => MapEntry(k, Category.fromJson(k, v)))
                ?.values
                ?.toList() ??
            []
          ..sort((a, b) => a.priority.compareTo(b.priority)),
        updated = json['updated'] {
    for (var c in categories) {
      for (var s in c.series) {
        s.category = c;
      }
    }
  }

  @override
  String toString() {
    return 'ConfigMock{categories: $categories}';
  }
}

enum NoticeType { version, normal, important }

class Notice {
  String nid;
  NoticeType noticeType;
  String message;
  Map<String, String> localized;
  DateTime date;

  Notice({
    this.nid,
    this.noticeType,
    this.message,
    this.localized,
    this.date,
  });

  Notice.fromJson(Map<String, dynamic> json)
      : this(
          nid: json['nid'],
          noticeType: json['noticeType'] == 'important'
              ? NoticeType.important
              : NoticeType.normal,
          message: json['message'],
          localized: (json['localized'] as Map<String, dynamic>)
                  ?.map((k, v) => MapEntry(k, v as String)) ??
              {},
          date: DateTime.tryParse(json['date'] ?? ''),
        );

  @override
  String toString() {
    return 'Notice{nid: $nid, noticeType: $noticeType, message: $message, localized: $localized, date: $date}';
  }
}
