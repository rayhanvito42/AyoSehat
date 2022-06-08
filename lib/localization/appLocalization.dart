/* localized content */
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalization {
  final Locale locale;

  AppLocalization(this.locale);

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization);
  }

  // Read the json file into a map for easy use
  Map<String, String> _localizedStrings;

  // load function to read json file
  Future<void> load() async {
    String jsonStringValues =
        await rootBundle.loadString('lib/lang/${locale.languageCode}.json');
    // Parse json file
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    // Write to _localizedStrings
    _localizedStrings =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  //Translate, translate will be called when each widget needs it
  String translate(String key) {
    return _localizedStrings[key];
  }

  // static member to have simple access to the delegate from Material App
  static const LocalizationsDelegate<AppLocalization> delegate =
      _AppLocalizationsDelegate();
}

//This is AppLocalizations' own initialization
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalization> {
  // This delegate instance will never change
  const _AppLocalizationsDelegate();

  
  // Check if the language is supported
  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    AppLocalization localization = new AppLocalization(locale);
    await localization.load();
    return localization;
  }

  // Reload
  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) => false;
}
