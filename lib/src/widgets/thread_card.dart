import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:mxd/src/home/home_view.dart';
import 'package:mxd/src/widgets/thread_card_model.dart';

class ThreadCard extends StatelessWidget {
  final ThreadCardModel threadCardModel;

  final HomeViewState homeViewState;

  const ThreadCard(
      {Key? key, required this.threadCardModel, required this.homeViewState})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String forumName = homeViewState.findForumNameByFId(threadCardModel.fid);
    final isAdmin = threadCardModel.admin == 1;
    final isSage = threadCardModel.sage == 1;

    return InkWell(
      onTap: () {
        Navigator.pushNamed(
            context, '/thread?id=${threadCardModel.id}&fn=${forumName}');
      },
      child: Card(
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
