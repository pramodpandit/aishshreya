//
// import 'package:aishshreya/data/model/UserReminder.dart';
// import 'package:flutter/foundation.dart';
// import 'package:hive/hive.dart';
//
// class HiveBoxes {
//   static const reminders = "REMINDERS";
// }
//
// class HiveService {
//   HiveService() {
//     init();
//   }
//
//   late Box<UserReminder> reminderBox;
//
//   init() async {
//     debugPrint("initiate hive box item");
//     await Future.wait([
//       _openReminderBox(),
//     ]);
//   }
//
//   //#region -Reminders
//   Box<UserReminder> reminders() => Hive.box<UserReminder>(HiveBoxes.reminders);
//
//   Future _openReminderBox() async {
//     reminderBox = await Hive.openBox<UserReminder>(HiveBoxes.reminders);
//   }
//
//   bool saveNewReminder(UserReminder newReminder) {
//     // List<UserReminder> reminders = reminderBox.values.toList();
//
//     try{
//       reminderBox.add(newReminder);
//       return true;
//     } catch(e,s) {
//       debugPrint('$e');
//       debugPrintStack(stackTrace: s);
//       return false;
//     }
//   }
//
//   bool removeReminder(UserReminder reminder) {
//     try{
//       var list = Hive.box<UserReminder>(HiveBoxes.reminders).values.toList();
//       bool notFound = true;
//       for(UserReminder r in list) {
//         if(r.id == reminder.id) {
//           notFound = false;
//           r.delete();
//         }
//       }
//       if(notFound) {
//         return false;
//       }
//       return true;
//     } catch(e,s) {
//       debugPrint('$e');
//       debugPrintStack(stackTrace: s);
//       return false;
//     }
//   }
//
//
//
//   //#endregion
//
//
//
// }