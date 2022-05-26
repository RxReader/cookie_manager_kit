import 'dart:io';

import 'package:cookie_manager_kit/cookie_manager_kit.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text('CookieManager Kit'),
            ),
            body: ListView(
              children: <Widget>[
                ListTile(
                  title: Text('保存Cookie'),
                  onTap: () async {
                    final Cookie cookie = Cookie.fromSetCookieValue(
                        'clientId=3; expires=Tue, 25-Jan-2022 09:34:00 GMT; Max-Age=25920000; path=/; domain=baidu.com');
                    await CookieManager.instance.saveCookies(
                      url: 'http://www.baidu.com/',
                      cookies: <Cookie>[cookie],
                    );
                    // ignore: use_build_context_synchronously
                    _showTips(
                        context, '保存Cookie', 'cookie: ${cookie.toString()}');
                  },
                ),
                ListTile(
                  title: Text('读取Cookie'),
                  onTap: () async {
                    final List<Cookie>? cookies = await CookieManager.instance
                        .loadCookies(url: 'http://yun.baidu.com/');
                    if (cookies?.isNotEmpty ?? false) {
                      // ignore: use_build_context_synchronously
                      _showTips(context, '读取Cookie',
                          'cookie: ${cookies![0].toString()}');
                    } else {
                      // ignore: use_build_context_synchronously
                      _showTips(context, '读取Cookie', '没有相关Cookie');
                    }
                  },
                ),
                ListTile(
                  title: Text('清除所有Cookie'),
                  onTap: () async {
                    await CookieManager.instance.clearAllCookies();
                    // ignore: use_build_context_synchronously
                    _showTips(context, '清除所有Cookie', '所有Cookie都已清除');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTips(BuildContext context, String title, String content) {
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
