import 'package:flutter/material.dart';
import 'package:mxd/main.dart';
import 'package:mxd/src/models/reply_card.dart';

class ThreadService {
  Future<Map<String, dynamic>> getThreadReplies({
    required int id,
    required int page,
    required BuildContext context
  }) async {
    try {
      final data = await nmbxdClient.fetchThreadRepliesByID(id, page,context);
      return data;
    } on Exception {
      rethrow;
    }
  }

  ReplyCardModel parseMainReply(Map<String, dynamic> data) {
    return ReplyCardModel.fromJson(data);
  }

  List<ReplyCardModel> parseReplies(Map<String, dynamic> data) {
    final replies = (data['Replies'] as List)
        .map((json) => ReplyCardModel.fromJson(json))
        .toList();

    return replies;
  }
}
