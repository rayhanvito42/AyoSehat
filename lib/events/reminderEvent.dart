import 'package:bp_notepad/models/alarmModel.dart';

// Records various events in the interface

abstract class ReminderEvent {}

// Initialize reminder list
class SetAlarms extends ReminderEvent {
  List<AlarmDB> alarmList;

  SetAlarms(List<AlarmDB> alarms) {
    alarmList = alarms;
  }
}

// delete reminder
class DeleteAlarm extends ReminderEvent {
  int alarmIndex;

  DeleteAlarm(int index) {
    alarmIndex = index;
  }
}

// Add reminder
class AddAlarm extends ReminderEvent {
  AlarmDB newAlarm;

  AddAlarm(AlarmDB alarm) {
    newAlarm = alarm;
  }
}
