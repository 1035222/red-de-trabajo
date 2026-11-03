import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

class AppPreferences extends ChangeNotifier {
  AppPreferences._();

  static final AppPreferences instance = AppPreferences._();
  static const _darkModeKey = 'app_dark_mode';
  static const _localeKey = 'app_locale';

  bool _darkModeEnabled = false;
  Locale _locale = const Locale('es');

  bool get darkModeEnabled => _darkModeEnabled;
  Locale get locale => _locale;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _darkModeEnabled = preferences.getBool(_darkModeKey) ?? false;
    _locale = Locale(preferences.getString(_localeKey) == 'en' ? 'en' : 'es');
    AppLocalizations.currentLocale = _locale;
    AppColors.isDarkMode = _darkModeEnabled;
  }

  Future<void> setDarkMode(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_darkModeKey, enabled);
    _darkModeEnabled = enabled;
    AppColors.isDarkMode = enabled;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!['es', 'en'].contains(locale.languageCode)) {
      throw ArgumentError.value(locale, 'locale', 'Unsupported locale');
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_localeKey, locale.languageCode);
    _locale = locale;
    AppLocalizations.currentLocale = locale;
    notifyListeners();
  }
}
