import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aishshreya/data/model/UserDetail.dart';
import 'package:aishshreya/data/repository/employee_repository.dart';
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
import 'bloc.dart';
import 'bloc.dart';

class EmployeesBloc extends Bloc {
  final EmployeeRepository _repo;
  EmployeesBloc(this._repo);

  initEmployeeList() {

    page = 1;
    isLastPage = false;
    employees.value.clear();
    employees.notifyListeners();

    getEmployees();

  }

  ScrollController scrollController = ScrollController();
  int page = 1;
  bool isLastPage = false;

  employeesScrollListener() {
    if (scrollController.position.extentAfter < 500) {
      if (employeeState.value==LoadingState.done) {
        if (!isLastPage) {
          getEmployees();
        }
      }
    }
  }

  ValueNotifier<LoadingState> employeeState = ValueNotifier(LoadingState.done);
  PropertyNotifier<List<UserDetail>> employees = PropertyNotifier([]);

  Future getEmployees() async {
    try{
      if(employeeState.value==LoadingState.loading || employeeState.value==LoadingState.paginating) {
        return;
      }
      if(isLastPage) {
        return;
      }
      if(page==1) {
        employeeState.value = LoadingState.loading;
      } else {
        employeeState.value = LoadingState.paginating;
      }
      ApiResponse<List<UserDetail>> res = await _repo.getEmployees(page, sort: sort.value['id'], sortAsc: isAscending.value, filter: filter.value['id']);
      if(res.status) {
        List<UserDetail> data = res.data ?? [];
        if(data.isEmpty) {
          isLastPage = true;
        } else {
          employees.value.addAll(data);
          page++;
          employees.notifyListeners();
        }
        employeeState.value = LoadingState.done;
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

  //#region -Sort
  ValueNotifier<Map<String, dynamic>> sort = ValueNotifier({'name': 'Name', 'id': 'name'});
  ValueNotifier<bool> isAscending = ValueNotifier(true);
  List<Map<String, dynamic>> sortTypes = [
    {'name': 'Name', 'id': 'name'},
    {'name': 'Date Of Birth', 'id': 'dob'},
    {'name': 'Joining Date', 'id': 'joining_date'},
  ];

  updateSortType(Map<String, dynamic> sortType) {
    sort.value = sortType;
    initEmployeeList();
  }
  updateSortAsc(bool val) {
    isAscending.value = val;
    initEmployeeList();
  }
  //#endregion

  //#region -Filter
  ValueNotifier<Map<String, dynamic>> filter = ValueNotifier({'name': 'All', 'id': ''});
  List<Map<String, dynamic>> filterTypes = [
    {'name': 'All', 'id': ''},
    {'name': 'Active', 'id': 'Active'},
    {'name': 'Inactive', 'id': 'Inactive'},
  ];
  updateFilter(Map<String, dynamic> val) {
    filter.value = val;
    initEmployeeList();
  }
  //#endregion

  //#region -Search

  TextEditingController searchQuery = TextEditingController();
  int searchPage = 1;
  bool searchLastPage = false;
  PropertyNotifier<List<UserDetail>> searchEmployees = PropertyNotifier([]);
  ValueNotifier<bool> searchingEmp = ValueNotifier(false);
  Timer? throttle;
  onSearch(String val) {
    if(val.isNotEmpty) {
      searchingEmp.value = true;
    } else {
      searchingEmp.value = false;
    }
    searchEmployees.value.clear();
    searchPage = 1;
    searchLastPage = false;
    if (throttle?.isActive ?? false) throttle?.cancel();
    throttle = Timer(const Duration(milliseconds: 700), () async {
      if(val.isNotEmpty) {
        searchCallLogs();
      }
    });
  }

  Future searchCallLogs() async {
    try{
      if(employeeState.value==LoadingState.loading || employeeState.value==LoadingState.paginating) {
        return;
      }
      if(searchLastPage) {
        return;
      }
      if(searchPage==1) {
        employeeState.value = LoadingState.loading;
      } else {
        employeeState.value = LoadingState.paginating;
      }
      ApiResponse<List<UserDetail>> res = await _repo.searchEmployee(searchPage, searchQuery.text, sort: sort.value['id'], sortAsc: isAscending.value, filter: filter.value['id']);
      if(res.status) {
        List<UserDetail> data = res.data ?? [];
        if(data.isEmpty) {
          searchLastPage = true;
        } else {
          searchEmployees.value.addAll(data);
          searchPage++;
          searchEmployees.notifyListeners();
        }
        employeeState.value = LoadingState.done;
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
  //#endregion

  //#region -Create Employee
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
  List<String> empTypes = [/*'Admin',*/ 'Accountant', 'Employee'];
  String? selectedEmpType;
  setEmpType(String type) {
    selectedEmpType = type;
  }

  ValueNotifier<CountryCode> dialCode = ValueNotifier(const CountryCode(name: 'India', code: 'IN', dialCode: '+91'));
  ValueNotifier<File?> image = ValueNotifier(null);
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
  StreamController<String> createEmployeeStream = StreamController.broadcast();

  createNewEmployee() async {
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
        "name": name.text,
        "dial_code": dialCode.value.dialCode,
        "phone": phone.text,
        "email": email.text,
        "dob": dob.value!=null ? DateFormat('yyyy-MM-dd').format(dob.value!) : null,
        "secondary_num": phone2.text,
        "address": address.text,
        "joining_date": joiningDate.value!=null ? DateFormat('yyyy-MM-dd').format(joiningDate.value!) : null,
        "insta": insta.text,
        "fb": fb.text,
        "linked_in": linkedIn.text,
        "other": other.text,
        "is_admin": selectedEmpType=="Accountant" ? "2" : selectedEmpType=="Employee" ? "0" : "1",
      };
      employeeJSON = jsonEncode(employee);
      ApiResponse res = await _repo.createNewEmployee(employeeJSON, image: image.value);
      if(res.status) {
        showMessage(const MessageType.success("Employee Created Successfully"));
        createEmployeeStream.add("SUCCESS");
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
      if(selectedEmpType==null) {
        showMessage(const MessageType.error('Select employee type!'));
        return true;
      }
      return false;
    }
    return true;
  }


  //#endregion

}