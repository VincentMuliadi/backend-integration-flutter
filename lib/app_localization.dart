import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'l10n/messages_all.dart';

class AppLocalizations {

  final String localeName;

  AppLocalizations(this.localeName);

  static Future<AppLocalizations> load(Locale locale) {
    final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);


    return initializeMessages(localeName).then((bool _) {
      return AppLocalizations(localeName);
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Step 1 from AppLocalizations to ARB
  // Run this terminal for generate intl_messages.arb
  // flutter pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/app_localization.dart

  // Step 2 copy intl_messages.arb and edit intl_en.arb
  // Step 3 copy intl_messages.arb and edit intl_id.arb
  // Step 4
  // Run this
  // flutter pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/l10n/intl_messages.arb lib/l10n/intl_en.arb lib/l10n/intl_id.arb lib/l10n/intl_zh.arb lib/app_localization.dart

  String get login {
    return Intl.message('login', name: 'login', locale: localeName);
  }

  String get username {
    return Intl.message('username', name: 'username', locale: localeName);
  }

  String get password {
    return Intl.message('password', name: 'password', locale: localeName);
  }

  String get version {
    return Intl.message('version', name: 'version', locale: localeName);
  }

}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {

  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'id'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}