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

  // ========== FONCTIONS BLUETOOTH (à implémenter plus tard) ==========

  // Fonction Bluetooth ID 50 : Remise à l'heure
  // Args: année depuis 2000 (0-255), mois (1-12), jour (1-31), heure (0-23), minute (0-59), secondes (0-59)
  Future<void> envoyerRemiseHeure() async {
    int annee = _dateTimeHorloge.year - 2000;
    int mois = _dateTimeHorloge.month;
    int jour = _dateTimeHorloge.day;
    int heure = _dateTimeHorloge.hour;
    int minute = _dateTimeHorloge.minute;
    int seconde = _dateTimeHorloge.second;

    print('Bluetooth ID 50: Remise à l\'heure');
    print('Args: $annee, $mois, $jour, $heure, $minute, $seconde');

    // TODO: Implémenter l'envoi Bluetooth
  }

  // Fonction Bluetooth ID 1 : Gestion néons
  // Args: mode des néons (0 off, 1 on, 2 programmation), marche néon 1 (1,0), marche néon 2 (1,0)
  Future<void> envoyerGestionNeons() async {
    int neon1 = _marcheNeon1 ? 1 : 0;
    int neon2 = _marcheNeon2 ? 1 : 0;

    print('Bluetooth ID 1: Gestion néons');
    print('Args: $_modeNeons, $neon1, $neon2');

    // TODO: Implémenter l'envoi Bluetooth
  }

  // Fonction Bluetooth ID 2 : Gestion horloges
  // Args: marche horloge 1 (0,1), marche horloge 2 (0,1), marche trotteuse 1 (0,1), marche trotteuse 2 (0,1)
  Future<void> envoyerGestionHorloges() async {
    int h1 = _marcheHorloge1 ? 1 : 0;
    int h2 = _marcheHorloge2 ? 1 : 0;
    int t1 = _marcheTrotteuse1 ? 1 : 0;
    int t2 = _marcheTrotteuse2 ? 1 : 0;

    print('Bluetooth ID 2: Gestion horloges');
    print('Args: $h1, $h2, $t1, $t2');

    // TODO: Implémenter l'envoi Bluetooth
  }

  // Fonction Bluetooth ID 3 : Programmation néons
  // Args variables: 4 bytes par plage horaire
  // jour/heure de départ (0-167), minutes de départ (0-59), jour/heure de fin (0-167), minutes de fin (0-59)
  Future<void> envoyerProgrammationNeons() async {
    print('Bluetooth ID 3: Programmation néons');
    print('Nombre de plages: ${_programmationNeons.length}');

    for (int i = 0; i < _programmationNeons.length; i++) {
      List<int> plage = _programmationNeons[i];
      print('Plage $i: ${plage[0]}, ${plage[1]}, ${plage[2]}, ${plage[3]}');
    }

    // TODO: Implémenter l'envoi Bluetooth
  }

  // Fonction pour tout envoyer d'un coup
  Future<void> synchroniserTout() async {
    await envoyerRemiseHeure();
    await envoyerGestionHorloges();
    await envoyerGestionNeons();
    await envoyerProgrammationNeons();
  }
}
