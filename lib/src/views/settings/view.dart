import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controller.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required SettingsController controller});

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SettingsController>(context);
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.theme),
                  DropdownButton<ThemeMode>(
                      value: controller.themeMode,
                      onChanged: controller.updateThemeMode,
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child:
                              Text(AppLocalizations.of(context)!.systemTheme),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(AppLocalizations.of(context)!.lightTheme),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(AppLocalizations.of(context)!.darkTheme),
                        )
                      ]),
                ],
              ),
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.fontSize,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: controller.fontSize,
                      min: 8.0,
                      max: 30.0,
                      divisions: 22,
                      label: controller.fontSize.toStringAsFixed(1),
                      onChanged: (value) {
                        controller.updateFontSize(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, "/cookie");
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
