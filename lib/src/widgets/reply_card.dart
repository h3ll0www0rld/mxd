import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mxd/src/api/nmbxd.dart';
import 'package:mxd/src/widgets/ref_dialog.dart';
import 'package:mxd/src/widgets/ref_model.dart';
import 'package:mxd/src/widgets/reply_card_model.dart';

class ReplyCard extends StatelessWidget {
  final ReplyCardModel replyCardModel;
  final String? po_hash;

  const ReplyCard({super.key, required this.replyCardModel, this.po_hash});

  @override
  Widget build(BuildContext context) {
    final isPO = replyCardModel.user_hash == po_hash;

    final isAdmin = replyCardModel.admin == 1;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // 添加内边距
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  replyCardModel.user_hash,
                  style: isAdmin
                      ? TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)
                      : isPO
                          ? TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold)
                          : TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  replyCardModel.now,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  "NO.${replyCardModel.id}",
                  style: TextStyle(color: Colors.grey[600]),
                )
              ],
            ),
            if (replyCardModel.title != "无标题") ...[
              Text(replyCardModel.title,
                  style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 8),
            ],
            if (replyCardModel.name != "无名氏") ...[
              Text(replyCardModel.name,
                  style: TextStyle(color: Colors.grey[600])),
              SizedBox(height: 8),
            ],
            SizedBox(height: 8),
            HtmlWidget(
              replyCardModel.content,
              textStyle: TextStyle(fontSize: 18),
              customWidgetBuilder: (element) {
                if (element.localName == 'font' &&
                    element.attributes['color'] == '#789922' &&
                    element.text.startsWith('>>No.')) {
                  final refId = _extractPostId(element.text);
                  if (refId != null) {
                    return GestureDetector(
                      onTap: () {
                        // 确保 refId 非空后再调用 _showRefDialog
                        _showRefDialog(context, refId);
                      },
                      child: Text(
                        ">>No.$refId", // 显示提取后的数字
                        style:
                            TextStyle(fontSize: 18, color: Color(0xFF789922)),
                      ),
                    );
                  }
                }
                return null;
              },
            ),
            SizedBox(height: 8),
            if (replyCardModel.img.isNotEmpty)
              GestureDetector(
                  onTap: () {
                    _showImage(context,
                        "https://image.nmb.best/image/${replyCardModel.img}${replyCardModel.ext}");
                  },
                  child: Image.network(
                    "https://image.nmb.best/image/${replyCardModel.img}${replyCardModel.ext}",
                    height: 250,
                    fit: BoxFit.cover,
                  ))
          ],
        ),
      ),
    );
  }

  int? _extractPostId(String text) {
    final RegExp regExp = RegExp(r'No\.(\d+)');
    final match = regExp.firstMatch(text);
    if (match != null) {
      final refIdStr = match.group(1);
      if (refIdStr != null) {
        return int.tryParse(refIdStr);
      }
    }
    return null;
  }

  void _showRefDialog(BuildContext context, int refID) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, dynamic>>(
          future: fetchRefByID(refID), // 请求数据
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              final refModel = RefModel.fromJson(snapshot.data!);
              return RefDialog(refModel: refModel); // 将数据传递给弹窗
            } else {
              return Center(child: Text('No data available'));
            }
          },
        );
      },
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
