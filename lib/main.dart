import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool switchGeneral = false;
  bool switch1 = false;
  bool switch2 = false;
  bool trotteuse1 = false;
  bool trotteuse2 = false;
  bool switchNeons = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(
          padding: EdgeInsets.all(20.0),
          children: [
            Center(
              child: Text(
                "Horloge SNCB",
                style: GoogleFonts.alfaSlabOne(
                  color: const Color.fromARGB(255, 58, 153, 230),
                  fontSize: 23,
                ),
              ),
            ),
            SizedBox(height: 10),
            // Bloc principal contenant les 3 éléments
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 58, 153, 230),
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
                        'Alimentation générale moteurs',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      SizedBox(width: 10),
                      Switch(
                        value: switchGeneral,
                        onChanged: (v) => setState(() => switchGeneral = v),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Reste des éléments
                  Row(
                    children: [
                      // Horloge 1 à gauche
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
                                  color: const Color.fromARGB(
                                    255,
                                    58,
                                    153,
                                    230,
                                  ),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Switch(
                                value: switch1,
                                onChanged: switchGeneral
                                    ? (bool newValue) {
                                        setState(() {
                                          switch1 = newValue;
                                        });
                                      }
                                    : null,
                              ),
                              SizedBox(height: 10),
                              // Trotteuse 1
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    width: 2,
                                    color: const Color.fromARGB(
                                      255,
                                      58,
                                      153,
                                      230,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Trotteuse",
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          58,
                                          153,
                                          230,
                                        ),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Switch(
                                      value: trotteuse1,
                                      onChanged: (switchGeneral && switch1)
                                          ? (bool newValue) {
                                              setState(() {
                                                trotteuse1 = newValue;
                                              });
                                            }
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Horloge 2 à droite
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
                                  color: const Color.fromARGB(
                                    255,
                                    58,
                                    153,
                                    230,
                                  ),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Switch(
                                value: switch2,
                                onChanged: switchGeneral
                                    ? (bool newValue) {
                                        setState(() {
                                          switch2 = newValue;
                                        });
                                      }
                                    : null,
                              ),
                              SizedBox(height: 10),
                              // Trotteuse 2
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    width: 2,
                                    color: const Color.fromARGB(
                                      255,
                                      58,
                                      153,
                                      230,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      "Trotteuse",
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          58,
                                          153,
                                          230,
                                        ),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Switch(
                                      value: trotteuse2,
                                      onChanged: (switchGeneral && switch2)
                                          ? (bool newValue) {
                                              setState(() {
                                                trotteuse2 = newValue;
                                              });
                                            }
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
            ),
            SizedBox(height: 10),
            // néons
            Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 58, 153, 230),
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
                        'Néons',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      SizedBox(width: 10),

                      Switch(
                        value: switchNeons,
                        onChanged: (v) => setState(() => switchNeons = v),
                        trackColor: WidgetStateProperty<Color?>.fromMap(
                          <WidgetStatesConstraint, Color>{
                            WidgetState.selected: Colors.amber,
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
