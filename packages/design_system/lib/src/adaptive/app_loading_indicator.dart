import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'app_design_platform.dart';

/// An app-level loading indicator that adapts to the active design language.
///
/// Use this instead of direct Material or Cupertino loading widgets in feature
/// code so loading states stay native per platform.
class AppLoadingIndicator extends StatelessWidget {
  /// Creates a centered-size adaptive loading indicator.
  const AppLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    if (AppDesignPlatform.of(context).isCupertino) {
      return const CupertinoActivityIndicator();
    }

    return const CircularProgressIndicator();
  }
}
