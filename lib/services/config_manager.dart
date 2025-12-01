import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/model.dart';

class ConfigInfo {
  final String id;
  final String name;
  final bool isDefault;
  final DateTime? dateAdded;

  ConfigInfo({
    required this.id,
    required this.name,
    required this.isDefault,
    this.dateAdded,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isDefault': isDefault,
    'dateAdded': dateAdded?.toIso8601String(),
  };

  factory ConfigInfo.fromJson(Map<String, dynamic> json) => ConfigInfo(
    id: json['id'],
    name: json['name'],
    isDefault: json['isDefault'],
    dateAdded: json['dateAdded'] != null ? DateTime.parse(json['dateAdded']) : null,
  );
}

class ConfigManager {
  static const String _configsFileName = 'configs_info.json';
  static const String _activeConfigFileName = 'active_config.txt';
  static const String _defaultConfigId = 'default';

  static Future<Directory> _getConfigsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final configDir = Directory('${appDir.path}/dominance_configs');
    if (!await configDir.exists()) {
      await configDir.create(recursive: true);
    }
    return configDir;
  }

  static Future<List<ConfigInfo>> getAvailableConfigs() async {
    try {
      final configDir = await _getConfigsDirectory();
      final configsFile = File('${configDir.path}/$_configsFileName');
      
      List<ConfigInfo> configs = [];
      
      // Siempre incluir la configuración por defecto
      configs.add(ConfigInfo(
        id: _defaultConfigId,
        name: 'Configuración Por Defecto',
        isDefault: true,
      ));

      if (await configsFile.exists()) {
        final content = await configsFile.readAsString();
        final List<dynamic> configsJson = json.decode(content);
        
        for (var configJson in configsJson) {
          configs.add(ConfigInfo.fromJson(configJson));
        }
      }

      return configs;
    } catch (e) {
      // En caso de error, al menos devolver la configuración por defecto
      return [ConfigInfo(
        id: _defaultConfigId,
        name: 'Configuración Por Defecto',
        isDefault: true,
      )];
    }
  }

  static Future<void> _saveConfigsList(List<ConfigInfo> configs) async {
    final configDir = await _getConfigsDirectory();
    final configsFile = File('${configDir.path}/$_configsFileName');
    
    // Solo guardar las configuraciones no predeterminadas
    final customConfigs = configs.where((c) => !c.isDefault).toList();
    final configsJson = customConfigs.map((c) => c.toJson()).toList();
    
    await configsFile.writeAsString(json.encode(configsJson));
  }

  static Future<String> saveConfig(String name, String content) async {
    // Validar que el JSON sea válido
    final jsonData = json.decode(content);
    GameConfig.fromJson(jsonData); // Esto lanzará excepción si no es válido
    
    final configDir = await _getConfigsDirectory();
    final configId = DateTime.now().millisecondsSinceEpoch.toString();
    final configFile = File('${configDir.path}/$configId.json');
    
    await configFile.writeAsString(content);
    
    // Actualizar la lista de configuraciones
    final configs = await getAvailableConfigs();
    configs.add(ConfigInfo(
      id: configId,
      name: name,
      isDefault: false,
      dateAdded: DateTime.now(),
    ));
    
    await _saveConfigsList(configs);
    
    return configId;
  }

  static Future<String> getConfigContent(String configId) async {
    if (configId == _defaultConfigId) {
      // Cargar la configuración por defecto desde assets
      return await rootBundle.loadString('assets/dominance_config.json');
    } else {
      // Cargar configuración personalizada
      final configDir = await _getConfigsDirectory();
      final configFile = File('${configDir.path}/$configId.json');
      return await configFile.readAsString();
    }
  }

  static Future<GameConfig> loadConfig(String configId) async {
    final content = await getConfigContent(configId);
    final jsonData = json.decode(content);
    return GameConfig.fromJson(jsonData);
  }

  static Future<void> deleteConfig(String configId) async {
    if (configId == _defaultConfigId) {
      throw Exception('No se puede eliminar la configuración por defecto');
    }

    final configDir = await _getConfigsDirectory();
    final configFile = File('${configDir.path}/$configId.json');
    
    if (await configFile.exists()) {
      await configFile.delete();
    }

    // Actualizar la lista de configuraciones
    final configs = await getAvailableConfigs();
    configs.removeWhere((c) => c.id == configId);
    await _saveConfigsList(configs);

    // Si era la configuración activa, cambiar a la por defecto
    final activeId = await getActiveConfigId();
    if (activeId == configId) {
      await setActiveConfig(_defaultConfigId);
    }
  }

  static Future<String> getActiveConfigId() async {
    try {
      final configDir = await _getConfigsDirectory();
      final activeFile = File('${configDir.path}/$_activeConfigFileName');
      
      if (await activeFile.exists()) {
        return await activeFile.readAsString();
      }
    } catch (e) {
      // En caso de error, usar la configuración por defecto
    }
    
    return _defaultConfigId;
  }

  static Future<void> setActiveConfig(String configId) async {
    final configDir = await _getConfigsDirectory();
    final activeFile = File('${configDir.path}/$_activeConfigFileName');
    await activeFile.writeAsString(configId);
  }

  static Future<GameConfig> loadActiveConfig() async {
    final activeId = await getActiveConfigId();
    return await loadConfig(activeId);
  }
}