import 'dart:async';

import 'package:flutter/services.dart';

class CookieManagerKit {
  static const MethodChannel _channel = const MethodChannel('cookie_manager_kit');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
