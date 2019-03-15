import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class CookieManager {
  const CookieManager._();

  factory CookieManager.shared() {
    return _instance;
  }

  static const CookieManager _instance = CookieManager._();

  static const String _METHOD_SAVECOOKIES = 'saveCookies';
  static const String _METHOD_LOADCOOKIES = 'loadCookies';
  static const String _METHOD_REMOVEALLCOOKIES = 'removeAllCookies';

  static const String _ARGUMENT_KEY_URL = 'url';
  static const String _ARGUMENT_KEY_COOKIES = 'cookies';

  static const MethodChannel _channel =
      MethodChannel('v7lin.github.io/fake_cookie_manager');

  Future<void> saveCookies(String url, List<Cookie> cookies) {
    assert(url != null && url.isNotEmpty);
    assert(cookies != null);
    return _channel.invokeMethod(
      _METHOD_SAVECOOKIES,
      <String, dynamic>{
        _ARGUMENT_KEY_URL: url,
        _ARGUMENT_KEY_COOKIES: cookies.map((Cookie cookie) {
          return cookie.toString();
        }).toList(),
      },
    );
  }

  Future<List<Cookie>> loadCookies(String url) {
    assert(url != null && url.isNotEmpty);
    return _channel.invokeMethod(
      _METHOD_LOADCOOKIES,
      <String, dynamic>{
        _ARGUMENT_KEY_URL: url,
      },
    ).then((dynamic value) {
      List<dynamic> cookies = value as List<dynamic>;
      return cookies.isNotEmpty
          ? cookies.map((dynamic cookie) {
              return Cookie.fromSetCookieValue(cookie as String);
            }).toList()
          : List<Cookie>.unmodifiable(const <Cookie>[]);
    });
  }

  Future<void> clearAllCookies() {
    return _channel.invokeMethod(_METHOD_REMOVEALLCOOKIES);
  }
}