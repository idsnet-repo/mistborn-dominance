import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/material.dart';
import '../domain/model.dart';
import '../domain/dominance_engine.dart';
import '../services/config_loader.dart';


class EventLogEntry {
  final int row;
  final int x;
  final EventConfig event;

  EventLogEntry({
    required this.row,
    required this.x,
    required this.event,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GameConfig? _config;
  DominanceEngine? _engine;

  DifficultyConfig? _selectedDifficulty;
  GameState? _gameState;
  EventConfig? _lastEvent;

  List<EventLogEntry> _eventHistory = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConfig();

    // Mantener la pantalla encendida mientras esta pantalla esté activa
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    // Volver a permitir que la pantalla se apague normalmente
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _loadConfig() async {
    try {
      final config = await loadGameConfig();
      setState(() {
        _config = config;
        _engine = DominanceEngine(config);
        _selectedDifficulty = config.difficulties.first;
        _gameState = GameState(difficulty: _selectedDifficulty!);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onDifficultyChanged(DifficultyConfig newDiff) {
    setState(() {
      _selectedDifficulty = newDiff;
      _gameState = GameState(difficulty: newDiff);
      _lastEvent = null;
      _eventHistory = [];
    });
  }

  void _onDominanceUp() {
    if (_engine == null || _gameState == null) return;

    final result = _engine!.nextEvent(_gameState!);
    final newState = result['state'] as GameState;
    final event = result['event'] as EventConfig?;

    final x = newState.currentX ?? 0;
    final row = newState.currentRow;

    setState(() {
      _gameState = newState;
      _lastEvent = event;

      if (event != null) {
        _eventHistory = List<EventLogEntry>.from(_eventHistory)
          ..add(EventLogEntry(row: row, x: x, event: event));
      }
    });
  }


  void _onResetGame() {
    if (_selectedDifficulty == null) return;

    setState(() {
      _gameState = GameState(difficulty: _selectedDifficulty!);
      _lastEvent = null;
      _eventHistory = [];
    });
  }

  BoxDecoration _buildMistbornGradient() {
    return const BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.topCenter,
        radius: 2.0,
        colors: [
          Color(0xFF2C2C2C), // Gris ceniza en el centro
          Color(0xFF1A1A1A), // Gris más oscuro
          Color(0xFF0D0D0D), // Negro profundo en los bordes
        ],
        stops: [0.0, 0.7, 1.0],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Container(
          decoration: _buildMistbornGradient(),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Container(
          decoration: _buildMistbornGradient(),
          child: Center(
            child: Text(
              'Error: $_error',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    final state = _gameState!;
    final x = state.currentX;
    final row = state.currentRow;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.auto_awesome,
              color: const Color(0xFFD4AF37),
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text(
              'Mistborn Dominance',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: _buildMistbornGradient(),
        child: Padding(
          padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de dificultad
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF404040).withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2F4F4F).withOpacity(0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B0000).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.tune,
                        color: Color(0xFFD4AF37),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Dificultad',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: const Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF2F4F4F),
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<DifficultyConfig>(
                        value: _selectedDifficulty,
                        dropdownColor: const Color(0xFF2C2C2C),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Color(0xFFD4AF37),
                        ),
                        items: _config!.difficulties.map((d) {
                          return DropdownMenuItem(
                            value: d,
                            child: Text(d.name),
                          );
                        }).toList(),
                        onChanged: (d) {
                          if (d != null) _onDifficultyChanged(d);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Estado del juego con progreso visual
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF404040).withOpacity(0.8),
                    const Color(0xFF2C2C2C).withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF8B0000).withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B0000).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de sección
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Color(0xFFD4AF37),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Dominance Track',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Barra de progreso
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFF2F4F4F),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: row / 16,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color.lerp(
                            const Color(0xFF2F4F4F),
                            const Color(0xFF8B0000),
                            row / 16,
                          )!,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Info de estado
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Fila',
                        row == 0 ? '-' : row.toString(),
                        '/ 16',
                        Icons.layers,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: const Color(0xFF2F4F4F),
                      ),
                      _buildStatCard(
                        'Valor X',
                        x?.toString() ?? '-',
                        '',
                        Icons.close,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Botones mejorados
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: row >= 16 ? null : _onDominanceUp,
                      icon: const Icon(
                        Icons.keyboard_arrow_up,
                        size: 24,
                      ),
                      label: const Text(
                        'Dominance Up',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _onResetGame,
                      icon: const Icon(
                        Icons.refresh,
                        size: 24,
                      ),
                      label: const Text(
                        'Nueva Partida',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Evento actual con estilo dramático
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF8B0000).withOpacity(0.1),
                    const Color(0xFF2C2C2C).withOpacity(0.8),
                    const Color(0xFF0D0D0D).withOpacity(0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _lastEvent != null 
                        ? const Color(0xFF8B0000).withOpacity(0.3)
                        : const Color(0xFF2F4F4F).withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de sección
                  Row(
                    children: [
                      Icon(
                        _lastEvent != null ? Icons.warning_amber : Icons.access_time,
                        color: _lastEvent != null 
                            ? const Color(0xFF8B0000) 
                            : const Color(0xFF2F4F4F),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Evento Actual',
                        style: TextStyle(
                          color: _lastEvent != null 
                              ? const Color(0xFFD4AF37) 
                              : const Color(0xFF2F4F4F),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Contenido del evento
                  if (_lastEvent == null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D0D).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF2F4F4F).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'La bruma permanece en calma... Por ahora.\n\nPulsa "Dominance Up" para desencadenar el próximo evento.',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D0D).withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF8B0000).withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _lastEvent!.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Historial de eventos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // Historial scrollable
            Expanded(
              child: _eventHistory.isEmpty
                  ? const Text(
                      'Sin eventos aún. A medida que avances en el Dominance Track, aparecerán aquí.')
                  : ListView.builder(
                      itemCount: _eventHistory.length,
                      itemBuilder: (context, index) {
                        final entry = _eventHistory[index];
                        return ListTile(
                          dense: true,
                          title: Text(
                            'Fila ${entry.row} (X=${entry.x})',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          subtitle: Text(
                            entry.event.text,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

//   @override
//   Widget build(BuildContext context) {
//     if (_loading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (_error != null) {
//       return Scaffold(
//         body: Center(child: Text('Error: $_error')),
//       );
//     }

//     final state = _gameState!;
//     final x = state.currentX;
//     final row = state.currentRow;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Mistborn Dominance'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Dificultad', style: Theme.of(context).textTheme.titleMedium),
//             const SizedBox(height: 8),
//             DropdownButton<DifficultyConfig>(
//               value: _selectedDifficulty,
//               items: _config!.difficulties.map((d) {
//                 return DropdownMenuItem(
//                   value: d,
//                   child: Text(d.name),
//                 );
//               }).toList(),
//               onChanged: (d) {
//                 if (d != null) _onDifficultyChanged(d);
//               },
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Fila actual: ${row == 0 ? "-" : row}',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             Text(
//               'X actual: ${x?.toString() ?? "-"}',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: row >= 16 ? null : _onDominanceUp,
//               child: const Text('Dominance Up'),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'Evento actual:',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//             const SizedBox(height: 8),
//             if (_lastEvent == null)
//               const Text('Aún no hay evento. Pulsa "Dominance Up".')
//             else
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(12),
//                   child: Text(
//                     _lastEvent!.text,
//                     style: Theme.of(context).textTheme.bodyLarge,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
}

