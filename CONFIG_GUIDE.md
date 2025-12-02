# 📋 Guía para Crear Configuraciones JSON Personalizadas

## 📖 Introducción

Esta guía te ayudará a crear tus propios archivos de configuración JSON para personalizar los eventos y dificultades del juego Mistborn Dominance.

## 📁 Estructura General del Archivo

```json
{
  "events": [
    // Array de eventos disponibles
  ],
  "difficulties": [
    // Array de configuraciones de dificultad
  ]
}
```

## 🎲 Sección: Events (Eventos)

### Estructura Básica de un Evento

```json
{
  "id": "identificador_unico_del_evento",
  "text": "Texto descriptivo del evento que verán los jugadores",
  "dominance": 5,
  "tags": ["tag1", "tag2"],
  "source": "custom",
  "weight": 1
}
```

### Campos Explicados

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | String | ✅ Sí | Identificador único para el evento (sin espacios) |
| `text` | String | ✅ Sí | Texto que aparece al jugador cuando ocurre el evento |
| `dominance` | Integer | ❌ No | Valor X específico para que aparezca (ver sección especial) |
| `tags` | Array[String] | ❌ No | Etiquetas para categorizar el evento |
| `source` | String | ❌ No | Origen del evento ("custom", "intro_like", etc.) |
| `weight` | Integer | ❌ No | Peso para probabilidad (por defecto: 1) |
| `maxTimesPerGame` | Integer | ❌ No | Máximo número de veces que puede aparecer por partida |

### 🎯 Sistema de Dominance

El campo `dominance` controla cuándo puede aparecer un evento:

#### Eventos Específicos
```json
{
  "dominance": 3,
  "text": "Este evento SOLO aparece cuando X = 3"
}
```

#### Eventos Genéricos
```json
{
  // Sin campo dominance - puede aparecer en cualquier X
  "text": "Este evento puede aparecer siempre"
}
```

```json
{
  "dominance": 0,  // Equivalente a omitir el campo
  "text": "Este evento también puede aparecer siempre"
}
```

### 💡 Variables Dinámicas en Texto

Puedes usar `{X}` en el texto para mostrar el valor actual de X:

```json
{
  "text": "Cada jugador recibe {X} de daño.",
  "dominance": 0
}
```

### 🏷️ Tags Recomendados

```json
"tags": [
  "damage",      // Eventos que causan daño
  "discard",     // Eventos que hacen descartar cartas
  "mill",        // Eventos que descartan del mazo
  "tap",         // Eventos que agotan cartas
  "metals",      // Eventos relacionados con metales
  "restriction", // Eventos que limitan acciones
  "mild",        // Eventos suaves (X bajo)
  "severe",      // Eventos severos (X alto)
  "finale",      // Eventos de final de partida
  "generic"      // Eventos genéricos
]
```

### 📊 Sistema de Weight (Peso)

El peso controla la probabilidad de que aparezca un evento:

```json
{
  "weight": 1,  // Probabilidad normal
  "text": "Evento común"
},
{
  "weight": 3,  // 3 veces más probable
  "text": "Evento frecuente"
},
{
  "weight": 0.5,  // Mitad de probabilidad (NO usar, solo enteros)
  "text": "❌ Incorrecto - usar solo números enteros"
}
```

### 🔢 Sistema de maxTimesPerGame

Controla cuántas veces puede aparecer un evento en una partida:

```json
{
  "maxTimesPerGame": 1,  // Solo puede aparecer 1 vez
  "text": "Evento único y especial"
},
{
  "maxTimesPerGame": 3,  // Máximo 3 veces por partida
  "text": "Evento limitado"
},
{
  // Sin maxTimesPerGame - puede aparecer ilimitadamente
  "text": "Evento sin límite"
}
```

**Casos de uso típicos:**
- `"maxTimesPerGame": 1` → Eventos únicos, efectos permanentes
- `"maxTimesPerGame": 2-3` → Eventos especiales pero no únicos
- Sin `maxTimesPerGame` → Eventos comunes que pueden repetirse

## ⚙️ Sección: Difficulties (Dificultades)

### Estructura de una Dificultad

```json
{
  "id": "identificador_unico",
  "name": "Nombre Visible",
  "xCurve": [1,1,1,2,2,3,3,4,5,6,7,8,9,10,11,12]
}
```

### Campos Explicados

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `id` | String | ✅ Sí | Identificador único (sin espacios) |
| `name` | String | ✅ Sí | Nombre que ve el jugador |
| `xCurve` | Array[Integer] | ✅ Sí | Array de exactamente 16 valores (filas 1-16) |

### 📈 Diseño de xCurve

El `xCurve` define cómo progresa X a medida que avanzas en las filas:

```json
{
  "name": "Fácil",
  "xCurve": [1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4]
  // X aumenta lentamente, máximo X=4
}
```

```json
{
  "name": "Normal", 
  "xCurve": [1,1,2,2,3,3,4,5,6,7,8,9,10,11,12,13]
  // Progresión equilibrada
}
```

```json
{
  "name": "Extremo",
  "xCurve": [1,3,5,7,9,11,13,15,16,16,16,16,16,16,16,16]
  // X aumenta rápidamente, plateau en 16
}
```

## 📝 Ejemplos Completos

### Evento Específico (Solo X=1)
```json
{
  "id": "intro_damage",
  "text": "Cada jugador recibe 1 de daño.",
  "dominance": 1,
  "tags": ["damage", "mild"],
  "source": "custom",
  "weight": 2,
  "maxTimesPerGame": 1
}
```

### Evento Escalable (Cualquier X)
```json
{
  "id": "variable_damage",
  "text": "Cada jugador recibe {X} de daño según el nivel actual del Dominance Track.",
  "tags": ["damage", "variable"],
  "source": "custom",
  "weight": 1
}
```

### Evento de Final de Partida
```json
{
  "id": "endgame_catastrophe",
  "text": "Las brumas consumen la ciudad: agota todas las cartas que tengas en juego y descarta las {X} cartas superiores de tu mazo.",
  "dominance": 16,
  "tags": ["tap", "mill", "finale", "severe"],
  "source": "custom",
  "weight": 1
}
```

## 🎮 Configuración Completa de Ejemplo

```json
{
  "events": [
    {
      "id": "early_pressure",
      "text": "Los Obligadores patrullan: cada jugador descarta 1 carta.",
      "dominance": 1,
      "tags": ["discard", "mild"],
      "source": "custom",
      "weight": 2
    },
    {
      "id": "scaling_damage",
      "text": "Las brumas se intensifican: cada jugador recibe {X} de daño.",
      "tags": ["damage", "variable"],
      "source": "custom",
      "weight": 1
    },
    {
      "id": "metal_disruption",
      "text": "Interferencia alomántica: elige 1 metal que hayas usado este turno. No podrás usarlo el próximo turno.",
      "dominance": 8,
      "tags": ["metals", "restriction", "severe"],
      "source": "custom",
      "weight": 1
    }
  ],
  "difficulties": [
    {
      "id": "beginner",
      "name": "Principiante",
      "xCurve": [1,1,1,1,1,2,2,2,2,3,3,3,4,4,4,5]
    },
    {
      "id": "expert",
      "name": "Experto",
      "xCurve": [2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,16]
    }
  ]
}
```

## 🔧 Consejos de Diseño

### ✅ Buenas Prácticas

1. **Balance de Eventos por X**: Asegúrate de tener eventos para diferentes valores de X
2. **Eventos Genéricos**: Incluye algunos eventos sin `dominance` para flexibilidad
3. **Progresión Coherente**: Los eventos con X más alto deben ser más severos
4. **IDs Únicos**: Usa IDs descriptivos y únicos para cada evento
5. **Testear**: Prueba tu configuración antes de usarla en partidas importantes

### ❌ Errores Comunes

1. **xCurve incorrecto**: Debe tener exactamente 16 valores
2. **IDs duplicados**: Cada evento debe tener un ID único
3. **Dominance fuera de rango**: Usar valores de 1-16 (o 0 para genérico)
4. **JSON inválido**: Verificar sintaxis (comas, llaves, etc.)

## 🛠️ Herramientas Útiles

- **Validador JSON**: https://jsonlint.com/
- **Editor JSON**: Cualquier editor de texto con resaltado de sintaxis
- **Calculadora de Probabilidades**: Para balancear weights

## 📱 Uso en la App

1. Crea tu archivo JSON siguiendo esta guía
2. Ve a **Configuración** en la app
3. Toca **"Importar Configuración"**
4. Selecciona tu archivo JSON
5. ¡Listo para jugar con tu configuración personalizada!

---

**¡Que disfrutes creando configuraciones épicas para Mistborn Dominance! ⚔️✨**