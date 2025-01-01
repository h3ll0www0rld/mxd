import 'package:intl/intl.dart';

class ReplyCardModel {
  final int id;
  final String user_hash;
  final int admin;
  final String title;
  final String now;
  final String content;
  final String img;
  final String ext;
  final String name;

  ReplyCardModel(
      {required this.id,
      required this.user_hash,
      required this.admin,
      required this.title,
      required this.now,
      required this.content,
      required this.img,
      required this.ext,
      required this.name});
  
  factory ReplyCardModel.fromJson(Map<String, dynamic> json) {
    return ReplyCardModel(
      id: json['id'],
      user_hash: json['user_hash'],
      admin: json['admin'],
      title: json['title'],
      now: json['now'],
      content: json['content'],
      img: json['img'],
      ext: json['ext'],
      name: json['name'],
    );
  }

  String getFormattedTime() {
    String cleanedNow = now.replaceAll(RegExp(r'\(.*\)'), ' ').trim();

    DateTime postTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(cleanedNow);

    DateTime nowTime = DateTime.now();
    String formattedTime = '';

    if (postTime.year == nowTime.year) {
      formattedTime = DateFormat('MM-dd HH:mm').format(postTime);
    } else {
      formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(postTime);
    }

    if (postTime.year == nowTime.year &&
        postTime.month == nowTime.month &&
        postTime.day == nowTime.day) {
      formattedTime = DateFormat('HH:mm').format(postTime);
    }

    if (postTime.isBefore(nowTime) && nowTime.difference(postTime).inDays == 1) {
      formattedTime = '昨天 ${DateFormat('HH:mm').format(postTime)}';
    }

    return formattedTime;
  }
}