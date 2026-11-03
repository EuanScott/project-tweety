import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/widgets/water_scene/water_scene.widget.dart';

const _scene = Color(0xFFFF0000);
const _page = Color(0xFFFFFFFF);
const _boundaryKey = ValueKey('boundary');

void main() {
  group('SceneWavyFade', () {
    /// Paints the fade over a red scene and returns the pixels.
    Future<({ByteData bytes, int width})> paint(
      WidgetTester tester, {
      required Size size,
      required Axis axis,
      TextDirection direction = TextDirection.ltr,
    }) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: direction,
          child: Center(
            child: RepaintBoundary(
              key: _boundaryKey,
              child: SizedBox.fromSize(
                size: size,
                child: Stack(
                  children: [
                    const Positioned.fill(child: ColoredBox(color: _scene)),
                    Positioned.fill(
                      child: SceneWavyFade(axis: axis, background: _page),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(_boundaryKey),
      );
      final bytes = await tester.runAsync(() async {
        final image = await boundary.toImage();
        return image.toByteData(format: ui.ImageByteFormat.rawRgba);
      });

      return (bytes: bytes!, width: size.width.toInt());
    }

    Color pixel(({ByteData bytes, int width}) image, int x, int y) {
      final offset = (y * image.width + x) * 4;
      final b = image.bytes;

      return Color.fromARGB(
        b.getUint8(offset + 3),
        b.getUint8(offset),
        b.getUint8(offset + 1),
        b.getUint8(offset + 2),
      );
    }

    /// How much of the page colour covers the red scene: 0 none, 1 all.
    double cover(Color color) => color.g;

    testWidgets('a downward fade keeps the scene at the top and is solid '
        'page colour at the bottom', (tester) async {
      final image = await paint(
        tester,
        size: const Size(300, 100),
        axis: Axis.vertical,
      );

      for (final x in [10, 150, 290]) {
        expect(cover(pixel(image, x, 0)), lessThan(0.05));
        expect(pixel(image, x, 99), _page);
      }
      expect(cover(pixel(image, 150, 50)), inExclusiveRange(0.1, 0.99));
    });

    testWidgets('a sideways fade runs toward the end edge', (tester) async {
      final image = await paint(
        tester,
        size: const Size(100, 300),
        axis: Axis.horizontal,
      );

      expect(cover(pixel(image, 0, 150)), lessThan(0.05));
      expect(pixel(image, 99, 150), _page);
    });

    testWidgets('right-to-left, a sideways fade runs toward the left', (
      tester,
    ) async {
      final image = await paint(
        tester,
        size: const Size(100, 300),
        axis: Axis.horizontal,
        direction: TextDirection.rtl,
      );

      expect(cover(pixel(image, 99, 150)), lessThan(0.05));
      expect(pixel(image, 0, 150), _page);
    });
  });
}
