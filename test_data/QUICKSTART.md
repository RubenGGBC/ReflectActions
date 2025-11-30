# 🚀 Quick Start - Datos de Prueba Analytics V4

## Opción A: Método Rápido (Dart) - RECOMENDADO

### 1. Copia el seeder al proyecto
```bash
# Ya está en test_data/simple_analytics_data_seeder.dart
# No necesitas moverlo, solo importarlo
```

### 2. Usa el código de ejemplo
```dart
import 'package:reflect_actions/test_data/simple_analytics_data_seeder.dart';

// En algún botón de desarrollo:
final seeder = SimpleAnalyticsDataSeeder(
  context.read<OptimizedDatabaseService>()
);

await seeder.seedAllData(userId: 1, daysBack: 90);
```

### 3. Abre Analytics Screen
Navega a la pantalla de Analytics V4 y deberías ver todos los datos.

---

## Opción B: Método SQL Directo

### 1. Localiza la base de datos
```bash
# Android
adb shell
run-as com.tuapp.reflect_actions
cd databases/
```

### 2. Ejecuta el script
```bash
sqlite3 reflect_zen.db < /path/to/analytics_test_data.sql
```

### 3. Verifica
```sql
SELECT COUNT(*) FROM daily_entries WHERE user_id = 1;
```

---

## 📁 Archivos Disponibles

| Archivo | Descripción |
|---------|-------------|
| `analytics_test_data.sql` | Script SQL con datos pre-generados |
| `simple_analytics_data_seeder.dart` | Seeder Dart fácil de usar |
| `README.md` | Documentación completa |
| `USAGE_EXAMPLE.dart` | Ejemplos de código completos |
| `EXPECTED_RESULTS.md` | Qué esperar en la UI |
| `QUICKSTART.md` | Esta guía rápida |

---

## ⚡ Comando Único (Dart)

```dart
// Pega esto en un botón de prueba:
await SimpleAnalyticsDataSeeder(
  context.read<OptimizedDatabaseService>()
).seedAllData(userId: context.read<OptimizedAuthProvider>().currentUser!.id);
```

---

## 🧹 Limpiar Datos

```dart
await SimpleAnalyticsDataSeeder(
  context.read<OptimizedDatabaseService>()
).clearAllData(userId: 1);
```

---

## ❓ Problemas Comunes

**No veo datos:**
- Verifica que user_id = 1 exista
- Recarga la pantalla de Analytics
- Revisa los logs de debug

**Error de inserción:**
- Asegúrate de que las tablas existan
- Verifica que el usuario esté logueado

**Datos incorrectos:**
- Limpia datos viejos primero
- Regenera con el seeder

---

## 📖 Más Información

- Ver `README.md` para documentación completa
- Ver `USAGE_EXAMPLE.dart` para código de ejemplo
- Ver `EXPECTED_RESULTS.md` para validar resultados
