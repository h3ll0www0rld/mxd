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
      content: json['content'], // 替换 <br/> 为换行符
      img: json['img'],
      ext: json['ext'],
      name: json['name'],
    );
  }
}