import 'dart:math';

import 'package:aishshreya/data/model/LeadHistory.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'bloc.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aishshreya/data/model/ClientDetail.dart';
import 'package:aishshreya/data/model/LeadDetail.dart';
import 'package:aishshreya/data/model/UserDetail.dart';
import 'package:aishshreya/data/repository/employee_repository.dart';
import 'package:aishshreya/data/repository/lead_repository.dart';
import 'package:aishshreya/data/repository/service_repository.dart';
import 'package:aishshreya/bloc/property_notifier.dart';
import 'package:aishshreya/data/model/ServiceDetail.dart';
import 'package:aishshreya/data/model/api_response.dart';
import 'package:aishshreya/utils/enums.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeadDetailBloc extends Bloc {
  final EmployeeRepository _repo;
  final LeadsRepository _leadRepo;
  final ServiceRepository _serviceRepo;
  final LeadDetail lead;
  LeadDetailBloc(this.lead, this._repo, this._leadRepo, this._serviceRepo);

  ValueNotifier<LoadingState> state = ValueNotifier(LoadingState.loading);

  initClientDetails() async {
    state.value = LoadingState.loading;
    leadDetail.value = lead;
    try {
      await Future.wait([
        // getClientServices(),
        // getEmployees(),
        getLeadDetails(),
        getLeadPastServices(),
        getPastServiceLeadHistory(),
      ]);
      state.value = LoadingState.done;
    } catch (e, s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      state.value = LoadingState.error;
    }
  }

  ValueNotifier<LoadingState> employeeState = ValueNotifier(LoadingState.done);
  PropertyNotifier<LeadDetail?> leadDetail = PropertyNotifier(null);
  Future getLeadDetails() async {
    try {
      if (employeeState.value == LoadingState.loading) {
        return;
      }
      employeeState.value = LoadingState.loading;
      ApiResponse<LeadDetail> res = await _leadRepo.getLeadDetails('${lead.id}');
      if (res.status) {
        leadDetail.value = res.data;
      } else {
        showMessage(MessageType.error(res.message));
        employeeState.value = LoadingState.error;
      }
    } catch (e, s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      employeeState.value = LoadingState.error;
      rethrow;
    } finally {
      employeeState.value = LoadingState.done;
    }
  }

  ValueNotifier<LoadingState> serviceState = ValueNotifier(LoadingState.done);
  PropertyNotifier<List<ServiceDetail>> services = PropertyNotifier([]);
  Future getLeadPastServices() async {
    try {
      if (serviceState.value == LoadingState.loading) {
        return;
      }
      serviceState.value = LoadingState.loading;
      ApiResponse<List<ServiceDetail>> res = await _leadRepo.getPasLeadServices('${lead.id}');
      if (res.status) {
        services.value = res.data ?? [];
        services.notifyListeners();
      } else {
        // showMessage(MessageType.error(res.message));
        // serviceState.value = LoadingState.error;
      }
    } catch (e, s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      serviceState.value = LoadingState.error;
      rethrow;
    } finally {
      serviceState.value = LoadingState.done;
    }
  }
  ValueNotifier<int> selectedPage = ValueNotifier(0);
  updatePage(int page) {
    selectedPage.value = page;
  }
  ScrollController scrollController = ScrollController();
  scrollListener() {
    if (scrollController.position.extentAfter < 500) {
      if(selectedPage.value==2) {
        if(leadHistoryState.value==LoadingState.done) {
          if (!isLastLHPage) {
            getPastServiceLeadHistory();
          }
        }
      }
    }
  }

  ValueNotifier<LoadingState> leadHistoryState = ValueNotifier(LoadingState.done);
  int lhPage = 1;
  bool isLastLHPage = false;
  PropertyNotifier<List<LeadHistory>> leadServiceHistory = PropertyNotifier([]);
  Future getPastServiceLeadHistory() async {
    try {
      if(leadHistoryState.value==LoadingState.loading || leadHistoryState.value==LoadingState.paginating) {
        return;
      }
      if(isLastLHPage) {
        return;
      }
      if(lhPage==1) {
        leadHistoryState.value = LoadingState.loading;
      } else {
        leadHistoryState.value = LoadingState.paginating;
      }
      ApiResponse<List<LeadHistory>> res = await _leadRepo.getPastServiceLeadHistory(lhPage, '${lead.id}');
      if (res.status) {
        List<LeadHistory> data = res.data ?? [];
        if(data.isEmpty) {
          isLastLHPage = true;
        } else {
          leadServiceHistory.value.addAll(data);
          lhPage++;
          leadServiceHistory.notifyListeners();
        }
        leadHistoryState.value = LoadingState.done;
      } else {
        // showMessage(MessageType.error(res.message));
        // leadHistoryState.value = LoadingState.error;
      }
    } catch (e, s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      leadHistoryState.value = LoadingState.error;
      rethrow;
    }
  }

  //#region -Edit Lead
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  ValueNotifier<bool> creating = ValueNotifier(false);

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController phone2 = TextEditingController();
  TextEditingController requirement = TextEditingController();

  ValueNotifier<File?> image = ValueNotifier(null);
  ValueNotifier<String?> imageURL = ValueNotifier(null);

  StreamController<String> editLeadStream = StreamController.broadcast();

  initEditLeadDetails() {
    LeadDetail? lead = leadDetail.value;
    lead ??= this.lead;
    name.text = lead.name ?? '';
    phone.text = lead.phone ?? '';
    phone2.text = lead.phone2 ?? '';
    email.text = lead.email ?? '';
    requirement.text = lead.requirement ?? '';
    imageURL.value = lead.image ?? '';
  }

  editLead() async {
    try {
      if (validateEmployee()) {
        return;
      }
      if (creating.value) {
        return;
      }
      creating.value = true;
      String leadJSON = "";
      Map<String, dynamic> lead = {
        "id": '${this.lead.id}',
        "name": name.text,
        "phone": phone.text,
        "phone2": phone2.text,
        "email": email.text,
        "requirement": requirement.text,
      };
      leadJSON = jsonEncode(lead);
      ApiResponse res =
      await _leadRepo.editLeadDetails(leadJSON, image: image.value);
      if (res.status) {
        showMessage(const MessageType.success("Lead Edited Successfully"));
        editLeadStream.add("SUCCESS");
      } else {
        showMessage(MessageType.error(res.message));
      }
    } catch (e, s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      showMessage(
          const MessageType.error("Some error occurred! Please try again!"));
    } finally {
      creating.value = false;
    }
  }

  bool validateEmployee() {
    if (formState.currentState!.validate()) {
      // if(image.value==null) {
      //   showMessage(const MessageType.error('Profile image required!'));
      //   return true;
      // }

      return false;
    }
    return true;
  }

//#endregion

  //#region -Update Lead Status
  // PropertyNotifier<List<UserDetail>> employees = PropertyNotifier([]);
  // Future getEmployees() async {
  //   try{
  //     ApiResponse<List<UserDetail>> res = await _repo.getEmployees(1, showAll: true);
  //     if(res.status) {
  //       employees.value = res.data ?? [];
  //     }
  //   } catch(e,s) {
  //     debugPrint('$e');
  //     debugPrintStack(stackTrace: s);
  //   }
  // }
  // ValueNotifier<UserDetail?> employee = ValueNotifier(null);
  //
  // String? selectedEmpId;
  //
  // updateEmployee(String empId) {
  //   selectedEmpId = empId;
  //   for(UserDetail e in employees.value) {
  //     if('${e.id}'==empId) {
  //       employee.value = e;
  //     }
  //   }
  // }
  ValueNotifier<bool> creatingLead = ValueNotifier(false);
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  ValueNotifier<String?> leadStatus = ValueNotifier(null);
  // 'Confirmed',
  List<String> leadStatuses = ['Active', 'FollowUp', 'Dead'];
  updateLS(String status) {
    leadStatus.value = status;
  }

  Future updateLeadStatus() async {
    try {
      if (creatingLead.value) {
        return;
      }
      if(lead.id==null) {
        showMessage(const MessageType.error('Lead Not Found!'));
        return;
      }
      print('here');
      if(validateLead()) {
        return;
      }
      creatingLead.value = true;
      ApiResponse res = await _leadRepo.updateLeadStatus('${lead.id}', title.text, description.text, leadStatus.value!, schedule: leadStatus.value! == 'FollowUp' ? schedule.value : null);
      if (res.status) {
        if(leadStatus.value! == 'FollowUp') {
          await AwesomeNotifications().createNotification(
              content: NotificationContent(
                // id: (lead.id ?? Random().nextInt(9999)).toInt(),
                id: Random().nextInt(9999),
                channelKey: 'scheduled',
                title: 'Follow up with ${lead.name} is scheduled for now.',
                body: 'About ${lead.requirement} (${title.text})',
                wakeUpScreen: true,
                category: NotificationCategory.Reminder,
                notificationLayout: NotificationLayout.BigText,
                autoDismissible: false,
                payload: {
                  "id": '${lead.id}',
                  "page": "lead",
                },
              ),
              schedule: NotificationCalendar.fromDate(date: schedule.value!, allowWhileIdle: true, preciseAlarm: true));
        }
        title.clear();
        description.clear();
        description.clear();
        schedule.value = null;
        showMessage(const MessageType.success('Lead Status updated successfully!'));
        createController.add("SUCCESS");
      } else {
        showMessage(MessageType.error(res.message));
      }
    } catch (e, s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      showMessage(const MessageType.error("Some error occurred!"));
    } finally {
      creatingLead.value = false;
    }
  }
  validateLead() {
    if(formState.currentState!.validate()) {
      if(leadStatus.value==null) {
        showMessage(const MessageType.error("Please select status!"));
        return true;
      }
      if(leadStatus.value=='FollowUp') {
        if(schedule.value==null) {
          showMessage(const MessageType.error("Please select the schedule date"));
          return true;
        }
      }
      return false;
    }
    return true;
  }
  //#endregion

  //#region -Create Service With Lead
  ValueNotifier<bool> creatingService = ValueNotifier(false);

  TextEditingController serviceName = TextEditingController();
  TextEditingController amount = TextEditingController();
  ValueNotifier<DateTime?> schedule = ValueNotifier(null);
  updateSchedule(DateTime date) {
    schedule.value = date;
  }
  StreamController<String> createController = StreamController.broadcast();
  Future createServiceWithLead() async {
    try {
      if (creatingService.value) {
        return;
      }
      if(lead.id==null) {
        return;
      }
      if(validateService()) {
        return;
      }
      creatingService.value = true;
      ApiResponse res = await _leadRepo.createServiceWithLead('${lead.id}', serviceName.text, amount.text, schedule.value!);
      if (res.status) {
        showMessage(const MessageType.success('Service created successfully!'));
        createController.add("SUCCESS");
      } else {
        showMessage(MessageType.error(res.message));
      }
    } catch (e, s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      showMessage(const MessageType.error("Some error occurred!"));
    } finally {
      creatingService.value = false;
    }
  }
  validateService() {
    if(formState.currentState!.validate()) {
      if(schedule.value==null) {
        showMessage(const MessageType.error("Please select the schedule date"));
        return true;
      }

      return false;
    }
    return true;
  }
//#endregion



}