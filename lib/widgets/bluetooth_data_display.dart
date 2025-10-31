import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class BluetoothDataDisplay extends StatelessWidget {
  const BluetoothDataDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        // N'afficher que si connecté
        if (!provider.isConnected) {
          return SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: [
              // Titre
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DONNÉES REÇUES',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.clear, color: Colors.white),
                    onPressed: () => provider.clearReceivedDataHistory(),
                    tooltip: 'Effacer l\'historique',
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Dernières données reçues
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dernière réception:',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      provider.lastReceivedData.isEmpty
                          ? 'Aucune donnée reçue'
                          : provider.lastReceivedData.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Courier',
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 15),

                    // Historique
                    Text(
                      'Historique:',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                      constraints: BoxConstraints(maxHeight: 150),
                      child: SingleChildScrollView(
                        reverse:
                            true, // Pour scroller automatiquement vers le bas
                        child: Text(
                          provider.receivedDataHistory.isEmpty
                              ? 'Aucun historique'
                              : provider.receivedDataHistory,
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Courier',
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
