import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'dart:io';
import '../services/config_manager.dart';
import '../domain/model.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  List<ConfigInfo> _configs = [];
  String? _activeConfigId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    try {
      final configs = await ConfigManager.getAvailableConfigs();
      final activeId = await ConfigManager.getActiveConfigId();
      
      setState(() {
        _configs = configs;
        _activeConfigId = activeId;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      _showError('Error cargando configuraciones: $e');
    }
  }

  Future<void> _importConfig() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        
        // Validar JSON
        final jsonData = json.decode(content);
        GameConfig.fromJson(jsonData); // Validación
        
        // Mostrar diálogo para nombre
        final name = await _showNameDialog();
        if (name != null && name.isNotEmpty) {
          await ConfigManager.saveConfig(name, content);
          _loadConfigs();
          _showSuccess('Configuración "$name" importada exitosamente');
        }
      }
    } catch (e) {
      _showError('Error importando archivo: $e');
    }
  }

  Future<void> _exportConfig(ConfigInfo config) async {
    try {
      final content = await ConfigManager.getConfigContent(config.id);
      final file = XFile.fromData(
        utf8.encode(content),
        name: '${config.name}.json',
        mimeType: 'application/json',
      );
      
      await Share.shareXFiles([file], text: 'Configuración de Mistborn Dominance: ${config.name}');
    } catch (e) {
      _showError('Error exportando configuración: $e');
    }
  }

  Future<void> _setActiveConfig(String configId) async {
    try {
      await ConfigManager.setActiveConfig(configId);
      setState(() {
        _activeConfigId = configId;
      });
      _showSuccess('Configuración activada');
    } catch (e) {
      _showError('Error activando configuración: $e');
    }
  }

  Future<void> _deleteConfig(ConfigInfo config) async {
    final confirmed = await _showConfirmDialog(
      'Eliminar Configuración',
      '¿Estás seguro de que deseas eliminar "${config.name}"?',
    );
    
    if (confirmed) {
      try {
        await ConfigManager.deleteConfig(config.id);
        _loadConfigs();
        _showSuccess('Configuración eliminada');
      } catch (e) {
        _showError('Error eliminando configuración: $e');
      }
    }
  }

  Future<String?> _showNameDialog() async {
    String? name;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nombre de la Configuración'),
        content: TextField(
          onChanged: (value) => name = value,
          decoration: const InputDecoration(
            hintText: 'Ingresa un nombre...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, name),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Eventos'),
        backgroundColor: const Color(0xFF2C2C2C),
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Botón de importar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _importConfig,
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Importar Configuración'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B0000),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Título
                  const Text(
                    'Configuraciones Disponibles',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Lista de configuraciones
                  Expanded(
                    child: ListView.builder(
                      itemCount: _configs.length,
                      itemBuilder: (context, index) {
                        final config = _configs[index];
                        final isActive = config.id == _activeConfigId;
                        
                        return Card(
                          color: const Color(0xFF2C2C2C),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              isActive ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: isActive ? const Color(0xFFD4AF37) : Colors.grey,
                            ),
                            title: Text(
                              config.name,
                              style: TextStyle(
                                color: isActive ? const Color(0xFFD4AF37) : Colors.white,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              config.isDefault ? 'Configuración por defecto' : 'Configuración personalizada',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _exportConfig(config),
                                  icon: const Icon(Icons.share, color: Colors.blue),
                                  tooltip: 'Exportar',
                                ),
                                if (!config.isDefault)
                                  IconButton(
                                    onPressed: () => _deleteConfig(config),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Eliminar',
                                  ),
                              ],
                            ),
                            onTap: isActive ? null : () => _setActiveConfig(config.id),
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
}