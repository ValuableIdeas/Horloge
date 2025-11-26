import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        // Afficher si on est en train de se connecter OU de synchroniser
        if (!provider.isConnecting && !provider.isSynchronizing) {
          return const SizedBox.shrink();
        }

        // Écran de chargement rose
        return Container(
          color: Theme.of(context).primaryColor,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white, strokeWidth: 4),
                const SizedBox(height: 30),
                Text(
                  provider.isSynchronizing
                      ? 'Synchronisation...'
                      : 'Connexion en cours...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
