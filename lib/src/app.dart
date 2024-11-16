import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mxd/src/provider/forum_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mxd/src/home/home_view.dart';
import 'package:mxd/src/thread/thread_view.dart';

import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ForumProvider()),
          ],
          child: MaterialApp(
            restorationScopeId: 'app',
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh', ''),
            ],
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context)!.appTitle,
            theme: ThemeData(),
            darkTheme: ThemeData.dark(),
            themeMode: settingsController.themeMode,
            onGenerateRoute: (RouteSettings routeSettings) {
              final Uri uri = Uri.parse(routeSettings.name ?? '');

              switch (uri.path) {
                case SettingsView.routeName:
                  return MaterialPageRoute<void>(
                    settings: routeSettings,
                    builder: (BuildContext context) {
                      return SettingsView(controller: settingsController);
                    },
                  );
                case ThreadView.routeName:
                  final id = uri.queryParameters['id'];
                  if (id != null) {
                    return MaterialPageRoute<void>(
                      settings: routeSettings,
                      builder: (BuildContext context) {
                        return ThreadView(
                          threadID: int.parse(id),
                        );
                      },
                    );
                  }
                  break;
                case HomeView.routeName:
                default:
                  return MaterialPageRoute<void>(
                    settings: routeSettings,
                    builder: (BuildContext context) {
                      return HomeView();
                    },
                  );
              }
              return null;
            },
          ),
        );
      },
    );
  }
}
