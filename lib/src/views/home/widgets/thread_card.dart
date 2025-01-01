import 'package:flutter/material.dart';
import 'package:mxd/src/core/widgets/html_preview_widget.dart';
import 'package:mxd/src/core/widgets/image_widget.dart';
import 'package:mxd/src/core/widgets/sage_widget.dart';
import 'package:mxd/src/core/widgets/text_widget.dart';
import 'package:mxd/src/provider/forum_list.dart';
import 'package:mxd/src/models/thread_card.dart';
import 'package:provider/provider.dart';

class ThreadCard extends StatelessWidget {
  final ThreadCardModel threadCardModel;

  const ThreadCard({super.key, required this.threadCardModel});

  @override
  Widget build(BuildContext context) {
    final forumProvider = Provider.of<ForumProvider>(context);
    final forumName = forumProvider.findForumNameByFId(threadCardModel.fid);
    final isAdmin = threadCardModel.admin == 1;
    final isSage = threadCardModel.sage == 1;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context,
            '/thread?id=${threadCardModel.id}&fid=${threadCardModel.fid}');
      },
      child: Card(
        color: Theme.of(context).splashColor,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isAdmin) ...[
                    AdminText(user_hash: threadCardModel.user_hash,),
                  ] else ...[
                    InformationText(information: threadCardModel.user_hash),
                  ],
                  InformationText(information: forumName.toString()),
                  InformationText(
                      information: threadCardModel.ReplyCount.toString()),
                ],
              ),
              InformationText(information: threadCardModel.getFormattedTime()),
              SizedBox(height: 8),
              if (isSage) ...[
                SageWidget(),
                SizedBox(height: 8),
              ],
              if (threadCardModel.title != "无标题") ...[
                TitleText(title: threadCardModel.title),
                SizedBox(height: 8),
              ],
              if (threadCardModel.name != "无名氏") ...[
                TitleText(title: threadCardModel.name),
                SizedBox(height: 8),
              ],
              HtmlPreviewWidget(content: threadCardModel.content),
              SizedBox(height: 8),
              if (threadCardModel.img.isNotEmpty &&
                  threadCardModel.ext.isNotEmpty) ...[
                ImageWidget(img: threadCardModel.img, ext: threadCardModel.ext),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
