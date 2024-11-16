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

Future<List<Map<String, dynamic>>> fetchTimeLineList() async {
  final response =
      await http.get(Uri.parse('https://api.nmb.best/api/getTimelineList'));

  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  } else {
    throw Exception('Failed to get /getTimeLineList');
  }
}

Future<List<dynamic>> fetchForumByFID(int fid, int page) async {
  final response = await http
      .get(Uri.parse('https://api.nmb.best/api/showf?id=${fid}&page=${page}'));

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    if (responseData is Map && responseData['success'] == false) {
      throw Exception(responseData['error']);
    }
    return responseData;
  } else {
    throw Exception('Failed to get /showf?id=${fid}&page=${page}');
  }
}

Future<List<dynamic>> fetchTimeLineByID(int id, int page) async {
  final response = await http.get(
      Uri.parse('https://api.nmb.best/api/timeline?id=${id}&page=${page}'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to get /timeline?id=${id}&page=${page}');
  }
}

Future<Map<String, dynamic>> fetchThreadRepliesByID(int id, int page) async {
  final response = await http
      .get(Uri.parse('https://api.nmb.best/api/thread?id=${id}&page=${page}'));

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    if (responseData is String && responseData == '该串不存在') {
      throw Exception('该串不存在'); // 抛出自定义异常
    }
    if (responseData['success'] == false) {
      throw Exception(responseData['error']);
    }
    return responseData;
  } else {
    throw Exception('Failed to get /thread?id=${id}&page=${page}');
  }
}

Future<Map<String, dynamic>> fetchRefByID(int id) async {
  final response =
      await http.get(Uri.parse('https://api.nmb.best/api/ref?id=${id}'));

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    if (responseData['success'] == false) {
      throw Exception(responseData['error']);
    }
    return responseData;
  } else {
    throw Exception('Failed to get /ref?id=${id}');
  }
}
