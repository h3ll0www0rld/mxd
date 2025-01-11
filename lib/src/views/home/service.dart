import 'package:flutter/material.dart';
import 'package:mxd/main.dart';
import 'package:mxd/src/models/thread_card.dart';
import 'package:mxd/src/provider/forum.dart';
import 'package:mxd/src/views/settings/controller.dart';
import 'package:provider/provider.dart';

class HomeService {
  Future<List<Map<String, dynamic>>> getCategoryForumList(BuildContext context,
      {bool forceRefresh = false}) async {
    try {
      final settingsController =
          Provider.of<SettingsController>(context, listen: false);
      final forumProvider = Provider.of<ForumProvider>(context, listen: false);

      if (!forceRefresh) {
        final cachedForumData = settingsController.forumData;

        if (cachedForumData != null) {
          // 如果缓存中有数据且不强制刷新，直接返回
          forumProvider.setForums(cachedForumData);
          return cachedForumData;
        }
      }

      final forumListFuture = nmbxdClient.fetchForumList(context);
      final timelineListFuture = nmbxdClient.fetchTimeLineList(context);

      final results = await Future.wait([forumListFuture, timelineListFuture]);

      final forumList = results[0];
      final timelineList = results[1];

      final categoryForumList = forumList.map((category) {
        final filteredForums = (category['forums'] as List)
            .where((forum) => forum['id'] != '-1')
            .toList();
        return {...category, 'forums': filteredForums};
      }).toList();

      final categoryTimelineList = timelineList.map((timeline) {
        return {
          'id': 'timeline_${timeline['id']}',
          'name': timeline['display_name'],
          'msg': timeline['notice'] ?? ''
        };
      }).toList();

      categoryForumList
          .add({'id': '-1', 'name': '时间线', 'forums': categoryTimelineList});

      // 更新缓存
      settingsController.updateForumData(categoryForumList);
      forumProvider.setForums(categoryForumList);

      return categoryForumList;
    } on Exception {
      rethrow;
    }
  }

  Future<List<ThreadCardModel>> getThreads(
      String fid, int currentPage, BuildContext context) async {
    try {
      List rawData;

      if (fid.startsWith('timeline_')) {
        final timelineID = int.parse(fid.split('_').last);
        
        rawData = await nmbxdClient.fetchTimeLineByID(
            timelineID, currentPage, context);
        
      } else {
        final forumID = int.parse(fid);
        rawData =
            await nmbxdClient.fetchForumByFID(forumID, currentPage, context);
      }

      return rawData
          .map<ThreadCardModel>((json) => ThreadCardModel.fromJson(json))
          .toList();
    } on Exception {
      rethrow;
    }
  }
}
