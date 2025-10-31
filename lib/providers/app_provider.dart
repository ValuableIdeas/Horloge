import 'package:flutter/foundation.dart';
import '../services/bluetooth_service.dart';
import '../services/bluetooth_message_builder.dart';

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
  String _connectionStatus = "Déconnecté";

  // Données reçues
  List<int> _lastReceivedData = [];
  String _receivedDataHistory = "";

  // Getters
  bool get mainSwitchOn => _mainSwitchOn;
  BluetoothService get bluetoothService => _bluetoothService;
  bool get isConnected => _bluetoothService.isConnected;
  bool get isConnecting => _isConnecting;
  String get connectionStatus => _connectionStatus;
  List<int> get lastReceivedData => _lastReceivedData;
  String get receivedDataHistory => _receivedDataHistory;

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
    _bluetoothService.onConnected = () {
      _connectionStatus = "Connecté";
      notifyListeners();
      // Envoi de la remise à l'heure lors de la connexion
      _sendTimeSet();
      // Démarrer l'écoute des données
      _bluetoothService.startListening();
    };

    _bluetoothService.onDisconnected = () {
      _connectionStatus = "Déconnecté";
      notifyListeners();
    };

    _bluetoothService.onError = (error) {
      _connectionStatus = "Erreur: $error";
      notifyListeners();
    };

    _bluetoothService.onDataReceived = (data) {
      _lastReceivedData = data;
      _receivedDataHistory +=
          "${DateTime.now().toString().substring(11, 19)} - $data\n";
      notifyListeners();
    };
  }

  /// Connexion au dispositif Bluetooth
  Future<void> connectBluetooth() async {
    _isConnecting = true;
    _connectionStatus = "Connexion en cours...";
    notifyListeners();

    bool success = await _bluetoothService.connectToDevice();

    _isConnecting = false;
    if (!success) {
      _connectionStatus = "Échec de connexion";
    }
    notifyListeners();
  }

  /// Déconnexion du dispositif Bluetooth
  Future<void> disconnectBluetooth() async {
    await _bluetoothService.disconnect();
    _connectionStatus = "Déconnecté";
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
    notifyListeners();
  }

  // Setters - Clocks
  void setClock1Running(bool value) {
    _clock1Running = value;
    if (!value) {
      _secondHand1Running = false;
    }
    _sendClockControl();
    notifyListeners();
  }

  void setClock2Running(bool value) {
    _clock2Running = value;
    if (!value) {
      _secondHand2Running = false;
    }
    _sendClockControl();
    notifyListeners();
  }

  void setSecondHand1Running(bool value) {
    _secondHand1Running = value;
    _sendClockControl();
    notifyListeners();
  }

  void setSecondHand2Running(bool value) {
    _secondHand2Running = value;
    _sendClockControl();
    notifyListeners();
  }

  // Setters - Neons
  void setNeonMode(int value) {
    if (value >= 0 && value <= 2) {
      _neonMode = value;
      _sendNeonControl();
      notifyListeners();
    }
  }

  void setNeon1Running(bool value) {
    _neon1Running = value;
    _sendNeonControl();
    notifyListeners();
  }

  void setNeon2Running(bool value) {
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
}
