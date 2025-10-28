import 'package:flutter/foundation.dart';

class AppProvider extends ChangeNotifier {
  // Variables horloges (pour fonction Bluetooth ID 2)
  bool _marcheHorloge1 = false;
  bool _marcheHorloge2 = false;
  bool _marcheTrotteuse1 = false;
  bool _marcheTrotteuse2 = false;

  // Variables néons (pour fonction Bluetooth ID 1)
  int _modeNeons = 0; // 0: off, 1: on, 2: programmation
  bool _marcheNeon1 = false;
  bool _marcheNeon2 = false;

  // Programmation néons (pour fonction Bluetooth ID 3)
  // Liste de plages horaires : chaque plage = [jourHeureDebut, minuteDebut, jourHeureFin, minuteFin]
  List<List<int>> _programmationNeons = [];

  // Variables pour remise à l'heure (pour fonction Bluetooth ID 50)
  DateTime _dateTimeHorloge = DateTime.now();

  // Variable pour l'alimentation générale (non envoyée par Bluetooth, juste pour l'UI)
  bool _alimentationGenerale = false;

  // Getters - Horloges
  bool get marcheHorloge1 => _marcheHorloge1;
  bool get marcheHorloge2 => _marcheHorloge2;
  bool get marcheTrotteuse1 => _marcheTrotteuse1;
  bool get marcheTrotteuse2 => _marcheTrotteuse2;
  bool get alimentationGenerale => _alimentationGenerale;

  // Getters - Néons
  int get modeNeons => _modeNeons;
  bool get marcheNeon1 => _marcheNeon1;
  bool get marcheNeon2 => _marcheNeon2;
  List<List<int>> get programmationNeons => _programmationNeons;

  // Getters - Date/Heure
  DateTime get dateTimeHorloge => _dateTimeHorloge;

  // Setters - Alimentation générale
  void setAlimentationGenerale(bool value) {
    _alimentationGenerale = value;
    // Si on coupe l'alimentation, on coupe tout
    if (!value) {
      _marcheHorloge1 = false;
      _marcheHorloge2 = false;
      _marcheTrotteuse1 = false;
      _marcheTrotteuse2 = false;
    }
    notifyListeners();
  }

  // Setters - Horloges
  void setMarcheHorloge1(bool value) {
    _marcheHorloge1 = value;
    if (!value) {
      _marcheTrotteuse1 = false;
    }
    notifyListeners();
  }

  void setMarcheHorloge2(bool value) {
    _marcheHorloge2 = value;
    if (!value) {
      _marcheTrotteuse2 = false;
    }
    notifyListeners();
  }

  void setMarcheTrotteuse1(bool value) {
    _marcheTrotteuse1 = value;
    notifyListeners();
  }

  void setMarcheTrotteuse2(bool value) {
    _marcheTrotteuse2 = value;
    notifyListeners();
  }

  // Setters - Néons
  void setModeNeons(int value) {
    if (value >= 0 && value <= 2) {
      _modeNeons = value;
      notifyListeners();
    }
  }

  void setMarcheNeon1(bool value) {
    _marcheNeon1 = value;
    notifyListeners();
  }

  void setMarcheNeon2(bool value) {
    _marcheNeon2 = value;
    notifyListeners();
  }

  // Setters - Programmation néons
  void ajouterPlageNeons(
    int jourHeureDebut,
    int minuteDebut,
    int jourHeureFin,
    int minuteFin,
  ) {
    _programmationNeons.add([
      jourHeureDebut,
      minuteDebut,
      jourHeureFin,
      minuteFin,
    ]);
    notifyListeners();
  }

  void supprimerPlageNeons(int index) {
    if (index >= 0 && index < _programmationNeons.length) {
      _programmationNeons.removeAt(index);
      notifyListeners();
    }
  }

  void viderProgrammationNeons() {
    _programmationNeons.clear();
    notifyListeners();
  }

  // Setter - Date/Heure
  void setDateTimeHorloge(DateTime dateTime) {
    _dateTimeHorloge = dateTime;
    notifyListeners();
  }
}
