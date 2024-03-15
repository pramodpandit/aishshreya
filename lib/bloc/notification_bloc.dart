import 'package:aishshreya/data/model/AppNotification.dart';
import 'package:aishshreya/data/model/api_response.dart';
import 'package:aishshreya/data/repository/app_repository.dart';
import 'package:aishshreya/utils/enums.dart';
import 'package:aishshreya/utils/message_handler.dart';
import 'package:flutter/cupertino.dart';

import 'bloc.dart';
import 'property_notifier.dart';

class NotificationBloc extends Bloc {
  final AppRepository _repo;
  NotificationBloc(this._repo);

  //#region -Get Notifications
  ScrollController scrollController = ScrollController();
  int page = 1;
  bool isLastPage = false;

  scrollListener() {
    if (scrollController.position.extentAfter < 500) {
      if (notificationState.value==LoadingState.done) {
        if (!isLastPage) {
          getNotifications();
        }
      }
    }
  }

  ValueNotifier<LoadingState> notificationState = ValueNotifier(LoadingState.done);
  PropertyNotifier<List<AppNotification>> notifications = PropertyNotifier([]);
  Future getNotifications() async {
    try{
      if(notificationState.value==LoadingState.loading || notificationState.value==LoadingState.paginating) {
        return;
      }
      if(isLastPage) {
        return;
      }
      if(page==1) {
        notificationState.value = LoadingState.loading;
      } else {
        notificationState.value = LoadingState.paginating;
      }
      ApiResponse<List<AppNotification>> res = await _repo.getNotifications(page);
      if(res.status) {
        List<AppNotification> data = res.data ?? [];
        if(data.isEmpty) {
          isLastPage = true;
        } else {
          notifications.value.addAll(data);
          page++;
          notifications.notifyListeners();
        }
        notificationState.value = LoadingState.done;
      } else {
        showMessage(MessageType.error(res.message));
        notificationState.value = LoadingState.error;
      }
    } catch(e,s) {
      debugPrint('$e');
      debugPrintStack(stackTrace: s);
      notificationState.value = LoadingState.error;
      rethrow;
    } finally {
      notificationState.value = LoadingState.done;
    }
  }
  //#endregion
}