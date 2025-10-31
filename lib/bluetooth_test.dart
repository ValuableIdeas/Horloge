import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:horloge/bluetooth.dart';

void main() {
  runApp(const MyApp());
}

//
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String data = "Not connected";
  BluetoothDevice? device;

  Future<void> connection() async {
    // Get device
    device = await getDevice();
    // Connect
    await connect(device);
    // Add disconnection listener
    addDisconnectListener(device, onDisconnect);

    setState(() {
      data = "Connected";
    });
  }

  Future<void> disconnection() async {
    // Connect
    await disconnect(device);
  }

  void onDisconnect() {
    setState(() {
      data = "Disconnected";
    });
  }

  Future<void> get() async {
    // Recieve
    await addRecieveListener(device, ((value) {
      print(value);
    }));
  }

  Future<void> set1() async {
    // Send
    //await send(device, utf8.encode("patate"));
    await send(device, new List.from([1, 3, 1, 1, 1]));
  }

  Future<void> set2() async {
    // Send
    //await send(device, utf8.encode("patate"));
    await send(device, new List.from([1, 3, 1, 0, 0]));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Device state:'),
            Text(data, style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: connection,
            tooltip: 'Connect',
            heroTag: 'connectBtn', // 👈 needed if you have multiple FABs
            child: const Icon(Icons.bluetooth),
          ),
          const SizedBox(width: 12), // spacing between buttons
          FloatingActionButton(
            onPressed: disconnection,
            tooltip: 'Disconnect',
            heroTag: 'disconnectBtn',
            child: const Icon(Icons.bluetooth_disabled),
          ),
          const SizedBox(width: 12), // spacing between buttons
          FloatingActionButton(
            onPressed: set1,
            tooltip: 'Send',
            heroTag: 'setBtn',
            child: const Icon(Icons.light),
          ),
          const SizedBox(width: 12), // spacing between buttons
          FloatingActionButton(
            onPressed: set2,
            tooltip: 'Send',
            heroTag: 'setBtn2',
            child: const Icon(Icons.dark_mode),
          ),
          const SizedBox(width: 12), // spacing between buttons
          FloatingActionButton(
            onPressed: get,
            tooltip: 'Receive',
            heroTag: 'getBtn',
            child: const Icon(Icons.arrow_downward),
          ),
        ],
      ),
    );
  }
}
