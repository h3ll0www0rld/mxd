import 'package:flutter/material.dart';

class ForumProvider with ChangeNotifier {
  List<dynamic> forums = [];
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  void setForums(List<dynamic> forumData) {
    forums = forumData;
    notifyListeners();
  }

  String findForumNameByFId(int fid) {
    _isLoading = false;
    for (var category in forums) {
      for (var forum in category['forums']) {
        if (int.parse(forum['id']) == fid) {
          return forum['name'];
        }
      }
    }
    return "Error";
  }
}
