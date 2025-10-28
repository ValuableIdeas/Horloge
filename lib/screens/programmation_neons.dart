import 'package:flutter/material.dart';
import '../theme.dart';

class ProgrammationNeons extends StatelessWidget {
  const ProgrammationNeons({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programmation des néons'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: Center(
        child: SizedBox(
          height: 200,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 50,
            onSelectedItemChanged: (index) {
              // Optionnel: faire quelque chose pendant le scroll
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                final number = (index % 12) + 1;
                return GestureDetector(
                  onTap: () => Navigator.pop(context, number),
                  child: Center(
                    child: Text('$number', style: TextStyle(fontSize: 32)),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryBlue,
        onPressed: () {
          // Retourne la valeur actuellement visible
          Navigator.pop(context, 1); // Valeur par défaut
        },
        child: Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}
