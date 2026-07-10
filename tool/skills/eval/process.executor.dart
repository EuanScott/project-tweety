import 'dart:async';
import 'dart:convert';
import 'dart:io';

final class ProcessRequest {
  const ProcessRequest({
    required this.executable,
    required this.arguments,
    required this.workingDirectory,
    this.standardInput,
    this.timeout,
  });

  final String executable;
  final List<String> arguments;
  final String workingDirectory;
  final String? standardInput;
  final Duration? timeout;
}

final class ProcessExecution {
  const ProcessExecution({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
    this.timedOut = false,
  });

  final int exitCode;
  final String stdout;
  final String stderr;
  final bool timedOut;
}

abstract interface class ProcessExecutor {
  Future<ProcessExecution> run(ProcessRequest request);
}

typedef ProcessStarter =
    Future<Process> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
    });

final class SystemProcessExecutor implements ProcessExecutor {
  SystemProcessExecutor({ProcessStarter? processStarter})
    : _processStarter = processStarter ?? _startProcess;

  final ProcessStarter _processStarter;

  @override
  Future<ProcessExecution> run(ProcessRequest request) async {
    final process = await _processStarter(
      request.executable,
      request.arguments,
      workingDirectory: request.workingDirectory,
    );
    final stdoutFuture = utf8.decoder.bind(process.stdout).join();
    final stderrFuture = utf8.decoder.bind(process.stderr).join();
    final standardInput = request.standardInput;
    if (standardInput != null) {
      process.stdin.write(standardInput);
    }
    await process.stdin.close();
    final exitCodeFuture = process.exitCode;
    var timedOut = false;
    late final int exitCode;
    try {
      exitCode = request.timeout == null
          ? await exitCodeFuture
          : await exitCodeFuture.timeout(request.timeout!);
    } on TimeoutException {
      timedOut = true;
      process.kill(ProcessSignal.sigterm);
      try {
        exitCode = await exitCodeFuture.timeout(const Duration(seconds: 2));
      } on TimeoutException {
        process.kill(ProcessSignal.sigkill);
        exitCode = await exitCodeFuture;
      }
    }
    return ProcessExecution(
      exitCode: exitCode,
      stdout: await stdoutFuture,
      stderr: await stderrFuture,
      timedOut: timedOut,
    );
  }

  static Future<Process> _startProcess(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) =>
      Process.start(executable, arguments, workingDirectory: workingDirectory);
}
