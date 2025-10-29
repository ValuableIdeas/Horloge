import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class ProgrammationNeons extends StatefulWidget {
  const ProgrammationNeons({super.key});

  @override
  State<ProgrammationNeons> createState() => _ProgrammationNeonsState();
}

class _ProgrammationNeonsState extends State<ProgrammationNeons> {
  final FixedExtentScrollController _heureDebutController =
      FixedExtentScrollController();
  final FixedExtentScrollController _minuteDebutController =
      FixedExtentScrollController();
  final FixedExtentScrollController _heureFinController =
      FixedExtentScrollController();
  final FixedExtentScrollController _minuteFinController =
      FixedExtentScrollController();

  final ScrollController _jourDebutController = ScrollController();
  final ScrollController _jourFinController = ScrollController();

  int _heureDebut = 0;
  int _minuteDebut = 0;
  int _heureFin = 0;
  int _minuteFin = 0;
  int? _jourDebut;
  int? _jourFin;

  final List<String> _jours = ['Lu', 'Ma', 'Me', 'Je', 'Ve', 'Sa', 'Di'];

  @override
  void dispose() {
    _heureDebutController.dispose();
    _minuteDebutController.dispose();
    _heureFinController.dispose();
    _minuteFinController.dispose();
    _jourDebutController.dispose();
    _jourFinController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Centrer les listes de jours pour permettre le scroll dans les 2 sens
      _jourDebutController.jumpTo(
        500 * 39.0,
      ); // 500 items * (35px + 4px padding)
      _jourFinController.jumpTo(500 * 39.0);
    });
  }

  void _resetSelection() {
    setState(() {
      _jourDebut = null;
      _jourFin = null;
    });
  }

  void _validerPlage(AppProvider provider) {
    if (_jourDebut == null || _jourFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner les jours de début et de fin'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    int jourHeureDebut = _jourDebut! * 24 + _heureDebut;
    int jourHeureFin = _jourFin! * 24 + _heureFin;

    provider.addNeonTimeSlot(
      jourHeureDebut,
      _minuteDebut,
      jourHeureFin,
      _minuteFin,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plage ajoutée !'),
        duration: Duration(seconds: 1),
      ),
    );

    _resetSelection();
  }

  Widget _buildTimeWheel({
    required FixedExtentScrollController controller,
    required int maxValue,
    required Function(int) onChanged,
  }) {
    return SizedBox(
      width: 60,
      height: 150,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black,
              Colors.black,
              Colors.transparent,
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: Stack(
          children: [
            // Zone de contraste au milieu
            Center(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            // Liste dé
            ListWheelScrollView.useDelegate(
              controller: controller,
              itemExtent: 40,
              diameterRatio: 1.5,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: onChanged,
              childDelegate: ListWheelChildLoopingListDelegate(
                children: List.generate(
                  maxValue + 1,
                  (index) => Center(
                    child: Text(
                      index.toString().padLeft(2, '0'),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourSelector(
    int? jourSelectionne,
    Function(int) onSelect,
    ScrollController scrollController,
  ) {
    return SizedBox(
      width: 140,
      height: 45,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 1000, // Nombre très élevé pour simuler l'infini
        itemBuilder: (context, index) {
          int jourIndex = index % 7;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => onSelect(jourIndex),
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: jourSelectionne == jourIndex
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _jours[jourIndex],
                    style: TextStyle(
                      color: jourSelectionne == jourIndex
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatPlage(List<int> plage) {
    int jourDebut = plage[0] ~/ 24;
    int heureDebut = plage[0] % 24;
    int minuteDebut = plage[1];

    int jourFin = plage[2] ~/ 24;
    int heureFin = plage[2] % 24;
    int minuteFin = plage[3];

    return '${_jours[jourDebut]} ${heureDebut.toString().padLeft(2, '0')}:${minuteDebut.toString().padLeft(2, '0')} - ${_jours[jourFin]} ${heureFin.toString().padLeft(2, '0')}:${minuteFin.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Programmation'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Sélecteur de plage horaire (toujours visible)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryColor, width: 2),
                ),
                child: Column(
                  children: [
                    // Titre avec bouton +
                    Stack(
                      children: [
                        const Center(
                          child: Text(
                            'Nouvelle plage',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -10,
                          top: -10,
                          child: IconButton(
                            onPressed: () => _validerPlage(provider),
                            icon: const Icon(Icons.add_circle),
                            color: primaryColor,
                            iconSize: 32,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Ligne des heures/minutes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Début
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'DÉBUT',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                _buildTimeWheel(
                                  controller: _heureDebutController,
                                  maxValue: 23,
                                  onChanged: (index) {
                                    setState(() => _heureDebut = index);
                                  },
                                ),
                                const Text(
                                  ':',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                _buildTimeWheel(
                                  controller: _minuteDebutController,
                                  maxValue: 59,
                                  onChanged: (index) {
                                    setState(() => _minuteDebut = index);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _buildJourSelector(
                              _jourDebut,
                              (index) => setState(() => _jourDebut = index),
                              _jourDebutController,
                            ),
                          ],
                        ),

                        // Séparateur
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            '-',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Fin
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'FIN',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                _buildTimeWheel(
                                  controller: _heureFinController,
                                  maxValue: 23,
                                  onChanged: (index) {
                                    setState(() => _heureFin = index);
                                  },
                                ),
                                const Text(
                                  ':',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                _buildTimeWheel(
                                  controller: _minuteFinController,
                                  maxValue: 59,
                                  onChanged: (index) {
                                    setState(() => _minuteFin = index);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            _buildJourSelector(
                              _jourFin,
                              (index) => setState(() => _jourFin = index),
                              _jourFinController,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Récapitulatif des plages (scrollable)
              Expanded(
                child: provider.neonSchedule.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune plage programmée',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Plages programmées',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: provider.neonSchedule.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    title: Text(
                                      _formatPlage(
                                        provider.neonSchedule[index],
                                      ),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      onPressed: () {
                                        provider.removeNeonTimeSlot(index);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
