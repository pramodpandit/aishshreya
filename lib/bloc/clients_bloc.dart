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
import 'bloc.dart';
import 'bloc.dart';

class ClientsBloc extends Bloc {
  final LeadsRepository _repo;
  ClientsBloc(this._repo);

  ValueNotifier<LoadingState> state = ValueNotifier(LoadingState.loading);

  initClientDetails() async {
    clientPage = 1;
    clientLastPage = false;
    clients.value.clear();
    clients.notifyListeners();
    getClients();
  }

  ValueNotifier<int> selectedPage = ValueNotifier(0);
  updatePage(int page) {
    selectedPage.value = page;
  }
  ScrollController scrollController = ScrollController();
  scrollListener() {
    if (scrollController.position.extentAfter < 500) {
      if (clientsState.value==LoadingState.done) {
        if (!clientLastPage) {
          getClients();
        }
      }
    }
  }

  //#region -Clients
  ValueNotifier<LoadingState> clientsState = ValueNotifier(LoadingState.done);
  PropertyNotifier<List<ClientDetail>> clients = PropertyNotifier([]);
  int clientPage = 1;
  bool clientLastPage = false;
  Future getClients() async {
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
      ApiResponse<List<ClientDetail>> res = await _repo.getClients(clientPage, sort: sort.value['id'], sortAsc: isAscending.value, filter: filter.value['id']);
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

  //#region -Sort
  ValueNotifier<Map<String, dynamic>> sort = ValueNotifier({'name': 'Name', 'id': 'name'});
  ValueNotifier<bool> isAscending = ValueNotifier(true);
  List<Map<String, dynamic>> sortTypes = [
    {'name': 'Name', 'id': 'name'},
    {'name': 'Date Of Creation', 'id': 'created_at'},
    // {'name': 'Joining Date', 'id': 'joining_date'},
  ];

  updateSortType(Map<String, dynamic> sortType) {
    sort.value = sortType;
    if(searchingCli.value) {
      initClientSearch();
    } else {
      initClientDetails();
    }
  }
  updateSortAsc(bool val) {
    isAscending.value = val;
    if(searchingCli.value) {
      initClientSearch();
    } else {
      initClientDetails();
    }
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
    if(searchingCli.value) {
      initClientSearch();
    } else {
      initClientDetails();
    }
  }
//#endregion

  //#region -Search

  TextEditingController searchQuery = TextEditingController();
  int searchPage = 1;
  bool searchLastPage = false;
  PropertyNotifier<List<ClientDetail>> searchClients = PropertyNotifier([]);
  ValueNotifier<bool> searchingCli = ValueNotifier(false);
  Timer? throttle;
  onSearch(String val) {
    if(val.isNotEmpty) {
      searchingCli.value = true;
    } else {
      searchingCli.value = false;
    }
    searchClients.value.clear();
    searchPage = 1;
    searchLastPage = false;
    if (throttle?.isActive ?? false) throttle?.cancel();
    throttle = Timer(const Duration(milliseconds: 700), () async {
      if(val.isNotEmpty) {
        searchClient();
      }
    });
  }

  initClientSearch() {
    searchPage = 1;
    searchLastPage = false;
    searchClients.value.clear();
    searchClients.notifyListeners();
    searchClient();
  }

  Future searchClient() async {
    try{
      if(clientsState.value==LoadingState.loading || clientsState.value==LoadingState.paginating) {
        return;
      }
      if(searchLastPage) {
        return;
      }
      if(searchPage==1) {
        clientsState.value = LoadingState.loading;
      } else {
        clientsState.value = LoadingState.paginating;
      }
      ApiResponse<List<ClientDetail>> res = await _repo.getClients(searchPage, sort: sort.value['id'], sortAsc: isAscending.value, filter: filter.value['id'], searchQuery: searchQuery.text);
      if(res.status) {
        List<ClientDetail> data = res.data ?? [];
        if(data.isEmpty) {
          searchLastPage = true;
        } else {
          searchClients.value.addAll(data);
          searchPage++;
          searchClients.notifyListeners();
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

  //#region -Create New Client

  GlobalKey<FormState> formState = GlobalKey<FormState>();
  ValueNotifier<bool> creating = ValueNotifier(false);

  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController phone2 = TextEditingController();
  TextEditingController requirement = TextEditingController();

  ValueNotifier<File?> image = ValueNotifier(null);

  String? selectedEmpId, clientId, imageURL;


  StreamController<String> createClientController = StreamController.broadcast();

  createNewClient() async {
    try {
      if(validateClient()) {
        return;
      }
      if(creating.value) {
        return;
      }
      creating.value = true;
      String clientJSON = "";
      Map<String, dynamic> client = {
        "name": name.text,
        "phone": phone.text,
        "phone2": phone2.text,
        "email": email.text,
      };
      clientJSON = jsonEncode(client);
      ApiResponse res = await _repo.createNewClient(clientJSON, image: image.value);
      if(res.status) {
        showMessage(const MessageType.success("Client Created Successfully"));
        createClientController.add("SUCCESS");
        name.clear();
        phone.clear();
        phone2.clear();
        email.clear();
        requirement.clear();

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
  bool validateClient() {
    if(formState.currentState!.validate()) {
      // if(image.value==null) {
      //   showMessage(const MessageType.error('Profile image required!'));
      //   return true;
      // }
      return false;
    }
    return true;
  }


//#endregion

}