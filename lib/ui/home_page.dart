import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/material.dart';
import '../domain/model.dart';
import '../domain/dominance_engine.dart';
import '../services/config_loader.dart';
import '../services/config_manager.dart';
import 'config_page.dart';

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
  bool _xIncreased = false; // Rastrea si X se incrementó en el último evento

  List<EventLogEntry> _eventHistory = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConfig();
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  Future<String> _getActiveConfigName() async {
    return await ConfigManager.getActiveConfigId();
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
      _xIncreased = false;
    });
  }

  void _onDominanceUp() {
    if (_engine == null || _gameState == null) return;

    final oldX = _gameState!.currentX ?? 0;
    
    final result = _engine!.nextEvent(_gameState!);
    final newState = result['state'] as GameState;
    final event = result['event'] as EventConfig?;

    final newX = newState.currentX ?? 0;
    final row = newState.currentRow;
    final xIncreased = newX > oldX;

    setState(() {
      _gameState = newState;
      _lastEvent = event;
      _xIncreased = xIncreased; // Nuevo campo para rastrear si X aumentó

      if (event != null) {
        _eventHistory = List<EventLogEntry>.from(_eventHistory)
          ..add(EventLogEntry(row: row, x: newX, event: event));
      }
    });
  }

  void _onResetGame() {
    if (_selectedDifficulty == null) return;

    setState(() {
      _gameState = GameState(difficulty: _selectedDifficulty!);
      _lastEvent = null;
      _eventHistory = [];
      _xIncreased = false;
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



  Widget _buildStatCard(String label, String value, String suffix, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF2F4F4F),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (suffix.isNotEmpty)
              Text(
                suffix,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ],
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
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
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
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ),
      );
    }

    final state = _gameState!;
    final x = state.currentX;
    final row = state.currentRow;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Color(0xFFFFB300),
                size: MediaQuery.of(context).size.width * 0.07,
              ),
              const SizedBox(width: 8),
              Text(
                'Mistborn Dominance',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                ),
              ),
            ],
          ),
          actions: [
            FutureBuilder<String>(
              future: _getActiveConfigName(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != 'default') {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB71C1C).withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFB300), width: 1),
                    ),
                    child: Text(
                      'Custom',
                      style: TextStyle(
                        color: const Color(0xFFFFB300),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              onPressed: () async {
                final currentConfigId = await ConfigManager.getActiveConfigId();
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ConfigPage()),
                );
                // Solo recargar si cambió la configuración
                final newConfigId = await ConfigManager.getActiveConfigId();
                if (currentConfigId != newConfigId) {
                  _loadConfig();
                }
              },
              icon: const Icon(
                Icons.settings,
                color: Color(0xFFFFB300),
              ),
              tooltip: 'Configuración',
            ),
          ],
        ),
        body: Container(
          decoration: _buildMistbornGradient(),
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04), // 4% del ancho
            child: SingleChildScrollView(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // Selector de dificultad con estilo Mistborn
              Container(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                decoration: BoxDecoration(
                  color: const Color(0xFF404040).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2F4F4F).withValues(alpha: 0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB71C1C).withValues(alpha: 0.1),
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
                          color: Color(0xFFFFB300),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dificultad',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFFFFB300),
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
                            color: Color(0xFFFFB300),
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

              SizedBox(height: MediaQuery.of(context).size.height * 0.025),

              // Estado del juego con progreso visual
              Container(
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF404040).withValues(alpha: 0.8),
                      const Color(0xFF2C2C2C).withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFB71C1C).withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB71C1C).withValues(alpha: 0.2),
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
                          color: Color(0xFFFFB300),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Dominance Track',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: const Color(0xFFFFB300),
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
                              const Color(0xFFB71C1C),
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

              SizedBox(height: MediaQuery.of(context).size.height * 0.025),

              // Botones mejorados
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.07, // Altura responsiva
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: ElevatedButton.icon(
                          onPressed: row >= 16 ? null : _onDominanceUp,
                          icon: const Icon(
                            Icons.keyboard_arrow_up,
                            size: 24,
                          ),
                          label: Text(
                            'Dominance Up',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.032,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.07, // Altura responsiva
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        child: OutlinedButton.icon(
                          onPressed: _onResetGame,
                          icon: const Icon(
                            Icons.refresh,
                            size: 24,
                          ),
                          label: Text(
                            'Nueva Partida',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.032,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.03),

              // Evento actual con estilo dramático
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFB71C1C).withValues(alpha: 0.1),
                      const Color(0xFF2C2C2C).withValues(alpha: 0.8),
                      const Color(0xFF0D0D0D).withValues(alpha: 0.9),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _lastEvent != null 
                          ? const Color(0xFFB71C1C).withValues(alpha: 0.3)
                          : const Color(0xFF2F4F4F).withValues(alpha: 0.2),
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
                              ? const Color(0xFFB71C1C) 
                              : const Color(0xFF2F4F4F),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Evento Actual',
                          style: TextStyle(
                            color: _lastEvent != null 
                                ? const Color(0xFFFFB300) 
                                : const Color(0xFF2F4F4F),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.015),
                    
                    // Contenido del evento
                    if (row >= 16)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB71C1C).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFB71C1C),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.dangerous,
                              color: Color(0xFFB71C1C),
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '🏴‍☠️ JUEGO TERMINADO 🏴‍☠️',
                              style: TextStyle(
                                color: Color(0xFFB71C1C),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'El Lord Legislador ha triunfado.\n\nLos héroes han sido derrotados y Luthadel ha caído bajo su dominio absoluto.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.6,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Pulsa "Nueva Partida" para intentarlo de nuevo.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else if (_lastEvent == null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D0D0D).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF2F4F4F).withValues(alpha: 0.3),
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
                        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.03),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D0D0D).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFB71C1C).withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Información del incremento de X (solo cuando X se incremente)
                            if (_xIncreased)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFB300).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFFFB300).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '📈 X se ha incrementado a ${x ?? 0}!',
                                  style: const TextStyle(
                                    color: Color(0xFFFFB300),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            // Texto del evento
                            Text(
                              _lastEvent!.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.6,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Historial con estilo Mistborn
              Row(
                children: [
                  const Icon(
                    Icons.history,
                    color: Color(0xFFFFB300),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Historial de Eventos',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFFFFB300),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Historial scrollable - altura adaptativa
              Container(
                height: MediaQuery.of(context).size.height * 0.25, // 25% de la altura de pantalla
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF2F4F4F).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                  child: _eventHistory.isEmpty
                      ? const Center(
                          child: Text(
                            'Sin eventos aún.\n\nA medida que avances en el Dominance Track,\nlos eventos aparecerán aquí.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: _eventHistory.length,
                          itemBuilder: (context, index) {
                            final entry = _eventHistory[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF404040).withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFB71C1C).withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Fila ${entry.row} (X=${entry.x})',
                                    style: const TextStyle(
                                      color: Color(0xFFFFB300),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.event.text,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
            ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}