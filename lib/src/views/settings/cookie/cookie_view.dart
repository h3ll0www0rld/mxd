// ignore_for_file: non_constant_identifier_names
import 'package:flutter/material.dart';

class CookieView extends StatelessWidget {
  const CookieView({super.key});

  static const routeName = '/cookie';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("饼干管理"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // 跳转到 WebView 登录页面
            final cookies = await Navigator.pushNamed(context, "/login");

            // 显示返回的 Cookies
            if (cookies != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('登录成功！Cookies: $cookies'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: const Text("点击登录"),
        ),
      ),
    );
  }
}
