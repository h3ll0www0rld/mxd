import 'package:flutter/material.dart';
import 'package:mxd/main.dart';
import 'package:mxd/src/models/thread_card.dart';
import 'package:mxd/src/provider/forum_list.dart';
import 'package:mxd/src/views/settings/controller.dart';
import 'package:provider/provider.dart';

class HomeService {
  Future<List<Map<String, dynamic>>> getForumList(BuildContext context,
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

      final forumFuture = nmbxdClient.fetchForumList(context);
      final timelineFuture = nmbxdClient.fetchTimeLineList(context);

      final results = await Future.wait([forumFuture, timelineFuture]);

      final forumList = results[0];
      final timelineList = results[1];

      final filteredForumList = forumList.map((category) {
        final filteredForums = (category['forums'] as List)
            .where((forum) => forum['id'] != '-1')
            .toList();
        return {...category, 'forums': filteredForums};
      }).toList();

      final timelineForums = timelineList.map((timeline) {
        return {
          'id': 'timeline_${timeline['id']}',
          'name': timeline['display_name'],
          'msg': timeline['notice'] ?? ''
        };
      }).toList();

      filteredForumList
          .add({'id': '-1', 'name': '时间线', 'forums': timelineForums});

      filteredForumList
          .add({'id': '-1', 'name': '时间线', 'forums': timelineForums});

      // 更新缓存
      settingsController.updateForumData(filteredForumList);

      // 更新 ForumProvider 的状态
      forumProvider.setForums(filteredForumList);

      return filteredForumList;
    } on Exception {
      rethrow;
    }
  }

  Future<List<ThreadCardModel>> getThreads(
      int selectedForumID, int currentPage, BuildContext context) async {
    try {
      List rawData;

      if (selectedForumID >= 1 && selectedForumID <= 3) {
        rawData = await nmbxdClient.fetchTimeLineByID(
            selectedForumID, currentPage, context);
      } else {
        rawData = await nmbxdClient.fetchForumByFID(
            selectedForumID, currentPage, context);
      }

      return rawData
          .map<ThreadCardModel>((json) => ThreadCardModel.fromJson(json))
          .toList();
    } on Exception {
      rethrow;
    }
  }
}
