import 'dart:io';

import 'package:dart_style/dart_style.dart';

import '../../templates/feature_template_paths.dart';
import 'scaffold.models.dart';

/// Builds deterministic source manifests from this repository's `_template`.
final class ScaffoldGenerator {
  const ScaffoldGenerator({required this.repositoryRoot});

  final Directory repositoryRoot;

  Future<ScaffoldManifest> render(ScaffoldRequest request) async {
    _validateRequest(request);

    final featureClass = _pascalCase(request.feature);
    final initialLoadMethod = _lowerCamelCase(request.initialLoadOperation);
    final folderKey = request.folderKey ?? request.feature;
    final replacements = <String, String>{
      'data/repositories/_template/_template.repository.dart':
          'data/repositories/$folderKey/${request.feature}.repository.dart',
      'fetchTemplate': initialLoadMethod,
      '_template': request.feature,
      'Template': featureClass,
    };
    final files = <ScaffoldFile>[
      await _renderTemplate(
        const _TemplateArtifact(
          source: featureRepositoryContractTemplate,
          target: '',
        ).withTarget(
          'lib/data/repositories/$folderKey/'
          '${request.feature}.repository.dart',
        ),
        replacements,
      ),
      await _renderTemplate(
        const _TemplateArtifact(
          source: featureRepositoryImplementationTemplate,
          target: '',
        ).withTarget(
          'lib/data/repositories/$folderKey/'
          '${request.feature}.repository_impl.dart',
        ),
        replacements,
      ),
    ];

    switch (request.controller) {
      case ScaffoldController.bloc:
        files.addAll(
          await _renderBloc(
            feature: request.feature,
            replacements: replacements,
          ),
        );
      case ScaffoldController.cubit:
        files.addAll(
          await _renderCubitArtifacts(
            feature: request.feature,
            featureClass: featureClass,
            folderKey: folderKey,
            initialLoadMethod: initialLoadMethod,
            replacements: replacements,
          ),
        );
    }

    return ScaffoldManifest(files.map(_formatDart));
  }

  Future<List<ScaffoldFile>> _renderBloc({
    required String feature,
    required Map<String, String> replacements,
  }) async {
    final artifacts = [
      _TemplateArtifact(
        source: featurePageTemplate,
        target: 'lib/presentation/pages/$feature/$feature.page.dart',
      ),
      _TemplateArtifact(
        source: featureBlocTemplate,
        target: 'lib/presentation/pages/$feature/bloc/$feature.bloc.dart',
      ),
      _TemplateArtifact(
        source: featureBlocEventTemplate,
        target: 'lib/presentation/pages/$feature/bloc/$feature.event.dart',
      ),
      _TemplateArtifact(
        source: featureBlocStateTemplate,
        target: 'lib/presentation/pages/$feature/bloc/$feature.state.dart',
      ),
    ];
    final files = <ScaffoldFile>[];
    for (final artifact in artifacts) {
      files.add(await _renderTemplate(artifact, replacements));
    }
    return files;
  }

  Future<List<ScaffoldFile>> _renderCubitArtifacts({
    required String feature,
    required String featureClass,
    required String folderKey,
    required String initialLoadMethod,
    required Map<String, String> replacements,
  }) async {
    final page = await _renderTemplate(
      _TemplateArtifact(
        source: featurePageTemplate,
        target: 'lib/presentation/pages/$feature/$feature.page.dart',
      ),
      replacements,
    );
    final state = await _renderTemplate(
      _TemplateArtifact(
        source: featureBlocStateTemplate,
        target: 'lib/presentation/pages/$feature/cubit/$feature.state.dart',
      ),
      replacements,
    );

    return [
      ScaffoldFile(
        path: page.path,
        content: page.content
            .replaceAll(
              "import 'bloc/$feature.bloc.dart';",
              "import 'cubit/$feature.cubit.dart';",
            )
            .replaceAll('${featureClass}Bloc', '${featureClass}Cubit')
            .replaceAll(
              '..add(const ${featureClass}Started())',
              '..$initialLoadMethod()',
            ),
      ),
      ScaffoldFile(
        path: 'lib/presentation/pages/$feature/cubit/$feature.cubit.dart',
        content: _cubitSource(
          feature: feature,
          featureClass: featureClass,
          folderKey: folderKey,
          initialLoadMethod: initialLoadMethod,
        ),
      ),
      ScaffoldFile(
        path: state.path,
        content: state.content.replaceFirst('.bloc.dart', '.cubit.dart'),
      ),
    ];
  }

  Future<ScaffoldFile> _renderTemplate(
    _TemplateArtifact artifact,
    Map<String, String> replacements,
  ) async {
    final template = File('${repositoryRoot.path}/${artifact.source}');
    if (!await template.exists()) {
      throw ScaffoldException(
        code: 'template_missing',
        message: 'Required canonical template is missing.',
        paths: [artifact.source],
      );
    }
    final source = await template.readAsString();
    return ScaffoldFile(
      path: artifact.target,
      content: _replaceTemplateTokens(source, replacements),
    );
  }
}

ScaffoldFile _formatDart(ScaffoldFile file) => ScaffoldFile(
  path: file.path,
  content: _dartFormatter.format(file.content, uri: file.path),
);

final _dartFormatter = DartFormatter(
  languageVersion: DartFormatter.latestLanguageVersion,
);

final class _TemplateArtifact {
  const _TemplateArtifact({required this.source, required this.target});

  final String source;
  final String target;

  _TemplateArtifact withTarget(String value) =>
      _TemplateArtifact(source: source, target: value);
}

String _replaceTemplateTokens(String source, Map<String, String> replacements) {
  final tokens = replacements.keys.toList(growable: false)
    ..sort((left, right) => right.length.compareTo(left.length));
  final pattern = RegExp(tokens.map(RegExp.escape).join('|'));
  return source.replaceAllMapped(
    pattern,
    (match) => replacements[match.group(0)]!,
  );
}

String _cubitSource({
  required String feature,
  required String featureClass,
  required String folderKey,
  required String initialLoadMethod,
}) =>
    '''import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:project_tweety/data/repositories/$folderKey/$feature.repository.dart';

part '$feature.state.dart';
part '$feature.cubit.freezed.dart';

@injectable
class ${featureClass}Cubit extends Cubit<${featureClass}State> {
  ${featureClass}Cubit(this._repository) : super(const ${featureClass}State());

  final ${featureClass}Repository _repository;

  Future<void> $initialLoadMethod() async {
    emit(
      state.copyWith(status: ${featureClass}Status.loading, errorMessage: null),
    );

    try {
      await _repository.$initialLoadMethod();

      emit(
        state.copyWith(status: ${featureClass}Status.success, errorMessage: null),
      );
    } catch (error, stackTrace) {
      addError(error, stackTrace);
      emit(
        state.copyWith(
          status: ${featureClass}Status.failure,
          errorMessage: 'Unable to load $feature right now.',
        ),
      );
    }
  }
}
''';

void _validateRequest(ScaffoldRequest request) {
  if (request.layers.contains(ScaffoldLayer.domain)) {
    throw const ScaffoldException(
      code: 'domain_not_deterministic',
      message:
          'Domain policy cannot be generated from free text. Use '
          r'$domain-scaffold, then implement the policy with /implement and '
          'TDD.',
    );
  }
  _validateName('feature', request.feature);
  _validateName('folder-key', request.folderKey ?? request.feature);
  _validateName('initial-load-operation', request.initialLoadOperation);
  if (request.controller == ScaffoldController.cubit &&
      _cubitMemberNames.contains(
        _lowerCamelCase(request.initialLoadOperation),
      )) {
    throw ScaffoldException(
      code: 'invalid_name',
      message:
          'initial load operation conflicts with an inherited Cubit member: '
          '${request.initialLoadOperation}',
    );
  }
  final initialLoadVerb = request.initialLoadOperation.split('_').first;
  if (!_safeInitialLoadVerbs.contains(initialLoadVerb)) {
    throw ScaffoldException(
      code: 'unsafe_initial_load_operation',
      message:
          'initial load operations must start with a read-only verb: '
          '${request.initialLoadOperation}',
    );
  }
  final hasSupportedLayers =
      request.layers.length == 2 &&
      request.layers.contains(ScaffoldLayer.data) &&
      request.layers.contains(ScaffoldLayer.presentation);
  if (!hasSupportedLayers) {
    throw const ScaffoldException(
      code: 'unsupported_layers',
      message: 'Deterministic scaffolding requires exactly data,presentation.',
    );
  }
  if (request.domainReason != null) {
    throw const ScaffoldException(
      code: 'domain_reason_without_domain',
      message: '--domain-reason is only valid when domain is selected.',
    );
  }
}

void _validateName(String field, String value) {
  final snakeCase = RegExp(r'^[a-z][a-z0-9]*(?:_[a-z0-9]+)*$');
  final hasValidSyntax = snakeCase.hasMatch(value);
  final initialLoadMethod = hasValidSyntax && field == 'initial-load-operation'
      ? _lowerCamelCase(value)
      : null;
  final collidesWithDart =
      initialLoadMethod != null &&
      (_dartReservedWords.contains(initialLoadMethod) ||
          _objectMemberNames.contains(initialLoadMethod));
  if (!hasValidSyntax || collidesWithDart) {
    throw ScaffoldException(
      code: 'invalid_name',
      message: '$field must be safe snake_case: $value',
    );
  }
}

const _objectMemberNames = {
  'hashCode',
  'noSuchMethod',
  'runtimeType',
  'toString',
};

const _cubitMemberNames = {
  'addError',
  'close',
  'emit',
  'isClosed',
  'onChange',
  'onError',
  'state',
  'stream',
};

const _safeInitialLoadVerbs = {
  'fetch',
  'get',
  'list',
  'load',
  'read',
  'refresh',
  'watch',
};

const _dartReservedWords = {
  'abstract',
  'as',
  'assert',
  'async',
  'await',
  'base',
  'break',
  'case',
  'catch',
  'class',
  'const',
  'continue',
  'covariant',
  'default',
  'deferred',
  'do',
  'dynamic',
  'else',
  'enum',
  'export',
  'extends',
  'extension',
  'external',
  'factory',
  'false',
  'final',
  'finally',
  'for',
  'get',
  'hide',
  'if',
  'implements',
  'import',
  'in',
  'interface',
  'is',
  'late',
  'library',
  'mixin',
  'new',
  'null',
  'of',
  'on',
  'operator',
  'part',
  'required',
  'rethrow',
  'return',
  'sealed',
  'set',
  'show',
  'static',
  'super',
  'switch',
  'sync',
  'this',
  'throw',
  'true',
  'try',
  'type',
  'typedef',
  'var',
  'void',
  'when',
  'while',
  'with',
  'yield',
};

String _pascalCase(String value) => value
    .split('_')
    .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
    .join();

String _lowerCamelCase(String value) {
  final pascal = _pascalCase(value);
  return '${pascal[0].toLowerCase()}${pascal.substring(1)}';
}
