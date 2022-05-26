import 'dart:io';

import 'package:cookie_manager_kit/src/cookie_manager_kit_method_channel.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final MethodChannelCookieManagerKit platform =
      MethodChannelCookieManagerKit();
  const MethodChannel channel =
      MethodChannel('v7lin.github.io/cookie_manager_kit');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'loadCookies':
          return <String>[];
      }
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('loadCookies', () async {
    expect(await platform.loadCookies(url: 'https://flutter.dev/'), <Cookie>[]);
  });
}
