import 'package:flutter/material.dart';

class ProgrammationNeons extends StatelessWidget {
  const ProgrammationNeons({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programmation des néons'),
        backgroundColor: const Color.fromARGB(255, 58, 153, 230),
      ),
      body: Center(
        child: SizedBox(
          height: 200,
          child: ListWheelScrollView(
            itemExtent: 50,
            children: List.generate(
              12,
              (index) => Center(
                child: Text('${index + 1}', style: TextStyle(fontSize: 32)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
