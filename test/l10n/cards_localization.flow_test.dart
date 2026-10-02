import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_tweety/l10n/app_localizations.dart';

void main() {
  test(
    'provides Cards creation and edit copy in every supported language',
    () async {
      final english = await AppLocalizations.delegate.load(const Locale('en'));
      final spanish = await AppLocalizations.delegate.load(const Locale('es'));
      final hebrew = await AppLocalizations.delegate.load(const Locale('he'));

      expect(english.cardCreateAction, 'Create card');
      expect(spanish.cardCreateAction, 'Crear tarjeta');
      expect(hebrew.cardCreateAction, 'צור כרטיס');
      expect(hebrew.cardCreateFailed, 'לא ניתן לשמור את הכרטיס. נסה שוב.');
      expect(english.cardEditReturnToCardsAction, 'Return to cards');
      expect(spanish.cardEditSaveAction, 'Guardar cambios');
      expect(hebrew.cardEditNotFound, 'הכרטיס כבר לא קיים.');
    },
  );
}
