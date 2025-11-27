/// Classe pour parser les messages Bluetooth reçus
class BluetoothMessageParser {
  /// Parse un message reçu et retourne les données structurées
  static Map<String, dynamic>? parseMessage(List<int> message) {
    if (message.length < 2) {
      print("Message trop court: $message");
      return null;
    }

    int functionId = message[0];
    int argCount = message[1];

    // Vérifier que le message a la bonne longueur
    if (message.length != 2 + argCount) {
      print(
        "Longueur de message incorrecte. Attendu: ${2 + argCount}, Reçu: ${message.length}",
      );
      return null;
    }

    // Extraire les arguments
    List<int> args = message.sublist(2);

    return {'functionId': functionId, 'argCount': argCount, 'args': args};
  }

  /// Parse spécifiquement la fonction ID 25 (heure des horloges)
  /// Format: [25, 4, heures1, minutes1, heures2, minutes2]
  static Map<String, dynamic>? parseClockTimeMessage(List<int> message) {
    var parsed = parseMessage(message);

    if (parsed == null) return null;
    if (parsed['functionId'] != 25) {
      print(
        "ID de fonction incorrect. Attendu: 25, Reçu: ${parsed['functionId']}",
      );
      return null;
    }
    if (parsed['argCount'] != 4) {
      print(
        "Nombre d'arguments incorrect pour ID 25. Attendu: 4, Reçu: ${parsed['argCount']}",
      );
      return null;
    }

    List<int> args = parsed['args'];

    return {
      'clock1Hours': args[0],
      'clock1Minutes': args[1],
      'clock2Hours': args[2],
      'clock2Minutes': args[3],
    };
  }

  /// Formate l'heure au format "HH:MM"
  static String formatTime(int hours, int minutes) {
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  /// Parse spécifiquement la fonction ID 15 (température)
  /// Format: [15, 2, byte1, byte2]
  static double? parseTemperatureMessage(List<int> message) {
    var parsed = parseMessage(message);

    if (parsed == null) return null;
    if (parsed['functionId'] != 15) {
      print(
        "ID de fonction incorrect. Attendu: 15, Reçu: ${parsed['functionId']}",
      );
      return null;
    }
    if (parsed['argCount'] != 2) {
      print(
        "Nombre d'arguments incorrect pour ID 15. Attendu: 2, Reçu: ${parsed['argCount']}",
      );
      return null;
    }

    List<int> args = parsed['args'];
    int byte1 = args[0];
    int byte2 = args[1];

    const double OFFSET = 40.0;
    const double RESOLUTION = 4.0;

    int coded = byte1 * 256 + byte2;
    double temp = (coded / RESOLUTION) - OFFSET;

    return temp;
  }

  /// Parse spécifiquement la fonction ID 100 (synchronisation complète)
  /// Format: [100, arg_count, general, work0, work1, trot0, trot1,
  ///          state_neons, neons_work0, neons_work1, track_number,
  ///          hour0, minute0, hour1, minute1,
  ///          puis 4 bytes par plage]
  static Map<String, dynamic>? parseSyncMessage(List<int> message) {
    print(">>> Parsing message de synchronisation");
    print("    Message complet: $message");

    var parsed = parseMessage(message);

    if (parsed == null) {
      print("    ❌ Échec du parsing de base");
      return null;
    }

    if (parsed['functionId'] != 100) {
      print(
        "    ❌ ID de fonction incorrect. Attendu: 100, Reçu: ${parsed['functionId']}",
      );
      return null;
    }

    List<int> args = parsed['args'];

    print("    Arguments count: ${args.length}");

    // Vérifier qu'on a au minimum les 13 bytes fixes (9 + 4 pour les heures)
    if (args.length < 13) {
      print(
        "    ❌ Nombre d'arguments incorrect pour ID 100. Minimum: 13, Reçu: ${args.length}",
      );
      return null;
    }

    // Extraire les données fixes (13 premiers bytes)
    int general = args[0];
    int work0 = args[1];
    int work1 = args[2];
    int trot0 = args[3];
    int trot1 = args[4];
    int stateNeons = args[5];
    int neonsWork0 = args[6];
    int neonsWork1 = args[7];
    int trackNumber = args[8];

    // ✅ NOUVEAU : Heures des horloges
    int hour0 = args[9];
    int minute0 = args[10];
    int hour1 = args[11];
    int minute1 = args[12];

    print("    Données fixes extraites:");
    print("      general=$general, work=[$work0,$work1], trot=[$trot0,$trot1]");
    print("      neons: mode=$stateNeons, active=[$neonsWork0,$neonsWork1]");
    print("      track_number=$trackNumber");
    print("      horloges: H1=${hour0}:${minute0}, H2=${hour1}:${minute1}");

    // Vérifier la cohérence avec le nombre de plages
    int expectedLength = 13 + (trackNumber * 4);
    if (args.length != expectedLength) {
      print(
        "    ❌ Longueur incorrecte pour la programmation. Attendu: $expectedLength, Reçu: ${args.length}",
      );
      return null;
    }

    // Extraire les plages horaires
    List<List<int>> neonSchedule = [];
    for (int i = 0; i < trackNumber; i++) {
      int offset = 13 + (i * 4);
      neonSchedule.add([
        args[offset], // dayHourStart
        args[offset + 1], // minuteStart
        args[offset + 2], // dayHourEnd
        args[offset + 3], // minuteEnd
      ]);
    }

    print("    ✅ Parsing réussi - ${neonSchedule.length} plages extraites");

    return {
      'general': general == 1,
      'clock1Running': work0 == 1,
      'clock2Running': work1 == 1,
      'secondHand1Running': trot0 == 1,
      'secondHand2Running': trot1 == 1,
      'neonMode': stateNeons,
      'neon1Running': neonsWork0 == 1,
      'neon2Running': neonsWork1 == 1,
      'neonSchedule': neonSchedule,
      // ✅ NOUVEAU : Heures des horloges
      'clock1Hours': hour0,
      'clock1Minutes': minute0,
      'clock2Hours': hour1,
      'clock2Minutes': minute1,
    };
  }
}
