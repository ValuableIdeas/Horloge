import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:horloge/widgets/interrupteur_general.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme.dart';
import 'widgets/horloges_bloc.dart';
import 'widgets/neons_bloc.dart';
import 'widgets/leds_bloc.dart';
import 'widgets/temperature_display.dart';
import 'screens/connection_screen.dart';
import 'screens/advanced_zone.dart';
import 'screens/info_screen.dart';
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

  // ✅ NOUVEAU : Afficher le dialog de code PIN
  Future<void> _showPinDialog(BuildContext context) async {
    final TextEditingController pinController = TextEditingController();
    final primaryColor = Theme.of(context).primaryColor;
    final FocusNode focusNode = FocusNode();

    // Auto-focus après un court délai pour faire apparaître le clavier
    Future.delayed(Duration(milliseconds: 100), () {
      focusNode.requestFocus();
    });

    return showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Code d\'accès', style: TextStyle(color: primaryColor)),
          content: TextField(
            controller: pinController,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            maxLength: 4,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Entrez le code PIN',
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryColor, width: 2),
              ),
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          actions: [
            TextButton(
              onPressed: () {
                focusNode.dispose();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (pinController.text == '1830') {
                  focusNode.dispose();
                  Navigator.of(dialogContext).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdvancedZone(),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Code incorrect'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  focusNode.dispose();
                  Navigator.of(dialogContext).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );
  }

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
                  const LedsBloc(),
                  SizedBox(height: 10),
                  const TemperatureDisplay(),
                  SizedBox(height: 10),
                  // ✅ SUPPRIMÉ : BluetoothDataDisplay (déplacé vers Zone Avancée)
                  // const BluetoothDataDisplay(),

                  // ✅ NOUVEAU : Boutons Zone Avancée et Info
                  if (provider.isConnected)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _showPinDialog(context),
                              icon: Icon(Icons.lock_outline),
                              label: const Text('Zone Avancée'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Theme.of(context).primaryColor,
                                side: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 15),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const InfoScreen(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                              side: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2,
                              ),
                              padding: EdgeInsets.all(15),
                              minimumSize: Size(60, 50),
                            ),
                            child: Icon(Icons.info_outline, size: 24),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 20),
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
