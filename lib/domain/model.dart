import 'dart:convert';

class DifficultyConfig {
  final String id;
  final String name;
  final List<int> xCurve; // 16 valores

  DifficultyConfig({
    required this.id,
    required this.name,
    required this.xCurve,
  });

  factory DifficultyConfig.fromJson(Map<String, dynamic> json) {
    return DifficultyConfig(
      id: json['id'],
      name: json['name'],
      xCurve: (json['xCurve'] as List<dynamic>).map((e) => e as int).toList(),
    );
  }
}

class EventConfig {
  final String id;
  final int? dominance; // null o 0 = genérico, valor específico = solo para ese X
  final String text;
  final List<String> tags;
  final String? source;
  final int weight;
  final int? maxTimesPerGame;

  EventConfig({
    required this.id,
    this.dominance,
    required this.text,
    this.tags = const [],
    this.source,
    this.weight = 1,
    this.maxTimesPerGame,
  });

  factory EventConfig.fromJson(Map<String, dynamic> json) {
    return EventConfig(
      id: json['id'],
      dominance: json['dominance'] as int?,
      text: json['text'],
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      source: json['source'],
      weight: json['weight'] ?? 1,
      maxTimesPerGame: json['maxTimesPerGame'] as int?,
    );
  }

  EventConfig withX(int x) {
    return EventConfig(
      id: id,
      dominance: dominance,
      text: text.replaceAll('{X}', x.toString()),
      tags: tags,
      source: source,
      weight: weight,
      maxTimesPerGame: maxTimesPerGame,
    );
  }

  /// Determina si este evento puede aparecer para el valor X dado
  bool isAvailableForX(int x) {
    return dominance == null || dominance == 0 || dominance == x;
  }
}

class GameConfig {
  final List<DifficultyConfig> difficulties;
  final List<EventConfig> events;

  GameConfig({
    required this.difficulties,
    required this.events,
  });

  factory GameConfig.fromJson(Map<String, dynamic> json) {
    final diffsJson = json['difficulties'] as List<dynamic>;
    final eventsJson = json['events'] as List<dynamic>;
    return GameConfig(
      difficulties: diffsJson
          .map((e) => DifficultyConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      events: eventsJson
          .map((e) => EventConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Helper si luego quieres buscar dificultad por id
  DifficultyConfig? findDifficulty(String id) {
    return difficulties.firstWhere(
      (d) => d.id == id,
      orElse: () => difficulties.first,
    );
  }
}

class GameState {
  final DifficultyConfig difficulty;
  final int currentRow; // 0..16
  final Map<String, int> usageCount; // id -> veces usado

  GameState({
    required this.difficulty,
    this.currentRow = 0,
    this.usageCount = const {},
  });

  int? get currentX {
    if (currentRow >= 1 && currentRow <= difficulty.xCurve.length) {
      return difficulty.xCurve[currentRow - 1];
    }
    return null;
  }

  int timesUsed(String eventId) => usageCount[eventId] ?? 0;

  GameState copyWith({
    DifficultyConfig? difficulty,
    int? currentRow,
    Map<String, int>? usageCount,
  }) {
    return GameState(
      difficulty: difficulty ?? this.difficulty,
      currentRow: currentRow ?? this.currentRow,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}

