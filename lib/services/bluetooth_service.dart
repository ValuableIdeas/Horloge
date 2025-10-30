import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../utils/bluetooth.dart' as bt;

/// Service centralisant la gestion Bluetooth
class BluetoothService {
  BluetoothDevice? _device;
  bool _isConnected = false;

  // Callbacks
  Function()? onConnected;
  Function()? onDisconnected;
  Function(String)? onError;

  bool get isConnected => _isConnected;
  BluetoothDevice? get device => _device;

  /// Recherche et connexion au dispositif - EXACTEMENT comme dans le code qui marche
  Future<bool> connectToDevice() async {
    try {
      // Get device
      _device = await bt.getDevice();

      if (_device == null) {
        onError?.call("Appareil non trouvé");
        return false;
      }

      // Connect
      await bt.connect(_device);

      // Add disconnection listener
      bt.addDisconnectListener(_device, () {
        _isConnected = false;
        _device = null;
        if (onDisconnected != null) {
          onDisconnected!();
        }
      });

      // Marquer comme connecté
      _isConnected = true;

      // Callback de succès
      if (onConnected != null) {
        onConnected!();
      }

      return true;
    } catch (e) {
      print("Erreur de connexion: $e");
      _isConnected = false;
      _device = null;
      onError?.call("Erreur de connexion");
      return false;
    }
  }

  /// Déconnexion du dispositif
  Future<void> disconnect() async {
    if (_device != null) {
      await bt.disconnect(_device);
      _isConnected = false;
      _device = null;
    }
  }

  /// Envoi d'un message Bluetooth
  Future<void> sendMessage(List<int> message) async {
    if (_device == null || !_isConnected) {
      print("Erreur: Appareil non connecté");
      return;
    }

    await bt.send(_device, message);
    print("Message envoyé: $message");
  }
}
