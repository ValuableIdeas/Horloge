import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

StreamSubscription<BluetoothConnectionState>? disconnectListener;
StreamSubscription<List<int>>? receiveListener;

Future<BluetoothDevice?> getDevice() async {
  // Enable bluetoot
  var state = await FlutterBluePlus.adapterState.first;

  // If it's off, prompt to enable
  if (state == BluetoothAdapterState.off) {
    // Ask user to turn it on (Android only)
    await FlutterBluePlus.turnOn();
    // Wait for state to update
    await FlutterBluePlus.adapterState.firstWhere(
      (s) => s == BluetoothAdapterState.on,
    );
  }

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

  await Future.delayed(new Duration(seconds: 3));

  // Connect again (it's kinda bugged)
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

Future<void> addRecieveListener(
  BluetoothDevice? device,
  Function listener,
) async {
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
  final services = await device.discoverServices();
  // Find UART service
  final uartService = services.firstWhere(
    (s) => s.uuid.toString().toLowerCase().contains('ffe0'),
  );
  // Find main characteristic
  final txrxChar = uartService.characteristics.firstWhere(
    (c) => c.uuid.toString().toLowerCase().contains('ffe1'),
  );

  // Enable notifications (to receive data)
  await txrxChar.setNotifyValue(true);

  // Remove potentially existing listener
  StreamSubscription<List<int>>? receiveListen = receiveListener;
  if (receiveListen != null) {
    receiveListen.cancel();
  }
  // Listen for data coming from the module
  receiveListener = txrxChar.onValueReceived.listen(
    listener as void Function(List<int> event)?,
  );
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
