import 'package:flutter/foundation.dart';

class AppProvider extends ChangeNotifier {
  // Clock variables (for Bluetooth function ID 2)
  bool _mainSwitchOn = false;
  bool _clock1Running = false;
  bool _clock2Running = false;
  bool _secondHand1Running = false;
  bool _secondHand2Running = false;

  // Neon variables (for Bluetooth function ID 1)
  int _neonMode = 0; // 0: off, 1: on, 2: programming
  bool _neon1Running = false;
  bool _neon2Running = false;

  // Neon programming (for Bluetooth function ID 3)
  // List of time slots: each slot = [dayHourStart, minuteStart, dayHourEnd, minuteEnd]
  List<List<int>> _neonSchedule = [];

  // Variables for time setting (for Bluetooth function ID 50)
  DateTime _clockDateTime = DateTime.now();

  // Getters
  bool get mainSwitchOn => _mainSwitchOn;

  // Getters - Clocks
  bool get clock1Running => _clock1Running;
  bool get clock2Running => _clock2Running;
  bool get secondHand1Running => _secondHand1Running;
  bool get secondHand2Running => _secondHand2Running;

  // Getters - Neons
  int get neonMode => _neonMode;
  bool get neon1Running => _neon1Running;
  bool get neon2Running => _neon2Running;
  List<List<int>> get neonSchedule => _neonSchedule;

  // Getters - Date/Time
  DateTime get clockDateTime => _clockDateTime;

  // Setters
  void setMainSwitchOn(bool value) {
    _mainSwitchOn = value;
    notifyListeners();
  }

  // Setters - Clocks
  void setClock1Running(bool value) {
    _clock1Running = value;
    if (!value) {
      _secondHand1Running = false;
    }
    notifyListeners();
  }

  void setClock2Running(bool value) {
    _clock2Running = value;
    if (!value) {
      _secondHand2Running = false;
    }
    notifyListeners();
  }

  void setSecondHand1Running(bool value) {
    _secondHand1Running = value;
    notifyListeners();
  }

  void setSecondHand2Running(bool value) {
    _secondHand2Running = value;
    notifyListeners();
  }

  // Setters - Neons
  void setNeonMode(int value) {
    if (value >= 0 && value <= 2) {
      _neonMode = value;
      notifyListeners();
    }
  }

  void setNeon1Running(bool value) {
    _neon1Running = value;
    notifyListeners();
  }

  void setNeon2Running(bool value) {
    _neon2Running = value;
    notifyListeners();
  }

  // Setters - Neon programming
  void addNeonTimeSlot(
    int dayHourStart,
    int minuteStart,
    int dayHourEnd,
    int minuteEnd,
  ) {
    _neonSchedule.add([dayHourStart, minuteStart, dayHourEnd, minuteEnd]);
    notifyListeners();
  }

  void removeNeonTimeSlot(int index) {
    if (index >= 0 && index < _neonSchedule.length) {
      _neonSchedule.removeAt(index);
      notifyListeners();
    }
  }

  void clearNeonSchedule() {
    _neonSchedule.clear();
    notifyListeners();
  }

  // Setter - Date/Time
  void setClockDateTime(DateTime dateTime) {
    _clockDateTime = dateTime;
    notifyListeners();
  }
}
