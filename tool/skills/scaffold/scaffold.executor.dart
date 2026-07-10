import 'dart:io';

import 'scaffold.models.dart';

/// Applies rendered scaffold manifests to a supplied repository root.
///
/// The default commit atomically renames staged content over each individual
/// reserved target. A caught failure rolls back targets reserved by this run;
/// this is not an all-or-nothing, crash-atomic transaction across directories.
final class ScaffoldExecutor {
  ScaffoldExecutor({
    required this.repositoryRoot,
    Future<void> Function(File staged, File target)? commit,
    Future<void> Function(File target)? reserve,
  }) : _commit = commit ?? _renameStagedFile,
       _reserve = reserve ?? _reserveTarget;

  final Directory repositoryRoot;
  final Future<void> Function(File staged, File target) _commit;
  final Future<void> Function(File target) _reserve;

  Future<ScaffoldExecution> execute(
    ScaffoldManifest manifest, {
    ScaffoldMode mode = ScaffoldMode.dryRun,
  }) async {
    final invalidPaths = manifest.files
        .map((artifact) => artifact.path)
        .where((path) => !_isSafeManifestPath(path))
        .toList(growable: false);
    if (invalidPaths.isNotEmpty) {
      throw ScaffoldException(
        code: 'invalid_manifest_path',
        message: 'Manifest paths must remain inside the repository root.',
        paths: invalidPaths,
      );
    }

    switch (mode) {
      case ScaffoldMode.dryRun:
        return ScaffoldExecution(
          mode: mode,
          status: ScaffoldStatus.planned,
          manifest: manifest,
        );
      case ScaffoldMode.write:
        final preflight = await _preflightWrite(manifest);
        await _commitManifest(
          manifest,
          missingParents: preflight.missingParents,
        );
        return ScaffoldExecution(
          mode: mode,
          status: ScaffoldStatus.written,
          manifest: manifest,
        );
      case ScaffoldMode.check:
        return _check(manifest);
    }
  }

  Future<_WritePreflight> _preflightWrite(ScaffoldManifest manifest) async {
    final invalidParents = <String>{};
    final missingParents = <String>{};
    for (final artifact in manifest.files) {
      final segments = artifact.path.split('/');
      var relativeParent = '';
      for (final segment in segments.take(segments.length - 1)) {
        relativeParent = relativeParent.isEmpty
            ? segment
            : '$relativeParent/$segment';
        final type = await FileSystemEntity.type(
          '${repositoryRoot.path}/$relativeParent',
          followLinks: false,
        );
        if (type != FileSystemEntityType.notFound &&
            type != FileSystemEntityType.directory) {
          invalidParents.add(relativeParent);
          break;
        }
        if (type == FileSystemEntityType.notFound) {
          missingParents.add(relativeParent);
        }
      }
    }
    if (invalidParents.isNotEmpty) {
      throw ScaffoldException(
        code: 'parent_not_directory',
        message: 'Scaffold target parents must be real directories.',
        paths: invalidParents.toList(growable: false)..sort(),
      );
    }

    final existingTargets = <String>[];
    for (final artifact in manifest.files) {
      final targetPath = '${repositoryRoot.path}/${artifact.path}';
      final type = await FileSystemEntity.type(targetPath, followLinks: false);
      if (type != FileSystemEntityType.notFound) {
        existingTargets.add(artifact.path);
      }
    }
    if (existingTargets.isNotEmpty) {
      throw ScaffoldException(
        code: 'targets_exist',
        message: 'Refusing to overwrite existing scaffold targets.',
        paths: existingTargets,
      );
    }

    return _WritePreflight(missingParents);
  }

  Future<ScaffoldExecution> _check(ScaffoldManifest manifest) async {
    final drift = <ScaffoldDrift>[];
    for (final artifact in manifest.files) {
      final path = '${repositoryRoot.path}/${artifact.path}';
      final type = await FileSystemEntity.type(path, followLinks: false);
      if (type == FileSystemEntityType.notFound) {
        drift.add(
          ScaffoldDrift(path: artifact.path, kind: ScaffoldDriftKind.missing),
        );
      } else if (type != FileSystemEntityType.file) {
        drift.add(
          ScaffoldDrift(
            path: artifact.path,
            kind: ScaffoldDriftKind.targetNotFile,
          ),
        );
      } else if (await File(path).readAsString() != artifact.content) {
        drift.add(
          ScaffoldDrift(
            path: artifact.path,
            kind: ScaffoldDriftKind.contentMismatch,
          ),
        );
      }
    }
    return ScaffoldExecution(
      mode: ScaffoldMode.check,
      status: drift.isEmpty ? ScaffoldStatus.clean : ScaffoldStatus.drift,
      manifest: manifest,
      drift: List.unmodifiable(drift),
    );
  }

  Future<void> _commitManifest(
    ScaffoldManifest manifest, {
    required Set<String> missingParents,
  }) async {
    final stagingDirectory = Directory(
      '${repositoryRoot.path}/.scaffold_stage_${pid}_'
      '${DateTime.now().microsecondsSinceEpoch}',
    );
    final reservedTargets = <String>[];
    final orderedParents = missingParents.toList(growable: false)
      ..sort((left, right) {
        final depthComparison = left
            .split('/')
            .length
            .compareTo(right.split('/').length);
        return depthComparison != 0 ? depthComparison : left.compareTo(right);
      });

    try {
      await stagingDirectory.create();
      for (var index = 0; index < manifest.files.length; index++) {
        await File(
          '${stagingDirectory.path}/$index.stage',
        ).writeAsString(manifest.files[index].content);
      }
      for (final parent in orderedParents) {
        await Directory('${repositoryRoot.path}/$parent').create();
      }
      for (final artifact in manifest.files) {
        final target = File('${repositoryRoot.path}/${artifact.path}');
        await _reserve(target);
        reservedTargets.add(artifact.path);
      }
      for (var index = 0; index < manifest.files.length; index++) {
        final targetPath = manifest.files[index].path;
        await _commit(
          File('${stagingDirectory.path}/$index.stage'),
          File('${repositoryRoot.path}/$targetPath'),
        );
      }
    } on Object catch (error) {
      for (final targetPath in reservedTargets.reversed) {
        await _deleteEntity('${repositoryRoot.path}/$targetPath');
      }
      for (final parent in orderedParents.reversed) {
        final directory = Directory('${repositoryRoot.path}/$parent');
        if (await directory.exists() && await directory.list().isEmpty) {
          await directory.delete();
        }
      }
      throw ScaffoldException(
        code: 'write_failed',
        message: 'Scaffold commit failed and was rolled back: $error',
        paths: reservedTargets,
      );
    } finally {
      if (await stagingDirectory.exists()) {
        await stagingDirectory.delete(recursive: true);
      }
    }
  }
}

final class _WritePreflight {
  const _WritePreflight(this.missingParents);

  final Set<String> missingParents;
}

Future<void> _renameStagedFile(File staged, File target) async {
  await staged.rename(target.path);
}

Future<void> _reserveTarget(File target) async {
  await target.create(exclusive: true);
}

Future<void> _deleteEntity(String path) async {
  final type = await FileSystemEntity.type(path, followLinks: false);
  switch (type) {
    case FileSystemEntityType.file:
      await File(path).delete();
    case FileSystemEntityType.directory:
      await Directory(path).delete(recursive: true);
    case FileSystemEntityType.link:
      await Link(path).delete();
    case FileSystemEntityType.notFound:
      return;
    case FileSystemEntityType.pipe:
    case FileSystemEntityType.unixDomainSock:
      await File(path).delete();
  }
}

bool _isSafeManifestPath(String path) {
  if (path.isEmpty ||
      path.startsWith('/') ||
      path.contains(r'\') ||
      path.contains('\u0000')) {
    return false;
  }
  return path
      .split('/')
      .every(
        (segment) => segment.isNotEmpty && segment != '.' && segment != '..',
      );
}
