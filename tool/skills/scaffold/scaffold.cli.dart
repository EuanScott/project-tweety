import 'dart:convert';
import 'dart:io';

import 'scaffold.dart';

/// Command-line adapter for deterministic Project Tweety scaffolds.
final class ScaffoldCli {
  new({
    Directory? repositoryRoot,
    void Function(String line)? writeOutput,
    void Function(String line)? writeError,
  }) : repositoryRoot = repositoryRoot ?? Directory.current,
       _writeOutput = writeOutput ?? stdout.writeln,
       _writeError = writeError ?? stderr.writeln;

  final Directory repositoryRoot;
  final void Function(String line) _writeOutput;
  final void Function(String line) _writeError;

  Future<int> run(List<String> arguments) async {
    try {
      final invocation = _ScaffoldInvocation.parse(arguments);
      final manifest = await ScaffoldGenerator(
        repositoryRoot: repositoryRoot,
      ).render(invocation.request);
      final result = await ScaffoldExecutor(
        repositoryRoot: repositoryRoot,
      ).execute(manifest, mode: invocation.mode);
      _writeOutput(
        jsonEncode({
          'ok': true,
          'mode': result.mode.name,
          'status': result.status.name,
          'files': result.manifest.files
              .map((artifact) => artifact.toJson())
              .toList(growable: false),
          'drift': result.drift
              .map((difference) => difference.toJson())
              .toList(growable: false),
        }),
      );
      return result.status == ScaffoldStatus.drift ? 1 : 0;
    } on ScaffoldException catch (error) {
      _writeError(jsonEncode({'ok': false, 'error': error.toJson()}));
      return error.code == 'invalid_arguments' ? 64 : 1;
    } on Object catch (error) {
      _writeError(
        jsonEncode({
          'ok': false,
          'error': {'code': 'internal_error', 'message': error.toString()},
        }),
      );
      return 1;
    }
  }
}

final class _ScaffoldInvocation {
  const new({required this.request, required this.mode});

  final ScaffoldRequest request;
  final ScaffoldMode mode;

  static _ScaffoldInvocation parse(List<String> arguments) {
    const valueOptions = {
      '--feature',
      '--layers',
      '--initial-load-operation',
      '--folder-key',
      '--controller',
      '--domain-reason',
    };
    const modeOptions = {
      '--dry-run': ScaffoldMode.dryRun,
      '--write': ScaffoldMode.write,
      '--check': ScaffoldMode.check,
    };
    final values = <String, String>{};
    final modes = <ScaffoldMode>[];

    for (var index = 0; index < arguments.length; index++) {
      final argument = arguments[index];
      final mode = modeOptions[argument];
      if (mode != null) {
        modes.add(mode);
        continue;
      }
      if (!valueOptions.contains(argument)) {
        _invalidArguments('Unknown option: $argument');
      }
      if (values.containsKey(argument)) {
        _invalidArguments('Option may be supplied only once: $argument');
      }
      if (index + 1 >= arguments.length ||
          arguments[index + 1].startsWith('--')) {
        _invalidArguments('Option requires a value: $argument');
      }
      values[argument] = arguments[++index];
    }

    if (modes.length > 1) {
      _invalidArguments('Choose only one of --dry-run, --write, or --check.');
    }
    final feature = _required(values, '--feature');
    final initialLoadOperation = _required(values, '--initial-load-operation');
    final layerNames = _required(values, '--layers').split(',');
    if (layerNames.isEmpty || layerNames.toSet().length != layerNames.length) {
      _invalidArguments('--layers must contain unique comma-separated values.');
    }
    final layers = <ScaffoldLayer>{};
    for (final layerName in layerNames) {
      final layer = switch (layerName) {
        'data' => ScaffoldLayer.data,
        'presentation' => ScaffoldLayer.presentation,
        'domain' => ScaffoldLayer.domain,
        _ => null,
      };
      if (layer == null) {
        _invalidArguments('Unknown layer: $layerName');
      }
      layers.add(layer);
    }
    final controller = switch (values['--controller'] ?? 'bloc') {
      'bloc' => ScaffoldController.bloc,
      'cubit' => ScaffoldController.cubit,
      final value => _invalidArguments('Unknown controller: $value'),
    };

    return _ScaffoldInvocation(
      request: ScaffoldRequest(
        feature: feature,
        layers: layers,
        initialLoadOperation: initialLoadOperation,
        folderKey: values['--folder-key'],
        controller: controller,
        domainReason: values['--domain-reason'],
      ),
      mode: modes.isEmpty ? ScaffoldMode.dryRun : modes.single,
    );
  }

  static String _required(Map<String, String> values, String option) {
    final value = values[option];
    if (value == null || value.isEmpty) {
      _invalidArguments('Missing required option: $option');
    }
    return value;
  }

  static Never _invalidArguments(String message) {
    throw ScaffoldException(code: 'invalid_arguments', message: message);
  }
}
