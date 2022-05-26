import 'dart:io';

import 'package:cookie_manager_kit/src/cookie_manager_kit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class CookieManagerKitPlatform extends PlatformInterface {
  /// Constructs a CookieManagerKitPlatform.
  CookieManagerKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static CookieManagerKitPlatform _instance = MethodChannelCookieManagerKit();

  /// The default instance of [CookieManagerKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelCookieManagerKit].
  static CookieManagerKitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CookieManagerKitPlatform] when
  /// they register themselves.
  static set instance(CookieManagerKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> saveCookies({
    required String url,
    required List<Cookie> cookies,
  }) {
    throw UnimplementedError(
        'saveCookies({required url, required cookies}) has not been implemented.');
  }

  Future<List<Cookie>?> loadCookies({
    required String url,
  }) {
    throw UnimplementedError(
        'loadCookies({required url}) has not been implemented.');
  }

  Future<void> clearAllCookies() {
    throw UnimplementedError('clearAllCookies() has not been implemented.');
  }
}
