import 'dart:io';

import 'package:aishshreya/data/model/AppNotification.dart';
import 'package:aishshreya/data/model/api_response.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_service.dart';

class AppRepository {
  final SharedPreferences prefs;
  final ApiService _api;

  AppRepository(this.prefs, this._api);

  // Future<ApiResponse<AppDetail?>> getAppDetails() async {
  //   var res = await _api.getRequest('get_app_details', type: URLType.edansh);
  //   return ApiResponse.fromJson(res, res['data']!=null ? AppDetail.fromJson(res['data']) : null);
  // }
  //
  // Future<ApiResponse<List<AppVersionData>>> getAppVersion() async {
  //   var response = await _api.getRequest('get_app_version', type: URLType.edansh);
  //
  //   if (response == null) {
  //     throw ApiException.fromString("response null");
  //   }
  //
  //   return ApiResponse.fromJson(response, response['data']==null ? [] : List<AppVersionData>.from(response['data'].map((e) => AppVersionData.fromJson(e))));
  // }

  Future<ApiResponse<List<AppNotification>>> getNotifications(int page) async {
    var res = await _api.getRequest('notifications', data: {'page': page}, requireToken: true, cacheRequest: false, forceRefresh: true);
    return ApiResponse.fromJson(res, List.from((res['data'] ?? []).map((e) => AppNotification.fromJson(e))));
  }

}