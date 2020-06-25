import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cookie_manager_kit/cookie_manager_kit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel =
      MethodChannel('v7lin.github.io/cookie_manager_kit');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'saveCookies':
          return null;
        case 'loadCookies':
          return <String>[];
        case 'removeAllCookies':
          return null;
      }
      throw PlatformException(code: '0', message: '想啥呢，升级插件不想升级Mock？');
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('loadCookies', () async {
    expect(await CookieManager.loadCookies(url: 'http://www.baidu.com/'),
        const <String>[]);
  });
}
