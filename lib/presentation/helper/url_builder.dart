class UrlBuilder {
  static String withId(String baseUrl, dynamic id) {
    return '$baseUrl/$id';
  }

  static String withQuery(
      String baseUrl,
      Map<String, dynamic> query,
      ) {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters:
      query.map((k, v) => MapEntry(k, v.toString())),
    );
    return uri.toString();
  }
}
