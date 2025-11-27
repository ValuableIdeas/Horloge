import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                  height: 50,
                  width: 50,
                  margin: EdgeInsets.only(left: 5),
                  child: Material(
                    color: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.white, width: 2),
                    ),

                    child: InkWell(
                      onTap: () async {
                        // Afficher un dialog de confirmation
                        bool? confirm = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Déconnexion'),
                              content: Text(
                                "Quitter l'application pour rompre la connexion Bluetooth ?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text(
                                    'Quitter',
                                    style: TextStyle(color: primaryColor),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirm == true) {
                          // Déconnecter
                          await provider.disconnectBluetooth();

                          // Attendre un peu
                          await Future.delayed(Duration(milliseconds: 300));

                          // Redémarrer l'app
                          SystemNavigator.pop(); // Ferme l'app sur Android
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Icon(
                        Icons.power_settings_new,
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
