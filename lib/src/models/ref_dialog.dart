import 'package:intl/intl.dart';

class RefModel {
  final int id;
  final String img;
  final String ext;
  final String now;
  final String user_hash;
  final String name;
  final String title;
  final String content;
  final int sage;
  final int admin;

  RefModel(
      {required this.id,
      required this.img,
      required this.ext,
      required this.now,
      required this.user_hash,
      required this.name,
      required this.title,
      required this.content,
      required this.sage,
      required this.admin});

  factory RefModel.fromJson(Map<String, dynamic> json) {
    return RefModel(
        id: json['id'],
        img: json['img'],
        ext: json['ext'],
        now: json['now'],
        user_hash: json['user_hash'],
        name: json['name'],
        title: json['title'],
        content: json['content'],
        sage: json['sage'],
        admin: json['admin']);
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
