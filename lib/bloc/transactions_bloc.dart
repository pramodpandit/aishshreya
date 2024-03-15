import 'package:aishshreya/bloc/property_notifier.dart';
import 'package:aishshreya/bloc/service_bloc.dart';
import 'package:aishshreya/data/model/TransactionDetail.dart';
import 'package:aishshreya/data/model/api_response.dart';
import 'package:aishshreya/data/repository/service_repository.dart';
import 'package:aishshreya/utils/enums.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bloc.dart';

class TransactionsBloc extends Bloc {

  final ServiceRepository _repo;
  TransactionsBloc(this._repo);
  
  initTransactions() async {
    page = 1;
    lastPage = false;
    transactions.value.clear();
    transactions.notifyListeners();
    getTransactions();
  }

  ValueNotifier<int> selectedPage = ValueNotifier(0);
  updatePage(int page) {
    selectedPage.value = page;
  }
  ScrollController scrollController = ScrollController();
  scrollListener() {
    if (scrollController.position.extentAfter < 500) {
      if (transactionsState.value==LoadingState.done) {
        if (!lastPage) {
          getTransactions();
        }
      }
    }
  }

  //#region -Transactions
  ValueNotifier<LoadingState> transactionsState = ValueNotifier(LoadingState.done);
  PropertyNotifier<List<TransactionDetail>> transactions = PropertyNotifier([]);
  int page = 1;
  bool lastPage = false;
  Future getTransactions() async {
    try{
      if(transactionsState.value==LoadingState.loading || transactionsState.value==LoadingState.paginating) {
        return;
      }
      if(lastPage) {
        return;
      }
      if(page==1) {
        transactionsState.value = LoadingState.loading;
      } else {
        transactionsState.value = LoadingState.paginating;
      }
      ApiResponse<List<TransactionDetail>> res = await _repo.getTransactions(page, filterType: baseFilterValue.id, date: date.value, range: dateRange.value,);
      if(res.status) {
        List<TransactionDetail> data = res.data ?? [];
        if(data.isEmpty) {
          lastPage = true;
        } else {
          transactions.value.addAll(data);
          page++;
          transactions.notifyListeners();
        }
        transactionsState.value = LoadingState.done;
      } else {
        showMessage(MessageType.error(res.message));
        transactionsState.value = LoadingState.error;
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      transactionsState.value = LoadingState.error;
      rethrow;
    } finally {
      transactionsState.value = LoadingState.done;
    }
  }


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

    page = 1;
    lastPage = false;
    transactions.value.clear();
    transactions.notifyListeners();
    getTransactions();

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

    page = 1;
    lastPage = false;
    transactions.value.clear();
    transactions.notifyListeners();
    getTransactions();
    return true;
  }

  //#endregion

  //#endregion

  //#region -Update Status
  ValueNotifier<TransactionDetail?> transactionDetail = ValueNotifier(null);

  updateTransactionStatus(TransactionDetail trDetail, bool status) async {
    try {
      if(transactionDetail.value!=null) {
        return;
      }
      transactionDetail.value = trDetail;

      ApiResponse res = await _repo.updateTransactionStatus('${trDetail.id}', status);
      if(res.status) {
        showMessage(const MessageType.success("Status updated"));
        initTransactions();
      } else {
        showMessage(const MessageType.error("Error Occurred!"));
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      showMessage(const MessageType.error("Error Occurred!"));
    } finally {
      transactionDetail.value = null;
    }
  }
  //#endregion
}