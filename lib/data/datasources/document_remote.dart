import 'package:clean_water/core/network/dio_client.dart';
import 'package:clean_water/data/models/index_model.dart';

class DocumentRemote {
  Future<List<Document>> getList() async {
    final res = await DioClient.dio.get("/student/documents");

    final List list = res.data;

    return list.map((e) => Document.fromJson(e)).toList();
  }
}
