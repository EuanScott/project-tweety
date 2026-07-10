import 'dart:convert';

final class CodexEventSummary {
  const CodexEventSummary({
    required this.events,
    required this.usage,
    required this.toolCalls,
    required this.commands,
    required this.finalOutput,
    required this.metadata,
    required this.harnessErrors,
  });

  factory CodexEventSummary.parse(String jsonLines) {
    final events = <Map<String, dynamic>>[];
    final harnessErrors = <String>[];
    final lines = const LineSplitter().convert(jsonLines);
    for (var index = 0; index < lines.length; index += 1) {
      final line = lines[index];
      if (line.trim().isEmpty) {
        continue;
      }
      try {
        final decoded = jsonDecode(line);
        if (decoded is Map<String, dynamic>) {
          events.add(decoded);
        } else {
          events.add({'type': 'unparsed', 'raw': line});
          harnessErrors.add(
            'Codex emitted non-object JSONL at line ${index + 1}.',
          );
        }
      } on FormatException {
        events.add({'type': 'unparsed', 'raw': line});
        harnessErrors.add('Codex emitted unparsed JSONL at line ${index + 1}.');
      }
    }

    var usage = const TokenUsage.zero();
    var hasTerminalUsage = false;
    var hasMalformedTerminalUsage = false;
    var hasTerminalEvent = false;
    var hasFinalAgentOutput = false;
    final commands = <String>[];
    final toolIds = <String>{};
    var unkeyedToolCalls = 0;
    var finalOutput = '';
    final metadata = <String, dynamic>{};

    for (final event in events) {
      final model = _findFirstString(event, const ['model', 'model_name']);
      if (model != null) {
        metadata['model'] = model;
      }
      final rawUsage = event['usage'];
      if (event['type'] == 'turn.completed') {
        hasTerminalEvent = true;
        final parsedUsage = rawUsage is Map<String, dynamic>
            ? TokenUsage.tryParse(rawUsage)
            : null;
        if (parsedUsage == null) {
          hasMalformedTerminalUsage = true;
        } else {
          hasTerminalUsage = true;
          usage = usage + parsedUsage;
        }
      }
      final item = event['item'];
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final type = item['type'];
      if (event['type'] == 'item.completed' && type == 'agent_message') {
        final text = item['text'];
        if (text is String && text.trim().isNotEmpty) {
          hasFinalAgentOutput = true;
          finalOutput = text;
        }
        continue;
      }
      if (!_isToolType(type)) {
        continue;
      }
      final id = item['id'];
      if (id is String && id.isNotEmpty) {
        toolIds.add(id);
      } else {
        unkeyedToolCalls += 1;
      }
      if (type == 'command_execution') {
        final command = item['command'];
        if (command is String) {
          commands.add(command);
        }
      }
    }

    if (hasMalformedTerminalUsage) {
      harnessErrors.add('Codex JSONL contains malformed terminal usage.');
    }
    if (!hasTerminalUsage && !hasTerminalEvent) {
      harnessErrors.add('Codex JSONL is missing terminal usage.');
    }
    if (!hasFinalAgentOutput) {
      harnessErrors.add('Codex JSONL is missing final agent output.');
    }

    return CodexEventSummary(
      events: events,
      usage: usage,
      toolCalls: toolIds.length + unkeyedToolCalls,
      commands: commands,
      finalOutput: finalOutput,
      metadata: metadata,
      harnessErrors: harnessErrors,
    );
  }

  final List<Map<String, dynamic>> events;
  final TokenUsage usage;
  final int toolCalls;
  final List<String> commands;
  final String finalOutput;
  final Map<String, dynamic> metadata;
  final List<String> harnessErrors;

  static bool _isToolType(Object? type) => const {
    'command_execution',
    'mcp_tool_call',
    'tool_call',
    'web_search',
  }.contains(type);

  static String? _findFirstString(
    Map<String, dynamic> value,
    List<String> keys,
  ) {
    for (final key in keys) {
      final candidate = value[key];
      if (candidate is String && candidate.isNotEmpty) {
        return candidate;
      }
    }
    for (final nested in value.values.whereType<Map<String, dynamic>>()) {
      final candidate = _findFirstString(nested, keys);
      if (candidate != null) {
        return candidate;
      }
    }
    return null;
  }
}

final class TokenUsage {
  const TokenUsage({
    required this.inputTokens,
    required this.cachedInputTokens,
    required this.outputTokens,
  });

  const TokenUsage.zero()
    : inputTokens = 0,
      cachedInputTokens = 0,
      outputTokens = 0;

  static TokenUsage? tryParse(Map<String, dynamic> json) {
    final input = _readField(json, 'input_tokens', 'inputTokens');
    final output = _readField(json, 'output_tokens', 'outputTokens');
    final cached = _readField(json, 'cached_input_tokens', 'cachedInputTokens');
    if (!_isNonNegativeInteger(input.value) ||
        !_isNonNegativeInteger(output.value) ||
        (cached.present && !_isNonNegativeInteger(cached.value))) {
      return null;
    }
    return TokenUsage(
      inputTokens: input.value! as int,
      cachedInputTokens: cached.present ? cached.value! as int : 0,
      outputTokens: output.value! as int,
    );
  }

  final int inputTokens;
  final int cachedInputTokens;
  final int outputTokens;

  int get totalTokens => inputTokens + outputTokens;

  TokenUsage operator +(TokenUsage other) => TokenUsage(
    inputTokens: inputTokens + other.inputTokens,
    cachedInputTokens: cachedInputTokens + other.cachedInputTokens,
    outputTokens: outputTokens + other.outputTokens,
  );

  Map<String, dynamic> toJson() => {
    'inputTokens': inputTokens,
    'cachedInputTokens': cachedInputTokens,
    'outputTokens': outputTokens,
    'totalTokens': totalTokens,
  };

  static ({bool present, Object? value}) _readField(
    Map<String, dynamic> json,
    String snakeCase,
    String camelCase,
  ) {
    if (json.containsKey(snakeCase)) {
      return (present: true, value: json[snakeCase]);
    }
    if (json.containsKey(camelCase)) {
      return (present: true, value: json[camelCase]);
    }
    return (present: false, value: null);
  }

  static bool _isNonNegativeInteger(Object? value) =>
      value is int && value >= 0;
}
