import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'api_exception.dart';

class NowPaymentApiService {
  final Dio dio;
  NowPaymentApiService(this.dio);

  static const _baseUrl = "https://api.nowpayments.io/v1/";

  dynamic postRequest(String subUrl, Map<String, dynamic> inputData, {bool isJson = false}) async {
    try {
      print('---POST url $_baseUrl$subUrl');
      if(isJson) {
        print('---Params ${json.encode(inputData)}');
      } else {
        print('---Params $inputData');
      }
      Response res = await dio.post(
        "$_baseUrl$subUrl",
        data: isJson ? json.encode(inputData) : FormData.fromMap(inputData),
        options: Options(
          contentType: Headers.jsonContentType,
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            'Content-type': 'application/json',
            "Accept": "application/json",
            // "Accept-Encoding": "gzip, deflate, br",
            'now-payment-key': true,
          },
        ),
      );
      print('res.data ${res.data}');

      if (res.statusCode == 200) {
        var rData = res.data;
        print('---RESULT: $rData');
        print('---RESULT END');
        return rData;
      } else if(res.statusCode == 201) {
        var rData = res.data;
        print('---RESULT: $rData');
        print('---RESULT END');
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

  dynamic getRequest(String subUrl, {Map<String, dynamic> data = const {}}) async {
    try {
      print('---GET url $_baseUrl$subUrl');
      print('---Params $data');
      Response res = await dio.get(
        "$_baseUrl$subUrl",
        queryParameters: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType, //'application/json',
          headers: {
            'now-payment-key': true,
          },
        ),
      );
      print('---RESULT: ${res.data}');
      if (res.statusCode == 200) {
        var rData = res.data;
        print('---RESULT END');
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
