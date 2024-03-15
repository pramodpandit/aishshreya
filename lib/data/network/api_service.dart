import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import '../../utils/enums.dart';
import 'api_exception.dart';


class ApiService {
  final Dio dio;
  ApiService(this.dio);
  static const host = "https://krishnadeep.com/aishshreya2/";
  // static const host = "http://192.168.1.49:80/aishshreya/";
  //
  static const _baseUrl = "${host}api/";

  dynamic postRequest(String subUrl, Map<String, dynamic> inputData, {bool withFile = false, bool requireToken=false, bool cacheRequest = true, bool forceRefresh = false}) async {
    try {
      String url = "$_baseUrl$subUrl";

      // print('---POST1 url $url');
      // print('---Params $inputData');
      Options option = Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: requireToken ? {
          'token': true,
        } : {},
      );
      Response res = await dio.post(
        "$url",
        data: withFile ? FormData.fromMap(inputData) : inputData,
        options: cacheRequest ? buildCacheOptions(
          const Duration(minutes: 30),
          maxStale: const Duration(days: 2),
          forceRefresh: forceRefresh,
          options: option,
        ) : option,
      );

      if (res.statusCode == 200) {
        var rData = res.data;
        // print('---RESULT: $rData');
        // print('---RESULT END');
        return rData;
      } else {
        throw ApiException.fromString("Error Occurred. ${res.statusCode}");
      }
    } on SocketException {
      throw ApiException.fromString("No Internet Connection!");
    } on DioError catch (dioError) {
      throw ApiException.fromDioError(dioError);
    }
  }

  dynamic getRequest(String subUrl, {Map<String, dynamic> data = const {}, bool requireToken = false, bool cacheRequest = true, bool forceRefresh = false}) async {
    try {

      String url = "$_baseUrl$subUrl";

      // print('---GET1 url $url');
      // print('---Params $data');

      Options option = Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: requireToken ? {
          'token': true,
        } : {},
      );
      Response res = await dio.get(
        url,
        queryParameters: data,
        options: cacheRequest ? buildCacheOptions(
          const Duration(minutes: 30),
          maxStale: const Duration(days: 2),
          forceRefresh: forceRefresh,
          options: option,
        ) : option,
      );
      // print('---RESULT: ${res.data}');
      if (res.statusCode == 200) {
        var rData = res.data;
        // print('---RESULT END');
        return rData;
      } else {
        throw ApiException.fromString("Error Occurred. ${res.statusCode}");
      }
    } on SocketException {
      throw ApiException.fromString("No Internet Connection!");
    } on DioError catch (dioError) {
      throw ApiException.fromDioError(dioError);
    }
  }
}
