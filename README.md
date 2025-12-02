# 🌟 Mistborn Dominance Tracker

Una aplicación companion para el juego de mesa **Mistborn: House War** que te ayuda a gestionar el Dominance Track y los eventos dinámicos durante tus partidas.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=flat&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=flat&logo=android&logoColor=white)

## ✨ Características

### 🎮 **Gameplay Dinámico**
- **Dominance Track interactivo**: Progresión visual del track con valores X automáticos
- **Eventos contextuales**: Sistema inteligente de eventos basado en la posición actual
- **Múltiples dificultades**: Diferentes curvas de progresión para variar la experiencia

### 🎯 **Sistema de Eventos Avanzado** 
- **Eventos específicos**: Aparecen solo en valores X determinados
- **Eventos genéricos**: Disponibles en cualquier momento con efectos escalables
- **Sistema de fallback**: Si no hay eventos para X, busca automáticamente en X-1
- **Control de frecuencia**: Algunos eventos solo pueden aparecer una vez por partida

### ⚙️ **Configuración Personalizable**
- **Importar/Exportar**: Crea y comparte tus propias configuraciones de eventos
- **Validación automática**: Sistema robusto de validación de archivos JSON
- **Múltiples configuraciones**: Cambia entre diferentes sets de eventos
- **Gestión intuitiva**: Interfaz fácil para manejar configuraciones

### 🎨 **Diseño Temático Mistborn**
- **Paleta de colores inmersiva**: Inspirada en las brumas y metales de Scadrial
- **Interfaz responsiva**: Optimizada para diferentes tamaños de pantalla
- **Iconografía personalizada**: Íconos únicos creados específicamente para la app
- **Feedback visual**: Animaciones y transiciones que mejoran la experiencia

## 🚀 Instalación

### Compilar desde el código fuente

#### **Requisitos**
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.0+)
- [Android Studio](https://developer.android.com/studio) o VS Code
- Dispositivo Android o emulador

#### **Pasos**
```bash
# Clonar el repositorio
git clone https://github.com/idsnet-repo/mistborn_dominance.git
cd mistborn_dominance

# Instalar dependencias
flutter pub get

# Generar íconos de la aplicación
flutter pub run flutter_launcher_icons:main

# Ejecutar en modo debug
flutter run

# O compilar APK de release
flutter build apk --release
```

## 📱 Uso de la Aplicación

### 🎯 **Flujo Básico de Juego**

1. **Selecciona la dificultad** en el dropdown superior
2. **Pulsa "Dominance Up"** para avanzar en el track
3. **Lee el evento** que aparece y aplícalo al juego
4. **Observa el incremento de X** cuando se muestre el banner dorado
5. **Consulta el historial** para revisar eventos anteriores
6. **Reinicia** con "Nueva Partida" cuando sea necesario

### 🔧 **Gestión de Configuraciones**

1. **Ve a Configuración** (⚙️) desde el menú superior
2. **Importar**: Toca "Importar Configuración" y selecciona un archivo JSON
3. **Exportar**: Usa "Exportar Configuración" para compartir tu setup
4. **Cambiar**: Selecciona diferentes configuraciones desde la lista

## 📋 Configuraciones Personalizadas

¿Quieres crear tus propios eventos y dificultades? ¡Es muy fácil!

👉 **[Guía completa de configuraciones](CONFIG_GUIDE.md)** 

### Ejemplo rápido:
```json
{
  "events": [
    {
      "id": "mi_evento_custom",
      "text": "Cada jugador recibe {X} de daño.",
      "dominance": 3,
      "tags": ["damage"],
      "weight": 2,
      "maxTimesPerGame": 1
    }
  ],
  "difficulties": [
    {
      "id": "facil",
      "name": "Fácil",
      "xCurve": [1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6]
    }
  ]
}
```

## 🛠️ Tecnologías Utilizadas

- **[Flutter](https://flutter.dev/)**: Framework de UI multiplataforma
- **[Dart](https://dart.dev/)**: Lenguaje de programación
- **Material Design 3**: Sistema de diseño moderno
- **SharedPreferences**: Persistencia de configuraciones
- **File Picker**: Importación de archivos JSON
- **Wakelock Plus**: Mantiene la pantalla activa durante el juego

## 🎮 Compatibilidad con Mistborn: The Deckbuilding Game

Esta aplicación está diseñada como companion para **Mistborn: The Deckbuilding Game** de Brotherwise Games. Los eventos y mecánicas están inspirados en el juego oficial pero son completamente customizables.

### 📚 **Relación con el Juego Base**
- **Dominance Track**: Refleja la mecánica central del juego
- **Eventos**: Inspirados en las cartas de evento del juego base
- **Valores X**: Corresponden al sistema de escalado del juego oficial

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Si tienes ideas para mejorar la app:

### 💡 **Ideas para contribuir**
- Nuevas configuraciones de eventos
- Mejoras en la UI/UX
- Soporte para más idiomas
- Nuevas características de gameplay
- Optimizaciones de rendimiento

## 📄 Licencia

Este proyecto está licenciado bajo la [MIT License](LICENSE).

---

**¡Que disfrutes tus partidas de Mistborn con esta companion app!** ⚔️✨
