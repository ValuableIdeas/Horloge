import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

StreamSubscription<BluetoothConnectionState>? disconnectListener;

Future<BluetoothDevice?> getDevice() async {
  final completer = Completer<BluetoothDevice?>();

  // Listens for scan result
  var subscription = FlutterBluePlus.onScanResults.listen((results) {
    if (results.isNotEmpty) {
      ScanResult r = results.last; // the most recently found device
      print('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
      completer.complete(r.device);
      FlutterBluePlus.stopScan();
    }
  });

  // Cancels subscription when completed
  FlutterBluePlus.cancelWhenScanComplete(subscription);

  // Await bluetooth being turned on
  await FlutterBluePlus.adapterState
      .where((val) => val == BluetoothAdapterState.on)
      .first;

  // Scan
  await FlutterBluePlus.startScan(
    withServices: [Guid("180D")], // match any of the specified services
    withNames: ["HORLOGE"], // *or* any of the specified names
    timeout: Duration(seconds: 15),
  );

  // Await scanning to stop
  await FlutterBluePlus.isScanning.where((val) => val == false).first;
  if (!completer.isCompleted) {
    completer.complete(null);
  }

  return completer.future;
}

Future<void> connect(BluetoothDevice? device) async {
  // Check if device exists
  if (device == null) {
    print("Device not found");
    return;
  }
  // Connect
  await device.connect(license: License.free, timeout: Duration(seconds: 15));

  // Wait for connection
  await device.connectionState
      .where((val) => val == BluetoothConnectionState.connected)
      .first;
}

Future<void> disconnect(BluetoothDevice? device) async {
  // Check if device exists
  if (device == null) {
    print("Device not found");
    return;
  }
  // Connect
  await device.disconnect();
}

void addDisconnectListener(BluetoothDevice? device, Function listener) {
  // Check if device exists
  if (device == null) {
    print("Device not found");
    return;
  }
  // Check if device is disconnected
  if (!device.isConnected) {
    print("Device disconnected");
    return;
  }
  // Remove potentially existing listener
  StreamSubscription<BluetoothConnectionState>? disconnectListen =
      disconnectListener;
  if (disconnectListen != null) {
    disconnectListen.cancel();
  }
  // Listen for disconnection
  disconnectListener = device.connectionState.listen((
    BluetoothConnectionState state,
  ) async {
    if (state == BluetoothConnectionState.disconnected) {
      listener();
    }
  });
}

Future<void> recieve(BluetoothDevice? device) async {
  // Check if device exists
  if (device == null) {
    print("Device not found");
    return;
  }
  // Check if device is disconnected
  if (!device.isConnected) {
    print("Device disconnected");
    return;
  }
  // Get services
  List<BluetoothService> services = await device.discoverServices();
  services.forEach((service) async {
    // Reads all characteristics
    var characteristics = service.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      if (c.properties.read) {
        List<int> value = await c.read();
        print(value);
      }
    }
  });
}

Future<void> send(BluetoothDevice? device, List<int> message) async {
  // Check if device exists
  if (device == null) {
    print("Device not found");
    return;
  }
  if (!device.isConnected) {
    print("Device disconnected");
    return;
  }
  // Get services
  List<BluetoothService> services = await device.discoverServices();
  services.forEach((service) async {
    // Reads all characteristics
    var characteristics = service.characteristics;
    for (BluetoothCharacteristic c in characteristics) {
      if (c.properties.write) {
        await c.write(message);
        return;
      }
    }
  });
}
