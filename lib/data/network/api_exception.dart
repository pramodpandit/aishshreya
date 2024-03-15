import 'package:dio/dio.dart';

class ApiException implements Exception {
  static const networkMessage = "Connection to API server failed due to internet connection";
  ApiException.fromDioError(DioError dioError) {
    print("Error calling url: ${dioError.requestOptions.path} - ${dioError.error.toString()}");
    switch (dioError.type) {
      case DioErrorType.cancel:
        message = "Request to API server was cancelled";
        break;
      case DioErrorType.connectTimeout:
        message = "Connection timeout with API server";
        break;
      case DioErrorType.other:
        message = networkMessage;
        break;
      case DioErrorType.receiveTimeout:
        message = "Receive timeout in connection with API server";
        break;
      case DioErrorType.response:
        message = _handleError(dioError.response!.statusCode);
        break;
      case DioErrorType.sendTimeout:
        message = "Send timeout in connection with API server";
        break;
      default:
        message = "Something went wrong";
        break;
    }
  }

  ApiException.fromString(String errorMsg) {
    message = errorMsg;
  }

  String message = '';

  String _handleError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 404:
        return 'The requested resource was not found';
      case 500:
        return 'Internal server error';
      default:
        return 'Something went wrong on server';
    }
  }

  @override
  String toString() => message;
}
