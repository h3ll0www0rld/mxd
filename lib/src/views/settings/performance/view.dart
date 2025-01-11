import 'package:flutter/material.dart';
import 'package:mxd/src/core/widgets/text.dart';
import 'package:mxd/src/provider/forum.dart';
import 'package:mxd/src/views/home/service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PerformanceView extends StatefulWidget {
  const PerformanceView({super.key});
  static const routeName = '/performance';

  @override
  State<PerformanceView> createState() => _PerformanceViewState();
}

class _PerformanceViewState extends State<PerformanceView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.performanceManager)),
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
                    Container(width: 16),
                    WidgetText(text: AppLocalizations.of(context)!.refreshForums),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshForums(BuildContext buildContext) async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(buildContext);
      final homeService = HomeService();
      final refreshedForums =
          await homeService.getCategoryForumList(buildContext, forceRefresh: true);

      if (!mounted) return;
      Provider.of<ForumProvider>(context, listen: false)
          .setForums(refreshedForums);

      if (mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context)!.refreshSuccess),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.refreshFailed),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
