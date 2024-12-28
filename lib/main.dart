import 'package:flutter/material.dart';
import 'package:mxd/src/core/services/nmbxd_client.dart';

import 'src/app.dart';
import 'src/views/settings/controller.dart';

final nmbxdClient = NmbxdClient(baseUrl: 'https://api.nmb.best');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsController = SettingsController();

  await settingsController.loadSettings();

  runApp(MyApp(settingsController: settingsController));
}
