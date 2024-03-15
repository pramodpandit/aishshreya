import 'package:hive/hive.dart';

part 'UserReminder.g.dart';

@HiveType(typeId: 0)
class UserReminder extends HiveObject {

  @HiveField(0)
  late num id;
  @HiveField(1)
  late String title;
  @HiveField(2)
  late String description;
  @HiveField(3)
  late DateTime scheduleDateTime;
  @HiveField(4)
  late int repeatId;
  @HiveField(5)
  int repeatDays = 0;
  @HiveField(6)
  bool status = true;

}