import 'dart:io';

import 'package:aishshreya/data/model/DashboardDetail.dart';
import 'package:aishshreya/data/model/ServiceDetail.dart';
import 'package:aishshreya/data/model/TransactionDetail.dart';
import 'package:aishshreya/data/model/UserDetail.dart';
import 'package:aishshreya/data/model/api_response.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_service.dart';

class ServiceRepository {
  final SharedPreferences prefs;
  final ApiService _api;

  ServiceRepository(this.prefs, this._api);

  Future<ApiResponse> createServiceWithLead(String leadId, String serviceName, DateTime serviceDate, num amount) async {
    Map<String, dynamic> data = {
      'lead_id': leadId,
      'service_name': serviceName,
      'service_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(serviceDate),
      'amount': amount,
    };
    var res = await _api.postRequest('create_service_with_lead', data, requireToken: true, cacheRequest: false);
    return ApiResponse.fromJson(res);
  }

  Future<ApiResponse> createServiceWithClient(String clientId, String serviceName, DateTime serviceDate, num amount) async {
    Map<String, dynamic> data = {
      'lead_id': clientId,
      'service_name': serviceName,
      'service_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(serviceDate),
      'amount': amount,
    };
    var res = await _api.postRequest('create_service_with_client', data, requireToken: true, cacheRequest: false);
    return ApiResponse.fromJson(res);
  }

  Future<ApiResponse<List<ServiceDetail>>> getServices(int page, {String? eid,  String status = 'all', String filterType='none', String sortType='new_first', DateTime? date, DateTimeRange? range, String? query}) async {
    Map<String, dynamic> data = {
      'page': page,
      'status': status,
      'filter_type': filterType,
      'sort_type': sortType,
    };
    if(eid!=null) {
      data['eid'] = eid;
    }
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
    var res = await _api.getRequest('services', data: data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res, List.from((res['data'] ?? []).map((e) => ServiceDetail.fromJson(e))));
  }

  Future<ApiResponse<ServiceDetail>> getServiceDetail(String serviceId) async {
    Map<String, dynamic> data = {
      'id': serviceId,
    };
    var res = await _api.getRequest('service_detail', data: data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res, res['data']!=null ? ServiceDetail.fromJson(res['data']) : null);
  }

  Future<ApiResponse<List<ServiceDetail>>> getServiceAmountDue(int page) async {
    Map<String, dynamic> data = {
      'page': page,
    };

    var res = await _api.getRequest('due_services', data: data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res, List.from((res['data'] ?? []).map((e) => ServiceDetail.fromJson(e))));
  }

  Future<ApiResponse> clearServiceDue(String serviceId, String amount, {String? clearDueDesc}) async {
    Map<String, dynamic> data = {
      'service_id': serviceId,
      'amount': amount,
    };
    if(clearDueDesc!=null && clearDueDesc!='') {
      data['desc'] = clearDueDesc;
    }

    var res = await _api.postRequest('clearServicesDue', data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res);
  }

  Future<ApiResponse<List<TransactionDetail>>> getTransactions(int page, {String? serviceId, String filterType = '', DateTime? date, DateTimeRange? range}) async {
    Map<String, dynamic> data = {
      'page': page,
      'filter_type': filterType,
    };
    if(serviceId!=null) {
      data['serviceId'] = serviceId;
    }
    if(date!=null) {
      data['date'] = DateFormat('yyyy-MM-dd').format(date);
    }
    if(range!=null) {
      data['start_date'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(range.start);
      data['end_date'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(range.end);
    }
    var res = await _api.getRequest('transactions', data: data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res, List.from((res['data'] ?? []).map((e) => TransactionDetail.fromJson(e))));
  }
  Future<ApiResponse> addServiceAmount(String serviceId, String description, String amount, bool isAdditionalService, {DateTime? schedule}) async {
    Map<String, dynamic> data = {
      'service_id': serviceId,
      'title': description,
      'amount': amount,
      'type': isAdditionalService ? 'service' : 'other',
    };
    if(schedule!=null) {
      data['schedule'] = DateFormat("yyyy-MM-dd hh:mm:ss").format(schedule);
    }
    var res = await _api.postRequest('add_services_due', data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res);
  }

  Future<ApiResponse> updateTransactionStatus(String transactionId, bool status) async {
    Map<String, dynamic> data = {
      'tr_id': transactionId,
      'status': status ? '1' : '0',
    };

    var res = await _api.postRequest('update_transaction_status', data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res);
  }

  Future<ApiResponse> editServiceAmount(String id, String amount) async {
    Map<String, dynamic> data = {
      'id': id,
      'amount': amount,
    };

    var res = await _api.postRequest('edit_service_amount', data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res);
  }

  Future<ApiResponse> editServiceInvoiceDescp(String id, String title) async {
    Map<String, dynamic> data = {
      'service_id': id,
      'title': title,
    };

    var res = await _api.postRequest('edit_service_description', data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res);
  }

  Future<ApiResponse> cancelService(String id, String trId) async {
    Map<String, dynamic> data = {
      'id': id,
      'trId': trId,
    };

    var res = await _api.postRequest('cancel_additional_service', data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res);
  }
}