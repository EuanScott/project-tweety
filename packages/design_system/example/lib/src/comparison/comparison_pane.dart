import 'package:design_system/design_system.dart';
import 'package:material_ui/material_ui.dart';

/// One half of a showcase's two-pane comparison, rendering [contentBuilder]
/// under a single platform's design language.
class const ComparisonPane({
  required final String label,
  required final TargetPlatform platform,
  required final Brightness brightness,
  required final WidgetBuilder contentBuilder,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final baseTheme = brightness == Brightness.dark
        ? DesignSystemTheme.dark()
        : DesignSystemTheme.light();
    final paneTheme = baseTheme.copyWith(platform: platform);

    return ColoredBox(
      color: paneTheme.scaffoldBackgroundColor,
      child: Theme(
        data: paneTheme,
        child: Column(
          children: [
            Padding(
              padding: const .all(12),
              child: Text(label, style: paneTheme.textTheme.labelLarge),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const .all(24),
                  child: Builder(builder: contentBuilder),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
