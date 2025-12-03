import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/app_provider.dart';
import '../theme.dart';

class LedsBloc extends StatelessWidget {
  const LedsBloc({super.key});

  // Couleurs prédéfinies
  static const List<Color> presetColors = [
    Color(0xFFFF0000), // Rouge
    Color(0xFF00FF00), // Vert
    Color(0xFF0000FF), // Bleu
    Color(0xFFFFFF00), // Jaune
    Color(0xFF00FFFF), // Cyan
    Color(0xFFFF00FF), // Magenta
    Color(0xFFFFFFFF), // Blanc
    Color(0xFFFFA500), // Orange
  ];

  void _showFrequencyDialog(BuildContext context, AppProvider provider) {
    double currentFreq = provider.ledFrequency.toDouble();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Fréquence de clignotement'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: currentFreq,
                    min: 0,
                    max: 255,
                    divisions: 255,
                    onChanged: (value) {
                      setState(() {
                        currentFreq = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    provider.setLedFrequency(currentFreq.round());
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Valider'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFunctionButton({
    required BuildContext context,
    required AppProvider provider,
    required int functionId,
    required String label,
    required IconData icon,
    bool hasSettings = false,
  }) {
    final isSelected = provider.ledFunction == functionId;
    final secondaryColor = AppTheme.secondaryColor;

    return Container(
      width: 100,
      height: hasSettings ? 90 : 80,
      margin: EdgeInsets.all(4),
      child: Column(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => provider.setLedFunction(functionId),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? secondaryColor : Colors.white,
                foregroundColor: isSelected ? Colors.white : Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 24),
                  SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          if (hasSettings)
            SizedBox(
              height: 30,
              child: IconButton(
                onPressed: () => _showFrequencyDialog(context, provider),
                icon: Icon(Icons.settings, size: 18),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                color: Theme.of(context).primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        // Vérifier si la fonction nécessite un sélecteur de couleur
        final needsColorPicker =
            provider.ledFunction != 4; // Pas pour arc-en-ciel

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
                'LEDS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),

              // ToggleButtons : Off / On / Suivi néons
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
                  provider.ledState == 0,
                  provider.ledState == 1,
                  provider.ledState == 2,
                ],
                onPressed: (int index) {
                  provider.setLedState(index);
                },
                children: const [Text('OFF'), Text('ON'), Text('SUIVI')],
              ),

              SizedBox(height: 15),

              // Boutons de fonction LED
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 0,
                runSpacing: 0,
                children: [
                  _buildFunctionButton(
                    context: context,
                    provider: provider,
                    functionId: 1,
                    label: 'Couleur\nunie',
                    icon: Icons.circle,
                  ),
                  _buildFunctionButton(
                    context: context,
                    provider: provider,
                    functionId: 2,
                    label: 'Clignotant',
                    icon: Icons.flash_on,
                    hasSettings: true,
                  ),
                  _buildFunctionButton(
                    context: context,
                    provider: provider,
                    functionId: 3,
                    label: 'Fondu',
                    icon: Icons.blur_circular,
                  ),
                  _buildFunctionButton(
                    context: context,
                    provider: provider,
                    functionId: 4,
                    label: 'Arc-en-ciel',
                    icon: Icons.palette,
                  ),
                ],
              ),

              // Sélecteur de couleur (seulement si nécessaire)
              if (needsColorPicker) ...[
                SizedBox(height: 15),

                // Ligne de couleurs prédéfinies
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: presetColors.map((color) {
                    final isSelected =
                        provider.ledColorR == color.red &&
                        provider.ledColorG == color.green &&
                        provider.ledColorB == color.blue;

                    return GestureDetector(
                      onTap: () {
                        provider.setLedColor(
                          color.red,
                          color.green,
                          color.blue,
                        );
                      },
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.white54,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 15),

                // Sélecteur de couleur avancé
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SlidePicker(
                    pickerColor: Color.fromARGB(
                      255,
                      provider.ledColorR,
                      provider.ledColorG,
                      provider.ledColorB,
                    ),
                    onColorChanged: (Color color) {
                      provider.setLedColor(color.red, color.green, color.blue);
                    },
                    colorModel: ColorModel.rgb,
                    enableAlpha: false,
                    displayThumbColor: true,
                    showLabel: false,
                    showIndicator: true,
                    indicatorBorderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
