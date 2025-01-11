import 'package:flutter/material.dart';
import 'package:mxd/main.dart';
import 'package:mxd/src/core/widgets/html_preview.dart';
import 'package:mxd/src/core/widgets/image.dart';
import 'package:mxd/src/core/widgets/sage.dart';
import 'package:mxd/src/core/widgets/text.dart';
import 'package:mxd/src/models/ref_dialog.dart';
import 'package:mxd/src/models/thread_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RefDialog extends StatelessWidget {
  final RefModel refModel;

  const RefDialog({super.key, required this.refModel});

  @override
  Widget build(BuildContext context) {
    final isAdmin = refModel.admin == 1;
    final isSage = refModel.sage == 1;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (isAdmin) ...[
                  AdminText(user_hash: refModel.user_hash,),
                ] else ...[
                  InformationText(information: refModel.user_hash),
                ],
                InformationText(
                  information: refModel.getFormattedTime()
                ),
              ],
            ),
            SizedBox(height: 8),
            if (isSage) ...[
              SageWidget(),
              SizedBox(height: 8),
            ],
            if (refModel.title != "无标题") ...[
              TitleText(title: refModel.title),
              SizedBox(height: 8),
            ],
            if (refModel.name != "无名氏") ...[
              TitleText(title: refModel.name),
              SizedBox(height: 8),
            ],
            HtmlPreviewWidget(content: refModel.content),
            SizedBox(height: 8),
            if (refModel.img.isNotEmpty && refModel.ext.isNotEmpty) ...[
              ImageWidget(
                img: refModel.img,
                ext: refModel.ext,
              ),
            ],
            FutureBuilder<Map<String, dynamic>>(
              future:
                  nmbxdClient.fetchThreadRepliesByID(refModel.id, 1, context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  if (snapshot.error is Exception &&
                      snapshot.error.toString() == 'Exception: 该串不存在') {
                    return SizedBox.shrink();
                  }
                }

                if (snapshot.hasData) {
                  final threadData = ThreadCardModel.fromJson(snapshot.data!);

                  return Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context,
                              '/thread?id=${refModel.id}&fid=${threadData.fid}');
                        },
                        child:
                            Text(AppLocalizations.of(context)!.jumpToThread)),
                  );
                }

                return Text('Unexpected error occurred.');
              },
            ),
          ],
        ),
      ),
    );
  }
}
