import 'package:design_system_gallery/src/catalog/gallery_catalog.dart';
import 'package:design_system_gallery/src/shell/gallery_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('GalleryNav renders long labels without overflow', (
    tester,
  ) async {
    FlutterError.onError = (details) => fail(details.exceptionAsString());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 260,
            height: 800,
            child: GalleryNav(
              selected: galleryCatalog.last,
              onSelected: (_) {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  });
}
