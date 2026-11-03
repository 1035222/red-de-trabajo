import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:red_de_trabajo/l10n/app_localizations.dart';
import 'package:red_de_trabajo/services/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AppLocalizations', () {
    test('translates app labels to English', () {
      const localizations = AppLocalizations(Locale('en'));

      expect(localizations.translate('Notificaciones'), 'Notifications');
      expect(localizations.translate('Mis servicios'), 'My services');
    });

    test('keeps Spanish text in the Spanish locale', () {
      const localizations = AppLocalizations(Locale('es'));

      expect(localizations.translate('Notificaciones'), 'Notificaciones');
    });

    test('translates dynamic phrases', () {
      const localizations = AppLocalizations(Locale('en'));

      expect(localizations.translate('Hace 3 días'), '3 days ago');
      expect(localizations.translate('Calificación 4.8'), 'Rating 4.8');
      expect(localizations.translate('¡Hola, Migue!'), 'Hello, Migue!');
      expect(localizations.translate('¡Hola!'), 'Hello!');
      expect(
        localizations.translate('La foto no se pudo cargar'),
        'The photo could not be loaded',
      );
      expect(
        localizations.translate('¿Eliminar mensaje para todos?'),
        'Delete message for everyone?',
      );
      expect(
        localizations.translate('Error al eliminar mensaje: No encontrado'),
        'Could not delete message: No encontrado',
      );
    });

    test('persists the selected locale', () async {
      SharedPreferences.setMockInitialValues({});
      await AppPreferences.instance.setLocale(const Locale('en'));

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('app_locale'), 'en');
      expect(AppPreferences.instance.locale.languageCode, 'en');

      await AppPreferences.instance.setLocale(const Locale('es'));
    });
  });
}
