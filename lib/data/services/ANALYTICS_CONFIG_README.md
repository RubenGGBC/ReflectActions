# Analytics Configuration System v3

## Visión General

El nuevo sistema de configuraciones dinámicas para Analytics V3 elimina todos los valores hardcodeados y permite personalización completa por usuario. El sistema incluye:

- **Configuraciones dinámicas** basadas en datos del usuario
- **Presets configurables** para diferentes niveles de experiencia
- **Adaptación automática** basada en patrones de uso
- **Validación estadística mejorada** con thresholds configurables

## Componentes Principales

### 1. AnalyticsConfig
Configuración principal que contiene todos los parámetros de análisis:

```dart
final config = await configService.getConfigForUser(userId);

// Acceder a pesos de wellness score
final moodWeight = config.wellnessConfig.componentWeights['mood']; // 0.25

// Acceder a thresholds de correlación
final strongThreshold = config.correlationConfig.strengthThresholds['strong']; // 0.7

// Obtener configuración de hábitos
final meditationTarget = config.getHabitTarget('meditation'); // 10.0 minutos
```

### 2. Presets Predefinidos
Tres niveles de configuración automática:

- **Principiante**: Análisis simplificado, thresholds más permisivos
- **Intermedio**: Configuración balanceada (por defecto)
- **Avanzado**: Análisis completo, thresholds más estrictos

### 3. Adaptación Automática
El sistema se adapta automáticamente basado en:

- **Disponibilidad de datos**: Ajusta pesos según métricas disponibles
- **Varianza de datos**: Modifica thresholds según consistencia
- **Rendimiento histórico**: Personaliza targets de hábitos

## Uso en Código

### Inicialización
```dart
// En el provider
await analyticsProvider.initialize();

// O directamente en extension
await analyticsExtension.initialize();
```

### Obtener Configuración
```dart
// Obtener configuración del usuario (con fallback a global)
final config = await configService.getConfigForUser(userId);

// Obtener configuración optimizada según experiencia
final optimizedConfig = await configService.getOptimizedConfigForUser(userId);
```

### Actualizar Configuraciones
```dart
// Actualizar sección específica
await configService.updateConfigSection(userId, 'wellness', {
  'componentWeights': {
    'mood': 0.3,    // Dar más peso al estado de ánimo
    'energy': 0.25,
    'stress': 0.25,
    'sleep': 0.2,
  }
});

// Adaptación automática basada en datos
await configService.adaptConfigToUserData(userId);
```

### Crear Configuración Personalizada
```dart
// Crear desde preset
await configService.createUserConfigFromPreset(userId, 'Avanzado');

// Modificar configuración existente
final userConfig = await configService.getConfigForUser(userId);
final updatedConfig = userConfig.copyWith(
  wellnessConfig: userConfig.wellnessConfig.copyWith(
    componentWeights: {'mood': 0.4, 'energy': 0.6}, // Solo mood y energy
  ),
);
await configService.saveConfig(updatedConfig);
```

## Configuraciones Disponibles

### Wellness Score
```dart
WellnessScoreConfig(
  componentWeights: {
    'mood': 0.25,           // Peso del estado de ánimo
    'energy': 0.20,         // Peso de energía
    'stress': 0.20,         // Peso de estrés (invertido)
    'sleep': 0.15,          // Peso de sueño
    'anxiety': 0.10,        // Peso de ansiedad (invertido)
    'motivation': 0.05,     // Peso de motivación
    'emotional_stability': 0.03,  // Peso de estabilidad emocional
    'life_satisfaction': 0.02,    // Peso de satisfacción de vida
  },
  wellnessThresholds: {
    'excellent': 8.0,       // > 8.0 = Excelente
    'good': 6.5,           // 6.5-8.0 = Bueno
    'average': 5.0,        // 5.0-6.5 = Promedio
    'poor': 0.0,           // < 5.0 = Necesita atención
  },
  minimumDataPoints: 3,    // Mínimo de entradas para análisis confiable
  significanceThreshold: 0.05,  // p-value para significancia estadística
)
```

### Correlaciones
```dart
CorrelationConfig(
  minimumDataPoints: 7,    // Mínimo de puntos de datos para correlación
  strengthThresholds: {
    'strong': 0.7,         // |r| >= 0.7 = Correlación fuerte
    'moderate': 0.5,       // |r| >= 0.5 = Correlación moderada
    'weak': 0.3,           // |r| >= 0.3 = Correlación débil
    'negligible': 0.0,     // |r| < 0.3 = Correlación negligible
  },
  confidenceLevel: 0.95,   // 95% de confianza estadística
)
```

### Hábitos
```dart
HabitConfig(
  habitName: 'meditation',
  displayName: 'Meditación',
  column: 'meditation_minutes',
  targets: {
    'beginner': 5.0,       // Meta para principiantes
    'intermediate': 15.0,  // Meta para intermedios
    'advanced': 30.0,      // Meta para avanzados
    'recommended': 10.0,   // Meta recomendada general
  },
  scoreRanges: {
    'excellent': 20.0,     // >= 20 min = Excelente
    'good': 15.0,          // >= 15 min = Bueno
    'average': 10.0,       // >= 10 min = Promedio
    'poor': 5.0,           // >= 5 min = Bajo
    'none': 0.0,           // 0 min = Ninguno
  },
  unit: 'minutos',
  isInverted: false,       // false = más es mejor, true = menos es mejor
)
```

## Mejoras Implementadas

### 1. Eliminación de Valores Hardcodeados
- ❌ Antes: `moodScore * 0.25` (hardcodeado)
- ✅ Ahora: `moodScore * config.wellnessConfig.componentWeights['mood']`

### 2. Validación Estadística Mejorada
- Thresholds de significancia configurables
- Grados de libertad considerados correctamente
- P-values calculados más precisamente

### 3. Targets Dinámicos para Hábitos
- Basados en rendimiento histórico del usuario (percentil 75)
- Configurables por nivel de experiencia
- Bounds automáticos basados en configuración

### 4. Recomendaciones Personalizadas
- Generadas dinámicamente basadas en configuración
- Consideran varianza de datos para contexto
- Incluyen métricas de calidad de datos

### 5. Adaptación Automática
- Ajusta pesos basado en disponibilidad de datos
- Modifica thresholds según varianza de datos
- Personaliza targets según rendimiento histórico

## Migración desde Sistema Anterior

### Valores Equivalentes
Los valores por defecto mantienen compatibilidad con el sistema anterior:

```dart
// Antes (hardcodeado)
if (overallScore >= 8.0) wellnessLevel = 'excellent';

// Ahora (configurable)
final wellnessLevel = config.getWellnessLevel(overallScore);
```

### Inicialización Requerida
```dart
// Asegurar inicialización antes de usar analytics
await analyticsProvider.initialize();
```

### Limpieza de Cache
```dart
// Limpiar cache después de cambios de configuración
analyticsProvider.clearCache();
```

## Performance y Caching

### Caching Multinivel
1. **Provider Level**: Cache de configuraciones por usuario
2. **Extension Level**: Cache de configuraciones frecuentemente usadas
3. **Service Level**: Cache de configuraciones globales

### Invalidación Inteligente
- Cache se invalida automáticamente al actualizar configuraciones
- Limpieza selectiva por usuario
- Recarga automática en próximo acceso

## Monitoreo y Debugging

### Logs de Configuración
```dart
if (kDebugMode) {
  print('Using config version: ${config.id}');
  print('Wellness weights: ${config.wellnessConfig.componentWeights}');
}
```

### Métricas de Calidad de Datos
```dart
final dataQuality = rawMetrics['data_quality']; // 0.0 - 1.0
final configVersion = rawMetrics['configuration_version'];
```

## Casos de Uso Comunes

### 1. Usuario Principiante
```dart
await configService.createUserConfigFromPreset(userId, 'Principiante');
```

### 2. Usuario Experto
```dart
final config = await configService.getConfigForUser(userId);
final customConfig = config.copyWith(
  correlationConfig: config.correlationConfig.copyWith(
    strengthThresholds: {'strong': 0.6, 'moderate': 0.4}, // Más sensible
  ),
);
await configService.saveConfig(customConfig);
```

### 3. Optimización Automática
```dart
// Ejecutar periódicamente (ej: cada 30 días)
await configService.adaptConfigToUserData(userId);
```

Esta implementación proporciona un sistema completamente configurable y adaptable que mejora significativamente la precisión y personalización de los analytics mientras mantiene compatibilidad con el código existente.