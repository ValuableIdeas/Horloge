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
  Function(List<int>)? onDataReceived;

  bool get isConnected => _isConnected;
  BluetoothDevice? get device => _device;

  /// Recherche et connexion au dispositif avec gestion de la double connexion
  Future<bool> connectToDevice() async {
    int globalAttempt = 0;

    while (true) {
      // ✅ Boucle infinie jusqu'au succès
      globalAttempt++;
      print("🔄 Tentative globale #$globalAttempt");

      try {
        print("🔍 Recherche du dispositif Bluetooth...");

        // Get device avec retry infini
        _device = await _getDeviceWithInfiniteRetry();

        if (_device == null) {
          print("❌ Appareil non trouvé après tous les retries");
          // Ne pas retourner false, continuer la boucle
          await Future.delayed(Duration(seconds: 5));
          continue;
        }

        print("✅ Appareil trouvé: ${_device!.remoteId}");

        // Première tentative de connexion
        print("🔗 Tentative de connexion 1/2...");

        try {
          await bt.connect(_device);
        } catch (e) {
          print("⚠️ Erreur lors de la 1ère connexion: $e");
          _device = null;
          await Future.delayed(Duration(seconds: 3));
          continue; // Recommencer depuis le scan
        }

        print("⏳ Attente de stabilisation (3s)...");
        await Future.delayed(Duration(seconds: 3));

        // Vérifier si _device existe toujours
        if (_device == null) {
          print("⚠️ Device est null après l'attente");
          await Future.delayed(Duration(seconds: 2));
          continue; // Recommencer depuis le scan
        }

        // Vérifier si toujours connecté
        bool stillConnected = false;
        try {
          stillConnected = _device!.isConnected;
        } catch (e) {
          print("⚠️ Erreur vérification: $e");
          stillConnected = false;
        }

        if (!stillConnected) {
          print("⚠️ Première connexion perdue (normal)");
          print("🔗 Tentative de connexion 2/2...");

          try {
            await bt.connect(_device);
          } catch (e) {
            print("⚠️ Erreur lors de la 2ème connexion: $e");
            _device = null;
            await Future.delayed(Duration(seconds: 3));
            continue; // Recommencer
          }

          print("⏳ Attente de stabilisation finale (2s)...");
          await Future.delayed(Duration(seconds: 2));
        }

        // Vérification finale
        if (_device == null || !_device!.isConnected) {
          print("⚠️ Connexion échouée, nouvelle tentative...");
          _device = null;
          await Future.delayed(Duration(seconds: 3));
          continue; // Recommencer
        }

        print("✅ Connexion stable établie");

        // Setup disconnection listener
        bt.addDisconnectListener(_device, () {
          print("📴 Déconnexion détectée");
          _isConnected = false;
          _device = null;
          if (onDisconnected != null) {
            onDisconnected!();
          }
        });

        _isConnected = true;

        if (onConnected != null) {
          onConnected!();
        }

        return true; // ✅ SUCCÈS - Sortir de la boucle
      } catch (e) {
        print("❌ Erreur dans la tentative #$globalAttempt: $e");
        _device = null;
        await Future.delayed(Duration(seconds: 3));
        // Continue la boucle
      }
    }
  }

  /// Recherche l'appareil avec retry INFINI
  Future<BluetoothDevice?> _getDeviceWithInfiniteRetry() async {
    int attempt = 0;

    while (attempt < 10) {
      // Max 10 tentatives avant d'abandonner ce cycle
      attempt++;

      print("🔍 Scan tentative #$attempt");
      var device = await bt.getDevice();

      if (device != null) {
        if (attempt > 1) {
          print("✅ Appareil trouvé à la tentative #$attempt");
        }
        return device;
      }

      // Délai progressif : 2s, 3s, 5s, 5s, 5s...
      int delay = attempt == 1 ? 2 : (attempt == 2 ? 3 : 5);
      print("⏳ Nouvelle tentative dans ${delay}s...");
      await Future.delayed(Duration(seconds: delay));
    }

    return null; // Abandon après 10 tentatives
  }

  /// Déconnexion du dispositif avec nettoyage complet
  Future<void> disconnect() async {
    print("📴 Déconnexion manuelle...");

    if (_device != null) {
      try {
        // Déconnecter
        await bt.disconnect(_device);
        print("✅ Déconnexion Bluetooth réussie");
      } catch (e) {
        print("⚠️ Erreur lors de la déconnexion: $e");
      }

      _isConnected = false;

      // Déclencher le callback
      if (onDisconnected != null) {
        onDisconnected!();
      }

      _device = null;
    }

    // Attendre un peu pour que le Bluetooth se stabilise
    await Future.delayed(Duration(milliseconds: 500));

    print("✅ Déconnexion terminée");
  }

  /// Envoi d'un message Bluetooth
  Future<void> sendMessage(List<int> message) async {
    if (_device == null || !_isConnected) {
      print("❌ Erreur: Appareil non connecté");
      return;
    }

    await bt.send(_device, message);
    print("📤 Message envoyé: $message");
  }

  /// Active l'écoute des données reçues
  Future<void> startListening() async {
    if (_device == null || !_isConnected) {
      print("❌ Erreur: Appareil non connecté");
      return;
    }

    try {
      await bt.addRecieveListener(_device, (List<int> data) {
        print("📥 Données reçues: $data");
        if (onDataReceived != null) {
          onDataReceived!(data);
        }
      });
      print("✅ Écoute Bluetooth activée");
    } catch (e) {
      print("❌ Erreur lors de l'activation du listener: $e");
    }
  }
}
