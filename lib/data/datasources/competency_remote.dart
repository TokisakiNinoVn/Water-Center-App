import 'package:clean_water/core/network/dio_client.dart';
import 'package:clean_water/presentation/utils/index_utils.dart';

class CompetencyRemote {
  Future<Map<String, dynamic>> get() async {
    final res = await DioClient.dio.get("/student/competency");
    return res.data;
  }
}
