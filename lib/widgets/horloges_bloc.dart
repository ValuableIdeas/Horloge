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
              // Alimentation générale moteurs en haut
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'HORLOGES',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(width: 10),
                  Switch(
                    value: provider.alimentationGenerale,
                    onChanged: (v) => provider.setAlimentationGenerale(v),
                  ),
                ],
              ),
              SizedBox(height: 20),
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
                            value: provider.marcheHorloge1,
                            onChanged: provider.alimentationGenerale
                                ? (v) => provider.setMarcheHorloge1(v)
                                : null,
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
                                  value: provider.marcheTrotteuse1,
                                  onChanged:
                                      (provider.alimentationGenerale &&
                                          provider.marcheHorloge1)
                                      ? (v) => provider.setMarcheTrotteuse1(v)
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
                            value: provider.marcheHorloge2,
                            onChanged: provider.alimentationGenerale
                                ? (v) => provider.setMarcheHorloge2(v)
                                : null,
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
                                  value: provider.marcheTrotteuse2,
                                  onChanged:
                                      (provider.alimentationGenerale &&
                                          provider.marcheHorloge2)
                                      ? (v) => provider.setMarcheTrotteuse2(v)
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
