import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mxd/src/views/settings/controller.dart';
import 'dart:convert';

import 'package:provider/provider.dart';

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
    required BuildContext context,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      http.Response response;

      final enabledCookie =
          Provider.of<SettingsController>(context, listen: false).enabledCookie;
      final requestHeaders = {
        ...?headers,
        if (enabledCookie?.user_hash != null)
          'Cookie': 'userhash=${enabledCookie?.user_hash}',
      };

      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: requestHeaders);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: requestHeaders,
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
          context: context,
        );
      } else {
        throw Exception('Request failed after $maxRetries retries: $e');
      }
    }
  }

  Future<List<Map<String, dynamic>>> fetchForumList(
      BuildContext context) async {
    final response = await _makeRequest(
      '/api/getForumList',
      method: 'GET',
      context: context,
    );
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<List<Map<String, dynamic>>> fetchTimeLineList(
      BuildContext context) async {
    final response = await _makeRequest(
      '/api/getTimelineList',
      method: 'GET',
      context: context,
    );
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  }

  Future<List<dynamic>> fetchTimeLineByID(
      int id, int page, BuildContext context) async {
    final response = await _makeRequest(
      '/api/timeline?id=$id&page=$page',
      method: 'GET',
      context: context,
    );
    return json.decode(response.body);
  }

  Future<List<dynamic>> fetchForumByFID(
      int fid, int page, BuildContext context) async {
    final response = await _makeRequest(
      '/api/showf?id=$fid&page=$page',
      method: 'GET',
      context: context,
    );
    final responseData = json.decode(response.body);

    if (responseData is Map && responseData['success'] == false) {
      throw Exception(responseData['error']);
    }
    return responseData;
  }

  Future<Map<String, dynamic>> fetchThreadRepliesByID(
      int id, int page, BuildContext context) async {
    final response = await _makeRequest(
      '/api/thread?id=$id&page=$page',
      method: 'GET',
      context: context,
    );
    final responseData = json.decode(response.body);

    if (responseData is String && responseData == '该串不存在') {
      throw Exception('该串不存在');
    }
    if (responseData['success'] == false) {
      throw Exception(responseData['error']);
    }
    return responseData;
  }

  Future<Map<String, dynamic>> fetchRefByID(
      int id, BuildContext context) async {
    final response = await _makeRequest(
      '/api/ref?id=$id',
      method: 'GET',
      context: context,
    );
    final responseData = json.decode(response.body);

    if (responseData['success'] == false) {
      throw Exception(responseData['error']);
    }
    return responseData;
  }
}
