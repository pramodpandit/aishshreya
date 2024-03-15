// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'UserReminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserReminderAdapter extends TypeAdapter<UserReminder> {
  @override
  final int typeId = 0;

  @override
  UserReminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserReminder()
      ..id = fields[0] as num
      ..title = fields[1] as String
      ..description = fields[2] as String
      ..scheduleDateTime = fields[3] as DateTime
      ..repeatId = fields[4] as int
      ..repeatDays = fields[5] as int
      ..status = fields[6] as bool;
  }

  @override
  void write(BinaryWriter writer, UserReminder obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.scheduleDateTime)
      ..writeByte(4)
      ..write(obj.repeatId)
      ..writeByte(5)
      ..write(obj.repeatDays)
      ..writeByte(6)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
