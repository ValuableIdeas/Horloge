import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class HorlogesBloc extends StatelessWidget {
  const HorlogesBloc({super.key});

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
              // Titre uniquement
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'HORLOGES',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Horloges
              Row(
                children: [
                  // Horloge 1
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: 5),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Horloge 1",
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Switch(
                            value: provider.clock1Running,
                            onChanged: provider.mainSwitchOn
                                ? (v) => provider.setClock1Running(v)
                                : null,
                          ),
                          SizedBox(height: 15),
                          // Affichage de l'heure
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: primaryColor, width: 2),
                            ),
                            child: Text(
                              provider.clock1TimeString,
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Courier',
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          // Trotteuse 1
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(width: 2, color: primaryColor),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Trotteuse",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Switch(
                                  value: provider.secondHand1Running,
                                  onChanged:
                                      (provider.clock1Running &&
                                          provider.mainSwitchOn)
                                      ? (v) => provider.setSecondHand1Running(v)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Horloge 2
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 5),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Horloge 2",
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Switch(
                            value: provider.clock2Running,
                            onChanged: provider.mainSwitchOn
                                ? (v) => provider.setClock2Running(v)
                                : null,
                          ),
                          SizedBox(height: 15),
                          // Affichage de l'heure
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: primaryColor, width: 2),
                            ),
                            child: Text(
                              provider.clock2TimeString,
                              style: TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Courier',
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          // Trotteuse 2
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(width: 2, color: primaryColor),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Trotteuse",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Switch(
                                  value: provider.secondHand2Running,
                                  onChanged:
                                      (provider.clock2Running &&
                                          provider.mainSwitchOn)
                                      ? (v) => provider.setSecondHand2Running(v)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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
