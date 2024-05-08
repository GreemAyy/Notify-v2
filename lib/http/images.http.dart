import 'dart:io';
import 'package:dio/dio.dart';
import '../app_settings/const.dart';

abstract class ImagesHttp{
  static Future<Map<String, dynamic>> sendSingleFile(File file) async {
    var url = Uri.parse('${Constants.URL_MAIN}/api/images/load-single');
    var dio = Dio();
    var formData = FormData();
    formData.files.add(
        MapEntry("file", await MultipartFile.fromFile(file.path))
    );
    var res = await dio.post(url.toString(), data:formData);
    return res.data as Map<String, dynamic>;
  }
}