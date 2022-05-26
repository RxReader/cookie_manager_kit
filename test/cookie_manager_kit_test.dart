import 'dart:io';

import 'package:cookie_manager_kit/src/cookie_manager_kit.dart';
import 'package:cookie_manager_kit/src/cookie_manager_kit_method_channel.dart';
import 'package:cookie_manager_kit/src/cookie_manager_kit_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCookieManagerKitPlatform
    with MockPlatformInterfaceMixin
    implements CookieManagerKitPlatform {
  @override
  Future<void> saveCookies({
    required String url,
    required List<Cookie> cookies,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<List<Cookie>?> loadCookies({
    required String url,
  }) {
    return Future<List<Cookie>>.value(<Cookie>[]);
  }

  @override
  Future<void> clearAllCookies() {
    throw UnimplementedError();
  }
}

void main() {
  final CookieManagerKitPlatform initialPlatform =
      CookieManagerKitPlatform.instance;

  test('$MethodChannelCookieManagerKit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCookieManagerKit>());
  });

  test('loadCookies', () async {
    final MockCookieManagerKitPlatform fakePlatform =
        MockCookieManagerKitPlatform();
    CookieManagerKitPlatform.instance = fakePlatform;

    expect(
        await CookieManager.instance.loadCookies(url: 'https://flutter.dev/'),
        <Cookie>[]);
  });
}
