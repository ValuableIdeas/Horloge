import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

  // LED variables (for Bluetooth function ID 4)
  int _ledState = 0; // 0: off, 1: on, 2: suivi néons
  int _ledFunction = 1; // 1: uni, 2: clignotant, 3: fondu, 4: arc-en-ciel
  int _ledColorR = 255;
  int _ledColorG = 0;
  int _ledColorB = 0;
  int _ledFrequency = 128; // Pour la fonction clignotant (0-255)

  // Variables for time setting (for Bluetooth function ID 50)
  DateTime _clockDateTime = DateTime.now();

  // État de connexion
  bool _isConnecting = false;
  bool _isSynchronizing = false;
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
  bool get isSynchronizing => _isSynchronizing;
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

  // Getters - LEDs
  int get ledState => _ledState;
  int get ledFunction => _ledFunction;
  int get ledColorR => _ledColorR;
  int get ledColorG => _ledColorG;
  int get ledColorB => _ledColorB;
  int get ledFrequency => _ledFrequency;

  // Getters - Date/Time
  DateTime get clockDateTime => _clockDateTime;

  AppProvider() {
    _setupBluetoothCallbacks();
  }

  /// Configuration des callbacks Bluetooth
  void _setupBluetoothCallbacks() {
    _bluetoothService.onConnected = () async {
      print("🔗 Connexion Bluetooth établie - Démarrage de la séquence");

      _isSynchronizing = true;
      _connectionStatus = "Synchronisation...";
      notifyListeners();

      try {
        await _bluetoothService.startListening();
        print("👂 Écoute activée");

        await Future.delayed(Duration(milliseconds: 1000));

        _requestSynchronization();
        print("📤 Demande de synchronisation envoyée");

        int attempts = 0;
        while (_isSynchronizing && attempts < 50) {
          await Future.delayed(Duration(milliseconds: 100));
          attempts++;
        }

        if (!_bluetoothService.isConnected) {
          print("⚠️ Déconnecté pendant la synchronisation");
          _isSynchronizing = false;
          _isConnecting = false;
          notifyListeners();
          return;
        }

        if (_isSynchronizing) {
          print("⚠️ Timeout de synchronisation (5s)");
          _isSynchronizing = false;
          _connectionStatus = "Erreur de synchronisation";
          notifyListeners();

          await disconnectBluetooth();
          return;
        }

        print("✅ Synchronisation reçue et traitée");

        await Future.delayed(Duration(milliseconds: 200));

        if (!_bluetoothService.isConnected) {
          print("⚠️ Déconnecté après synchronisation");
          _isSynchronizing = false;
          _isConnecting = false;
          notifyListeners();
          return;
        }

        _sendTimeSet();
        print("🕐 Remise à l'heure envoyée");

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

        try {
          await disconnectBluetooth();
        } catch (disconnectError) {
          print("❌ Erreur lors de la déconnexion: $disconnectError");
        }
      }
    };

    _bluetoothService.onDisconnected = () {
      print("🔴 Callback onDisconnected appelé - Fermeture de l'app");
      _connectionStatus = "Déconnecté";
      _isConnecting = false;
      _isSynchronizing = false;
      notifyListeners();

      // ✅ MODIFICATION : Fermer l'application automatiquement
      SystemNavigator.pop();
    };

    _bluetoothService.onError = (error) {
      print("❌ Erreur Bluetooth: $error");
      _connectionStatus = "Erreur: $error";
      _isConnecting = false;
      _isSynchronizing = false;
      notifyListeners();
    };

    _bluetoothService.onDataReceived = (data) {
      print("<<< Données brutes reçues: $data");

      _lastReceivedData = data;
      _receivedDataHistory +=
          "${DateTime.now().toString().substring(11, 19)} - $data\n";

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

    bool success = await _bluetoothService.connectToDevice();

    if (!success) {
      print("❌ Échec critique de la connexion");
      _isConnecting = false;
      _isSynchronizing = false;
      _connectionStatus = "Échec de connexion";
      notifyListeners();
    }
  }

  /// Déconnexion du dispositif Bluetooth
  Future<void> disconnectBluetooth() async {
    print("🔴 Demande de déconnexion");
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

  /// Ajouter une minute à une horloge (fonction ID 51)
  void addMinuteToClock(int clockIndex) {
    if (!_bluetoothService.isConnected) return;

    final message = BluetoothMessageBuilder.buildAddMinuteMessage(clockIndex);
    _bluetoothService.sendMessage(message);
    print(">>> Ajout d'une minute à l'horloge $clockIndex");
  }

  /// Retirer une minute à une horloge (fonction ID 52)
  void removeMinuteFromClock(int clockIndex) {
    if (!_bluetoothService.isConnected) return;

    final message = BluetoothMessageBuilder.buildRemoveMinuteMessage(
      clockIndex,
    );
    _bluetoothService.sendMessage(message);
    print(">>> Retrait d'une minute à l'horloge $clockIndex");
  }

  /// Envoi de la commande de gestion des LEDs (fonction ID 4)
  void _sendLedControl() {
    if (!_bluetoothService.isConnected) return;

    final message = BluetoothMessageBuilder.buildLedControlMessage(
      state: _ledState,
      functionId: _ledFunction,
      r: _ledColorR,
      g: _ledColorG,
      b: _ledColorB,
      parameter: _ledFrequency,
    );
    _bluetoothService.sendMessage(message);
    print(">>> Commande LED envoyée: état=$_ledState, fonction=$_ledFunction");
  }

  // Setters - LEDs
  void setLedState(int value) {
    if (value >= 0 && value <= 2) {
      _ledState = value;
      _sendLedControl();
      notifyListeners();
    }
  }

  void setLedFunction(int value) {
    if (value >= 1 && value <= 4) {
      _ledFunction = value;
      _sendLedControl();
      notifyListeners();
    }
  }

  void setLedColor(int r, int g, int b) {
    _ledColorR = r;
    _ledColorG = g;
    _ledColorB = b;
    _sendLedControl();
    notifyListeners();
  }

  void setLedFrequency(int value) {
    if (value >= 0 && value <= 255) {
      _ledFrequency = value;
      _sendLedControl();
      notifyListeners();
    }
  }

  // Setters
  void setMainSwitchOn(bool value) {
    _mainSwitchOn = value;

    if (!value) {
      _clock1Running = false;
      _clock2Running = false;
      _secondHand1Running = false;
      _secondHand2Running = false;

      _neonMode = 0;
      _neon1Running = false;
      _neon2Running = false;

      _sendMainSwitch();
      _sendClockControl();
      _sendNeonControl();
    } else {
      _sendMainSwitch();
    }

    notifyListeners();
  }

  // Setters - Clocks
  void setClock1Running(bool value) {
    if (!_mainSwitchOn) return;

    _clock1Running = value;
    if (!value) {
      _secondHand1Running = false;
    }
    _sendClockControl();
    notifyListeners();
  }

  void setClock2Running(bool value) {
    if (!_mainSwitchOn) return;

    _clock2Running = value;
    if (!value) {
      _secondHand2Running = false;
    }
    _sendClockControl();
    notifyListeners();
  }

  void setSecondHand1Running(bool value) {
    if (!_mainSwitchOn) return;

    _secondHand1Running = value;
    _sendClockControl();
    notifyListeners();
  }

  void setSecondHand2Running(bool value) {
    if (!_mainSwitchOn) return;

    _secondHand2Running = value;
    _sendClockControl();
    notifyListeners();
  }

  // Setters - Neons
  void setNeonMode(int value) {
    if (!_mainSwitchOn) return;

    if (value >= 0 && value <= 2) {
      _neonMode = value;
      _sendNeonControl();
      notifyListeners();
    }
  }

  void setNeon1Running(bool value) {
    if (!_mainSwitchOn) return;

    _neon1Running = value;
    _sendNeonControl();
    notifyListeners();
  }

  void setNeon2Running(bool value) {
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
    int offset = 0;

    while (offset < data.length) {
      if (offset + 1 >= data.length) break;

      int argCount = data[offset + 1];

      int messageLength = 2 + argCount;
      if (offset + messageLength > data.length) {
        print("Message incomplet à l'offset $offset");
        break;
      }

      List<int> singleMessage = data.sublist(offset, offset + messageLength);

      _parseSingleMessage(singleMessage);

      offset += messageLength;
    }
  }

  /// Analyse un seul message
  void _parseSingleMessage(List<int> data) {
    var parsed = BluetoothMessageParser.parseMessage(data);

    if (parsed == null) return;

    int functionId = parsed['functionId'];

    switch (functionId) {
      case 25:
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

      case 15:
        var temp = BluetoothMessageParser.parseTemperatureMessage(data);
        if (temp != null) {
          _temperature = temp;
          print("Température: ${_temperature.toStringAsFixed(1)}°C");
        }
        break;

      case 100:
        _parseSyncMessage(data);
        break;

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

    _mainSwitchOn = syncData['general'];
    _clock1Running = syncData['clock1Running'];
    _clock2Running = syncData['clock2Running'];
    _secondHand1Running = syncData['secondHand1Running'];
    _secondHand2Running = syncData['secondHand2Running'];
    _neonMode = syncData['neonMode'];
    _neon1Running = syncData['neon1Running'];
    _neon2Running = syncData['neon2Running'];

    _clock1Hours = syncData['clock1Hours'];
    _clock1Minutes = syncData['clock1Minutes'];
    _clock2Hours = syncData['clock2Hours'];
    _clock2Minutes = syncData['clock2Minutes'];

    _neonSchedule = List<List<int>>.from(
      syncData['neonSchedule'].map((item) => List<int>.from(item)),
    );

    _ledState = syncData['ledState'];
    _ledFunction = syncData['ledFunction'];
    _ledColorR = syncData['ledR'];
    _ledColorG = syncData['ledG'];
    _ledColorB = syncData['ledB'];
    _ledFrequency = syncData['ledFrequency'];

    print("État après synchronisation :");
    print("  - Interrupteur général: $_mainSwitchOn");
    print("  - Horloges: H1=$_clock1Running H2=$_clock2Running");
    print("  - Trotteuses: T1=$_secondHand1Running T2=$_secondHand2Running");
    print("  - Heures: H1=${clock1TimeString} H2=${clock2TimeString}");
    print("  - Néons mode: $_neonMode");
    print("  - Néons actifs: N1=$_neon1Running N2=$_neon2Running");
    print("  - Programmation: ${_neonSchedule.length} plages");
    print(
      "  - LEDs: état=$_ledState, fonction=$_ledFunction, RGB=($_ledColorR,$_ledColorG,$_ledColorB), fréquence=$_ledFrequency",
    );
    print("==============================");

    _isSynchronizing = false;

    notifyListeners();
  }
}
