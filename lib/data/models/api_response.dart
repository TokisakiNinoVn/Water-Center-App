class ApiResponse {
  final int? statusCode;
  final bool? success;
  final String? message;
  final dynamic data;
  final int? totalDocs;
  final String? error;
  final String? errorMessage;
  final Map<String, dynamic>? meta;

  ApiResponse({this.statusCode, this.success, this.message, this.totalDocs, required this.data, this.error, this.errorMessage, this.meta});

  @override
  String toString() {
    return 'ApiResponse(statusCode: $statusCode, message: $message, data: $data)';
  }

}
