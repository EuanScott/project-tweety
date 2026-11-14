import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// The dev code signs in a made-up Account and skips Firebase, so it must
/// never reach a release build. Release builds start from `lib/main.dart`, so
/// only `lib/main_dev.dart` and `lib/dev/` itself may import it.
void main() {
  test('only the dev entrypoint and lib/dev import lib/dev', () {
    final devDirectory = p.normalize(p.absolute('lib', 'dev'));
    final devEntrypoint = p.normalize(p.absolute('lib', 'main_dev.dart'));
    // A whole directive up to its `;`, so a conditional import's every URI
    // and a directive split across lines are both read.
    final directive = RegExp(
      r'^\s*(?:import|export|part)\b[^;]*;',
      multiLine: true,
    );
    final quotedUri = RegExp('''['"]([^'"]+)['"]''');

    final violations = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      final path = p.normalize(p.absolute(file.path));
      if (file is! File ||
          !path.endsWith('.dart') ||
          path == devEntrypoint ||
          p.isWithin(devDirectory, path)) {
        continue;
      }

      for (final match in directive.allMatches(file.readAsStringSync())) {
        for (final uri in quotedUri.allMatches(match.group(0)!)) {
          final target = _resolve(uri.group(1)!, from: path);
          if (target != null && p.isWithin(devDirectory, target)) {
            violations.add('${p.relative(path)} imports ${uri.group(1)}');
          }
        }
      }
    }

    expect(violations, isEmpty);
  });
}

/// The absolute path of [uri] imported from [from], or null for another
/// package or a `dart:` library.
String? _resolve(String uri, {required String from}) {
  const ownPackage = 'package:project_tweety/';
  if (uri.startsWith(ownPackage)) {
    return p.normalize(p.absolute('lib', uri.substring(ownPackage.length)));
  }
  if (uri.contains(':')) {
    return null;
  }

  return p.normalize(p.join(p.dirname(from), uri));
}
