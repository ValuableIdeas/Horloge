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
        "Nombre d'arguments incorrect pour ID 50. Attendu: 4, Reçu: ${parsed['argCount']}",
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
}
