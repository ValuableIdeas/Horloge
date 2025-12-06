import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../screens/info_screen.dart';

class ConnectionScreen extends StatelessWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        // Si connecté ET pas en train de synchroniser, ne rien afficher
        if (provider.isConnected && !provider.isSynchronizing) {
          return const SizedBox.shrink();
        }

        // Si en synchronisation, ne rien afficher (LoadingOverlay s'en charge)
        if (provider.isSynchronizing) {
          return const SizedBox.shrink();
        }

        // Sinon, afficher l'écran de connexion
        return Stack(
          children: [
            // Écran de connexion principal
            Container(
              color: Theme.of(context).primaryColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Icône
                    Icon(
                      provider.isConnecting
                          ? Icons.bluetooth_searching
                          : Icons.bluetooth_disabled,
                      size: 100,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 30),

                    // Titre
                    Text(
                      'Horloge SNCB',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Statut de connexion
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        provider.connectionStatus,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Bouton de connexion ou indicateur de chargement
                    if (provider.isConnecting)
                      Column(
                        children: [
                          CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Connexion en cours...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Validez les pop-ups Android\nLa connexion peut prendre jusqu\'à 30s',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () async {
                          await provider.connectBluetooth();

                          // Attendre un peu pour voir si la connexion a réussi
                          await Future.delayed(Duration(milliseconds: 500));

                          if (!provider.isConnected && !provider.isConnecting) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(provider.connectionStatus),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.bluetooth, size: 28),
                        label: Text(
                          'SE CONNECTER',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(context).primaryColor,
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 20,
              right: 20,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const InfoScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white, width: 2),
                  padding: EdgeInsets.all(15),
                  minimumSize: Size(60, 60),
                  shape: CircleBorder(),
                ),
                child: Icon(Icons.info_outline, size: 28),
              ),
            ),
          ],
        );
      },
    );
  }
}
