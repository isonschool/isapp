import 'package:flutter/material.dart';
import 'package:isapp/models/models.dart';

const _languageCodes = <String>[
  'af',
  'am',
  'ar',
  'az',
  'be',
  'bg',
  'bn',
  'bs',
  'ca',
  'co',
  'cs',
  'cy',
  'da',
  'de',
  'el',
  'en',
  'es',
  'et',
  'eu',
  'fa',
  'fi',
  'fil',
  'fr',
  'fy',
  'gd',
  'gl',
  'gu',
  'ha',
  'he',
  'hi',
  'hr',
  'hu',
  'hy',
  'id',
  'ig',
  'is',
  'it',
  'ja',
  'jv',
  'ka',
  'kk',
  'km',
  'kn',
  'ko',
  'ku',
  'ky',
  'lb',
  'lo',
  'lt',
  'lv',
  'mg',
  'mi',
  'mk',
  'ml',
  'mn',
  'mr',
  'ms',
  'mt',
  'my',
  'ne',
  'nl',
  'no',
  'pa',
  'pl',
  'ps',
  'pt',
  'ro',
  'ru',
  'sd',
  'si',
  'sk',
  'sl',
  'sm',
  'sn',
  'so',
  'sq',
  'sr',
  'st',
  'su',
  'sv',
  'sw',
  'ta',
  'te',
  'tg',
  'th',
  'tr',
  'uk',
  'ur',
  'uz',
  'vi',
  'xh',
  'yi',
  'yo',
  'zh',
  'zu'
];

class Localized {
  Localized(this.locale) {
    if (!_languageCodes.contains(locale.languageCode)) {
      langCode = 'en';
    } else if (locale.languageCode == 'zh') {
      if (locale.scriptCode == 'Hant') {
        langCode = 'zh_Hant';
      } else {
        langCode = 'zh_Hans';
      }
    } else {
      langCode = locale.languageCode;
    }
  }

  final Locale locale;
  String langCode;

  static LocalizationsDelegate<Localized> delegate =
      IsonSchoolLocalizationsDelegate();

  static Localized of(BuildContext context) {
    return Localizations.of<Localized>(context, Localized);
  }

  String categoryName(Category category) {
    if (!category.localized.containsKey(langCode)) return category.cname;
    return category.localized[langCode];
  }

  String serieName(Serie serie) {
    if (!serie.localized.containsKey(langCode)) return serie.sname;
    return serie.localized[langCode];
  }

  String noticeMessage(Notice notice) {
    if (!notice.localized.containsKey(langCode)) return notice.message;
    return notice.localized[langCode];
  }
}

class IsonSchoolLocalizationsDelegate extends LocalizationsDelegate<Localized> {
  @override
  Future<Localized> load(Locale locale) async => Localized(locale);

  @override
  bool shouldReload(IsonSchoolLocalizationsDelegate old) => false;

  @override
  bool isSupported(Locale locale) =>
      _languageCodes.contains(locale.languageCode);
}
