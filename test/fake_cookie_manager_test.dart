import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cookie_manager/fake_cookie_manager.dart';

void main() {
  const MethodChannel channel = MethodChannel('fake_cookie_manager');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FakeCookieManager.platformVersion, '42');
  });
}
