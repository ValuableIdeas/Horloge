/// Classe utilitaire pour construire les messages Bluetooth
class BluetoothMessageBuilder {
  /// ID de fonction 50: Remise à l'heure
  /// Args: année depuis 2000, mois, jour, heure, minute, secondes
  static List<int> buildTimeSetMessage(DateTime dateTime) {
    int year = dateTime.year - 2000; // Année depuis 2000
    int month = dateTime.month;
    int day = dateTime.day;
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    int second = dateTime.second;

    return [
      50, // ID fonction
      6, // Nombre d'arguments
      year,
      month,
      day,
      hour,
      minute,
      second,
    ];
  }

  /// ID de fonction 1: Gestion néons
  /// Args: mode (0=off, 1=on, 2=prog), neon1 (0/1), neon2 (0/1)
  static List<int> buildNeonControlMessage({
    required int mode,
    required bool neon1Running,
    required bool neon2Running,
  }) {
    return [
      1, // ID fonction
      3, // Nombre d'arguments
      mode,
      neon1Running ? 1 : 0,
      neon2Running ? 1 : 0,
    ];
  }

  /// ID de fonction 2: Gestion horloges
  /// Args: horloge1, horloge2, trotteuse1, trotteuse2 (0/1)
  static List<int> buildClockControlMessage({
    required bool clock1Running,
    required bool clock2Running,
    required bool secondHand1Running,
    required bool secondHand2Running,
  }) {
    return [
      2, // ID fonction
      4, // Nombre d'arguments
      clock1Running ? 1 : 0,
      clock2Running ? 1 : 0,
      secondHand1Running ? 1 : 0,
      secondHand2Running ? 1 : 0,
    ];
  }

  /// ID de fonction 3: Programmation néons
  /// Args: 4 bytes par plage horaire
  /// [jourHeureDebut(0-167), minuteDebut(0-59), jourHeureFin(0-167), minuteFin(0-59)]
  static List<int> buildNeonScheduleMessage(List<List<int>> schedule) {
    List<int> message = [
      3, // ID fonction
      schedule.length * 4, // Nombre d'arguments (4 par plage)
    ];

    // Ajout de chaque plage horaire
    for (var slot in schedule) {
      // slot[0] = dayHourStart
      // slot[1] = minuteStart
      // slot[2] = dayHourEnd
      // slot[3] = minuteEnd
      message.addAll([
        slot[0], // jourHeureDebut (0-167)
        slot[1], // minuteDebut (0-59)
        slot[2], // jourHeureFin (0-167)
        slot[3], // minuteFin (0-59)
      ]);
    }

    return message;
  }
}
