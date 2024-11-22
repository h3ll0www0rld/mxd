import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mxd/src/image/image_view.dart';
import 'package:mxd/src/provider/forum_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mxd/src/home/home_view.dart';
import 'package:mxd/src/thread/thread_view.dart';

import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.settingsController});

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: settingsController,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ForumProvider()),
        ],
        child: DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            final ColorScheme lightColorScheme =
                lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.blue);
            final ColorScheme darkColorScheme = darkDynamic ??
                ColorScheme.fromSeed(
                    seedColor: Colors.blue, brightness: Brightness.dark);
            return Consumer<SettingsController>(
              builder: (context, controller, child) {
                return MaterialApp(
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
                  theme: ThemeData(
                    colorScheme: lightColorScheme,
                    useMaterial3: true,
                  ),
                  darkTheme: ThemeData(
                    colorScheme: darkColorScheme,
                    useMaterial3: true,
                  ),
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
                        final fid = uri.queryParameters['fid'];
                        if (id != null && fid != null) {
                          return MaterialPageRoute<void>(
                            settings: routeSettings,
                            builder: (BuildContext context) {
                              return ThreadView(
                                threadID: int.parse(id),
                                forumID: int.parse(fid),
                              );
                            },
                          );
                        }
                        break;
                      case '/image':
                        final img = uri.queryParameters['img'];
                        final ext = uri.queryParameters['ext'];
                        if (img != null && ext != null) {
                          return MaterialPageRoute<void>(
                            settings: routeSettings,
                            builder: (BuildContext context) {
                              return ImageView(imageName: img, imageExt: ext);
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
                );
              },
            );
          },
        ),
      ),
    );
  }
}
