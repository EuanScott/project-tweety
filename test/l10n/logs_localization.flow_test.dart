import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/l10n/app_localizations.dart';

void main() {
  test(
    'provides log entry creation and edit copy in every supported language',
    () async {
      final english = await AppLocalizations.delegate.load(const Locale('en'));
      final spanish = await AppLocalizations.delegate.load(const Locale('es'));
      final hebrew = await AppLocalizations.delegate.load(const Locale('he'));

      expect(english.logEntryCreateAction, 'Create entry');
      expect(spanish.logEntryCreateAction, 'Crear entrada');
      expect(hebrew.logEntryCreateAction, 'צור רשומה');
      expect(hebrew.logEntryCreateFailed, 'לא ניתן לשמור את הרשומה. נסה שוב.');
      expect(english.logEntryEditReturnToLogsAction, 'Return to logs');
      expect(spanish.logEntryEditSaveAction, 'Guardar cambios');
      expect(hebrew.logEntryEditNotFound, 'הרשומה כבר לא קיימת.');
    },
  );
}
