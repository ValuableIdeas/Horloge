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
              // Titre
              const Text(
                'NÉONS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),

              // ToggleButtons : Off / On / Prog
              ToggleButtons(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.white,
                selectedColor: primaryColor,
                fillColor: Colors.white,
                color: Colors.white,
                borderColor: Colors.white70,
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                  minWidth: 80.0,
                ),
                isSelected: [
                  provider.neonMode == 0,
                  provider.neonMode == 1,
                  provider.neonMode == 2,
                ],
                onPressed: (int index) {
                  provider.setNeonMode(index);
                },
                children: const [
                  Text('OFF'),
                  Text('ON'),
                  Icon(Icons.calendar_month),
                ],
              ),

              SizedBox(height: 10),

              // Bouton de programmation
              ElevatedButton(
                onPressed: () {
                  print('Bouton cliqué - Navigation vers programmation');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProgrammationNeons(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                ),
                child: const Text('Gérer les plages horaires'),
              ),

              SizedBox(height: 10),

              // Switch individuels des néons
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
                        value: provider.neon1Running,
                        onChanged: (v) => provider.setNeon1Running(v),
                        activeThumbColor: Colors.amber,
                        activeTrackColor: Colors.amber.withOpacity(0.5),
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
                        value: provider.neon2Running,
                        onChanged: (v) => provider.setNeon2Running(v),
                        activeThumbColor: Colors.amber,
                        activeTrackColor: Colors.amber.withOpacity(0.5),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
