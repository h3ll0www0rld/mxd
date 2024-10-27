import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Map<String, dynamic>>> fetchForumList() async {
  final response =
      await http.get(Uri.parse('https://api.nmb.best/api/getForumList'));

  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  } else {
    throw Exception('Failed to get /getForumList');
  }
}

Future<List<dynamic>> fetchForumByFID(int fid, int page) async {
  final response = await http
      .get(Uri.parse('https://api.nmb.best/api/showf?id=${fid}&page=${page}'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to get /showf?id=${fid}');
  }
}

Future<Map<String, dynamic>> fetchThreadRepliesByID(int id, int page) async {
  final response = await http
      .get(Uri.parse('https://api.nmb.best/api/thread?id=${id}&page=${page}'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to get /thread?id=${id}');
  }
}
