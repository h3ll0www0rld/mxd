import 'package:flutter/material.dart';

class ForumProvider with ChangeNotifier {
  List<dynamic> forums = [];

  void setForums(List<dynamic> forumData) {
    forums = forumData;
    notifyListeners();
  }

  String findForumNameByFId(int fid) {
    // print(forums);
    for (var category in forums) {
      for (var forum in category['forums']) {
        if (int.parse(forum['id']) == fid) {
          return forum['name'];
        }
      }
    }
    return "Null";
  }
}
