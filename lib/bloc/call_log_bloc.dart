import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aishshreya/bloc/service_bloc.dart';
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
import 'bloc.dart';
import 'bloc.dart';

class CallLogBloc extends Bloc {
  final EmployeeRepository _repo;
  CallLogBloc(this._repo);

  ValueNotifier<LoadingState> state = ValueNotifier(LoadingState.loading);

  initCallLogs() async {
    page = 1;
    lastPage = false;
    callLogs.value.clear();
    callLogs.notifyListeners();
    getCallLogs();
  }

  ValueNotifier<int> selectedPage = ValueNotifier(0);
  updatePage(int page) {
    selectedPage.value = page;
  }
  ScrollController scrollController = ScrollController();
  scrollListener() {
    if (scrollController.position.extentAfter < 500) {
      if (logsState.value==LoadingState.done) {
        if(searchingLogs.value) {
          if (!searchLastPage) {
            searchCallLogs();
          }
        } else {
          if (!lastPage) {
            getCallLogs();
          }
        }

      }
    }
  }

  //#region -Logs
  ValueNotifier<LoadingState> logsState = ValueNotifier(LoadingState.done);
  PropertyNotifier<List<CallLogDetail>> callLogs = PropertyNotifier([]);
  int page = 1;
  bool lastPage = false;
  Future getCallLogs() async {
    try{
      if(logsState.value==LoadingState.loading || logsState.value==LoadingState.paginating) {
        return;
      }
      if(lastPage) {
        return;
      }
      if(page==1) {
        logsState.value = LoadingState.loading;
      } else {
        logsState.value = LoadingState.paginating;
      }
      ApiResponse<List<CallLogDetail>> res = await _repo.getCallLogs(page, filterType: baseFilterValue.id, date: date.value, range: dateRange.value, query: searchQuery.text);
      if(res.status) {
        List<CallLogDetail> data = res.data ?? [];
        if(data.isEmpty) {
          lastPage = true;
        } else {
          callLogs.value.addAll(data);
          page++;
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

  //#region -Filters Sorts

  AppFilter baseFilterValue = AppFilter('none', '');
  List<AppFilter> filter = [
    AppFilter('date', 'Date'),
    AppFilter('range', 'Date Range'),
  ];

  ValueNotifier<AppFilter?> selectedFilter = ValueNotifier(null);
  ValueNotifier<DateTime?> date = ValueNotifier(null);
  ValueNotifier<DateTimeRange?> dateRange = ValueNotifier(null);
  initFilterSort() {
    selectedFilter.value = baseFilterValue;
  }
  resetFilter() {
    baseFilterValue = AppFilter('none', '');
    date.value = null;
    dateRange.value = null;

    if(searchingLogs.value) {
      searchPage = 1;
      searchLastPage = false;
      searchLogs.value.clear();
      searchLogs.notifyListeners();
      searchCallLogs();
    } else {
      page = 1;
      lastPage = false;
      callLogs.value.clear();
      callLogs.notifyListeners();
      searchQuery.clear();
      getCallLogs();
    }

  }
  updateFilter(AppFilter filter) {
    selectedFilter.value = filter;
  }
  updateDate(DateTime date) {
    this.date.value = date;
  }
  updateDateRange(DateTimeRange dateRange) {
    this.dateRange.value = dateRange;
  }
  ValueNotifier<bool> showFilter = ValueNotifier(true);
  updateShowFilter(bool show) {
    showFilter.value = show;
  }
  bool applyFilter() {
    if(selectedFilter.value?.id=='range') {
      if(dateRange.value==null) {
        showMessage(const MessageType.error("Please select date range"));
        return false;
      }
    }
    if(selectedFilter.value?.id=='date') {
      if(date.value==null) {
        showMessage(const MessageType.error("Please select date!"));
        return false;
      }
    }
    baseFilterValue = selectedFilter.value!;

    if(searchingLogs.value) {
      searchPage = 1;
      searchLastPage = false;
      searchLogs.value.clear();
      searchLogs.notifyListeners();
      searchCallLogs();
    } else {
      page = 1;
      lastPage = false;
      callLogs.value.clear();
      callLogs.notifyListeners();
      searchQuery.clear();
      getCallLogs();
    }
    return true;
  }

  //#endregion

  //#region -Search

  TextEditingController searchQuery = TextEditingController();
  int searchPage = 1;
  bool searchLastPage = false;
  PropertyNotifier<List<CallLogDetail>> searchLogs = PropertyNotifier([]);
  ValueNotifier<bool> searchingLogs = ValueNotifier(false);
  Timer? throttle;
  onSearch(String val) {
    if(val.isNotEmpty) {
      searchingLogs.value = true;
    } else {
      searchingLogs.value = false;
    }
    searchLogs.value.clear();
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
      if(logsState.value==LoadingState.loading || logsState.value==LoadingState.paginating) {
        return;
      }
      if(searchLastPage) {
        return;
      }
      if(searchPage==1) {
        logsState.value = LoadingState.loading;
      } else {
        logsState.value = LoadingState.paginating;
      }
      ApiResponse<List<CallLogDetail>> res = await _repo.getCallLogs(searchPage, filterType: baseFilterValue.id, date: date.value, range: dateRange.value, query: searchQuery.text);
      if(res.status) {
        List<CallLogDetail> data = res.data ?? [];
        if(data.isEmpty) {
          searchLastPage = true;
        } else {
          searchLogs.value.addAll(data);
          searchPage++;
          searchLogs.notifyListeners();
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

}