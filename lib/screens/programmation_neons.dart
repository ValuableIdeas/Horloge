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
  int? _jourDebut = 0;
  int? _jourFin = 0;

  int? _editingIndex;

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
      _jourDebutController.jumpTo(490 * 39.0);
      _jourFinController.jumpTo(490 * 39.0);
    });
  }

  void _resetSelection() {
    setState(() {
      _editingIndex = null;
      _jourDebut = null;
      _jourFin = null;
    });
  }

  int _plageToMinutes(int jour, int heure, int minute) {
    return jour * 24 * 60 + heure * 60 + minute;
  }

  bool _doRangesOverlap(int start1, int end1, int start2, int end2) {
    if (start1 <= end1 && start2 <= end2) {
      return start1 < end2 && end1 > start2;
    }

    if (start1 > end1) {
      if (start2 <= end2) {
        return (start2 <= end1) || (end2 > start1);
      } else {
        return true;
      }
    }

    if (start2 > end2) {
      return (start1 <= end2) || (end1 > start2);
    }

    return false;
  }

  List<int> _checkConflicts(AppProvider provider, int startMin, int endMin) {
    List<int> conflicts = [];

    for (int i = 0; i < provider.neonSchedule.length; i++) {
      if (_editingIndex != null && i == _editingIndex) continue;

      var plage = provider.neonSchedule[i];
      int existingStart = _plageToMinutes(
        plage[0] ~/ 24,
        plage[0] % 24,
        plage[1],
      );
      int existingEnd = _plageToMinutes(
        plage[2] ~/ 24,
        plage[2] % 24,
        plage[3],
      );

      if (_doRangesOverlap(startMin, endMin, existingStart, existingEnd)) {
        conflicts.add(i);
      }
    }

    return conflicts;
  }

  void _mergeConflicts(
    AppProvider provider,
    List<int> conflicts,
    int jourHeureDebut,
    int minuteDebut,
    int jourHeureFin,
    int minuteFin,
  ) {
    List<Map<String, int>> allRanges = [];

    int newStart = _plageToMinutes(_jourDebut!, _heureDebut, _minuteDebut);
    int newEnd = _plageToMinutes(_jourFin!, _heureFin, _minuteFin);
    allRanges.add({'start': newStart, 'end': newEnd});

    for (int index in conflicts) {
      var plage = provider.neonSchedule[index];
      allRanges.add({
        'start': _plageToMinutes(plage[0] ~/ 24, plage[0] % 24, plage[1]),
        'end': _plageToMinutes(plage[2] ~/ 24, plage[2] % 24, plage[3]),
      });
    }

    int finalStart = allRanges[0]['start']!;
    int finalEnd = allRanges[0]['end']!;

    bool hasCircular = allRanges.any((r) => r['start']! > r['end']!);

    if (!hasCircular) {
      for (var range in allRanges) {
        if (range['start']! < finalStart) finalStart = range['start']!;
        if (range['end']! > finalEnd) finalEnd = range['end']!;
      }
    } else {
      const int WEEK_MINUTES = 7 * 24 * 60;

      List<Map<String, dynamic>> events = [];

      for (var range in allRanges) {
        if (range['start']! <= range['end']!) {
          events.add({'time': range['start']!, 'type': 'start'});
          events.add({'time': range['end']! + 1, 'type': 'end'});
        } else {
          events.add({'time': range['start']!, 'type': 'start'});
          events.add({'time': WEEK_MINUTES, 'type': 'end'});
          events.add({'time': 0, 'type': 'start'});
          events.add({'time': range['end']! + 1, 'type': 'end'});
        }
      }

      events.sort((a, b) => a['time'].compareTo(b['time']));

      int activeRanges = 0;
      int? gapStart;
      int maxGapSize = 0;
      int maxGapStart = 0;
      int maxGapEnd = 0;

      for (var event in events) {
        if (event['type'] == 'start') {
          if (activeRanges == 0 && gapStart != null) {
            int gapSize = event['time'] - gapStart;
            if (gapSize > maxGapSize) {
              maxGapSize = gapSize;
              maxGapStart = gapStart;
              maxGapEnd = event['time'];
            }
            gapStart = null;
          }
          activeRanges++;
        } else {
          activeRanges--;
          if (activeRanges == 0) {
            gapStart = event['time'];
          }
        }
      }

      if (gapStart != null) {
        int firstCoverStart = events.firstWhere(
          (e) => e['type'] == 'start',
        )['time'];
        int gapSize = (WEEK_MINUTES - gapStart) + firstCoverStart;
        if (gapSize > maxGapSize) {
          maxGapSize = gapSize;
          maxGapStart = gapStart;
          maxGapEnd = firstCoverStart;
        }
      }

      if (maxGapSize > 0) {
        finalStart = maxGapEnd % WEEK_MINUTES;
        finalEnd = (maxGapStart - 1 + WEEK_MINUTES) % WEEK_MINUTES;
      } else {
        finalStart = 0;
        finalEnd = WEEK_MINUTES - 1;
      }
    }

    for (int i = conflicts.length - 1; i >= 0; i--) {
      provider.removeNeonTimeSlot(conflicts[i]);
    }

    int startJour = finalStart ~/ (24 * 60);
    int startHeure = (finalStart % (24 * 60)) ~/ 60;
    int startMinute = finalStart % 60;

    int endJour = finalEnd ~/ (24 * 60);
    int endHeure = (finalEnd % (24 * 60)) ~/ 60;
    int endMinute = finalEnd % 60;

    provider.addNeonTimeSlot(
      startJour * 24 + startHeure,
      startMinute,
      endJour * 24 + endHeure,
      endMinute,
    );

    _sortSchedule(provider);
  }

  void _replaceConflicts(
    AppProvider provider,
    List<int> conflicts,
    int jourHeureDebut,
    int minuteDebut,
    int jourHeureFin,
    int minuteFin,
  ) {
    for (int i = conflicts.length - 1; i >= 0; i--) {
      provider.removeNeonTimeSlot(conflicts[i]);
    }

    provider.addNeonTimeSlot(
      jourHeureDebut,
      minuteDebut,
      jourHeureFin,
      minuteFin,
    );
    _sortSchedule(provider);
  }

  void _sortSchedule(AppProvider provider) {
    provider.neonSchedule.sort((a, b) {
      int startA = _plageToMinutes(a[0] ~/ 24, a[0] % 24, a[1]);
      int startB = _plageToMinutes(b[0] ~/ 24, b[0] % 24, b[1]);
      return startA.compareTo(startB);
    });
  }

  Future<void> _showConflictDialog(
    AppProvider provider,
    List<int> conflicts,
    int jourHeureDebut,
    int minuteDebut,
    int jourHeureFin,
    int minuteFin,
  ) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Plages superposées'),
          content: const Text(
            'La nouvelle plage chevauche une ou plusieurs plages existantes. Que souhaitez-vous faire ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _mergeConflicts(
                  provider,
                  conflicts,
                  jourHeureDebut,
                  minuteDebut,
                  jourHeureFin,
                  minuteFin,
                );
                _resetSelection();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Plages fusionnées !'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Text('Fusionner'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _replaceConflicts(
                  provider,
                  conflicts,
                  jourHeureDebut,
                  minuteDebut,
                  jourHeureFin,
                  minuteFin,
                );
                _resetSelection();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Plages remplacées !'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const Text('Remplacer'),
            ),
          ],
        );
      },
    );
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

    int startMin = _plageToMinutes(_jourDebut!, _heureDebut, _minuteDebut);
    int endMin = _plageToMinutes(_jourFin!, _heureFin, _minuteFin);

    List<int> conflicts = _checkConflicts(provider, startMin, endMin);

    if (conflicts.isNotEmpty) {
      _showConflictDialog(
        provider,
        conflicts,
        jourHeureDebut,
        _minuteDebut,
        jourHeureFin,
        _minuteFin,
      );
      return;
    }

    if (_editingIndex != null) {
      provider.removeNeonTimeSlot(_editingIndex!);
    }

    provider.addNeonTimeSlot(
      jourHeureDebut,
      _minuteDebut,
      jourHeureFin,
      _minuteFin,
    );
    _sortSchedule(provider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _editingIndex != null ? 'Plage modifiée !' : 'Plage ajoutée !',
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    _resetSelection();
  }

  void _editPlage(AppProvider provider, int index) {
    var plage = provider.neonSchedule[index];

    setState(() {
      _editingIndex = index;
      _jourDebut = plage[0] ~/ 24;
      _heureDebut = plage[0] % 24;
      _minuteDebut = plage[1];
      _jourFin = plage[2] ~/ 24;
      _heureFin = plage[2] % 24;
      _minuteFin = plage[3];
    });

    _heureDebutController.jumpToItem(_heureDebut);
    _minuteDebutController.jumpToItem(_minuteDebut);
    _heureFinController.jumpToItem(_heureFin);
    _minuteFinController.jumpToItem(_minuteFin);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_jourDebutController.hasClients && _jourFinController.hasClients) {
        double currentPosDebut = _jourDebutController.offset;
        int currentIndexDebut = (currentPosDebut / 39.0).round() % 7;
        int targetIndexDebut = _jourDebut!;
        int diffDebut = (targetIndexDebut - currentIndexDebut) % 7;
        _jourDebutController.jumpTo(currentPosDebut + diffDebut * 39.0);

        double currentPosFin = _jourFinController.offset;
        int currentIndexFin = (currentPosFin / 39.0).round() % 7;
        int targetIndexFin = _jourFin!;
        int diffFin = (targetIndexFin - currentIndexFin) % 7;
        _jourFinController.jumpTo(currentPosFin + diffFin * 39.0);
      }
    });
  }

  Future<void> _showDeleteAllDialog(AppProvider provider) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer toutes les plages ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                provider.neonSchedule.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Toutes les plages ont été supprimées'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: Text(
                'Supprimer',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        );
      },
    );
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
          return const LinearGradient(
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
        itemCount: 1000,
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

  // ✅ MODIFICATION : Gestion du retour arrière système
  Future<bool> _handleBackButton(AppProvider provider) async {
    provider.sendNeonSchedule();
    return true; // Permet la navigation
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        // ✅ MODIFICATION : WillPopScope gère maintenant le retour système
        return WillPopScope(
          onWillPop: () => _handleBackButton(provider),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Programmation'),
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  provider.sendNeonSchedule();
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: Column(
              children: [
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
                      Stack(
                        children: [
                          Center(
                            child: Text(
                              _editingIndex != null
                                  ? 'Modifier plage'
                                  : 'Nouvelle plage',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Positioned(
                            right: -10,
                            top: -10,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_editingIndex != null)
                                  IconButton(
                                    onPressed: _resetSelection,
                                    icon: const Icon(Icons.close),
                                    color: primaryColor,
                                    iconSize: 32,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                IconButton(
                                  onPressed: () => _validerPlage(provider),
                                  icon: Icon(
                                    _editingIndex != null
                                        ? Icons.check_circle
                                        : Icons.add_circle,
                                  ),
                                  color: primaryColor,
                                  iconSize: 32,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                                    onChanged: (index) =>
                                        setState(() => _heureDebut = index),
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
                                    onChanged: (index) =>
                                        setState(() => _minuteDebut = index),
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
                                    onChanged: (index) =>
                                        setState(() => _heureFin = index),
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
                                    onChanged: (index) =>
                                        setState(() => _minuteFin = index),
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
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Plages programmées',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_sweep),
                                    color: primaryColor,
                                    onPressed: () =>
                                        _showDeleteAllDialog(provider),
                                    tooltip: 'Tout supprimer',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: provider.neonSchedule.length,
                                itemBuilder: (context, index) {
                                  bool isEditing = _editingIndex == index;
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    color: isEditing ? Colors.grey[300] : null,
                                    child: ListTile(
                                      title: Text(
                                        _formatPlage(
                                          provider.neonSchedule[index],
                                        ),
                                        style: TextStyle(
                                          color: isEditing
                                              ? Colors.grey[600]
                                              : null,
                                        ),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            color: primaryColor,
                                            onPressed: isEditing
                                                ? null
                                                : () => _editPlage(
                                                    provider,
                                                    index,
                                                  ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            color: primaryColor,
                                            onPressed: () {
                                              if (_editingIndex == index) {
                                                _resetSelection();
                                              }
                                              provider.removeNeonTimeSlot(
                                                index,
                                              );
                                            },
                                          ),
                                        ],
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
            ),
          ),
        );
      },
    );
  }
}
