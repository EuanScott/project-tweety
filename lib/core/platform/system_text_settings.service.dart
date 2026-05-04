import 'package:flutter/services.dart';

class SystemTextSettingsService {
  SystemTextSettingsService._();

  static const MethodChannel _channel = MethodChannel(
    'project_tweety/system_text_settings',
  );

  static Future<bool> open() async {
    try {
      return await _channel.invokeMethod<bool>('openTextSettings') ?? false;
    } on PlatformException {
      return false;
    }
  }
}
