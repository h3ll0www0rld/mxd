import 'package:mxd/main.dart';
import 'package:mxd/src/models/thread_card.dart';

class HomeService {
  Future<List> getForumList() async {
    try {
      final forumFuture = nmbxdClient.fetchForumList();
      final timelineFuture = nmbxdClient.fetchTimeLineList();

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
          'id': timeline['id'].toString(),
          'name': timeline['display_name'],
          'msg': timeline['notice'] ?? ''
        };
      }).toList();

      filteredForumList
          .add({'id': '-1', 'name': '时间线', 'forums': timelineForums});

      return filteredForumList;
    } on Exception {
      rethrow;
    }
  }

  Future<List<ThreadCardModel>> getThreads(
      int selectedForumID, int currentPage) async {
    try {
      List rawData;

      if (selectedForumID >= 1 && selectedForumID <= 3) {
        rawData =
            await nmbxdClient.fetchTimeLineByID(selectedForumID, currentPage);
      } else {
        rawData =
            await nmbxdClient.fetchForumByFID(selectedForumID, currentPage);
      }

      return rawData
          .map<ThreadCardModel>((json) => ThreadCardModel.fromJson(json))
          .toList();
    } on Exception {
      rethrow;
    }
  }
}
