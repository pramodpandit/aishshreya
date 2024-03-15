import 'dart:io';

import 'package:aishshreya/data/model/ClientDetail.dart';
import 'package:aishshreya/data/model/DashboardDetail.dart';
import 'package:aishshreya/data/model/LeadDetail.dart';
import 'package:aishshreya/data/model/LeadHistory.dart';
import 'package:aishshreya/data/model/ServiceDetail.dart';
import 'package:aishshreya/data/model/UserDetail.dart';
import 'package:aishshreya/data/model/api_response.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_service.dart';

class LeadsRepository {
  final SharedPreferences prefs;
  final ApiService _api;

  LeadsRepository(this.prefs, this._api);

  Future<ApiResponse<List<LeadDetail>>> getLeads(int page,
      {String? eid, String? sort, bool sortAsc = false, String? filter}) async {
    Map<String, dynamic> data = {
      "page": page,
      "sortType": sortAsc ? "ASC" : "DESC"
    };
    if (eid != null) {
      data['eid'] = eid;
    }
    if (sort != null) {
      data['sort'] = sort;
    }
    if (filter != null) {
      data['filter'] = filter;
    }
    var res = await _api.getRequest('leads',
        data: data, requireToken: true, cacheRequest: false);
    return ApiResponse.fromJson(
        res, List.from((res['data'] ?? []).map((e) => LeadDetail.fromJson(e))));
  }

  Future<ApiResponse<List<ClientDetail>>> getClients(int page,
      {String? eid,
      String? sort,
      bool sortAsc = false,
      String? filter,
      bool showAll = false,
      String? searchQuery}) async {
    Map<String, dynamic> data = {
      "page": page,
      "sortType": sortAsc ? "ASC" : "DESC",
    };
    if (eid != null) {
      data['eid'] = eid;
    }
    if (sort != null) {
      data['sort'] = sort;
    }
    if (filter != null) {
      data['filter'] = filter;
    }
    if (showAll) {
      data['all'] = '1';
    }
    if(searchQuery!=null) {
      data['q'] = searchQuery;
    }
    var res = await _api.getRequest('clients',
        data: data, requireToken: true, cacheRequest: false);
    return ApiResponse.fromJson(res,
        List.from((res['data'] ?? []).map((e) => ClientDetail.fromJson(e))));
  }

  Future<ApiResponse> createNewLead(String lead, {File? image}) async {
    Map<String, dynamic> data = {
      'lead': lead,
    };
    if (image != null) {
      data['image'] = await MultipartFile.fromFile(image.path,
          filename: image.path.split('/').last);
    }
    var res = await _api.postRequest('create_lead', data,
        withFile: true, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res);
  }

  Future<ApiResponse> createNewClient(String client, {File? image}) async {
    Map<String, dynamic> data = {
      'client': client,
    };
    if (image != null) {
      data['image'] = await MultipartFile.fromFile(image.path,
          filename: image.path.split('/').last);
    }
    var res = await _api.postRequest('create_client', data,
        withFile: true, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res);
  }

  Future<ApiResponse<ClientDetail>> getClientDetail(String clientId) async {
    var res = await _api.getRequest('clients-details/$clientId',
        cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res, res['data']!=null ? ClientDetail.fromJson(res['data']) : null);
  }

  Future<ApiResponse<LeadDetail>> getLeadDetails(String leadId) async {
    Map<String, dynamic> data = {"lead_id": leadId};
    var res = await _api.getRequest('leads_details', data: data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res, res['data']!=null ? LeadDetail.fromJson(res['data']) : null);
  }

  Future<ApiResponse<List<ServiceDetail>>> getClientServices(
      String clientId) async {
    // Map<String, dynamic> data = {
    //   'id': clientId,
    // };
    var res = await _api.getRequest('client-services/$clientId', cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res,
        List.from((res['data'] ?? []).map((e) => ServiceDetail.fromJson(e))));
  }

  Future<ApiResponse> editClientDetails(String client, {File? image}) async {
    Map<String, dynamic> data = {
      'client': client,
    };
    if (image != null) {
      data['image'] = await MultipartFile.fromFile(image.path,
          filename: image.path.split('/').last);
    }
    var res = await _api.postRequest('edit_client', data,
        withFile: true, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res);
  }

  Future<ApiResponse> editLeadDetails(String lead, {File? image}) async {
    Map<String, dynamic> data = {
      'lead': lead,
    };
    if (image != null) {
      data['image'] = await MultipartFile.fromFile(image.path,
          filename: image.path.split('/').last);
    }
    var res = await _api.postRequest('edit_lead', data,
        withFile: true, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res);
  }

  Future<ApiResponse> createLeadWithClient(String clientId, String requirement, {String? empId}) async {
    Map<String, dynamic> data = {
      'client_id': clientId,
      'requirement': requirement,
    };
    if(empId!=null) {
      data['eid'] = empId;
    }
    var res = await _api.postRequest('create-lead-with-client', data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res);
  }

  Future<ApiResponse> createServiceWithClient(String clientId, String service, String amount, DateTime date) async {
    Map<String, dynamic> data = {
      'client_id': clientId,
      'service_name': service,
      'service_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(date),
      'amount': amount,
    };
    var res = await _api.postRequest('create_service_with_client', data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res);
  }

  Future<ApiResponse> updateLeadStatus(String leadId, String title, String description, String status, {DateTime? schedule}) async {
    Map<String, dynamic> data = {
      'lead_id': leadId,
      'title': title,
      'description': description,
      'status': status,
    };
    if(schedule!=null) {
      data['schedule'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(schedule);
    }
    var res = await _api.postRequest('add-lead-history', data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res);
  }

  Future<ApiResponse> createServiceWithLead(String leadId, String service, String amount, DateTime date) async {
    Map<String, dynamic> data = {
      'lead_id': leadId,
      'service_name': service,
      'service_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(date),
      'amount': amount,
    };
    var res = await _api.postRequest('create_service_with_lead', data, cacheRequest: false, requireToken: true);
    return ApiResponse.fromJson(res);
  }

  Future<ApiResponse<List<LeadDetail>>> getClientLeads(int page, String clientId) async {
    Map<String, dynamic> data = {
      "page": page,
      "client": clientId
    };

    var res = await _api.getRequest('leads', data: data, requireToken: true, cacheRequest: false);
    return ApiResponse.fromJson(
        res, List.from((res['data'] ?? []).map((e) => LeadDetail.fromJson(e))));
  }

  Future<ApiResponse<List<ServiceDetail>>> getPasLeadServices(String leadId) async {
    Map<String, dynamic> data = {
      "lead_id": leadId
    };

    var res = await _api.getRequest('past_lead_service', data: data, requireToken: true, cacheRequest: false);
    return ApiResponse.fromJson(
        res, List.from((res['data'] ?? []).map((e) => ServiceDetail.fromJson(e))));
  }

  Future<ApiResponse<List<LeadHistory>>> getPastServiceLeadHistory(int page, String leadId) async {
    Map<String, dynamic> data = {
      "page": page,
      "lead_id": leadId
    };

    var res = await _api.getRequest('past_service_lead_history', data: data, requireToken: true, cacheRequest: false);
    return ApiResponse.fromJson(
        res, List.from((res['data'] ?? []).map((e) => LeadHistory.fromJson(e))));
  }
}
