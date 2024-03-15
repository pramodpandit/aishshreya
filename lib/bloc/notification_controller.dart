import 'package:aishshreya/data/model/ClientDetail.dart';
import 'package:aishshreya/data/model/LeadDetail.dart';
import 'package:aishshreya/data/model/UserDetail.dart';
import 'package:aishshreya/main.dart';
import 'package:aishshreya/ui/clients/client_details_page.dart';
import 'package:aishshreya/ui/clients/client_page.dart';
import 'package:aishshreya/ui/employee/employee_detail_page.dart';
import 'package:aishshreya/ui/employee/employee_list.dart';
import 'package:aishshreya/ui/leads/lead_detail_page.dart';
import 'package:aishshreya/ui/leads/leads_list_page.dart';
import 'package:aishshreya/ui/services/service_list.dart';
import 'package:aishshreya/ui/services/service_transactions.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationController {

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    debugPrint('receivedAction.payload ${receivedAction.payload}');
    Map<String, String?>? payload = receivedAction.payload;
    if(payload!=null) {
      if(payload['page']=="lead") {
        var id = payload['id'];
        if(id!=null) {
          debugPrint('receivedAction.payload on lead with id');
          MyApp.navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => LeadDetailPage(lead: LeadDetail(id: num.parse(id)),)));
        } else {
          MyApp.navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => const LeadsListPage() ));
        }
      } else if(payload['page']=="employee") {
        var id = payload['id'];
        if(id!=null) {
          MyApp.navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => EmployeeDetailPage(employee: UserDetail(id:num.parse(id) ))));
        } else {
          MyApp.navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => const EmployeeList() ));
        }
      } else if(payload['page']=="service") {
        MyApp.navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => const ClientServicesPage() ));
      } else if(payload['page']=="client") {
        var id = payload['id'];
        if(id!=null) {
          MyApp.navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => ClientDetailPage(client: ClientDetail(id: num.parse(payload['id'] ?? '0')),)));
        } else {
          MyApp.navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => const ClientListPage() ));
        }
      } else if(payload['page']=="transaction") {
        MyApp.navigatorKey.currentState?.push(MaterialPageRoute(builder: (context) => const TransactionsHistoryPage() ));
      }

      // // Navigate into pages, avoiding to open the notification details page over another details page already opened
      // MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/notification-page',
      //         (route) => (route.settings.name != '/notification-page') || route.isFirst,
      //     arguments: receivedAction);
    }
  }
}