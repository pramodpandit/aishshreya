import 'dart:convert';
import 'dart:io';

import 'package:aishshreya/bloc/property_notifier.dart';
import 'package:aishshreya/data/model/DashboardDetail.dart';
import 'package:aishshreya/data/model/ServiceDetail.dart';
import 'package:aishshreya/data/model/api_response.dart';
import 'package:aishshreya/data/repository/employee_repository.dart';
import 'package:aishshreya/data/repository/service_repository.dart';
import 'package:aishshreya/utils/enums.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bloc.dart';

class DashboardBloc extends Bloc {
  final EmployeeRepository _repo;
  final ServiceRepository _serviceRepo;
  DashboardBloc(this._repo, this._serviceRepo);

  //#region -Dashboard
  ValueNotifier<LoadingState> state = ValueNotifier(LoadingState.done);

  initAdmin() async {
    if(state.value==LoadingState.loading) {
      return;
    }
    state.value = LoadingState.loading;
    try {
      await Future.wait([
        getDashboardInfo(),
        getUpcomingService(),
        getServiceDues(),
      ]);
      state.value = LoadingState.done;
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      state.value = LoadingState.error;
    }
  }

  //#region -Dashboard Details
  ValueNotifier<LoadingState> dashboardInfoState = ValueNotifier(LoadingState.done);
  PropertyNotifier<DashboardDetail?> dashboard = PropertyNotifier(null);
  Future getDashboardInfo() async {
    try{
      if(dashboardInfoState.value==LoadingState.loading) {
        return;
      }
      dashboardInfoState.value = LoadingState.loading;
      ApiResponse<DashboardDetail> res = await _repo.getDashBoard();
      if(res.status) {
        dashboard.value = res.data;
      } else {
        showMessage(MessageType.error(res.message));
        dashboardInfoState.value = LoadingState.error;
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      dashboardInfoState.value = LoadingState.error;
      rethrow;
    } finally {
      dashboardInfoState.value = LoadingState.done;
    }
  }
  //#endregion

  //#region -Upcoming Services
  ValueNotifier<LoadingState> upcomingServiceState = ValueNotifier(LoadingState.done);
  PropertyNotifier<List<ServiceDetail>> upcomingService = PropertyNotifier([]);
  Future getUpcomingService() async {
    try{
      if(upcomingServiceState.value==LoadingState.loading) {
        return;
      }
      upcomingServiceState.value = LoadingState.loading;
      ApiResponse<List<ServiceDetail>> res = await _serviceRepo.getServices(1);
      if(res.status) {
        upcomingService.value = res.data ?? [];
      } else {
        showMessage(MessageType.error(res.message));
        upcomingServiceState.value = LoadingState.error;
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      upcomingServiceState.value = LoadingState.error;
      rethrow;
    } finally {
      upcomingServiceState.value = LoadingState.done;
    }
  }
  //#endregion

  //#region -Due Services
  ValueNotifier<LoadingState> serviceDuesState = ValueNotifier(LoadingState.done);
  PropertyNotifier<List<ServiceDetail>> serviceDues = PropertyNotifier([]);
  Future getServiceDues() async {
    try{
      if(serviceDuesState.value==LoadingState.loading) {
        return;
      }
      serviceDuesState.value = LoadingState.loading;
      ApiResponse<List<ServiceDetail>> res = await _serviceRepo.getServiceAmountDue(1);
      if(res.status) {
        serviceDues.value = res.data ?? [];
      } else {
        showMessage(MessageType.error(res.message));
        serviceDuesState.value = LoadingState.error;
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      serviceDuesState.value = LoadingState.error;
      rethrow;
    } finally {
      serviceDuesState.value = LoadingState.done;
    }
  }
  //#endregion


  //#endregion

  //#region -Upload call logs
  uploadCallLogs() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if(!pref.containsKey('pendingUploads')) {
      debugPrint("NO PENDING UPLOADS");
      return;
    }
    String pendingUploadJSON = pref.getString('pendingUploads') ?? '';
    if(pendingUploadJSON.isEmpty || pendingUploadJSON=='[]') {
      debugPrint("EMPTY PENDING UPLOADS");
      return;
    }
    debugPrint("pendingUploadJSON $pendingUploadJSON");
    List<dynamic> pendingUploads = jsonDecode(pendingUploadJSON);
    List<dynamic> removingIndices = [];
    for(var file in pendingUploads) {
      String filePath = file['filePath'] ?? '';
      if(filePath.isEmpty) {
        removingIndices.add(file);
        continue;
      }
      Map<String, dynamic> params = {
        "call_duration": file['call_duration'],
        "call_status": file['call_status'],
        "other_number": file['other_number'],
      };
      if(file['created_at']!=null) {
        params["created_at"] = file['created_at'];
      }

      String data = jsonEncode(params);
      try {
        String path = file['filePath'];
        File audioFile = File(path);
        // print('path ${path.split('com.app.aishshreya/').last}');
        // print('filepath ${}')
        ApiResponse res = await _repo.addCallLogs(data, audioFile);
        if(res.status) {
          print("here");
          removingIndices.add(file);
          if(await audioFile.exists()) {
            audioFile.delete();
          }
        }
      } catch(e,s) {
        debugPrint('$e');
        debugPrintStack(stackTrace: s);
      }
    }
    for(var ri in removingIndices) {
      print('removing $ri');
      pendingUploads.remove(ri);
    }
    String jsonPU = jsonEncode(pendingUploads);
    print('jsonPU $jsonPU');
    pref.setString('pendingUploads', jsonPU);
  }
  //#endregion
}