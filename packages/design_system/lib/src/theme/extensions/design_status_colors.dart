import 'package:material_ui/material_ui.dart';

import '../design_brand.dart';

/// The brand's state colours, which [ColorScheme] has no slots for.
///
/// They mean state only: use them to mark a status, for example on an icon,
/// and never to decorate.
class DesignStatusColors extends ThemeExtension<DesignStatusColors> {
  const new({required this.success, required this.warning});

  new fromBrand(DesignBrand brand)
    : success = brand.success,
      warning = brand.warning;

  final Color success;
  final Color warning;

  /// The status colours of [theme]. Every design-system theme registers them.
  static DesignStatusColors of(ThemeData theme) =>
      theme.extension<DesignStatusColors>()!;

  @override
  DesignStatusColors copyWith({Color? success, Color? warning}) {
    return DesignStatusColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
    );
  }

  @override
  DesignStatusColors lerp(DesignStatusColors? other, double t) {
    if (other == null) {
      return this;
    }

    return DesignStatusColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}
