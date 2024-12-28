import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mxd/src/provider/forum_list_provider.dart';
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
                  Text(threadCardModel.user_hash,
                      style: isAdmin
                          ? TextStyle(color: Colors.red)
                          : TextStyle(color: Colors.grey[600])),
                  Text(forumName.toString(),
                      style: TextStyle(color: Colors.grey[600])),
                  Text(threadCardModel.now,
                      style: TextStyle(color: Colors.grey[600])),
                  Text(
                    (threadCardModel.ReplyCount).toString(),
                    style: TextStyle(color: Colors.grey[600]),
                  )
                ],
              ),
              SizedBox(height: 8),
              if (isSage) ...[
                Text("SAGE", style: TextStyle(color: Colors.red)),
                SizedBox(height: 8),
              ],
              if (threadCardModel.title != "无标题") ...[
                Text(threadCardModel.title,
                    style: TextStyle(color: Colors.grey[600])),
                SizedBox(height: 8),
              ],
              if (threadCardModel.name != "无名氏") ...[
                Text(threadCardModel.name,
                    style: TextStyle(color: Colors.grey[600])),
                SizedBox(height: 8),
              ],
              HtmlWidget(
                threadCardModel.content,
                textStyle: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 8),
              if (threadCardModel.img.isNotEmpty)
                Image.network(
                  "https://image.nmb.best/image/${threadCardModel.img}${threadCardModel.ext}",
                  height: 200,
                  fit: BoxFit.cover,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
