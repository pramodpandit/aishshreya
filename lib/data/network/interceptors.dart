import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInterceptors extends Interceptor {
  @override
  Future<dynamic> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint("===[${options.method}] ${options.baseUrl}${options.path}");
    if(options.queryParameters.isNotEmpty) {
      debugPrint("===[PARAMS] ${options.queryParameters}");
    }
    if(options.data!=null) {
      debugPrint("===[BODY] ${(options.data.runtimeType == FormData ? (options.data as FormData).fields : options.data).toString()}");
    }

    if (options.headers.containsKey("token")) {
      // print('asking token');
      //remove the auxiliary header
      options.headers.remove("token");
      var token =  prefs.get("token");
      // debugPrint("token $token");
      // var token = "eyJpdiI6InJOMTRMaFdXWkVUWmdlOUp6ZU9jemc9PSIsInZhbHVlIjoic1VvOERoeFNUWUFVbGRBYys2Y2VwY0xMQ29vTUR4bGFIM3dsaEJleDhTcjdJU014MmlOS2Z4aWlhdVZ3ZURSL20rRU1sdDJhNDYrUytyWk9CRGxvbWc9PSIsIm1hYyI6ImE2MzQ2OGZmY2JkZjZmMTRkNzc2ZWE0YTQ2MzBhZDkzMWZiZWQ4YWZkM2VhNjU0YzE3NDQ5OGZmNTM5MGY4ODEiLCJ0YWciOiIifQ==";

      // options.headers.addAll({"token": "$header"});
      options.headers["Authorization"] = "Bearer $token";
      return handler.next(options);
    }
    return handler.next(options);
  }

  @override
  Future<dynamic> onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response != null &&
        err.response?.statusCode != null &&
        err.response?.statusCode == 401) {
      // (await CacheManager()).cleanCache();
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // prefs.setString("apiToken", "");
      // navigatorKey.currentState.pushNamed(SplashScreen.routeName);

    }
    debugPrint('===[ERROR RESPONSE[${err.response?.statusCode}] - ${err.response?.realUri.toString()}] - ${err.response}');
    debugPrint('===END');
    return handler.next(err);
  }

  @override
  Future<dynamic> onResponse(Response response, ResponseInterceptorHandler handler) async {
    debugPrint('===[RESPONSE[${response.statusCode}-${response.realUri.toString()}]] - ${response.data}');
    debugPrint('===END');
    return handler.next(response);
  }
}