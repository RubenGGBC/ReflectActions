# 📊 Datos de Prueba para Analytics V4

Este directorio contiene herramientas para generar datos de prueba realistas para la pantalla de Analytics V4 de ReflectActions.

## 📁 Archivos Disponibles

### 1. `analytics_test_data.sql`
Script SQL directo con datos de prueba pre-generados.

**Contiene:**
- ✅ 30+ entradas diarias con métricas de bienestar
- ✅ 35+ momentos interactivos (Quick Moments)
- ✅ 15 metas de usuario (5 completadas, 10 activas)
- ✅ Tendencia clara de mejora a lo largo de 90 días
- ✅ Datos variados y realistas

**Uso:**
```sql
-- Opción 1: Desde un cliente SQLite
.read test_data/analytics_test_data.sql

-- Opción 2: Ejecutar consultas manualmente
-- Copia y pega las secciones del archivo SQL que necesites
```

### 2. `simple_analytics_data_seeder.dart`
Clase Dart para generar datos de prueba programáticamente.

**Características:**
- 🎯 Generación dinámica de datos
- 🔧 Personalizable (días, cantidad, usuario)
- 📈 Tendencias automáticas de mejora
- 🧹 Función de limpieza incluida

**Uso:**
```dart
import 'package:reflect_actions/test_data/simple_analytics_data_seeder.dart';
import 'package:reflect_actions/data/services/optimized_database_service.dart';

// Inicializar
final dbService = OptimizedDatabaseService();
final seeder = SimpleAnalyticsDataSeeder(dbService);

// Generar todos los datos
await seeder.seedAllData(userId: 1, daysBack: 90);

// O generar componentes individuales
await seeder.seedDailyEntries(userId: 1, daysBack: 60);
await seeder.seedQuickMoments(userId: 1, daysBack: 30);
await seeder.seedGoals(userId: 1);

// Limpiar cuando termines
await seeder.clearAllData(userId: 1);
```

### 3. `v4_analytics_test_data_seeder.dart`
Seeder original más complejo con algoritmos avanzados de generación de datos.

## 🚀 Guía Rápida de Uso

### Método 1: SQL Directo (Más Rápido)

**Paso 1:** Localiza tu base de datos SQLite
```bash
# Android
adb shell
cd /data/data/com.tuapp.reflect_actions/databases/
```

**Paso 2:** Ejecuta el script SQL
```bash
sqlite3 reflect_zen.db < analytics_test_data.sql
```

**Paso 3:** Verifica los datos
```sql
SELECT COUNT(*) FROM daily_entries WHERE user_id = 1;
SELECT COUNT(*) FROM interactive_moments WHERE user_id = 1;
SELECT COUNT(*) FROM user_goals WHERE user_id = 1;
```

### Método 2: Clase Dart (Más Flexible)

**Paso 1:** Copia el archivo al proyecto
```bash
cp test_data/simple_analytics_data_seeder.dart lib/test_data/
```

**Paso 2:** Crea un botón de prueba en tu app
```dart
// En alguna pantalla de desarrollo
ElevatedButton(
  onPressed: () async {
    final seeder = SimpleAnalyticsDataSeeder(
      context.read<OptimizedDatabaseService>()
    );

    await seeder.seedAllData(
      userId: currentUser.id,
      daysBack: 90
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Datos de prueba generados!'))
    );
  },
  child: Text('Generar Datos de Prueba'),
)
```

**Paso 3:** Ejecuta y prueba la pantalla de Analytics

## 📊 Estructura de Datos Generados

### Entradas Diarias (daily_entries)
```dart
{
  'user_id': 1,
  'entry_date': '2024-01-15',
  'mood_score': 8,              // 1-10, mejora con el tiempo
  'energy_level': 7,            // 1-10, mejora con el tiempo
  'stress_level': 3,            // 1-10, disminuye con el tiempo
  'sleep_quality': 8,           // 1-10, mejora con el tiempo
  'anxiety_level': 3,           // 1-10, disminuye con el tiempo
  'motivation_level': 8,        // 1-10, mejora con el tiempo
  'social_interaction': 7,      // 1-10
  'physical_activity': 7,       // 1-10
  'work_productivity': 8,       // 1-10
  'emotional_stability': 8,     // 1-10
  'focus_level': 8,             // 1-10
  'life_satisfaction': 8,       // 1-10
  'sleep_hours': 7.5,           // horas
  'water_intake': 8,            // vasos
  'meditation_minutes': 20,     // minutos (opcional)
  'exercise_minutes': 45,       // minutos (opcional)
  'screen_time_hours': 4.0,     // horas
  'free_reflection': 'Gran día...',
  'positive_tags': '["energizado", "motivado"]',
  'negative_tags': '[]'
}
```

### Momentos Interactivos (interactive_moments)
```dart
{
  'user_id': 1,
  'entry_date': '2024-01-15',
  'emoji': '☕',
  'text': 'Perfecto café de la mañana',
  'type': 'positive',           // positive, negative, neutral
  'intensity': 8,               // 1-10
  'category': 'routine',        // routine, exercise, social, etc.
  'time_str': '07:30',
  'created_at': '2024-01-15T07:30:00'
}
```

### Metas (user_goals)
```dart
{
  'user_id': 1,
  'title': 'Práctica Diaria de Meditación',
  'description': 'Meditar 10 minutos cada día',
  'target_value': 30,
  'current_value': 18,
  'status': 'active',           // active, completed
  'category': 'mindfulness',    // mindfulness, physical, emotional, etc.
  'created_at': '2024-01-01T10:00:00',
  'completed_at': null          // o fecha si está completada
}
```

## 🎨 Tendencias Generadas

Los datos incluyen tendencias realistas:

1. **Mejora Gradual** (90 días → hoy)
   - Mood: 4 → 9
   - Energy: 4 → 9
   - Stress: 8 → 3
   - Anxiety: 7 → 3

2. **Variación Diaria Realista**
   - Fines de semana: menos productividad, más descanso
   - Entre semana: más actividad, posible estrés
   - Variación aleatoria natural

3. **Patrones de Logros**
   - Metas completadas en el tiempo
   - Progreso incremental visible
   - Algunos días mejores que otros

## 🧪 Casos de Prueba

### Probar Motivation Score
- Verifica que el score esté entre 0-10
- Debe reflejar el promedio de las métricas

### Probar Wellbeing Trends
- Tendencias deben mostrar mejora
- Gráficos deben renderizar correctamente
- Porcentajes de mejora calculados

### Probar Goals Progress
- 5 metas completadas visibles
- 10 metas activas con progreso
- Tasas de éxito calculadas

### Probar Quick Moments
- ~150 momentos distribuidos
- 75% positivos, 25% negativos/neutrales
- Positivity ratio > 60%

## 🔧 Personalización

### Cambiar Cantidad de Días
```dart
await seeder.seedAllData(userId: 1, daysBack: 60); // Solo 60 días
```

### Generar Solo Ciertos Datos
```dart
// Solo entradas diarias
await seeder.seedDailyEntries(userId: 1, daysBack: 30);

// Solo momentos
await seeder.seedQuickMoments(userId: 1, daysBack: 14);

// Solo metas
await seeder.seedGoals(userId: 1);
```

### Limpiar Datos
```dart
await seeder.clearAllData(userId: 1); // Elimina todo
```

## 📝 Notas Importantes

1. **User ID:** Asegúrate de que el usuario exista antes de insertar datos
2. **Conflictos:** El SQL usa `INSERT` simple, el Dart usa `replace` en conflictos
3. **Performance:** Generar 90 días puede tomar 5-10 segundos
4. **Desarrollo:** Estos datos son solo para pruebas, no usar en producción

## 🐛 Solución de Problemas

### Error: "no such table: daily_entries"
**Solución:** Ejecuta primero las migraciones de la base de datos

### Error: "FOREIGN KEY constraint failed"
**Solución:** Crea primero un usuario con ID correspondiente

### Los datos no aparecen en Analytics
**Solución:**
1. Verifica que el user_id coincida
2. Recarga la pantalla de analytics
3. Revisa los logs de debug

## 📚 Recursos Adicionales

- Ver `analytics_screen_v4.dart` para entender qué datos usa la UI
- Ver `analytics_database_extension_v4_simple.dart` para queries de analytics
- Ver `analytics_provider_v4.dart` para lógica de procesamiento

---

**¿Preguntas?** Revisa el código de ejemplo en cada archivo o consulta la documentación del proyecto.
