# 🚀 CÓMO EJECUTAR EL SEEDER DE DATOS - Analytics V4

## ✨ Método Más Fácil (RECOMENDADO)

### Opción 1: Botón Flotante de Desarrollo

1. **Abre cualquier pantalla** de tu app (por ejemplo `home_screen_v2.dart`)

2. **Agrega el widget flotante** temporalmente:

```dart
// En lib/presentation/screens/v2/home_screen_v2.dart (o cualquier otra pantalla)

import '../../widgets/dev_seeder_fab.dart'; // <- Agregar import

class HomeScreenV2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(...),
      body: ...,

      // 👇 AGREGAR ESTA LÍNEA
      floatingActionButton: DevSeederFAB(),
    );
  }
}
```

3. **Ejecuta la app**:
```bash
flutter run
```

4. **Presiona el botón morado** con icono de ciencia en la esquina inferior derecha

5. **Selecciona "Generar Datos"**

6. **Espera 10-15 segundos**

7. **¡Listo!** Navega a Analytics V4 para ver los datos

---

## 🎯 Método Alternativo: Pantalla de Desarrollo

Si prefieres una pantalla dedicada:

1. **Navega a la pantalla de desarrollo**:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AnalyticsSeederScreen(),
  ),
);
```

2. **Presiona "Generar Datos Completos"**

3. **Espera y disfruta**

---

## 📝 Método Manual: Código Directo

Si quieres ejecutar el código directamente:

```dart
import 'package:reflect_actions/test_data/run_analytics_seeder.dart';

// Donde sea en tu código:
await runAnalyticsSeeder(userId: 1);
```

---

## 🗂️ Archivos Creados

### Scripts y Seeders:
- ✅ `lib/test_data/run_analytics_seeder.dart` - Script principal del seeder
- ✅ `lib/presentation/widgets/dev_seeder_fab.dart` - Botón flotante
- ✅ `lib/presentation/screens/dev/analytics_seeder_screen.dart` - Pantalla completa
- ✅ `test_data/analytics_test_data.sql` - SQL directo (alternativo)
- ✅ `test_data/simple_analytics_data_seeder.dart` - Seeder Dart alternativo

### Documentación:
- ✅ `test_data/README.md` - Documentación completa
- ✅ `test_data/QUICKSTART.md` - Guía rápida
- ✅ `test_data/EXPECTED_RESULTS.md` - Qué esperar en la UI
- ✅ `test_data/USAGE_EXAMPLE.dart` - Ejemplos de código
- ✅ `SEED_ANALYTICS_DATA.md` - Este archivo

---

## 📊 Datos Que Se Generarán

Cuando ejecutes el seeder, obtendrás:

| Tipo | Cantidad | Descripción |
|------|----------|-------------|
| 📝 Entradas Diarias | 60 días | Con todas las métricas de bienestar |
| ⚡ Quick Moments | 150+ | Momentos interactivos variados |
| 🎯 Metas | 12 | 4 completadas, 8 activas |
| 📈 Tendencias | Todas | Mejora progresiva en 90 días |

**Tendencias incluidas:**
- ✅ Mood: 4 → 9 (+125%)
- ✅ Energy: 4 → 9 (+125%)
- ✅ Stress: 8 → 3 (-62%)
- ✅ Sleep: 4 → 8 (+100%)
- ✅ Anxiety: 7 → 3 (-57%)

---

## 🔍 Verificar que Funcionó

Después de ejecutar el seeder:

1. **Revisa la consola de debug** - Deberías ver:
```
✅ 60 entradas diarias generadas
✅ 150+ momentos generados
✅ 12 metas generadas
```

2. **Abre Analytics V4** y verifica:
- Motivation Score: 7.5-8.5/10
- Wellbeing Trends mostrando mejoras
- Goals con 5 completadas, 10 activas
- Quick Moments con ratio >70% positivo

3. **Si algo falla:**
- Verifica que el usuario esté logueado
- Revisa los logs en la consola
- Intenta limpiar datos y regenerar

---

## 🧹 Limpiar Datos

Para eliminar todos los datos de prueba:

**Desde el FAB:**
- Presiona el botón morado → "Limpiar Datos"

**Desde código:**
```dart
await clearAnalyticsData(userId: 1);
```

---

## ❓ Solución de Problemas

### "No hay datos en Analytics"
**Solución:** Verifica que ejecutaste el seeder CON LA APP CORRIENDO

### "Error al insertar datos"
**Solución:** Asegúrate de que:
1. La app se ejecutó al menos una vez (para crear DB)
2. Hay un usuario logueado
3. Las tablas existen

### "Los datos no coinciden"
**Solución:**
1. Limpia datos viejos primero
2. Regenera los datos
3. Reinicia la pantalla de Analytics

---

## 💡 Tips

1. **El seeder solo funciona en modo DEBUG** por seguridad
2. **Toma 10-15 segundos** generar todos los datos
3. **Los datos son realistas** con patrones de mejora
4. **Puedes regenerar** las veces que quieras
5. **Elimina el FAB** cuando ya no lo necesites

---

## 🎉 ¡Eso es todo!

Con cualquiera de estos métodos tendrás datos completos en Analytics V4.

**Método recomendado:** Botón flotante `DevSeederFAB` - Más rápido y simple.

---

**¿Necesitas ayuda?** Revisa:
- `test_data/README.md` para documentación completa
- `test_data/EXPECTED_RESULTS.md` para saber qué esperar
- Los archivos de código tienen comentarios detallados
