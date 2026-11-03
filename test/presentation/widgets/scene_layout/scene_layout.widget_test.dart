import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:project_tweety/presentation/widgets/scene_layout/scene_frame.model.dart';
import 'package:project_tweety/presentation/widgets/scene_layout/scene_layout.widget.dart';
import 'package:project_tweety/presentation/widgets/water_scene/water_scene.widget.dart';

const _sceneKey = ValueKey('scene');
const _bodyKey = ValueKey('body');
const _footerKey = ValueKey('footer');
const _overlayKey = ValueKey('overlay');
const _contentKey = ValueKey('content');
const _contentPaneKey = ValueKey('content-pane');

void main() {
  late List<SceneFrame> frames;

  setUp(() => frames = []);

  /// A stand-in scene that records the frame it was handed and fills the
  /// composition box plus its fade.
  Widget scene(BuildContext context, SceneFrame frame) {
    frames.add(frame);
    final size = frame.compositionSize;

    return SizedBox(
      key: _sceneKey,
      width: frame.fadeAxis == Axis.horizontal
          ? size.width + frame.fadeExtent
          : size.width,
      height: frame.fadeAxis == Axis.vertical
          ? size.height + frame.fadeExtent
          : size.height,
    );
  }

  Future<void> pump(
    WidgetTester tester,
    Widget layout, {
    required Size size,
    EdgeInsets padding = EdgeInsets.zero,
    List<DisplayFeature> displayFeatures = const [],
    TextDirection direction = TextDirection.ltr,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: const [ScenePalette.fjordDay]),
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(padding: padding, displayFeatures: displayFeatures),
            child: Directionality(
              textDirection: direction,
              child: Scaffold(body: layout),
            ),
          ),
        ),
      ),
    );
  }

  group('SceneCompactLayout', () {
    final layout = SceneCompactLayout(
      scene: scene,
      body: const SizedBox(key: _bodyKey, height: 80),
      footer: const SizedBox(
        key: _footerKey,
        width: double.infinity,
        height: 48,
      ),
    );
    const phone = Size(390, 844);
    const insets = EdgeInsets.only(top: 59, bottom: 34);

    testWidgets('gives the scene half the height below the status bar, and '
        'a fade of a tenth below it', (tester) async {
      await pump(tester, layout, size: phone, padding: insets);

      expect(frames.last.compositionSize, const Size(390, 393));
      expect(frames.last.fadeExtent, 79);
      expect(frames.last.fadeAxis, Axis.vertical);
      expect(tester.getTopLeft(find.byKey(_sceneKey)), const Offset(0, 59));
    });

    testWidgets('fills behind the status bar with the sky', (tester) async {
      await pump(tester, layout, size: phone, padding: insets);

      final sky = find.byWidgetPredicate(
        (widget) =>
            widget is ColoredBox && widget.color == ScenePalette.fjordDay.sky,
      );
      expect(tester.getRect(sky), const Rect.fromLTWH(0, 0, 390, 59 + 393.0));
    });

    testWidgets('puts the body below the fade and the footer 40 px above '
        'the bottom inset', (tester) async {
      await pump(tester, layout, size: phone, padding: insets);

      expect(tester.getTopLeft(find.byKey(_bodyKey)).dy, 59 + 393 + 79 + 8);
      expect(tester.getRect(find.byKey(_footerKey)).bottom, 844 - 34 - 40);
      expect(tester.getRect(find.byKey(_footerKey)).left, 24);
    });

    testWidgets('on a small phone, scrolls the scene away but keeps the '
        'footer in place', (tester) async {
      await pump(tester, layout, size: const Size(320, 480));
      final footer = tester.getRect(find.byKey(_footerKey));

      await tester.drag(find.byKey(_bodyKey), const Offset(0, -200));
      await tester.pump();

      expect(tester.getRect(find.byKey(_footerKey)), footer);
      expect(tester.getTopLeft(find.byKey(_sceneKey)).dy, lessThan(0));
      expect(frames.last.scrollOffset, greaterThan(0));
    });
  });

  group('SceneSplitLayout', () {
    final layout = SceneSplitLayout(
      scene: scene,
      sceneOverlay: const SizedBox.expand(),
      sceneOverlayKey: _overlayKey,
      content: const SizedBox(key: _contentKey, height: 120),
      contentKey: _contentPaneKey,
    );
    const iPadLandscape = Size(1194, 834);

    testWidgets('gives the scene 55% of the width and fades it over 96 px '
        'at most', (tester) async {
      await pump(tester, layout, size: iPadLandscape);

      expect(frames.last.compositionSize, const Size(657, 834));
      expect(frames.last.fadeExtent, 96);
      expect(frames.last.fadeAxis, Axis.horizontal);
      expect(
        tester.getRect(find.byKey(_sceneKey)),
        const Rect.fromLTWH(0, 0, 657 + 96.0, 834),
      );
    });

    testWidgets('centres the content past the fade, at most 400 px wide', (
      tester,
    ) async {
      await pump(tester, layout, size: iPadLandscape);

      final content = tester.getRect(find.byKey(_contentKey));
      expect(tester.getRect(find.byKey(_contentPaneKey)).left, 657);
      expect(content.left, 657 + 48 + 96);
      expect(content.width, lessThanOrEqualTo(400));
      expect(content.center.dy, closeTo(834 / 2, 1));
    });

    testWidgets('keeps the overlay and the content off a hinge', (
      tester,
    ) async {
      await pump(
        tester,
        layout,
        size: const Size(882, 800),
        displayFeatures: const [
          DisplayFeature(
            bounds: Rect.fromLTRB(480, 0, 500, 800),
            type: DisplayFeatureType.hinge,
            state: DisplayFeatureState.postureFlat,
          ),
        ],
      );

      expect(tester.getRect(find.byKey(_overlayKey)).right, 480);
      expect(tester.getRect(find.byKey(_contentPaneKey)).left, 500);
    });

    testWidgets('right-to-left puts the scene on the right', (tester) async {
      await pump(
        tester,
        layout,
        size: iPadLandscape,
        direction: TextDirection.rtl,
      );

      expect(tester.getRect(find.byKey(_sceneKey)).right, 1194);
      expect(tester.getRect(find.byKey(_contentPaneKey)).right, 1194 - 657);
    });
  });
}
