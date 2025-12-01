import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../domain/model.dart';

Future<GameConfig> loadGameConfig() async {
  final jsonStr = await rootBundle.loadString('assets/dominance_config.json');
  final data = json.decode(jsonStr) as Map<String, dynamic>;
  return GameConfig.fromJson(data);
}

