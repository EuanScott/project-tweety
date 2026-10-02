import 'package:material_ui/material_ui.dart';

class const AppLanguageOption({
  required final String languageCode,
  required final String nativeLabel,
}) {
  Locale get locale => Locale(languageCode);
}
