import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:aishshreya/data/model/TransactionDetail.dart';
import 'package:aishshreya/data/repository/service_repository.dart';
import 'package:aishshreya/bloc/property_notifier.dart';
import 'package:aishshreya/data/model/ServiceDetail.dart';
import 'package:aishshreya/data/model/api_response.dart';
import 'package:aishshreya/ui/widget/pdf_invoice_generator.dart';
import 'package:aishshreya/utils/enums.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:pdf/src/widgets/document.dart';
import 'package:printing/printing.dart';
import 'bloc.dart';

class ServiceBloc extends Bloc {
  final ServiceRepository _repo;
  ServiceBloc(this._repo);

  //#region -Services

  ValueNotifier<bool> showDues = ValueNotifier(false);
  ValueNotifier<bool> showUpcoming = ValueNotifier(false);

  initService(bool showUpcoming, bool showDueService) {
    this.showUpcoming.value = showUpcoming;
    if(showUpcoming) {
      baseFilterValue = AppFilter('upcoming', 'Upcoming');
    }
    showDues.value = showDueService;
    page = 1;
    isLastPage = false;
    services.value.clear();
    services.notifyListeners();

    if(showDueService) {
      getServiceDues();
    } else {
      getServices();
    }
  }

  ScrollController scrollController = ScrollController();
  int page = 1;
  bool isLastPage = false;

  servicesScrollListener() {
    if (scrollController.position.extentAfter < 500) {
      if (serviceState.value==LoadingState.done) {
        if (!isLastPage) {
          if(showDues.value) {
            getServiceDues();
          } else {
            getServices();
          }
        }
      }
    }
  }

  ValueNotifier<LoadingState> serviceState = ValueNotifier(LoadingState.done);
  PropertyNotifier<List<ServiceDetail>> services = PropertyNotifier([]);
  Future getServices() async {
    try{
      if(serviceState.value==LoadingState.loading || serviceState.value==LoadingState.paginating) {
        return;
      }
      if(isLastPage) {
        return;
      }
      if(page==1) {
        serviceState.value = LoadingState.loading;
      } else {
        serviceState.value = LoadingState.paginating;
      }
      ApiResponse<List<ServiceDetail>> res = await _repo.getServices(page, filterType: baseFilterValue.id, sortType: baseSortValue.id, status: baseStatusValue.id, range: dateRange.value, date: date.value);
      if(res.status) {
        List<ServiceDetail> data = res.data ?? [];
        if(data.isEmpty) {
          isLastPage = true;
        } else {
          services.value.addAll(data);
          page++;
          services.notifyListeners();
        }
        serviceState.value = LoadingState.done;
      } else {
        showMessage(MessageType.error(res.message));
        serviceState.value = LoadingState.error;
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      serviceState.value = LoadingState.error;
      rethrow;
    } finally {
      serviceState.value = LoadingState.done;
    }
  }

  //#region Filters Sorts

  //   'page': page,
  //   'status': status,
  //   'filter_type': filterType,
  //   'sort_type': sortType,
  // data['date'] = DateFormat('yyyy-MM-dd').format(date);
  // data['start_date'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(range.start);
  // data['end_date'] = DateFormat('yyyy-MM-dd HH:mm:ss').format(range.end);
  // data['q'] = query;

  AppFilter baseFilterValue = AppFilter('none', '');
  AppFilter baseSortValue = AppFilter('new_first', 'Newest First');
  AppFilter baseStatusValue = AppFilter('all', 'All');
  List<AppFilter> filter = [
    AppFilter('upcoming', 'Upcoming'),
    AppFilter('date', 'Date'),
    AppFilter('range', 'Date Range'),
  ];
  List<AppFilter> sort = [
    AppFilter('new_first', 'Newest First'),
    AppFilter('old_first', 'Oldest First'),
  ];
  List<AppFilter> serviceStatus = [
    AppFilter('all', 'All'),
    AppFilter('paid', 'Paid'),
    AppFilter('not_paid', 'Not Paid'),
  ];
  ValueNotifier<AppFilter?> selectedFilter = ValueNotifier(null);
  ValueNotifier<AppFilter?> selectedSort = ValueNotifier(null);
  ValueNotifier<AppFilter?> selectedStatus = ValueNotifier(null);
  ValueNotifier<DateTime?> date = ValueNotifier(null);
  ValueNotifier<DateTimeRange?> dateRange = ValueNotifier(null);
  initFilterSort() {
    selectedFilter.value = baseFilterValue;
    selectedSort.value = baseSortValue;
    selectedStatus.value = baseStatusValue;
  }
  resetFilter() {
    baseFilterValue = AppFilter('none', '');
    baseSortValue = AppFilter('new_first', 'Newest First');
    baseStatusValue = AppFilter('all', 'All');
    date.value = null;
    dateRange.value = null;

    if(searchingCli.value) {
      searchPage = 1;
      searchLastPage = false;
      searchService.value.clear();
      searchService.notifyListeners();
      searchServices();
    } else {
      page = 1;
      isLastPage = false;
      services.value.clear();
      services.notifyListeners();
      getServices();
    }

  }
  updateFilter(AppFilter filter, int type) {
    switch(type) {
      case 1:
        selectedFilter.value = filter;
        break;
      case 2:
        selectedSort.value = filter;
        break;
      case 3:
        selectedStatus.value = filter;
        break;
    }
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
    baseSortValue = selectedSort.value!;
    baseStatusValue = selectedStatus.value!;

    if(searchingCli.value) {
      searchPage = 1;
      searchLastPage = false;
      searchService.value.clear();
      searchService.notifyListeners();
      searchServices();
    } else {
      page = 1;
      isLastPage = false;
      services.value.clear();
      services.notifyListeners();
      getServices();
    }
    return true;
  }

  //#endregion

  //#region -Search

  TextEditingController searchQuery = TextEditingController();
  int searchPage = 1;
  bool searchLastPage = false;
  PropertyNotifier<List<ServiceDetail>> searchService = PropertyNotifier([]);
  ValueNotifier<bool> searchingCli = ValueNotifier(false);
  Timer? throttle;
  onSearch(String val) {
    if(val.isNotEmpty) {
      searchingCli.value = true;
    } else {
      searchingCli.value = false;
    }
    searchService.value.clear();
    searchPage = 1;
    searchLastPage = false;
    if (throttle?.isActive ?? false) throttle?.cancel();
    throttle = Timer(const Duration(milliseconds: 700), () async {
      if(val.isNotEmpty) {
        searchServices();
      }
    });
  }

  Future searchServices() async {
    try{
      if(serviceState.value==LoadingState.loading || serviceState.value==LoadingState.paginating) {
        return;
      }
      if(searchLastPage) {
        return;
      }
      if(searchPage==1) {
        serviceState.value = LoadingState.loading;
      } else {
        serviceState.value = LoadingState.paginating;
      }
      ApiResponse<List<ServiceDetail>> res = await _repo.getServices(searchPage, filterType: baseFilterValue.id, sortType: baseSortValue.id, status: baseStatusValue.id, range: dateRange.value, date: date.value, query: searchQuery.text);
      if(res.status) {
        List<ServiceDetail> data = res.data ?? [];
        if(data.isEmpty) {
          searchLastPage = true;
        } else {
          searchService.value.addAll(data);
          searchPage++;
          searchService.notifyListeners();
        }
        serviceState.value = LoadingState.done;
      } else {
        showMessage(MessageType.error(res.message));
        serviceState.value = LoadingState.error;
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      serviceState.value = LoadingState.error;
      rethrow;
    } finally {
      serviceState.value = LoadingState.done;
    }
  }
  //#endregion

  Future getServiceDues() async {
    try{
      if(serviceState.value==LoadingState.loading || serviceState.value==LoadingState.paginating) {
        return;
      }
      if(isLastPage) {
        return;
      }
      if(page==1) {
        serviceState.value = LoadingState.loading;
      } else {
        serviceState.value = LoadingState.paginating;
      }
      ApiResponse<List<ServiceDetail>> res = await _repo.getServiceAmountDue(page);
      if(res.status) {
        List<ServiceDetail> data = res.data ?? [];
        if(data.isEmpty) {
          isLastPage = true;
        } else {
          services.value.addAll(data);
          page++;
          services.notifyListeners();
        }
        serviceState.value = LoadingState.done;
      } else {
        showMessage(MessageType.error(res.message));
        serviceState.value = LoadingState.error;
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      serviceState.value = LoadingState.error;
      rethrow;
    } finally {
      serviceState.value = LoadingState.done;
    }
  }
  //#endregion

  //#region - Service Detail
  ValueNotifier<ServiceDetail?> service = ValueNotifier(null);
  ValueNotifier<LoadingState> serviceDetailState = ValueNotifier(LoadingState.done);
  setServiceDetail(ServiceDetail service) {
    this.service.value = service;
    amountVal.value = (service.amount ?? 0) - (service.amountPaid ?? 0).toDouble();
    amount.text = '${amountVal.value.toInt()}';
    initServiceDetail();
  }
  initServiceDetail() async {
    try {
      await Future.wait([
        getServiceDetail(),
        gerServiceTransactions(),
      ]);
    } catch(e,s) {

    }
  }

  Future getServiceDetail() async {
    try{
      if(serviceDetailState.value==LoadingState.loading) {
        return;
      }
      serviceDetailState.value = LoadingState.loading;
      ApiResponse<ServiceDetail> res = await _repo.getServiceDetail('${service.value?.id}');
      if(res.status) {
        service.value = res.data;
        invoiceDescp.text = service.value?.description ?? '';
        serviceDetailState.value = LoadingState.done;
      } else {
        showMessage(MessageType.error(res.message));
        serviceDetailState.value = LoadingState.error;
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      serviceDetailState.value = LoadingState.error;
      rethrow;
    }
  }
  ValueNotifier<List<TransactionDetail>> transactions = ValueNotifier([]);
  ValueNotifier<LoadingState> transactionState = ValueNotifier(LoadingState.done);
  Future gerServiceTransactions() async {
    try{
      if(transactionState.value==LoadingState.loading) {
        return;
      }
      transactionState.value = LoadingState.loading;
      ApiResponse<List<TransactionDetail>> res = await _repo.getTransactions(1, serviceId: '${service.value?.id}');
      if(res.status) {
        transactions.value = res.data ?? [];
        transactionState.value = LoadingState.done;
      } else {
        showMessage(MessageType.error(res.message));
        transactionState.value = LoadingState.error;
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      transactionState.value = LoadingState.error;
      rethrow;
    }
  }

  TextEditingController invoiceDescp = TextEditingController();
  ValueNotifier<bool> loadingDes = ValueNotifier(false);
  editServiceInvoiceDescp() async {
    try {
      if(loadingDes.value) {
        return;
      }
      if(service.value==null) {
        return;
      }
      loadingDes.value = true;
      ApiResponse res = await _repo.editServiceInvoiceDescp('${service.value?.id}', invoiceDescp.text);
      if(res.status) {
        showMessage(const MessageType.success("Invoice description successfully!"));
        initServiceDetail();
      } else {
        showMessage(const MessageType.error("Error occurred adding Invoice description!"));
        // return;
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
    } finally {
      loadingDes.value = false;
    }
  }
  //#endregion

  //#region - Clear Service Dues
  setService(ServiceDetail service) {
    this.service.value = service;
    amountVal.value = (service.amount ?? 0) - (service.amountPaid ?? 0).toDouble();
    amount.text = '${amountVal.value.toInt()}';
  }
  updateAmount(double amount) {
    amountVal.value = amount;
    this.amount.text = '${amountVal.value.toInt()}';
  }
  ValueNotifier<bool> clearing = ValueNotifier(false);
  StreamController<String> dueController = StreamController.broadcast();
  TextEditingController amount = TextEditingController();
  ValueNotifier<double> amountVal = ValueNotifier(0);
  TextEditingController clearDueDesc = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  clearDues() async {
    try {
      if(clearing.value) {
        return;
      }

      if(validateAmount()) {
        return;
      }
      clearing.value = true;

      ApiResponse res = await _repo.clearServiceDue('${service.value?.id}', amount.text, clearDueDesc: clearDueDesc.text);
      if(res.status) {
        showMessage(const MessageType.success("Dues cleared!"));
        dueController.add("CLEARED");
      } else {
        showMessage(MessageType.error(res.message));
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      showMessage(const MessageType.error("Some error occurred! Please try again!"));
    } finally {
      clearing.value = false;
    }
  }

  bool validateAmount() {
    if(formState.currentState!.validate()) {
      if(service.value==null) {
        showMessage(const MessageType.error("Please select service"));
        return true;
      }
      if(amount.text.isEmpty) {
        showMessage(const MessageType.error("Please enter amount"));
        return true;
      }
      num due = service.value?.amount ?? 0;
      num duePaid = service.value?.amountPaid ?? 0;
      num setAmount = num.parse(amount.text);
      if(duePaid + setAmount > due) {
        showMessage(const MessageType.error("Amount can not be more than due amount"));
        return true;
      }
      return false;
    }

    return true;
  }
  //#endregion

  //#region -Invoice
  ValueNotifier<ServiceDetail?> invoiceService = ValueNotifier(null);
  generateInvoice(ServiceDetail service) async {
    try {
      if(invoiceService.value!=null) {
        return;
      }
      invoiceService.value = service;
      Document invoiceFile = await PdfInvoiceApi.generateInvoice(service, transactions.value);
      await Printing.sharePdf(bytes: await invoiceFile.save(), filename: 'my-document.pdf');

    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
    } finally {
      invoiceService.value = null;
    }
  }
  //#endregion

  //#region -Edit Service Amount

  ValueNotifier<ServiceDetail?> selectedService = ValueNotifier(null);
  TextEditingController editAmount = TextEditingController();
  TextEditingController title = TextEditingController();
  ValueNotifier<DateTime?> schedule = ValueNotifier(null);
  updateSchedule(DateTime date) {
    schedule.value = date;
  }
  ValueNotifier<bool> isAdditionalService = ValueNotifier(true);
  updateAdditionalService(bool val) => isAdditionalService.value = val;

  editServiceAmount(ServiceDetail service) async {
    try {
      if(selectedService.value!=null) {
        return;
      }
      if(editAmount.text.isEmpty) {
        showMessage(const MessageType.error("Please add service amount!"));
        return;
      }
      selectedService.value = service;
      ApiResponse res = await _repo.editServiceAmount('${service.id}', editAmount.text);
      if(res.status) {
        showMessage(const MessageType.success("Amount edited successfully!"));
        dueController.sink.add("CLEARED");
      } else {
        showMessage(const MessageType.error("Error occurred editing amount!"));
        // return;
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
    } finally {
      selectedService.value = null;
    }
  }
  addServiceAmount(ServiceDetail service) async {
    try {
      if(selectedService.value!=null) {
        return;
      }
      if(title.text.isEmpty) {
        showMessage(const MessageType.error("Please add description!"));
        return;
      }
      if(editAmount.text.isEmpty) {
        showMessage(const MessageType.error("Please add service amount!"));
        return;
      }
      if(isAdditionalService.value) {
        if(schedule.value==null) {
          showMessage(const MessageType.error("Please enter additional service date and time!"));
          return;
        }
      }
      selectedService.value = service;
      ApiResponse res = await _repo.addServiceAmount('${service.id}', title.text, editAmount.text, isAdditionalService.value, schedule: schedule.value);
      if(res.status) {
        if(schedule.value!=null) {
          await AwesomeNotifications().createNotification(
              content: NotificationContent(
                // id: (lead.id ?? Random().nextInt(9999)).toInt(),
                id: Random().nextInt(9999),
                channelKey: 'scheduled',
                title: 'Additional Service ${title.text} is scheduled for now.',
                body: 'For ${this.service.value?.clientName}',
                wakeUpScreen: true,
                category: NotificationCategory.Reminder,
                notificationLayout: NotificationLayout.BigText,
                autoDismissible: false,
              ),
              schedule: NotificationCalendar.fromDate(date: schedule.value!, allowWhileIdle: true, preciseAlarm: true),
          );
        }
        showMessage(const MessageType.success("Amount added successfully!"));
        dueController.add("CLEARED");

        title.clear();
        editAmount.clear();
        schedule.value = null;
      } else {
        showMessage(const MessageType.error("Error occurred editing amount!"));
        // return;
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
    } finally {
      selectedService.value = null;
    }
  }
//#endregion

  //#region -CancelService
  ValueNotifier<TransactionDetail?> cancelling = ValueNotifier(null);
  cancelService(TransactionDetail service) async {
    try {
      if(cancelling.value!=null) {
        return;
      }
      cancelling.value = service;
      ApiResponse res = await _repo.cancelService('${service.serviceId}', '${service.id}');
      if(res.status) {
        showMessage(const MessageType.error("Successfully cancelled service!"));
        dueController.sink.add("CANCELLED");
      } else {
        showMessage(MessageType.error(res.message));
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
    } finally {
      cancelling.value = null;
    }
  }
  //#endregion
}

class AppFilter {
  final String id, name;
  AppFilter(this.id, this.name);
}