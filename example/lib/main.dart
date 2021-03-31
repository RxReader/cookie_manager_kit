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
    SystemUiOverlayStyle systemUiOverlayStyle = const SystemUiOverlayStyle(statusBarColor: Colors.transparent);
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
              final Cookie cookie = Cookie.fromSetCookieValue('clientId=3; expires=Tue, 25-Jan-2022 09:34:00 GMT; Max-Age=25920000; path=/; domain=baidu.com');
              await CookieManager.saveCookies(
                url: 'http://www.baidu.com/',
                cookies: <Cookie>[cookie],
              );
              _showTips('保存Cookie', 'cookie: ${cookie.toString()}');
            },
          ),
          ListTile(
            title: const Text('读取Cookie'),
            onTap: () async {
              final List<Cookie> cookies = await CookieManager.loadCookies(url: 'http://yun.baidu.com/');
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
