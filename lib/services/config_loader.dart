import 'config_manager.dart';
import '../domain/model.dart';

Future<GameConfig> loadGameConfig() async {
  return await ConfigManager.loadActiveConfig();
}

