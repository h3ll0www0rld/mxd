import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ForumProvider with ChangeNotifier {
  List<dynamic> categoryForumList = [];
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  void setForums(List<dynamic> forumData) {
    if (categoryForumList != forumData) {
      categoryForumList = forumData;
      Future.microtask(() {
        _isLoading = false;
        notifyListeners();
      });
    }
  }

  String findForumNameByFId(dynamic fid, BuildContext context) {
    for (var category in categoryForumList) {
      for (var forum in category['forums']) {
        if (forum['id'].toString() == fid.toString()) {
          return forum['name'];
        }
      }
    }
    return AppLocalizations.of(context)!.unknownForum;
  }
}
