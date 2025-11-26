import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class InterrupteurGeneralBloc extends StatelessWidget {
  const InterrupteurGeneralBloc({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Partie gauche : Texte + Switch (prend le maximum de place)
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'ALIM GÉNÉRALE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 10),
                    Switch(
                      value: provider.mainSwitchOn,
                      onChanged: (v) => provider.setMainSwitchOn(v),
                      activeColor: Colors.white,
                      activeTrackColor: Colors.white.withOpacity(0.5),
                    ),
                  ],
                ),
              ),

              // Partie droite : Bouton de déconnexion (carré)
              if (provider.isConnected)
                Container(
                  height: 50, // Même hauteur que le switch
                  width: 50, // Carré
                  margin: EdgeInsets.only(left: 5),
                  child: Material(
                    color: Colors.red.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () async {
                        await provider.disconnectBluetooth();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Déconnecté'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Icon(
                        Icons.bluetooth_disabled,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
