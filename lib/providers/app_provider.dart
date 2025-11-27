import 'package:flutter/foundation.dart';
import '../services/bluetooth_service.dart';
import '../services/bluetooth_message_builder.dart';
import '../services/bluetooth_message_parser.dart';

class AppProvider extends ChangeNotifier {
  // Service Bluetooth
  final BluetoothService _bluetoothService = BluetoothService();

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
  List<List<int>> _neonSchedule = [];

  // Variables for time setting (for Bluetooth function ID 50)
  DateTime _clockDateTime = DateTime.now();

  // État de connexion
  bool _isConnecting = false;
  bool _isSynchronizing = false; // ✅ NOUVEAU : État de synchronisation
  String _connectionStatus = "Déconnecté";

  // Données reçues
  List<int> _lastReceivedData = [];
  String _receivedDataHistory = "";

  // Heure des horloges reçue depuis Arduino
  int _clock1Hours = 0;
  int _clock1Minutes = 0;
  int _clock2Hours = 0;
  int _clock2Minutes = 0;

  // Température reçue depuis Arduino
  double _temperature = 0.0;

  // Getters
  bool get mainSwitchOn => _mainSwitchOn;
  BluetoothService get bluetoothService => _bluetoothService;
  bool get isConnected => _bluetoothService.isConnected;
  bool get isConnecting => _isConnecting;
  bool get isSynchronizing => _isSynchronizing; // ✅ NOUVEAU
  String get connectionStatus => _connectionStatus;
  List<int> get lastReceivedData => _lastReceivedData;
  String get receivedDataHistory => _receivedDataHistory;

  // Getters - Heure des horloges
  int get clock1Hours => _clock1Hours;
  int get clock1Minutes => _clock1Minutes;
  int get clock2Hours => _clock2Hours;
  int get clock2Minutes => _clock2Minutes;
  String get clock1TimeString =>
      BluetoothMessageParser.formatTime(_clock1Hours, _clock1Minutes);
  String get clock2TimeString =>
      BluetoothMessageParser.formatTime(_clock2Hours, _clock2Minutes);

  // Getters - Température
  double get temperature => _temperature;

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

  AppProvider() {
    _setupBluetoothCallbacks();
  }

  /// Configuration des callbacks Bluetooth
  void _setupBluetoothCallbacks() {
    _bluetoothService.onConnected = () async {
      print("🔗 Connexion Bluetooth établie - Démarrage de la séquence");

      // IMMÉDIATEMENT marquer comme "en synchronisation"
      // pour que LoadingOverlay masque tout
      _isSynchronizing = true;
      _connectionStatus = "Synchronisation...";
      notifyListeners();

      try {
        // 1. Démarrer l'écoute des données
        await _bluetoothService.startListening();
        print("👂 Écoute activée");

        // 2. Attendre que le listener soit bien configuré
        await Future.delayed(Duration(milliseconds: 1000));

        // 3. Demander la synchronisation (on attend la réponse)
        _requestSynchronization();
        print("📤 Demande de synchronisation envoyée");

        // 4. Attendre la réponse de synchronisation (max 5 secondes)
        int attempts = 0;
        while (_isSynchronizing && attempts < 50) {
          await Future.delayed(Duration(milliseconds: 100));
          attempts++;
        }

        // ✅ VÉRIFIER SI TOUJOURS CONNECTÉ
        if (!_bluetoothService.isConnected) {
          print("⚠️ Déconnecté pendant la synchronisation");
          _isSynchronizing = false;
          _isConnecting = false;
          notifyListeners();
          return; // ✅ SORTIR - ne pas continuer
        }

        if (_isSynchronizing) {
          // Timeout - la synchronisation n'a pas répondu
          print("⚠️ Timeout de synchronisation (5s)");
          _isSynchronizing = false;
          _connectionStatus = "Erreur de synchronisation";
          notifyListeners();

          // Déconnecter et retourner
          await disconnectBluetooth();
          return; // ✅ SORTIR - ne pas continuer
        }

        print("✅ Synchronisation reçue et traitée");

        // 5. Attendre un peu pour stabiliser
        await Future.delayed(Duration(milliseconds: 200));

        // ✅ VÉRIFIER SI TOUJOURS CONNECTÉ
        if (!_bluetoothService.isConnected) {
          print("⚠️ Déconnecté après synchronisation");
          _isSynchronizing = false;
          _isConnecting = false;
          notifyListeners();
          return; // ✅ SORTIR
        }

        // 6. Envoyer la remise à l'heure
        _sendTimeSet();
        print("🕐 Remise à l'heure envoyée");

        // 7. Marquer comme connecté
        _connectionStatus = "Connecté";
        _isConnecting = false;
        notifyListeners();

        print("✅✅✅ Connexion et synchronisation terminées avec succès");
      } catch (e) {
        print("❌ Erreur lors de la séquence de connexion: $e");
        _isConnecting = false;
        _isSynchronizing = false;
        _connectionStatus = "Erreur";
        notifyListeners();

        // Déconnecter en cas d'erreur
        try {
          await disconnectBluetooth();
        } catch (disconnectError) {
          print("❌ Erreur lors de la déconnexion: $disconnectError");
        }
      }
    };

    _bluetoothService.onDisconnected = () {
      print("📴 Callback onDisconnected appelé");
      _connectionStatus = "Déconnecté";
      _isConnecting = false;
      _isSynchronizing = false; // ✅ AJOUTÉ
      notifyListeners();
    };

    _bluetoothService.onError = (error) {
      print("❌ Erreur Bluetooth: $error");
      _connectionStatus = "Erreur: $error";
      _isConnecting = false;
      _isSynchronizing = false; // ✅ AJOUTÉ
      notifyListeners();
    };

    _bluetoothService.onDataReceived = (data) {
      print("<<< Données brutes reçues: $data");

      _lastReceivedData = data;
      _receivedDataHistory +=
          "${DateTime.now().toString().substring(11, 19)} - $data\n";

      // Analyser le message reçu
      _parseReceivedMessage(data);

      notifyListeners();
    };
  }

  /// Demande la synchronisation des données depuis l'Arduino
  void _requestSynchronization() {
    final message = BluetoothMessageBuilder.buildSyncRequestMessage();
    _bluetoothService.sendMessage(message);
    print(">>> Demande de synchronisation envoyée: $message");
  }

  /// Connexion au dispositif Bluetooth
  Future<void> connectBluetooth() async {
    print("🚀 Démarrage de la connexion Bluetooth");

    _isConnecting = true;
    _isSynchronizing = false;
    _connectionStatus = "Connexion en cours...";
    notifyListeners();

    // ✅ Le service va retenter indéfiniment jusqu'au succès
    bool success = await _bluetoothService.connectToDevice();

    // Si on arrive ici avec success=false, c'est une erreur critique
    if (!success) {
      print("❌ Échec critique de la connexion");
      _isConnecting = false;
      _isSynchronizing = false;
      _connectionStatus = "Échec de connexion";
      notifyListeners();
    }
    // Si success=true, le callback onConnected prendra le relais
  }

  /// Déconnexion du dispositif Bluetooth
  Future<void> disconnectBluetooth() async {
    print("📴 Demande de déconnexion");
    await _bluetoothService.disconnect();
    _connectionStatus = "Déconnecté";
    _isConnecting = false;
    _isSynchronizing = false;
    notifyListeners();
  }

  /// Envoi de la remise à l'heure (appelé automatiquement lors de la connexion)
  void _sendTimeSet() {
    final message = BluetoothMessageBuilder.buildTimeSetMessage(DateTime.now());
    _bluetoothService.sendMessage(message);
  }

  /// Envoi de la commande de gestion des horloges
  void _sendClockControl() {
    if (!_bluetoothService.isConnected) return;

    final message = BluetoothMessageBuilder.buildClockControlMessage(
      clock1Running: _clock1Running,
      clock2Running: _clock2Running,
      secondHand1Running: _secondHand1Running,
      secondHand2Running: _secondHand2Running,
    );
    _bluetoothService.sendMessage(message);
  }

  /// Envoi de la commande de l'interrupteur général
  void _sendMainSwitch() {
    if (!_bluetoothService.isConnected) return;

    final message = BluetoothMessageBuilder.buildMainSwitchMessage(
      state: _mainSwitchOn,
    );
    _bluetoothService.sendMessage(message);
  }

  /// Envoi de la commande de gestion des néons
  void _sendNeonControl() {
    if (!_bluetoothService.isConnected) return;

    final message = BluetoothMessageBuilder.buildNeonControlMessage(
      mode: _neonMode,
      neon1Running: _neon1Running,
      neon2Running: _neon2Running,
    );
    _bluetoothService.sendMessage(message);
  }

  /// Envoi de la programmation des néons (à appeler manuellement)
  void sendNeonSchedule() {
    if (!_bluetoothService.isConnected) return;

    final message = BluetoothMessageBuilder.buildNeonScheduleMessage(
      _neonSchedule,
    );
    _bluetoothService.sendMessage(message);
  }

  // Setters
  void setMainSwitchOn(bool value) {
    _mainSwitchOn = value;

    // Si on désactive le switch général, tout désactiver
    if (!value) {
      // Désactiver les horloges
      _clock1Running = false;
      _clock2Running = false;
      _secondHand1Running = false;
      _secondHand2Running = false;

      // Désactiver les néons
      _neonMode = 0; // OFF
      _neon1Running = false;
      _neon2Running = false;

      // Envoyer les commandes Bluetooth
      _sendMainSwitch(); // Envoyer l'état général OFF
      _sendClockControl(); // Envoyer horloges OFF
      _sendNeonControl(); // Envoyer néons OFF
    } else {
      // Si on active le switch général, juste envoyer l'état
      _sendMainSwitch();
    }

    notifyListeners();
  }

  // Setters - Clocks
  void setClock1Running(bool value) {
    // Bloquer si le switch général est désactivé
    if (!_mainSwitchOn) return;

    _clock1Running = value;
    if (!value) {
      _secondHand1Running = false;
    }
    _sendClockControl();
    notifyListeners();
  }

  void setClock2Running(bool value) {
    // Bloquer si le switch général est désactivé
    if (!_mainSwitchOn) return;

    _clock2Running = value;
    if (!value) {
      _secondHand2Running = false;
    }
    _sendClockControl();
    notifyListeners();
  }

  void setSecondHand1Running(bool value) {
    // Bloquer si le switch général est désactivé
    if (!_mainSwitchOn) return;

    _secondHand1Running = value;
    _sendClockControl();
    notifyListeners();
  }

  void setSecondHand2Running(bool value) {
    // Bloquer si le switch général est désactivé
    if (!_mainSwitchOn) return;

    _secondHand2Running = value;
    _sendClockControl();
    notifyListeners();
  }

  // Setters - Neons
  void setNeonMode(int value) {
    // Bloquer si le switch général est désactivé
    if (!_mainSwitchOn) return;

    if (value >= 0 && value <= 2) {
      _neonMode = value;
      _sendNeonControl();
      notifyListeners();
    }
  }

  void setNeon1Running(bool value) {
    // Bloquer si le switch général est désactivé
    if (!_mainSwitchOn) return;

    _neon1Running = value;
    _sendNeonControl();
    notifyListeners();
  }

  void setNeon2Running(bool value) {
    // Bloquer si le switch général est désactivé
    if (!_mainSwitchOn) return;

    _neon2Running = value;
    _sendNeonControl();
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

  // Effacer l'historique des données reçues
  void clearReceivedDataHistory() {
    _receivedDataHistory = "";
    notifyListeners();
  }

  /// Analyse les messages Bluetooth reçus (peut contenir plusieurs messages collés)
  void _parseReceivedMessage(List<int> data) {
    // Si le message contient plusieurs fonctions collées, les séparer
    int offset = 0;

    while (offset < data.length) {
      // Vérifier qu'il reste au moins 2 bytes (ID + argCount)
      if (offset + 1 >= data.length) break;

      //int functionId = data[offset];
      int argCount = data[offset + 1];

      // Vérifier qu'on a assez de bytes pour ce message
      int messageLength = 2 + argCount;
      if (offset + messageLength > data.length) {
        print("Message incomplet à l'offset $offset");
        break;
      }

      // Extraire le message individuel
      List<int> singleMessage = data.sublist(offset, offset + messageLength);

      // Traiter le message
      _parseSingleMessage(singleMessage);

      // Passer au message suivant
      offset += messageLength;
    }
  }

  /// Analyse un seul message
  void _parseSingleMessage(List<int> data) {
    var parsed = BluetoothMessageParser.parseMessage(data);

    if (parsed == null) return;

    int functionId = parsed['functionId'];

    // Traiter selon l'ID de fonction
    switch (functionId) {
      case 25: // Heure des horloges
        var clockData = BluetoothMessageParser.parseClockTimeMessage(data);
        if (clockData != null) {
          _clock1Hours = clockData['clock1Hours'];
          _clock1Minutes = clockData['clock1Minutes'];
          _clock2Hours = clockData['clock2Hours'];
          _clock2Minutes = clockData['clock2Minutes'];
          print("Heure horloge 1: ${clock1TimeString}");
          print("Heure horloge 2: ${clock2TimeString}");
        }
        break;

      case 15: // Température
        var temp = BluetoothMessageParser.parseTemperatureMessage(data);
        if (temp != null) {
          _temperature = temp;
          print("Température: ${_temperature.toStringAsFixed(1)}°C");
        }
        break;

      case 100: // Synchronisation complète depuis Arduino
        _parseSyncMessage(data);
        break;

      // Ajouter d'autres cas ici pour les futures fonctions
      default:
        print("Fonction ID $functionId non gérée");
    }
  }

  /// Parse le message de synchronisation (fonction ID 100)
  void _parseSyncMessage(List<int> data) {
    var syncData = BluetoothMessageParser.parseSyncMessage(data);

    if (syncData == null) {
      print("❌ Erreur lors du parsing du message de synchronisation");
      return;
    }

    print("=== SYNCHRONISATION REÇUE ===");

    // Mettre à jour toutes les variables locales sans envoyer de commandes
    _mainSwitchOn = syncData['general'];
    _clock1Running = syncData['clock1Running'];
    _clock2Running = syncData['clock2Running'];
    _secondHand1Running = syncData['secondHand1Running'];
    _secondHand2Running = syncData['secondHand2Running'];
    _neonMode = syncData['neonMode'];
    _neon1Running = syncData['neon1Running'];
    _neon2Running = syncData['neon2Running'];

    // ✅ NOUVEAU : Mettre à jour les heures des horloges
    _clock1Hours = syncData['clock1Hours'];
    _clock1Minutes = syncData['clock1Minutes'];
    _clock2Hours = syncData['clock2Hours'];
    _clock2Minutes = syncData['clock2Minutes'];

    // Mettre à jour la programmation
    _neonSchedule = List<List<int>>.from(
      syncData['neonSchedule'].map((item) => List<int>.from(item)),
    );

    print("État après synchronisation :");
    print("  - Interrupteur général: $_mainSwitchOn");
    print("  - Horloges: H1=$_clock1Running H2=$_clock2Running");
    print("  - Trotteuses: T1=$_secondHand1Running T2=$_secondHand2Running");
    print("  - Heures: H1=${clock1TimeString} H2=${clock2TimeString}");
    print("  - Néons mode: $_neonMode");
    print("  - Néons actifs: N1=$_neon1Running N2=$_neon2Running");
    print("  - Programmation: ${_neonSchedule.length} plages");
    print("==============================");

    // ✅ Marquer la synchronisation comme terminée
    _isSynchronizing = false;

    notifyListeners();
  }
}
