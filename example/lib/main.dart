import 'dart:async';
import 'dart:io';

import 'package:cookie_manager_kit/cookie_manager_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runZoned(() {
    runApp(MyApp());
  }, onError: (dynamic error, dynamic stack) {
    print(error);
    print(stack);
  });

  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const String _TEST_URL = 'http://www.baidu.com/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CookieManager Kit'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('保存Cookie'),
            onTap: () async {
              Cookie cookie = Cookie.fromSetCookieValue(
                  'JSESSIONID=842DE78C987BEE8334F6855A642075D1; Path=/; HttpOnly');
              await CookieManager.saveCookies(
                url: _TEST_URL,
                cookies: <Cookie>[cookie],
              );
              _showTips('保存Cookie', 'cookie: ${cookie.toString()}');
            },
          ),
          ListTile(
            title: const Text('读取Cookie'),
            onTap: () async {
              List<Cookie> cookies =
                  await CookieManager.loadCookies(url: _TEST_URL);
              if (cookies != null && cookies.isNotEmpty) {
                _showTips('读取Cookie', 'cookie: ${cookies[0].toString()}');
              } else {
                _showTips('读取Cookie', '没有相关Cookie');
              }
            },
          ),
          ListTile(
            title: const Text('清除所有Cookie'),
            onTap: () async {
              await CookieManager.clearAllCookies();
              _showTips('清除所有Cookie', '所有Cookie都已清除');
            },
          ),
        ],
      ),
    );
  }

  void _showTips(String title, String content) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
        );
      },
    );
  }
}
