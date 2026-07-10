/// Layers accepted by the scaffold request contract.
enum ScaffoldLayer { data, presentation, domain }

/// Presentation controller generated for the feature.
enum ScaffoldController { bloc, cubit }

/// Filesystem action applied to a rendered manifest.
enum ScaffoldMode { dryRun, write, check }

/// Observable outcome of a scaffold filesystem action.
enum ScaffoldStatus { planned, written, clean, drift }

/// Difference between a rendered source input and its repository target.
enum ScaffoldDriftKind { missing, contentMismatch, targetNotFile }

/// Inputs that determine one scaffold manifest.
final class ScaffoldRequest {
  const ScaffoldRequest({
    required this.feature,
    required this.layers,
    required this.initialLoadOperation,
    this.folderKey,
    this.controller = ScaffoldController.bloc,
    this.domainReason,
  });

  final String feature;
  final Set<ScaffoldLayer> layers;
  final String initialLoadOperation;
  final String? folderKey;
  final ScaffoldController controller;
  final String? domainReason;
}

/// One source input in a generated scaffold.
final class ScaffoldFile {
  const ScaffoldFile({required this.path, required this.content});

  final String path;
  final String content;

  Map<String, Object> toJson() => {'path': path, 'content': content};
}

/// Exact, ordered source files for a generated scaffold.
final class ScaffoldManifest {
  ScaffoldManifest(Iterable<ScaffoldFile> files)
    : files = List.unmodifiable(files);

  final List<ScaffoldFile> files;

  Map<String, Object> toJson() => {
    'files': files.map((file) => file.toJson()).toList(growable: false),
  };
}

/// One ordered difference found by [ScaffoldMode.check].
final class ScaffoldDrift {
  const ScaffoldDrift({required this.path, required this.kind});

  final String path;
  final ScaffoldDriftKind kind;

  Map<String, Object> toJson() => {'path': path, 'kind': kind.name};
}

/// Result of applying one [ScaffoldMode] to a rendered manifest.
final class ScaffoldExecution {
  const ScaffoldExecution({
    required this.mode,
    required this.status,
    required this.manifest,
    this.drift = const [],
  });

  final ScaffoldMode mode;
  final ScaffoldStatus status;
  final ScaffoldManifest manifest;
  final List<ScaffoldDrift> drift;
}

/// Structured failure exposed by the scaffold library and CLI.
final class ScaffoldException implements Exception {
  const ScaffoldException({
    required this.code,
    required this.message,
    this.paths = const [],
  });

  final String code;
  final String message;
  final List<String> paths;

  Map<String, Object> toJson() => {
    'code': code,
    'message': message,
    if (paths.isNotEmpty) 'paths': paths,
  };

  @override
  String toString() => '$code: $message';
}
