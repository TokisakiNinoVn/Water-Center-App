class MapStatusCode {
  static String mapStatusToMessage(int statusCode) {
    switch (statusCode) {
      case 200:
      case 201:
        return 'Thành công';
      case 400:
        return 'Yêu cầu không hợp lệ';
      case 401:
        return 'Chưa xác thực';
      case 403:
        return 'Không có quyền';
      case 404:
        return 'Không tìm thấy';
      case 500:
        return 'Lỗi server';
      default:
        return 'Có lỗi xảy ra';
    }
  }

}