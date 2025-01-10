import 'package:flutter/material.dart';
import 'controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required SettingsController controller});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, "/appearance");
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.draw),
                    Container(
                      width: 16,
                    ),
                    Text(
                      AppLocalizations.of(context)!.appearanceManager,
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, "/cookie");
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.cookie),
                    Container(
                      width: 16,
                    ),
                    Text(
                      AppLocalizations.of(context)!.cookieManager,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
