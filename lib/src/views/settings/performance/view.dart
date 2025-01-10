import 'package:flutter/material.dart';
import 'package:mxd/src/provider/forum_list.dart';
import 'package:mxd/src/views/home/service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PerformanceView extends StatelessWidget {
  const PerformanceView({super.key});
  static const routeName = '/performance';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.performanceManager),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InkWell(
              onTap: () => _refreshForums(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.draw),
                    Container(
                      width: 16,
                    ),
                    Text(
                      AppLocalizations.of(context)!.refreshForums,
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

  Future<void> _refreshForums(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final homeService = HomeService();
      final refreshedForums = await homeService.getForumList(context, forceRefresh: true);

      Provider.of<ForumProvider>(context, listen: false)
          .setForums(refreshedForums);

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.refreshSuccess),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.refreshFailed),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
