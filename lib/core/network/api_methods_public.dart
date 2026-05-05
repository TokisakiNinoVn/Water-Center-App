import 'dart:convert';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:http/http.dart' as http;

import '../../data/enums/http_method.dart';
import '../../data/models/api_response.dart';
import '../../presentation/utils/map_status_code.dart';

class ApiMethodsPublic {
  static ApiResponse _buildApiResponse(http.Response res) {
    final statusCode = res.statusCode;

    dynamic decoded;
    try {
      decoded = res.body.isNotEmpty ? jsonDecode(res.body) : {};
    } catch (_) {
      decoded = {};
    }

    final success = statusCode >= 200 && statusCode < 300;

    String? message;
    dynamic data;
    int? totalDocs;
    Map<String, dynamic>? meta;

    if (decoded is Map<String, dynamic>) {
      message = decoded['message'];

      final temp = Map<String, dynamic>.from(decoded);

      temp.remove('message');
      totalDocs = temp.remove('totalDocs');
      meta = temp.remove('meta');

      data = temp;
    } else if (decoded is List) {
      data = decoded;
    } else {
      data = {};
    }

    message ??= MapStatusCode.mapStatusToMessage(statusCode);

    final apiResponse = ApiResponse(
      statusCode: statusCode,
      success: success,
      message: message,
      totalDocs: totalDocs,
      meta: meta,
      data: data,
    );

    // appLog('[FORMATTED] $apiResponse');

    return apiResponse;
  }

  // Base headers for all requests
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
  };

  static Future<ApiResponse> request(
      HttpMethod method,
      String url, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        Map<String, dynamic>? queryParams,
      }) async {
    try {
      Uri uri = Uri.parse(url);

      // ✅ auto build query param
      if (queryParams != null) {
        uri = uri.replace(
          queryParameters: queryParams.map(
                (key, value) => MapEntry(key, value.toString()),
          ),
        );
      }

      final mergedHeaders = {..._defaultHeaders, ...?headers};

      http.Response res;

      switch (method) {
        case HttpMethod.get:
          res = await http.get(uri, headers: mergedHeaders);
          break;
        case HttpMethod.post:
          res = await http.post(uri,
              headers: mergedHeaders, body: jsonEncode(body));
          break;
        case HttpMethod.put:
          res = await http.put(uri,
              headers: mergedHeaders, body: jsonEncode(body));
          break;
        case HttpMethod.patch:
          res = await http.patch(uri,
              headers: mergedHeaders, body: jsonEncode(body));
          break;
        case HttpMethod.delete:
          res = await http.delete(uri,
              headers: mergedHeaders, body: jsonEncode(body));
          break;
      }

      // appLog('[RAW] $method $uri | ${res.statusCode} | ${res.body}');
      return _buildApiResponse(res);

    } catch (e) {
      appLog('[ERROR] $method $url | $e');

      return ApiResponse(
        statusCode: 500,
        success: false,
        message: 'Lỗi kết nối tới server',
        data: {},
      );
    }
  }
}