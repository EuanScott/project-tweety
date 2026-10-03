import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

import '../comparison/comparison_view.dart';
import '../shell/showcase_controls.dart';

enum _GoogleSignInButtonState { ready, loading }

/// Showcase for [AppGoogleSignInButton], demonstrating the ready and loading
/// states and the disabled state in both comparison panes.
class const AppGoogleSignInButtonShowcase({super.key}) extends StatefulWidget {
  @override
  State<AppGoogleSignInButtonShowcase> createState() =>
      _AppGoogleSignInButtonShowcaseState();
}

class _AppGoogleSignInButtonShowcaseState
    extends State<AppGoogleSignInButtonShowcase> {
  _GoogleSignInButtonState _state = .ready;
  bool _enabled = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        ShowcaseControls(
          variantOptions: _GoogleSignInButtonState.values
              .map((state) => state.name)
              .toList(growable: false),
          variantValue: _state.name,
          onVariantChanged: (value) => setState(
            () => _state = _GoogleSignInButtonState.values.byName(value),
          ),
          enabled: _enabled,
          onEnabledChanged: (value) => setState(() => _enabled = value),
        ),
        Expanded(
          child: ComparisonView(
            contentBuilder: (context) => AppGoogleSignInButton(
              label: 'Sign in with Google',
              loadingLabel: 'Signing in…',
              onPressed: _enabled ? noop : null,
              loading: _state == .loading,
            ),
          ),
        ),
      ],
    );
  }
}
