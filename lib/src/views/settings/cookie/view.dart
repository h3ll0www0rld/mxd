import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mxd/src/views/settings/cookie/controller.dart';

import 'package:mxd/src/views/settings/cookie/widgets/cookie_card.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CookieView extends StatelessWidget {
  CookieView({super.key});
  static const routeName = '/cookie';

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.cookieManager),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.pasteCookieUrl,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    final uriText = _controller.text;
                    if (uriText.isNotEmpty) {
                      final uri = Uri.parse(uriText);
                      final textParam = uri.queryParameters['text'];

                      if (textParam != null) {
                        final decodedText =
                            utf8.decode(base64Decode(textParam));

                        Provider.of<CookiesController>(context, listen: false)
                            .addCookie(decodedText);
                        _controller.clear();
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<CookiesController>(
              builder: (context, controller, child) {
                return ListView.builder(
                  itemCount: controller.cookies.length,
                  itemBuilder: (context, index) {
                    final cookie = controller.cookies[index];
                    return CookieCard(
                      cookie: cookie,
                      onChanged: (cookie) {
                        controller.setEnabledCookie(cookie);
                      },
                      onDelete: () {
                        controller.removeCookie(cookie.name);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
