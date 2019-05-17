import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fake_cookie_manager/fake_cookie_manager.dart';

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
  static const String TEST_URL =
      'http://rap.xrjiot.cn/mockjsdata/13/api/app/v1/login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FakeCookieManager Demo'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('保存Cookie'),
            onTap: () async {
              Cookie cookie = Cookie.fromSetCookieValue(
                  'JSESSIONID=842DE78C987BEE8334F6855A642075D1; Path=/; HttpOnly');
              await CookieManager.saveCookies(url: TEST_URL, cookies: [cookie]);
              _showTips('保存Cookie', 'cookie: ${cookie.toString()}');
            },
          ),
          ListTile(
            title: Text('读取Cookie'),
            onTap: () async {
              List<Cookie> cookies =
                  await CookieManager.loadCookies(url: TEST_URL);
              if (cookies != null && cookies.isNotEmpty) {
                _showTips('读取Cookie', 'cookie: ${cookies[0].toString()}');
              } else {
                _showTips('读取Cookie', '没有相关Cookie');
              }
            },
          ),
          ListTile(
            title: Text('清除所有Cookie'),
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
    showDialog(
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
