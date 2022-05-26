import 'dart:io';

import 'package:cookie_manager_kit/src/cookie_manager_kit_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// An implementation of [CookieManagerKitPlatform] that uses method channels.
class MethodChannelCookieManagerKit extends CookieManagerKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final MethodChannel methodChannel =
      const MethodChannel('v7lin.github.io/cookie_manager_kit');

  @override
  Future<void> saveCookies({
    required String url,
    required List<Cookie> cookies,
  }) {
    return methodChannel.invokeMethod<void>(
      'saveCookies',
      <String, dynamic>{
        'url': url,
        'cookies': cookies.map((Cookie cookie) {
          return cookie.toString();
        }).toList(),
      },
    );
  }

  @override
  Future<List<Cookie>?> loadCookies({
    required String url,
  }) async {
    final List<String>? cookies = await methodChannel.invokeListMethod<String>(
      'loadCookies',
      <String, dynamic>{
        'url': url,
      },
    );
    return cookies?.map((String cookie) {
      return Cookie.fromSetCookieValue(cookie);
    }).toList();
  }

  @override
  Future<void> clearAllCookies() {
    return methodChannel.invokeMethod<void>('removeAllCookies');
  }
}
