import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mxd/main.dart';
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
                Text(refModel.user_hash,
                    style: isAdmin
                        ? TextStyle(color: Colors.red)
                        : TextStyle(color: Colors.grey[600])),
                Text(refModel.now, style: TextStyle(color: Colors.grey[600])),
                Text(
                  "NO.${refModel.id}",
                  style: TextStyle(color: Colors.grey[600]),
                )
              ],
            ),
            SizedBox(height: 8),
            if (isSage) ...[
              Text("SAGE", style: TextStyle(color: Colors.red)),
              SizedBox(height: 8),
            ],
            if (refModel.title != "无标题") ...[
              Text(refModel.title, style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 8),
            ],
            if (refModel.name != "无名氏") ...[
              Text(refModel.name, style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 8),
            ],
            HtmlWidget(
              refModel.content,
              textStyle: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            if (refModel.img.isNotEmpty)
              GestureDetector(
                  onTap: () {
                    _showImage(context,
                        "https://image.nmb.best/image/${refModel.img}${refModel.ext}");
                  },
                  child: Image.network(
                    "https://image.nmb.best/image/${refModel.img}${refModel.ext}",
                    height: 250,
                    fit: BoxFit.cover,
                  )),
            FutureBuilder<Map<String, dynamic>>(
              future: nmbxdClient.fetchThreadRepliesByID(refModel.id, 1),
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

  void _showImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints: BoxConstraints(maxWidth: 600, maxHeight: 600),
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}
