import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:horloge/widgets/interrupteur_general.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme.dart';
import 'widgets/horloges_bloc.dart';
import 'widgets/neons_bloc.dart';
import 'widgets/bluetooth_data_display.dart';
import 'widgets/temperature_display.dart';
import 'screens/connection_screen.dart';
import 'widgets/loading_overlay.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AppProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: AppTheme.theme, home: const HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: Stack(
            children: [
              // Contenu principal
              ListView(
                padding: EdgeInsets.all(20.0),
                children: [
                  Center(
                    child: Text(
                      "Horloge SNCB",
                      style: GoogleFonts.alfaSlabOne(
                        color: Theme.of(context).primaryColor,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  const InterrupteurGeneralBloc(),
                  SizedBox(height: 10),
                  const HorlogesBloc(),
                  SizedBox(height: 10),
                  const NeonsBloc(),
                  SizedBox(height: 10),
                  const TemperatureDisplay(),
                  SizedBox(height: 10),
                  const BluetoothDataDisplay(),
                  SizedBox(height: 30),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.grass),
                        Text("Projet mené à bien par Basile et Quentin "),
                      ],
                    ),
                  ),
                ],
              ),

              // Overlay de chargement (synchronisation)
              const LoadingOverlay(),

              // Écran de connexion par-dessus tout
              const ConnectionScreen(),
            ],
          ),
        );
      },
    );
  }
}
