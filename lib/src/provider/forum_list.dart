import 'package:flutter/material.dart';

class ForumProvider with ChangeNotifier {
  List<dynamic> forums = [];
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  void setForums(List<dynamic> forumData) {
    if (forums != forumData) {
      forums = forumData;
      Future.microtask(() {
        _isLoading = false;
        notifyListeners(); 
      });
    }
  }

  String findForumNameByFId(dynamic fid) {
    for (var forum in forums) {
      for (var subForum in forum['forums']) {
        if (subForum['id'].toString() == fid.toString()) {
          return subForum['name'];
        }
      }
    }
    return 'Unknown';
  }
}
