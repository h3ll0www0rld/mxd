import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mxd/src/widgets/reply_card_model.dart';

class ReplyCard extends StatelessWidget {
  final ReplyCardModel replyCardModel;
  final String? po_hash;

  const ReplyCard({Key? key, required this.replyCardModel, this.po_hash})
      : super(key: key);

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
            SizedBox(height: 8), // 标题和简介之间的间距
            HtmlWidget(
              replyCardModel.content,
              textStyle: TextStyle(fontSize: 18),
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

  void _showImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            constraints:
                BoxConstraints(maxWidth: 600, maxHeight: 600), // 设置最大宽高
            child: Image.network(imageUrl, fit: BoxFit.cover), // 显示大图
          ),
        );
      },
    );
  }
}
