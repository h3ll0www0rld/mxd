import 'package:flutter/material.dart';
import 'package:mxd/src/core/widgets/text.dart';
import 'package:mxd/src/views/settings/controller.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppearanceView extends StatelessWidget {
  const AppearanceView({super.key});
  static const routeName = '/appearance';

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SettingsController>(context);

    return Scaffold(
      extendBody: true,
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.appearanceManager)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.of(context)!.theme),
                DropdownButton<ThemeMode>(
                  value: controller.themeMode,
                  onChanged: controller.updateThemeMode,
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: WidgetText(
                          text: AppLocalizations.of(context)!.systemTheme),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: WidgetText(
                          text: AppLocalizations.of(context)!.lightTheme),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: WidgetText(
                          text: AppLocalizations.of(context)!.darkTheme),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: WidgetText(
                        text: AppLocalizations.of(context)!.titleFontSize)),
                Expanded(
                  child: Slider(
                    value: controller.titleFontSize,
                    min: 8.0,
                    max: 30.0,
                    divisions: 22,
                    label: controller.titleFontSize.toStringAsFixed(1),
                    onChanged: (value) {
                      controller.updateTitleFontSize(value);
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: WidgetText(
                        text: AppLocalizations.of(context)!.contentFontSize)),
                Expanded(
                  child: Slider(
                    value: controller.contentFontSize,
                    min: 8.0,
                    max: 30.0,
                    divisions: 22,
                    label: controller.contentFontSize.toStringAsFixed(1),
                    onChanged: (value) {
                      controller.updateContentFontSize(value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
