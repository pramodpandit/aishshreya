import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aishshreya/data/model/CallLogDetail.dart';
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
import 'bloc.dart';
import 'bloc.dart';

class ClientDetailBloc extends Bloc {
  final EmployeeRepository _repo;
  final LeadsRepository _leadRepo;
  final ServiceRepository _serviceRepo;
  final ClientDetail client;
  ClientDetailBloc(this.client, this._repo, this._leadRepo, this._serviceRepo);

  ValueNotifier<LoadingState> state = ValueNotifier(LoadingState.loading);

  initClientDetails() async {
    servicePage = 1;
    serviceLastPage = false;
    services.value.clear();
    services.notifyListeners();

    logPage = 1;
    logLastPage = false;
    callLogs.value.clear();
    callLogs.notifyListeners();

    leadPage = 1;
    leadLastPage = false;
    leads.value.clear();
    leads.notifyListeners();

    state.value = LoadingState.loading;
    clientDetails.value = client;
    try {
      await Future.wait([
        getClientServices(),
        getClientCallLog(),
        getClientLeads(),
        getEmployees(),
        getClientDetails(),
      ]);
      state.value = LoadingState.done;
    } catch (e, s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      state.value = LoadingState.error;
    }
  }

  ValueNotifier<int> selectedPage = ValueNotifier(0);
  updatePage(int page) {
    selectedPage.value = page;
  }

  ScrollController scrollController = ScrollController();
  scrollListener() {
    if (scrollController.position.extentAfter < 500) {
      switch(selectedPage.value) {
        case 0:
          if (servicesState.value == LoadingState.done) {
            if (!serviceLastPage) {
              getClientServices();
            }
          }
          break;
        case 1:
          if (leadsState.value == LoadingState.done) {
            if (!leadLastPage) {
              getClientLeads();
            }
          }
          break;
        case 2:
          if (logsState.value == LoadingState.done) {
            if (!logLastPage) {
              getClientCallLog();
            }
          }
          break;
      }

    }
  }

  //#region -Services
  ValueNotifier<LoadingState> servicesState = ValueNotifier(LoadingState.done);
  PropertyNotifier<List<ServiceDetail>> services = PropertyNotifier([]);
  int servicePage = 1;
  bool serviceLastPage = false;
  Future getClientServices() async {
    try {
      if (servicesState.value == LoadingState.loading ||
          servicesState.value == LoadingState.paginating) {
        return;
      }
      if (serviceLastPage) {
        return;
      }
      if (servicePage == 1) {
        servicesState.value = LoadingState.loading;
      } else {
        servicesState.value = LoadingState.paginating;
      }
      ApiResponse<List<ServiceDetail>> res =
          await _leadRepo.getClientServices('${client.id}');
      if (res.status) {
        List<ServiceDetail> data = res.data ?? [];
        if (data.isEmpty) {
          serviceLastPage = true;
        } else {
          services.value.addAll(data);
          servicePage++;
          services.notifyListeners();
        }
        servicesState.value = LoadingState.done;
      } else {
        showMessage(MessageType.error(res.message));
        servicesState.value = LoadingState.error;
      }
    } catch (e, s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      servicesState.value = LoadingState.error;
      rethrow;
    } finally {
      servicesState.value = LoadingState.done;
    }
  }
  //#endregion


  //#region -Leads
  ValueNotifier<LoadingState> leadsState = ValueNotifier(LoadingState.done);
  PropertyNotifier<List<LeadDetail>> leads = PropertyNotifier([]);
  int leadPage = 1;
  bool leadLastPage = false;
  Future getClientLeads() async {
    try{
      if(leadsState.value==LoadingState.loading || leadsState.value==LoadingState.paginating) {
        return;
      }
      if(leadLastPage) {
        return;
      }
      if(leadPage==1) {
        leadsState.value = LoadingState.loading;
      } else {
        leadsState.value = LoadingState.paginating;
      }
      ApiResponse<List<LeadDetail>> res = await _leadRepo.getClientLeads(leadPage, '${client.id}');
      if(res.status) {
        List<LeadDetail> data = res.data ?? [];
        if(data.isEmpty) {
          leadLastPage = true;
        } else {
          leads.value.addAll(data);
          leadPage++;
          leads.notifyListeners();
        }
        leadsState.value = LoadingState.done;
      } else {
        showMessage(MessageType.error(res.message));
        leadsState.value = LoadingState.error;
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      leadsState.value = LoadingState.error;
      rethrow;
    } finally {
      leadsState.value = LoadingState.done;
    }
  }
  //#endregion

  //#region -Call Logs
  ValueNotifier<LoadingState> logsState = ValueNotifier(LoadingState.done);
  PropertyNotifier<List<CallLogDetail>> callLogs = PropertyNotifier([]);
  int logPage = 1;
  bool logLastPage = false;
  Future getClientCallLog() async {
    try{
      if(logsState.value==LoadingState.loading || logsState.value==LoadingState.paginating) {
        return;
      }
      if(logLastPage) {
        return;
      }
      if(logPage==1) {
        logsState.value = LoadingState.loading;
      } else {
        logsState.value = LoadingState.paginating;
      }
      ApiResponse<List<CallLogDetail>> res = await _repo.getClientCallLogs(logPage, '${client.id}');
      if(res.status) {
        List<CallLogDetail> data = res.data ?? [];
        if(data.isEmpty) {
          leadLastPage = true;
        } else {
          callLogs.value.addAll(data);
          logPage++;
          callLogs.notifyListeners();
        }
        logsState.value = LoadingState.done;
      } else {
        showMessage(MessageType.error(res.message));
        logsState.value = LoadingState.error;
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      logsState.value = LoadingState.error;
      rethrow;
    } finally {
      logsState.value = LoadingState.done;
    }
  }
  //#endregion


  ValueNotifier<LoadingState> employeeState = ValueNotifier(LoadingState.done);
  PropertyNotifier<ClientDetail?> clientDetails = PropertyNotifier(null);
  Future getClientDetails() async {
    try {
      if (employeeState.value == LoadingState.loading) {
        return;
      }
      employeeState.value = LoadingState.loading;
      ApiResponse<ClientDetail> res =
          await _leadRepo.getClientDetail('${client.id}');
      if (res.status) {
        clientDetails.value = res.data;
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

  //#region -Edit Client
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  ValueNotifier<bool> creating = ValueNotifier(false);

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController phone2 = TextEditingController();

  ValueNotifier<File?> image = ValueNotifier(null);
  ValueNotifier<String?> imageURL = ValueNotifier(null);

  StreamController<String> editEmployeeStream = StreamController.broadcast();

  initEditClientDetails() {
    ClientDetail? client = clientDetails.value;
    client ??= this.client;
    name.text = client.name ?? '';
    phone.text = client.phone ?? '';
    phone2.text = client.phone2 ?? '';
    email.text = client.email ?? '';
    imageURL.value = client.image ?? '';
  }

  editClient() async {
    try {
      if (validateEmployee()) {
        return;
      }
      if (creating.value) {
        return;
      }
      creating.value = true;
      String clientJSON = "";
      Map<String, dynamic> client = {
        "id": '${this.client.id}',
        "name": name.text,
        // "dial_code": dialCode.value.dialCode,
        // "phone": phone.text,
        "phone2": phone2.text,
        "email": email.text,
      };
      clientJSON = jsonEncode(client);
      ApiResponse res =
          await _leadRepo.editClientDetails(clientJSON, image: image.value);
      if (res.status) {
        showMessage(const MessageType.success("Client Edited Successfully"));
        editEmployeeStream.add("SUCCESS");
        name.clear();
        phone.clear();
        email.clear();
        image.value = null;
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

  //#region -Create Lead With Client
  PropertyNotifier<List<UserDetail>> employees = PropertyNotifier([]);
  Future getEmployees() async {
    try{
      ApiResponse<List<UserDetail>> res = await _repo.getEmployees(1, showAll: true, doNotShowAccountant: true);
      if(res.status) {
        employees.value = res.data ?? [];
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
    }
  }
  ValueNotifier<UserDetail?> employee = ValueNotifier(null);

  String? selectedEmpId;

  updateEmployee(String empId) {
    selectedEmpId = empId;
    for(UserDetail e in employees.value) {
      if('${e.id}'==empId) {
        employee.value = e;
      }
    }
  }
  ValueNotifier<bool> creatingLead = ValueNotifier(false);

  TextEditingController requirement = TextEditingController();
  Future createLeadWithClient() async {
    try {
      if (creatingLead.value) {
        return;
      }
      if(client.id==null) {
        return;
      }
      if(await validateLead()) {
        return;
      }
      creatingLead.value = true;
      ApiResponse res = await _leadRepo.createLeadWithClient('${client.id}', requirement.text, empId: selectedEmpId);
      if (res.status) {
        showMessage(const MessageType.success('Lead created successfully!'));
        createController.add("CREATED");
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
  validateLead() async {
    if(formState.currentState!.validate()) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      if(pref.getBool('isAdmin')==true) {
        if(selectedEmpId==null) {
          showMessage(const MessageType.error("Please select employee!"));
          return true;
        }
      }
      return false;
    }
    return true;
  }
  //#endregion

  //#region -Create Service With Client
  ValueNotifier<bool> creatingService = ValueNotifier(false);

  TextEditingController serviceName = TextEditingController();
  TextEditingController amount = TextEditingController();
  ValueNotifier<DateTime?> schedule = ValueNotifier(null);
  updateSchedule(DateTime date) {
    schedule.value = date;
  }
  StreamController<String> createController = StreamController.broadcast();
  Future createServiceWithClient() async {
    try {
      if (creatingService.value) {
        return;
      }
      if(client.id==null) {
        return;
      }
      if(validateService()) {
        return;
      }
      creatingService.value = true;
      ApiResponse res = await _leadRepo.createServiceWithClient('${client.id}', serviceName.text, amount.text, schedule.value!);
      if (res.status) {
        showMessage(const MessageType.success('Service created successfully!'));
        createController.add("CREATED");
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
