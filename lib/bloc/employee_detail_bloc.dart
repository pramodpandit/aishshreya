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
import 'bloc.dart';
import 'bloc.dart';

class EmployeeDetailBloc extends Bloc {
  final EmployeeRepository _repo;
  final LeadsRepository _leadRepo;
  final ServiceRepository _serviceRepo;
  late UserDetail employee;
  EmployeeDetailBloc(this.employee, this._repo, this._leadRepo, this._serviceRepo);

  ValueNotifier<LoadingState> state = ValueNotifier(LoadingState.loading);

  initEmployeeDetails() async {
    leadPage = 1;
    leadLastPage = false;
    leads.value.clear();
    leads.notifyListeners();
    state.value = LoadingState.loading;
    try {
      await Future.wait([
        getEmployeeLeads(),
        getEmployeeServices(),
        getEmployeeClients(),
        getEmployeeDetail(),
      ]);
      state.value = LoadingState.done;
    } catch(e,s) {
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
      if (employeeState.value==LoadingState.done) {
        if(selectedPage.value==0) {
          if(clientsState.value==LoadingState.done) {
            if (!clientLastPage) {
              getEmployeeClients();
            }
          }
        } else if(selectedPage.value==1) {
          if(leadsState.value==LoadingState.done) {
            if (!leadLastPage) {
              getEmployeeLeads();
            }
          }
        } else {
          if(servicesState.value==LoadingState.done) {
            if (!serviceLastPage) {
              getEmployeeServices();
            }
          }
        }
      }
    }
  }

  //#region -Leads
  ValueNotifier<LoadingState> leadsState = ValueNotifier(LoadingState.done);
  PropertyNotifier<List<LeadDetail>> leads = PropertyNotifier([]);
  int leadPage = 1;
  bool leadLastPage = false;
  Future getEmployeeLeads() async {
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
      ApiResponse<List<LeadDetail>> res = await _leadRepo.getLeads(leadPage, eid: '${employee.id}');
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

  //#region -Clients
  ValueNotifier<LoadingState> clientsState = ValueNotifier(LoadingState.done);
  PropertyNotifier<List<ClientDetail>> clients = PropertyNotifier([]);
  int clientPage = 1;
  bool clientLastPage = false;
  Future getEmployeeClients() async {
    try{
      if(clientsState.value==LoadingState.loading || clientsState.value==LoadingState.paginating) {
        return;
      }
      if(clientLastPage) {
        return;
      }
      if(clientPage==1) {
        clientsState.value = LoadingState.loading;
      } else {
        clientsState.value = LoadingState.paginating;
      }
      ApiResponse<List<ClientDetail>> res = await _leadRepo.getClients(clientPage, eid: '${employee.id}');
      if(res.status) {
        List<ClientDetail> data = res.data ?? [];
        if(data.isEmpty) {
          clientLastPage = true;
        } else {
          clients.value.addAll(data);
          clientPage++;
          clients.notifyListeners();
        }
        clientsState.value = LoadingState.done;
      } else {
        showMessage(MessageType.error(res.message));
        clientsState.value = LoadingState.error;
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      clientsState.value = LoadingState.error;
      rethrow;
    } finally {
      clientsState.value = LoadingState.done;
    }
  }
  //#endregion

  //#region -Services
  ValueNotifier<LoadingState> servicesState = ValueNotifier(LoadingState.done);
  PropertyNotifier<List<ServiceDetail>> services = PropertyNotifier([]);
  int servicePage = 1;
  bool serviceLastPage = false;
  Future getEmployeeServices() async {
    try{
      if(servicesState.value==LoadingState.loading || servicesState.value==LoadingState.paginating) {
        return;
      }
      if(serviceLastPage) {
        return;
      }
      if(servicePage==1) {
        servicesState.value = LoadingState.loading;
      } else {
        servicesState.value = LoadingState.paginating;
      }
      ApiResponse<List<ServiceDetail>> res = await _serviceRepo.getServices(servicePage, eid: '${employee.id}');
      if(res.status) {
        List<ServiceDetail> data = res.data ?? [];
        if(data.isEmpty) {
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
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      servicesState.value = LoadingState.error;
      rethrow;
    } finally {
      servicesState.value = LoadingState.done;
    }
  }
  //#endregion

  ValueNotifier<LoadingState> employeeState = ValueNotifier(LoadingState.done);
  PropertyNotifier<UserDetail?> employeeDetail = PropertyNotifier(null);
  Future getEmployeeDetail() async {
    try{
      if(employeeState.value==LoadingState.loading || employeeState.value==LoadingState.paginating) {
        return;
      }
      employeeState.value = LoadingState.loading;
      ApiResponse<UserDetail> res = await _repo.getEmployeeDetail('${employee.id}');
      if(res.status) {
        employeeDetail.value = res.data;
      } else {
        showMessage(MessageType.error(res.message));
        employeeState.value = LoadingState.error;
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      employeeState.value = LoadingState.error;
      rethrow;
    } finally {
      employeeState.value = LoadingState.done;
    }
  }

  //#region -Edit Employee

  initOwnDetails() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    employee = UserDetail(id: num.parse(pref.getString('id') ?? '1'));
    await getEmployeeDetail();
  }

  GlobalKey<FormState> formState = GlobalKey<FormState>();
  ValueNotifier<bool> creating = ValueNotifier(false);

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController phone2 = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController insta = TextEditingController();
  TextEditingController fb = TextEditingController();
  TextEditingController linkedIn = TextEditingController();
  TextEditingController other = TextEditingController();

  ValueNotifier<CountryCode> dialCode = ValueNotifier(const CountryCode(name: 'India', code: 'IN', dialCode: '+91'));
  ValueNotifier<File?> image = ValueNotifier(null);
  ValueNotifier<String?> imageURL = ValueNotifier(null);
  ValueNotifier<DateTime?> dob = ValueNotifier(null);
  ValueNotifier<DateTime?> joiningDate = ValueNotifier(null);

  openImageFilePicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowCompression: true,
        allowedExtensions: ['jpg', 'png', 'jpeg'],
      );
      if(result!=null) {
        PlatformFile file = result.files.single;
        image.value = File(file.path!);
      }
    } catch(e,s) {
      showMessage(const MessageType.error("Image not added!"));
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
    }
  }
  updateDOB(DateTime date) {
    dob.value = date;
  }
  updateJoiningDate(DateTime date) {
    joiningDate.value = date;
  }
  updateDialCode(CountryCode code) {
    dialCode.value = code;
  }
  StreamController<String> editEmployeeStream = StreamController.broadcast();

  ValueNotifier<bool> editingOwn = ValueNotifier(false);

  initEditEmployeeDetails({bool editingOwn = false}) {
    if(editingOwn) {
      this.editingOwn.value = editingOwn;
    }
    UserDetail? employee = employeeDetail.value;
    employee ??= this.employee;
    name.text = employee.name ?? '';
    phone.text = employee.phone ?? '';
    var cp = const FlCountryCodePicker(
      favorites: ["US", 'IN'],
    );
    for(var cc in cp.countryCodes) {
      if(employee.dialCode==cc.dialCode) {
        dialCode.value = cc;
      }
    }
    phone2.text = employee.secondaryNum ?? '';
    email.text = employee.email ?? '';
    address.text = employee.address ?? '';
    fb.text = employee.fb ?? '';
    insta.text = employee.insta ?? '';
    linkedIn.text = employee.linkedIn ?? '';
    other.text = employee.other ?? '';
    dob.value = employee.dob==null ? null : DateFormat('yyyy-MM-dd').parse('${employee.dob}');
    joiningDate.value = employee.joiningDate==null ? null : DateFormat('yyyy-MM-dd').parse('${employee.joiningDate}');
    imageURL.value = employee.image ?? '';
  }

  editEmployee() async {
    try {
      if(validateEmployee()) {
        return;
      }
      if(creating.value) {
        return;
      }
      creating.value = true;
      String employeeJSON = "";
      Map<String, dynamic> employee = {
        "id": '${this.employee.id}',
        "name": name.text,
        // "dial_code": dialCode.value.dialCode,
        // "phone": phone.text,
        // "email": email.text,
        "dob": dob.value!=null ? DateFormat('yyyy-MM-dd').format(dob.value!) : null,
        "secondary_num": phone2.text,
        "address": address.text,
        "joining_date": joiningDate.value!=null ? DateFormat('yyyy-MM-dd').format(joiningDate.value!) : null,
        "insta": insta.text,
        "fb": fb.text,
        "linked_in": linkedIn.text,
        "other": other.text,
      };
      employeeJSON = jsonEncode(employee);
      ApiResponse<UserDetail> res = await _repo.editEmployeeDetails(employeeJSON, image: image.value);
      if(res.status) {
        showMessage(const MessageType.success("Employee Edited Successfully"));
        if(editingOwn.value) {
          _saveUserDetails(res.data);
        }
        editEmployeeStream.add("SUCCESS");
        name.clear();
        phone.clear();
        email.clear();
        phone2.clear();
        address.clear();
        fb.clear();
        insta.clear();
        linkedIn.clear();
        other.clear();
        dob.value = null;
        joiningDate.value = null;
        image.value = null;

      } else {
        showMessage(MessageType.error(res.message));
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      showMessage(const MessageType.error("Some error occurred! Please try again!"));
    } finally {
      creating.value = false;
    }
  }
  bool validateEmployee() {
    if(formState.currentState!.validate()) {
      // if(image.value==null) {
      //   showMessage(const MessageType.error('Profile image required!'));
      //   return true;
      // }
      if(dob.value==null) {
        showMessage(const MessageType.error('Date Of Birth required!'));
        return true;
      }
      if(joiningDate.value==null) {
        showMessage(const MessageType.error('Joining Date required!'));
        return true;
      }
      return false;
    }
    return true;
  }
  _saveUserDetails(UserDetail? userDetails) async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.setString('id', '${userDetails?.id}');
    _pref.setString('name', '${userDetails?.name}');
    _pref.setString('dialCode', '${userDetails?.dialCode}');
    _pref.setString('phone', '${userDetails?.phone}');
    _pref.setString('email', '${userDetails?.email}');
    _pref.setString('image', '${userDetails?.image}');
  }

//#endregion

}