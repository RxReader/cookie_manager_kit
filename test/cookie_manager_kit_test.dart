import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookie_manager_kit/cookie_manager_kit.dart';

void main() {
  const MethodChannel channel = MethodChannel('cookie_manager_kit');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await CookieManagerKit.platformVersion, '42');
  });
}
