import 'dart:convert';
import 'dart:io';

final class EvalManifest {
  static const defaultTimeout = Duration(minutes: 10);

  const new({required this.tiers, required this.cases});

  factory read(File file) {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, dynamic> || decoded['schemaVersion'] != 1) {
      throw const FormatException('Manifest schemaVersion must be 1.');
    }
    final rawTiers = decoded['tiers'];
    final rawCases = decoded['cases'];
    if (rawTiers is! Map<String, dynamic> || rawCases is! List) {
      throw const FormatException('Manifest requires tiers and cases.');
    }
    final tiers = <String, EvalTier>{};
    for (final MapEntry(key: name, value: value) in rawTiers.entries) {
      if (value is! Map<String, dynamic>) {
        throw FormatException('Tier "$name" must be an object.');
      }
      final defaultReplicas = value['defaultReplicas'];
      if (defaultReplicas is! int || defaultReplicas < 1) {
        throw FormatException(
          'Tier "$name" defaultReplicas must be a positive integer.',
        );
      }
      final timeout = _readTimeout(
        value,
        owner: 'Tier "$name"',
        fallback: defaultTimeout,
      );
      tiers[name] = EvalTier(
        name: name,
        defaultReplicas: defaultReplicas,
        timeout: timeout,
      );
    }
    final cases = rawCases
        .map((value) {
          if (value is! Map<String, dynamic>) {
            throw const FormatException('Each case must be an object.');
          }
          return EvalCase.fromJson(value);
        })
        .toList(growable: false);
    final ids = <String>{};
    for (final evalCase in cases) {
      if (!tiers.containsKey(evalCase.tier)) {
        throw FormatException(
          'Case "${evalCase.id}" refers to unknown tier "${evalCase.tier}".',
        );
      }
      if (!ids.add(evalCase.id)) {
        throw FormatException('Duplicate case id "${evalCase.id}".');
      }
    }
    return EvalManifest(tiers: tiers, cases: cases);
  }

  final Map<String, EvalTier> tiers;
  final List<EvalCase> cases;

  static Duration _readTimeout(
    Map<String, dynamic> json, {
    required String owner,
    required Duration fallback,
  }) {
    final value = json['timeoutSeconds'];
    if (value == null) {
      return fallback;
    }
    if (value is! int || value < 1) {
      throw FormatException(
        '$owner timeoutSeconds must be a positive integer.',
      );
    }
    return Duration(seconds: value);
  }
}

final class EvalTier {
  const new({
    required this.name,
    required this.defaultReplicas,
    required this.timeout,
  });

  final String name;
  final int defaultReplicas;
  final Duration timeout;

  Map<String, dynamic> toJson() => {
    'name': name,
    'defaultReplicas': defaultReplicas,
    'timeoutSeconds': timeout.inSeconds,
  };
}

final class EvalCase {
  const new({
    required this.id,
    required this.skill,
    required this.category,
    required this.tier,
    required this.prompt,
    required this.invariants,
    required this.timeout,
  });

  factory fromJson(Map<String, dynamic> json) {
    String requireString(String key) {
      final value = json[key];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('Case field "$key" must be a non-empty string.');
      }
      return value;
    }

    final rawInvariants = json['invariants'];
    if (rawInvariants is! List || rawInvariants.isEmpty) {
      throw const FormatException('Case invariants must be a non-empty list.');
    }
    return EvalCase(
      id: requireString('id'),
      skill: requireString('skill'),
      category: requireString('category'),
      tier: requireString('tier'),
      prompt: requireString('prompt'),
      timeout: _optionalTimeout(json),
      invariants: rawInvariants
          .map((value) {
            if (value is! Map<String, dynamic>) {
              throw const FormatException('Each invariant must be an object.');
            }
            return EvalInvariant.fromJson(value);
          })
          .toList(growable: false),
    );
  }

  final String id;
  final String skill;
  final String category;
  final String tier;
  final String prompt;
  final List<EvalInvariant> invariants;
  final Duration? timeout;

  static Duration? _optionalTimeout(Map<String, dynamic> json) {
    if (json['timeoutSeconds'] == null) {
      return null;
    }
    return EvalManifest._readTimeout(
      json,
      owner: 'Case "${json['id']}"',
      fallback: EvalManifest.defaultTimeout,
    );
  }
}

final class EvalInvariant {
  const new({
    required this.id,
    required this.kind,
    required this.configuration,
  });

  factory fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final kind = json['kind'];
    if (id is! String || id.isEmpty || kind is! String || kind.isEmpty) {
      throw const FormatException('Invariant requires string id and kind.');
    }
    return EvalInvariant(id: id, kind: kind, configuration: json);
  }

  final String id;
  final String kind;
  final Map<String, dynamic> configuration;
}
