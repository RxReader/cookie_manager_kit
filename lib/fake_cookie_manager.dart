import 'dart:async';

import 'package:flutter/services.dart';

class FakeCookieManager {
  static const MethodChannel _channel =
      const MethodChannel('fake_cookie_manager');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
