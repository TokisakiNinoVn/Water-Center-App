import 'dart:convert';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:clean_water/data/configs/app_config.dart';
import '../../presentation/common/snackbar.dart';
import '../storage/local_storage.dart';
import 'package:clean_water/core/storage/shared_preferences_utils.dart';
import 'package:clean_water/data/enums/http_method.dart';
import 'package:clean_water/data/models/api_response.dart';
import 'package:clean_water/presentation/routers/app_router.dart';
import 'package:clean_water/presentation/routers/configs/app_router_config.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';
import 'package:clean_water/presentation/utils/map_status_code.dart';

class ApiMethodsPrivate {
  // Base headers for all requests
  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
  };

  // Handle 401 Unauthorized - Session expired
  static Future<void> _handle401() async {
    final context = rootNavigatorKey.currentContext;
    await SharedPreferencesUtils.logOut();

    if (context != null) {
      SnackBarHelper.showError(
          context, "Phiên đăng nhập của bạn hết hạn, vui lòng đăng nhập lại!");
      context.go(AppRouterConfig.login);
    }
  }

  // Get authentication headers with token and email
  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await LocalStorage.getToken();
    // final email = await LocalStorage.getEmail();

    return {
      ..._defaultHeaders,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      // if (email != null && email.isNotEmpty) 'X-user-email': email,
    };
  }

  static ApiResponse _buildApiResponse(http.Response res) {
    final statusCode = res.statusCode;

    dynamic decoded;
    try {
      decoded = res.body.isNotEmpty ? jsonDecode(res.body) : null;
    } catch (_) {
      decoded = null;
    }

    final success = statusCode >= 200 && statusCode < 300;

    String? message;
    dynamic data;
    int? totalDocs;
    Map<String, dynamic>? meta;

    if (decoded is Map<String, dynamic>) {
      message = decoded['message'];
      totalDocs = decoded['totalDocs'];
      meta = decoded['meta'];

      // 🎯 Ưu tiên field "data" nếu có
      if (decoded.containsKey('data')) {
        data = decoded['data'];
      } else {
        // fallback: remove metadata rồi lấy phần còn lại
        final temp = Map<String, dynamic>.from(decoded)
          ..remove('message')
          ..remove('totalDocs')
          ..remove('meta');

        data = temp;
      }
    } else if (decoded is List) {
      data = decoded;
    } else {
      data = null;
    }

    message ??= MapStatusCode.mapStatusToMessage(statusCode);

    return ApiResponse(
      statusCode: statusCode,
      success: success,
      message: message,
      totalDocs: totalDocs,
      meta: meta,
      data: data,
    );
  }

  // Unified request method supporting all HTTP methods (JSON only)
  static Future<ApiResponse> request(
      HttpMethod method,
      String url, {
        Map<String, dynamic>? body,
        Map<String, String>? additionalHeaders,
        Map<String, dynamic>? queryParams,
        bool handle401 = true,
      }) async {
    try {

      if(AppConfig.isViewLogResponse) {
        appLog('[RAW REQUEST] $url | Body: ${body}');
      }
      // Build URI with query parameters
      Uri uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(
          queryParameters: queryParams.map(
                (key, value) => MapEntry(key, value.toString()),
          ),
        );
      }

      // Get authentication headers
      final authHeaders = await _getAuthHeaders();
      final mergedHeaders = {
        ...authHeaders,
        if (additionalHeaders != null) ...additionalHeaders,
      };

      http.Response res;

      // Execute request based on HTTP method
      switch (method) {
        case HttpMethod.get:
          res = await http.get(uri, headers: mergedHeaders);
          break;
        case HttpMethod.post:
          res = await http.post(
            uri,
            headers: mergedHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case HttpMethod.put:
          res = await http.put(
            uri,
            headers: mergedHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case HttpMethod.patch:
          res = await http.patch(
            uri,
            headers: mergedHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case HttpMethod.delete:
          res = await http.delete(
            uri,
            headers: mergedHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
      }

      if(AppConfig.isViewLogResponse) {
        appLog('[RAW RESPONSE] $url | Status: ${res.statusCode} | Body: ${res.body} - ', data: res.body);
      }

      // Handle 401 Unauthorized
      if (handle401 && res.statusCode == 401) {
        await _handle401();
        return ApiResponse(
          statusCode: 401,
          success: false,
          message: 'Phiên đăng nhập đã hết hạn',
          data: {},
        );
      }
      // appLog('[LOG-CHECK] - URL Request: $url');

      return _buildApiResponse(res);
    } catch (e) {
      appLog('[ERROR] $method $url | $e');

      return ApiResponse(
        statusCode: 500,
        success: false,
        message: 'Không thể kết nối đến server. Vui lòng thử lại sau: $e',
        data: {},
      );
    }
  }

  // NEW: Method riêng cho FormData upload
  static Future<ApiResponse> postFormData(
      String url, {
        required Map<String, String> fields,
        required Map<String, File> files,
        Map<String, String>? additionalHeaders,
        Map<String, dynamic>? queryParams,
        bool handle401 = true,
      }) async {
    try {
      // Build URI with query parameters
      Uri uri = Uri.parse(url);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(
          queryParameters: queryParams.map(
                (key, value) => MapEntry(key, value.toString()),
          ),
        );
      }

      // Get authentication headers (without Content-Type because multipart will set boundary)
      final token = await LocalStorage.getToken();
      // final email = await LocalStorage.getEmail();

      final Map<String, String> headers = {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        // if (email != null && email.isNotEmpty) 'X-user-email': email,
        if (additionalHeaders != null) ...additionalHeaders,
      };

      // Create multipart request
      var request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      // Add text fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add files
      for (var entry in files.entries) {
        final file = entry.value;
        final mimeType = _getMimeType(file.path);

        final multipartFile = await http.MultipartFile.fromPath(
          entry.key,
          file.path,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(multipartFile);
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Handle 401 Unauthorized
      if (handle401 && response.statusCode == 401) {
        await _handle401();
        return ApiResponse(
          statusCode: 401,
          success: false,
          message: 'Phiên đăng nhập đã hết hạn',
          data: {},
        );
      }

      return _buildApiResponse(response);
    } catch (e) {
      appLog('[ERROR] POST FORM_DATA $url | $e');

      return ApiResponse(
        statusCode: 500,
        success: false,
        message: 'Không thể upload file. Vui lòng thử lại sau: $e',
        data: {},
      );
    }
  }

  // Helper: Lấy MIME type từ file extension
  static String _getMimeType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
}