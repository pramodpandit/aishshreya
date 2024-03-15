import 'dart:io';

import 'package:aishshreya/data/model/CallLogDetail.dart';
import 'package:aishshreya/data/model/DashboardDetail.dart';
import 'package:aishshreya/data/model/UserDetail.dart';
import 'package:aishshreya/data/model/api_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_service.dart';

class EmployeeRepository {
  final SharedPreferences prefs;
  final ApiService _api;

  EmployeeRepository(this.prefs, this._api);

  Future<ApiResponse<DashboardDetail>> getDashBoard() async {
    var res = await _api.getRequest('dashboard_details', requireToken: true, cacheRequest: false);
    return ApiResponse.fromJson(res, res['data']!=null ? DashboardDetail.fromJson(res['data']) : null);
  }

  Future<ApiResponse> createNewEmployee(String employee, {File? image}) async {
    Map<String, dynamic> data = {
      'employee': employee,
    };
    if(image!=null) {
      data['image'] = await MultipartFile.fromFile(image.path, filename: image.path.split('/').last);
    }
    var res = await _api.postRequest('create_employee', data, withFile: true, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res);
  }

  Future<ApiResponse<List<UserDetail>>> getEmployees(int page, {String? sort, bool sortAsc=false, String? filter, bool showAll = false, bool doNotShowAccountant = false}) async {
    Map<String, dynamic> data = {
      'page': page,
      "sortType": sortAsc ? "ASC" : "DESC",
      "doNotShowAccountant": doNotShowAccountant ? 1 : 0,
    };
    if(sort!=null) {
      data['sort'] = sort;
    }
    if(filter!=null) {
      data['filter'] = filter;
    }
    if(showAll) {
      data['all'] = '1';
    }

    var res = await _api.getRequest('employees', data: data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res, List.from((res['data'] ?? []).map((e) => UserDetail.fromJson(e))));
  }

  Future<ApiResponse<UserDetail>> getEmployeeDetail(String id) async {
    var res = await _api.getRequest('employee/$id', cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res, res['data']!=null ? UserDetail.fromJson(res['data']) : null);
  }

  Future<ApiResponse<UserDetail>> editEmployeeDetails(String employee, {File? image}) async {
    Map<String, dynamic> data = {
      'employee': employee,
    };
    if(image!=null) {
      data['image'] = await MultipartFile.fromFile(image.path, filename: image.path.split('/').last);
    }
    var res = await _api.postRequest('update_employee', data, withFile: true, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res, res['data']!=null ? UserDetail.fromJson(res['data']) : null);
  }

  Future<ApiResponse<List<CallLogDetail>>> getCallLogs(int page, {String? filterType, String? query, DateTime? date, DateTimeRange? range}) async {
    Map<String, dynamic> data = {
      'page': page,
      'filter_type': filterType,
    };
    if(date!=null) {
      data['date'] = DateFormat('yyyy-MM-dd').format(date);
    }
    if(range!=null) {
      data['start_date'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(range.start);
      data['end_date'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(range.end);
    }
    if(query!=null) {
      data['q'] = query;
    }

    var res = await _api.getRequest('call_logs', data: data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res, List.from((res['data'] ?? []).map((e) => CallLogDetail.fromJson(e))));
  }

  Future<ApiResponse<List<CallLogDetail>>> getClientCallLogs(int page, String clientId) async {
    Map<String, dynamic> data = {
      'page': page,
      'client': clientId,
    };

    var res = await _api.getRequest('get_client_callLogs', data: data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res, List.from((res['data'] ?? []).map((e) => CallLogDetail.fromJson(e))));
  }

/*
  Future<ApiResponse<List<CallLogDetail>>> searchCallLogs(int page, String query) async {
    Map<String, dynamic> data = {
      'page': page,
      'q': query,
    };

    var res = await _api.getRequest('search_call_logs', data: data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res, List.from((res['data'] ?? []).map((e) => CallLogDetail.fromJson(e))));
  }
*/

  Future<ApiResponse<List<UserDetail>>> searchEmployee(int page, String query, {String? sort, bool sortAsc=false, String? filter, bool showAll = false}) async {
    Map<String, dynamic> data = {
      'page': page,
      'q': query,
      "sortType": sortAsc ? "ASC" : "DESC",
    };
    if(sort!=null) {
      data['sort'] = sort;
    }
    if(filter!=null) {
      data['filter'] = filter;
    }
    if(showAll) {
      data['all'] = '1';
    }

    var res = await _api.getRequest('search_employee', data: data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res, List.from((res['data'] ?? []).map((e) => UserDetail.fromJson(e))));
  }

// Future<ApiResponse<List<AppVersionData>>> getAppVersion() async {
//   var response = await _api.getRequest('get_app_version', type: URLType.edansh);
//
//   if (response == null) {
//     throw ApiException.fromString("response null");
//   }
//
//   return ApiResponse.fromJson(response, response['data']==null ? [] : List<AppVersionData>.from(response['data'].map((e) => AppVersionData.fromJson(e))));
// }

  Future<ApiResponse> addCallLogs(String callLog, File audioFile) async {
    Map<String, dynamic> data = {
      'callLog': callLog,
    };
    print('audioFile.path ${audioFile.path}');
    data['file'] = await MultipartFile.fromFile(audioFile.path, filename: audioFile.path.split('/').last);

    var res = await _api.postRequest('add_call_log', data, withFile: true, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res);
  }

}