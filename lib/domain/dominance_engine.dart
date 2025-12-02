import 'dart:math';
import 'model.dart';

class DominanceEngine {
  final GameConfig config;
  final Random _random;

  DominanceEngine(this.config, {Random? random}) : _random = random ?? Random();

  /// Devuelve un nuevo estado + evento (o null si no hay)
  Map<String, dynamic> nextEvent(GameState state) {
    if (state.currentRow >= 16) {
      return {'state': state, 'event': null};
    }

    final newRow = state.currentRow + 1;
    final x = state.difficulty.xCurve[newRow - 1];

    // Buscar eventos disponibles para este valor X
    var candidates = config.events.where((e) => e.isAvailableForX(x)).toList();
    
    // Si no hay eventos específicos para X, buscar hacia atrás (X-1, X-2, etc.)
    if (candidates.where((e) => e.dominance == x).isEmpty) {
      for (int fallbackX = x - 1; fallbackX >= 1; fallbackX--) {
        final fallbackEvents = config.events.where((e) => e.dominance == fallbackX).toList();
        if (fallbackEvents.isNotEmpty) {
          candidates.addAll(fallbackEvents);
          break;
        }
      }
    }

    if (candidates.isEmpty) {
      final newState = state.copyWith(currentRow: newRow);
      return {'state': newState, 'event': null};
    }

    final usable = candidates.where((e) {
      final used = state.timesUsed(e.id);
      if (e.maxTimesPerGame != null && used >= e.maxTimesPerGame!) {
        return false;
      }
      return true;
    }).toList();

    final pool = usable.isNotEmpty ? usable : candidates;
    final selected = _weightedRandom(pool);

    final newUsage = Map<String, int>.from(state.usageCount);
    newUsage[selected.id] = (newUsage[selected.id] ?? 0) + 1;

    final newState = state.copyWith(
      currentRow: newRow,
      usageCount: newUsage,
    );

    final eventWithX = selected.withX(x);

    return {'state': newState, 'event': eventWithX};
  }

  EventConfig _weightedRandom(List<EventConfig> events) {
    final totalWeight = events.fold<int>(0, (sum, e) => sum + e.weight);
    var r = _random.nextInt(totalWeight) + 1;
    for (final e in events) {
      r -= e.weight;
      if (r <= 0) return e;
    }
    return events.last;
  }
}

