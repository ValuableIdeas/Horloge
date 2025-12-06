import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/bluetooth_data_display.dart';

class AdvancedZone extends StatelessWidget {
  const AdvancedZone({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zone Avancée', style: GoogleFonts.alfaSlabOne()),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: EdgeInsets.all(20.0),
            children: [
              // Message d'avertissement
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 30,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Pour utilisateurs avancés',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Zone de réglage des minutes
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RÉGLAGE MINUTES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        // Horloge 1
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Horloge 1',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        provider.removeMinuteFromClock(0);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Icon(Icons.remove, size: 20),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        provider.addMinuteToClock(0);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Icon(Icons.add, size: 20),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        // Horloge 2
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Horloge 2',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        provider.removeMinuteFromClock(1);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Icon(Icons.remove, size: 20),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        provider.addMinuteToClock(1);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor,
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Icon(Icons.add, size: 20),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'INFORMATIONS SYSTÈME',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(
                            'État connexion',
                            provider.connectionStatus,
                          ),
                          Divider(),
                          _buildInfoRow(
                            'Interrupteur général',
                            provider.mainSwitchOn ? 'ON' : 'OFF',
                          ),
                          Divider(),
                          _buildInfoRow(
                            'Horloge 1',
                            provider.clock1Running ? 'Marche' : 'Arrêt',
                          ),
                          Divider(),
                          _buildInfoRow(
                            'Horloge 2',
                            provider.clock2Running ? 'Marche' : 'Arrêt',
                          ),
                          Divider(),
                          _buildInfoRow(
                            'Mode néons',
                            _neonModeText(provider.neonMode),
                          ),
                          Divider(),
                          _buildInfoRow(
                            'Néon 1',
                            provider.neon1Running ? 'Actif' : 'Inactif',
                          ),
                          Divider(),
                          _buildInfoRow(
                            'Néon 2',
                            provider.neon2Running ? 'Actif' : 'Inactif',
                          ),
                          Divider(),
                          _buildInfoRow(
                            'Plages programmées',
                            '${provider.neonSchedule.length}',
                          ),
                          Divider(),
                          _buildInfoRow(
                            'État LEDs',
                            _ledStateText(provider.ledState),
                          ),
                          Divider(),
                          _buildInfoRow(
                            'Fonction LED',
                            _ledFunctionText(provider.ledFunction),
                          ),
                          Divider(),
                          _buildInfoRow(
                            'Couleur LED',
                            'RGB(${provider.ledColorR},${provider.ledColorG},${provider.ledColorB})',
                          ),
                          Divider(),
                          _buildInfoRow(
                            'Fréquence LED',
                            '${provider.ledFrequency}',
                          ),
                          Divider(),
                          _buildInfoRow(
                            'Température',
                            '${provider.temperature.toStringAsFixed(1)}°C',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Terminal de debug
              const BluetoothDataDisplay(),

              SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  String _neonModeText(int mode) {
    switch (mode) {
      case 0:
        return 'OFF';
      case 1:
        return 'ON';
      case 2:
        return 'Programmation';
      default:
        return 'Inconnu';
    }
  }

  String _ledStateText(int state) {
    switch (state) {
      case 0:
        return 'OFF';
      case 1:
        return 'ON';
      case 2:
        return 'Suivi néons';
      default:
        return 'Inconnu';
    }
  }

  String _ledFunctionText(int function) {
    switch (function) {
      case 1:
        return 'Couleur unie';
      case 2:
        return 'Clignotant';
      case 3:
        return 'Fondu';
      case 4:
        return 'Arc-en-ciel';
      default:
        return 'Inconnu';
    }
  }
}
