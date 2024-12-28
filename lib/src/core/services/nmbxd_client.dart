import 'package:http/http.dart' as http;
import 'dart:convert';

class NmbxdClient {
  final String baseUrl;
  final int maxRetries;
  final Duration retryInterval;

  NmbxdClient({
    required this.baseUrl,
    this.maxRetries = 5,
    this.retryInterval = const Duration(seconds: 2),
  });

  Future<http.Response> _makeRequest(
    String endpoint, {
    required String method,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    int retries = 0,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        default:
          throw UnsupportedError('HTTP method $method is not supported');
      }

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      if (retries < maxRetries) {
        await Future.delayed(retryInterval);
        return _makeRequest(
          endpoint,
          method: method,
          headers: headers,
          body: body,
          retries: retries + 1,
        );
      } else {
        throw Exception('Request failed after $maxRetries retries: $e');
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchForumList() async {
    final response = await _makeRequest('/api/getForumList', method: 'GET');
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<List<Map<String, dynamic>>> fetchTimeLineList() async {
    final response = await _makeRequest('/api/getTimelineList', method: 'GET');
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<List<dynamic>> fetchTimeLineByID(int id, int page) async {
    final response =
        await _makeRequest('/api/timeline?id=$id&page=$page', method: 'GET');
    return json.decode(response.body);
  }

  Future<List<dynamic>> fetchForumByFID(int fid, int page) async {
    final response =
        await _makeRequest('/api/showf?id=$fid&page=$page', method: 'GET');
    final responseData = json.decode(response.body);

    if (responseData is Map && responseData['success'] == false) {
      throw Exception(responseData['error']);
    }
    return responseData;
  }

  Future<Map<String, dynamic>> fetchThreadRepliesByID(int id, int page) async {
    final response =
        await _makeRequest('/api/thread?id=$id&page=$page', method: 'GET');
    final responseData = json.decode(response.body);

    if (responseData is String && responseData == '该串不存在') {
      throw Exception('该串不存在');
    }
    if (responseData['success'] == false) {
      throw Exception(responseData['error']);
    }
    return responseData;
  }

  Future<Map<String, dynamic>> fetchRefByID(int id) async {
    final response = await _makeRequest('/api/ref?id=$id', method: 'GET');
    final responseData = json.decode(response.body);

    if (responseData['success'] == false) {
      throw Exception(responseData['error']);
    }
    return responseData;
  }
}
