import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../screens/programmation_neons.dart';

class NeonsBloc extends StatelessWidget {
  const NeonsBloc({super.key});

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
          child: Column(
            children: [
              const Text(
                'NÉONS',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),

              SizedBox(height: 10),
              // --- Coller dans Column(children: [ ... ici ... ]) ---
              StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  // état local (sera recréé si le parent rebuild)
                  final List<bool> _selectedModes = <bool>[true, false, false];

                  return ToggleButtons(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    selectedBorderColor: Theme.of(context).colorScheme.primary,
                    selectedColor: Colors.white,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.6),
                    color: Theme.of(context).colorScheme.onSurface,
                    constraints: const BoxConstraints(
                      minHeight: 40.0,
                      minWidth: 80.0,
                    ),
                    isSelected: _selectedModes,
                    onPressed: (int index) {
                      setState(() {
                        for (int i = 0; i < _selectedModes.length; i++) {
                          _selectedModes[i] = i == index;
                        }
                      });
                    },
                    children: const [Text('Off'), Text('On'), Text('Prog')],
                  );
                },
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Néons',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(width: 10),

                  // Switch pour mode on/off (0 ou 1)
                  Switch(
                    value: provider.modeNeons > 0,
                    onChanged: (v) => provider.setModeNeons(v ? 1 : 0),
                    trackColor: WidgetStateProperty<Color?>.fromMap(
                      <WidgetStatesConstraint, Color>{
                        WidgetState.selected: Colors.amber,
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProgrammationNeons(),
                        ),
                      );
                    },
                    child: Text(
                      provider.modeNeons == 2 ? 'Programmé' : 'Programmer',
                    ),
                  ),
                ],
              ),
              // Contrôles individuels des néons (seulement si mode > 0)
              if (provider.modeNeons > 0) ...[
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Néon 1',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Switch(
                          value: provider.marcheNeon1,
                          onChanged: (v) => provider.setMarcheNeon1(v),
                          activeThumbColor: Colors.amber,
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'Néon 2',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Switch(
                          value: provider.marcheNeon2,
                          onChanged: (v) => provider.setMarcheNeon2(v),
                          activeThumbColor: Colors.amber,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
