import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';

import 'app_design_platform.dart';

/// A colour choice shown by [AppSwatchPicker].
class const AppSwatchOption<T>({
  /// The value emitted when this option is selected.
  required final T value,

  /// The user-facing name, shown under the swatch and used as its accessible
  /// name.
  required final String label,

  /// The colour of the swatch.
  required final Color primary,
});

/// A row of colour tiles with one selected.
///
/// Each tile is a circle in one colour, with its label under it. The selected
/// tile has a ring, a tick and a bold label, so the choice never relies on
/// colour alone.
///
/// The row scrolls only when the tiles do not fit the width it gets. When it
/// scrolls, the last visible tile is cut in half to show there is more, the
/// row snaps to tile edges, and the selected tile is in view on first build.
///
/// The tile layout is the same on every platform. Press and focus feedback
/// follow the platform.
class AppSwatchPicker<T> extends StatefulWidget {
  const new({
    required this.options,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<AppSwatchOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  State<AppSwatchPicker<T>> createState() => _AppSwatchPickerState<T>();
}

class _AppSwatchPickerState<T> extends State<AppSwatchPicker<T>> {
  static const double _tileWidth = _SwatchTile.width;
  static const double _minGap = 4;
  static const double _peek = _tileWidth / 2;

  ScrollController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final count = widget.options.length;

        if (_rowWidth(_minGap) <= width) {
          return Row(children: _tiles(_minGap));
        }

        // Fit whole tiles plus half of the next one into the width.
        final wholeTiles = ((width - _peek) / (_tileWidth + _minGap))
            .floor()
            .clamp(1, count);
        final gap = ((width - _peek - wholeTiles * _tileWidth) / wholeTiles)
            .clamp(_minGap, double.infinity);
        final extent = _tileWidth + gap;
        final controller = _controller ??= ScrollController(
          initialScrollOffset: _initialOffset(width, wholeTiles, gap),
        );

        return SingleChildScrollView(
          scrollDirection: .horizontal,
          controller: controller,
          physics: _SnapToTilePhysics(extent: extent),
          child: Row(children: _tiles(gap)),
        );
      },
    );
  }

  double _rowWidth(double gap) {
    final count = widget.options.length;

    return count * _tileWidth + (count - 1) * gap;
  }

  /// Scrolls just far enough for the selected tile to be the last whole one.
  double _initialOffset(double width, int wholeTiles, double gap) {
    final selectedIndex = widget.options.indexWhere(
      (option) => option.value == widget.value,
    );
    final tilesToSkip = selectedIndex - wholeTiles + 1;
    if (tilesToSkip <= 0) {
      return 0;
    }

    final maxOffset = _rowWidth(gap) - width;

    return (tilesToSkip * (_tileWidth + gap)).clamp(0, maxOffset);
  }

  List<Widget> _tiles(double gap) {
    return [
      for (final (index, option) in widget.options.indexed) ...[
        if (index > 0) SizedBox(width: gap),
        _SwatchTile(
          option: option,
          isSelected: option.value == widget.value,
          onTap: () => widget.onChanged(option.value),
        ),
      ],
    ];
  }
}

class const _SwatchTile<T>({
  required final AppSwatchOption<T> option,
  required final bool isSelected,
  required final VoidCallback onTap,
}) extends StatelessWidget {
  static const double width = 72;
  static const double _minHeight = 44;
  static const double _labelSize = 12;
  static const BorderRadius _feedbackRadius = .all(.circular(12));

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final content = SizedBox(
      width: width,
      child: Padding(
        padding: const .symmetric(vertical: 4),
        child: Column(
          mainAxisSize: .min,
          children: [
            _Swatch(option: option, isSelected: isSelected),
            const SizedBox(height: 6),
            Text(
              option.label,
              maxLines: 1,
              overflow: .ellipsis,
              textAlign: .center,
              style: TextStyle(
                fontSize: _labelSize,
                fontWeight: isSelected ? .w700 : .w400,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );

    final button = AppDesignPlatform.of(context).isCupertino
        ? CupertinoButton(
            padding: .zero,
            minimumSize: const Size(width, _minHeight),
            onPressed: onTap,
            child: content,
          )
        : InkWell(
            borderRadius: _feedbackRadius,
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: _minHeight),
              child: content,
            ),
          );

    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: isSelected,
        inMutuallyExclusiveGroup: true,
        child: button,
      ),
    );
  }
}

class const _Swatch<T>({
  required final AppSwatchOption<T> option,
  required final bool isSelected,
}) extends StatelessWidget {
  static const double _diameter = 40;
  static const double _ringGap = 2;
  static const double _ringWidth = 2;
  static const double _tickDiscDiameter = 20;
  static const double _tickSize = 14;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: CircleBorder(
            side: isSelected
                ? BorderSide(color: colorScheme.onSurface, width: _ringWidth)
                : BorderSide.none,
          ),
        ),
        child: Padding(
          padding: const .all(_ringGap + _ringWidth),
          child: Container(
            width: _diameter,
            height: _diameter,
            alignment: .center,
            decoration: BoxDecoration(
              shape: .circle,
              color: option.primary,
            ),
            child: isSelected
                ? Container(
                    width: _tickDiscDiameter,
                    height: _tickDiscDiameter,
                    decoration: BoxDecoration(
                      shape: .circle,
                      color: colorScheme.surface,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: _tickSize,
                      color: colorScheme.onSurface,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

/// Settles a scroll on the nearest tile edge, in the direction of a fling.
class _SnapToTilePhysics extends ScrollPhysics {
  const new({required this.extent, super.parent});

  final double extent;

  @override
  _SnapToTilePhysics applyTo(ScrollPhysics? ancestor) {
    return _SnapToTilePhysics(extent: extent, parent: buildParent(ancestor));
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (position.outOfRange) {
      return super.createBallisticSimulation(position, velocity);
    }

    final tolerance = toleranceFor(position);
    final tilePosition = position.pixels / extent;
    final targetTile = velocity > tolerance.velocity
        ? tilePosition.ceil()
        : velocity < -tolerance.velocity
        ? tilePosition.floor()
        : tilePosition.round();
    final target = (targetTile * extent).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    if ((target - position.pixels).abs() < tolerance.distance) {
      return null;
    }

    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: tolerance,
    );
  }
}
