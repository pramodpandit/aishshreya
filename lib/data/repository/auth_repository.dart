import 'dart:io';
import 'package:aishshreya/data/model/AuthResponse.dart';
import 'package:aishshreya/data/model/UserDetail.dart';
import 'package:aishshreya/data/model/api_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_service.dart';

class AuthRepository {
  final SharedPreferences prefs;
  final ApiService _api;

  AuthRepository(this.prefs, this._api);

  Future<ApiResponse<UserDetail>> userLoginWithPhone(String dialCode, String phone, {String? fcmToken}) async {
    Map<String, dynamic> data = {
      'dialCode': dialCode,
      'phone': phone,
    };

    if(fcmToken!=null) {
      data['fcmToken'] = fcmToken;
    }

    var res = await _api.postRequest('login_with_phone', data, cacheRequest: false);
    return ApiResponse.fromJson(res, res['data']!=null ? UserDetail.fromJson(res['data']) : null);
  }

  // Future<ApiResponse<UserDetail?>> updateUser(String name, {File? image}) async {
  //   Map<String, dynamic> data = {
  //     'name': name,
  //   };
  //
  //   if(image!=null) {
  //     MultipartFile file = await MultipartFile.fromFile(image.path, filename: image.path.split('/').last);
  //     data['image'] = file;
  //   }
  //
  //   var res = await _api.postRequest('user_update', data, withFile: true, requireToken: true);
  //   return ApiResponse.fromJson(res, res['data']!=null ? UserDetail.fromJson(res['data']) : null);
  // }

  // Future<ApiResponse<UserDetail?>> getUserDetails() async {
  //   var res = await _api.getRequest('user_detail', requireToken: true);
  //   return ApiResponse.fromJson(res, res['data']!=null ? UserDetail.fromJson(res['data']) : null);
  // }

  // Future<ApiResponse<ForgotPasswordVerificationResult?>> sendForgotPasswordVerificationOTP(String email) async {
  //   Map<String, dynamic> data = {
  //     'email': email,
  //   };
  //
  //   var res = await _api.postRequest('forgot_password', data, cacheRequest: false);
  //   return ApiResponse.fromJson(res, res['data']!=null ? ForgotPasswordVerificationResult.fromJson(res['data']) : null);
  // }
  //
  // Future<ApiResponse> changeForgotPassword(String uid, String password) async {
  //   Map<String, dynamic> data = {
  //     'uid': uid,
  //     'password': password,
  //   };
  //
  //   var res = await _api.postRequest('update_password', data, cacheRequest: false);
  //   return ApiResponse.fromJson(res);
  // }

}

