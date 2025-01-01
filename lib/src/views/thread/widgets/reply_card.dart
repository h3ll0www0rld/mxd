// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:mxd/src/core/widgets/html_content_widget.dart';
import 'package:mxd/src/core/widgets/image_widget.dart';
import 'package:mxd/src/core/widgets/text_widget.dart';
import 'package:mxd/src/models/reply_card.dart';

class ReplyCard extends StatelessWidget {
  final ReplyCardModel replyCardModel;
  final String? po_hash;

  const ReplyCard({super.key, required this.replyCardModel, this.po_hash});

  @override
  Widget build(BuildContext context) {
    final isPO = replyCardModel.user_hash == po_hash;

    final isAdmin = replyCardModel.admin == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isAdmin) ...[
                    AdminText(
                      user_hash: replyCardModel.user_hash,
                    ),
                  ] else if (isPO) ...[
                    POText(user_hash: replyCardModel.user_hash),
                  ] else ...[
                    InformationText(information: replyCardModel.user_hash),
                  ],
                  InformationText(information: "NO.${replyCardModel.id}"),
                ],
              ),
              InformationText(information: replyCardModel.getFormattedTime()),
              SizedBox(height: 8),
              if (replyCardModel.title != "无标题") ...[
                TitleText(title: replyCardModel.title),
                SizedBox(height: 8),
              ],
              if (replyCardModel.name != "无名氏") ...[
                TitleText(title: replyCardModel.name),
                SizedBox(height: 8),
              ],
              HtmlContentWidget(content: replyCardModel.content),
              SizedBox(height: 8),
              if (replyCardModel.img.isNotEmpty &&
                  replyCardModel.ext.isNotEmpty) ...[
                ImageWidget(img: replyCardModel.img, ext: replyCardModel.ext),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
