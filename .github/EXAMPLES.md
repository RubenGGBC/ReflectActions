# 📚 Ejemplos de Uso - GitHub Actions + Claude

Este documento contiene ejemplos reales de cómo funcionan los workflows.

## Ejemplo 1: Bug de UI - Pantalla de Goals

### 1. Issue creado:

```markdown
**Título**: [UI] El formulario de crear goal es ilegible en pantallas pequeñas

**Descripción**:
En dispositivos con pantalla pequeña (< 5 pulgadas),
el formulario de crear goals se superpone y no es usable.
Adjunto screenshot del problema.
```

### 2. Acciones automáticas:

**Auto-Triage** detecta:
- Tipo: `ui-bug` 🎨
- Componente: `goals` (porque menciona "goals")
- Labels añadidos: `UI`, `component/goals`

**Claude Analysis** genera:

```
🤖 Análisis Automático con Claude AI

## Resumen del problema
El formulario de crear goals no es responsive en dispositivos pequeños (<5").

## Causa probable
El layout probablemente usa widths fijos o no tiene SingleChildScrollView/ResponsiveLayout.

## Pasos para reproducir
1. Abre la app en un dispositivo pequeño (< 5 pulgadas)
2. Navega a Goals → New Goal
3. Intenta ver el formulario completo
4. Nota la superposición de elementos

## Soluciones sugeridas
1. Wrap el formulario en SingleChildScrollView
2. Usar Flexible/Expanded para widgets que ocupan space
3. Implementar responsive design con MediaQuery
4. Considerar usar ResponsiveBuilder o layout_builder

## Archivos probablemente afectados
- lib/presentation/screens/v4/goals_screen.dart
- lib/presentation/widgets/goal_form_widget.dart
- lib/presentation/screens/v2/profile_screen.dart

## Prioridad
Alta - Afecta accesibilidad en dispositivos comunes
```

Labels añadidos automáticamente:
- ✅ `ui-problem`
- ✅ `priority-high`
- ✅ `component/goals`

---

## Ejemplo 2: Crash en Notificaciones

### 1. Issue creado:

```markdown
**Título**: [BUG] La app crashea cuando se activa una notificación

**Descripción**:
Stack trace:
```
E/AndroidRuntime: FATAL EXCEPTION: main
Process: com.example.reflect_flutter, PID: 12345
java.lang.NullPointerException: Attempt to invoke virtual method
'android.app.NotificationChannel.getId()' on a null object reference
```

**Dispositivo**: Android 11, Pixel 4
**Pasos**: 1. Abre la app 2. Espera a que llegue notificación 3. Tap en notificación 4. Crash
```

### 2. Acciones automáticas:

**Auto-Triage** detecta:
- Tipo: `crash` 💥
- Componente: `notification` (porque menciona "notificación")
- Labels: `crash`, `component/notification`, `android`

**Claude Analysis** genera:

```
🤖 Análisis Automático con Claude AI

## Resumen del problema
La app crashea con NullPointerException cuando se toca una notificación en Android.

## Causa probable
El NotificationChannel no está siendo inicializado correctamente antes de usarlo.
Posible: el channel_id no existe o no se crea en tiempo.

## Pasos para reproducir
1. Abre app en Android 11+
2. Configura notificaciones
3. Espera a que llegue notificación (o envía test)
4. Toca la notificación
5. Crash inmediato

## Soluciones sugeridas
1. Verificar que el NotificationChannel se crea ANTES de usar
2. Validar que channel_id existe en notificationManager
3. Usar try-catch para manejar nulos
4. Actualizar flutter_local_notifications a última versión

## Archivos probablemente afectados
- lib/services/notification_service.dart
- Configuración Android native

## Prioridad
Alta - Crash crítico que impide usar la app
```

Labels añadidos:
- ✅ `crash`
- ✅ `priority-high`
- ✅ `component/notification`

---

## Ejemplo 3: Problema de Performance

### 1. Issue creado:

```markdown
**Título**: [PERFORMANCE] La pantalla de Analytics se carga lentamente

**Descripción**:
Cuando abro la pantalla de Analytics, la app se queda congelada por
5+ segundos antes de mostrar los datos.

Dispositivos probados:
- iPhone 12: ~3 segundos
- iPhone 8: ~8 segundos
- Pixel 5: ~4 segundos

Parece que está relacionado con el cálculo de datos.
```

### 2. Acciones automáticas:

**Auto-Triage** detecta:
- Tipo: `performance` ⚡
- Componente: `analytics`
- Labels: `performance`, `component/analytics`

**Claude Analysis** genera:

```
🤖 Análisis Automático con Claude AI

## Resumen del problema
La pantalla Analytics tiene lag severo (3-8 segundos) al cargar datos.

## Causa probable
Cálculos computacionales en el main thread. Posibles causas:
- Cálculo de correlaciones sin optimización
- Queries de SQLite sin índices
- Rendering de muchos widgets sin virtualization

## Pasos para reproducir
1. Abre la app
2. Navega a Analytics
3. Observa lag de 3-8 segundos
4. Más evidente en dispositivos viejos

## Soluciones sugeridas
1. Mover cálculos a isolate/async
2. Añadir índices a tabla de analytics en SQLite
3. Implementar lazy loading o pagination
4. Usar ValueNotifier con optimización
5. Profile con DevTools para encontrar bottleneck exacto

## Archivos probablemente afectados
- lib/presentation/providers/analytics_provider_v4.dart
- lib/data/services/analytics_config_service.dart
- Database queries en OptimizedDatabaseService

## Prioridad
Media - Afecta user experience pero app es funcional
```

Labels añadidos:
- ✅ `performance`
- ✅ `priority-medium`
- ✅ `component/analytics`

---

## Ejemplo 4: Bug de State Management

### 1. Issue creado:

```markdown
**Título**: [STATE] El estado de goals se pierde al hacer hot reload

**Descripción**:
Cuando hago cambios y hace hot reload durante desarrollo,
los goals que acabo de crear desaparecen.
Parece que el estado no se preserva correctamente.
```

### 2. Acciones automáticas:

**Auto-Triage** detecta:
- Tipo: `state-management` 📦
- Componente: `goals`
- Labels: `component/goals`, `state-management`

**Claude Analysis** genera:

```
🤖 Análisis Automático con Claude API

## Resumen del problema
Los goals se pierden después de hot reload durante desarrollo.

## Causa probable
Probable: Los providers están registrados como factory en lugar de singleton.
El hot reload crea nuevas instancias perdiendo el estado anterior.
O la persistencia no se ejecuta correctamente.

## Pasos para reproducir
1. Abre app
2. Crea un nuevo goal
3. Verifica que se muestra
4. Haz un cambio en código
5. Espera hot reload
6. Goal desaparece

## Soluciones sugeridas
1. Verificar que GoalProvider está configurado correctamente en injection
2. Asegurar que goals se guardan a database inmediatamente
3. En hot reload, recargar desde database
4. Usar persistencia automática con sqflite
5. Considerar usar Riverpod en lugar de Provider (mejor control)

## Archivos probablemente afectados
- lib/presentation/providers/goals_provider.dart
- lib/injection_container_clean.dart
- lib/data/services/optimized_database_service.dart

## Prioridad
Baja - Solo afecta en desarrollo, no en producción
```

Labels añadidos:
- ✅ `state-management`
- ✅ `priority-low`
- ✅ `component/goals`

---

## Ejemplo 5: Bug en Momentos (Múltiples plataformas)

### 1. Issue creado:

```markdown
**Título**: [UI] Video de moment no carga en web

**Descripción**:
Los momentos con video adjunto no cargan en web.
La imagen de preview sí aparece, pero al tocar no reproduce nada.

Plataformas:
- ✅ Android: Funciona
- ✅ iOS: Funciona
- ❌ Web: No funciona
- ❌ Desktop: No funciona
```

### 2. Acciones automáticas:

**Auto-Triage** detecta:
- Tipo: `ui-bug` 🎨
- Componente: `moments`
- Labels: `UI`, `component/moments`, `web`, `desktop`

**Claude Analysis** genera:

```
🤖 Análisis Automático con Claude API

## Resumen del problema
Videos en moments no cargar en web/desktop, funciona en mobile.

## Causa probable
Probablemente diferencia en manejo de paths de archivos o permisos.
Video_player en web requiere diferentes configuraciones.
Assets en web necesitan estar en carpeta específica.

## Pasos para reproducir
1. Build app para web: flutter build web
2. Servir app
3. Crear un moment con video
4. Intenta reproducir en web
5. Video no aparece

En Android/iOS: Funciona perfectamente

## Soluciones sugeridas
1. Usar conditional imports para video_player web
2. Verificar que videos se copian a assets en build web
3. Usar diferentes paths según platform
4. Considerar usar chewie para player más robusto
5. Testear en chrome/firefox devtools

## Archivos probablemente afectados
- lib/presentation/widgets/moment_video_player.dart
- lib/presentation/screens/*/moment_detail_screen.dart
- web/index.html (verificar CORS)

## Prioridad
Media - Web/Desktop no son prioridad principal pero deberían funcionar
```

Labels añadidos:
- ✅ `ui-problem`
- ✅ `priority-medium`
- ✅ `component/moments`
- ✅ `web`

---

## 🎯 Patrón común en los análisis

### Lo que Claude siempre proporciona:

1. **Resumen**: Qué está mal en una frase
2. **Causa probable**: Por qué está mal
3. **Reproducción**: Cómo recrear el problema
4. **Soluciones**: 3-5 opciones ordenadas por relevancia
5. **Archivos**: Dónde buscar el problema
6. **Prioridad**: Qué tan urgente es

### Lo que los labels comunican:

- **Tipo**: ui-bug, crash, performance, database, notification, state-management
- **Prioridad**: priority-high, priority-medium, priority-low
- **Componente**: component/moments, component/goals, component/analytics, etc.
- **Plataforma**: android, ios, web, desktop (si aplica)

---

## 💡 Tips para obtener mejor análisis

### ✅ Issue bien descrito:
```markdown
[UI] Botón "Salvar" no visible en Goals en iPhone 8

En iPhone 8 (pantalla 4.7"), cuando intento crear un goal,
el botón de "Salvar" queda fuera de la pantalla.

Android (Pixel 4) y iPad: Funciona bien.

Stack: flutter 3.13.0, goal_form_widget.dart
```

### ❌ Issue mal descrito:
```markdown
[BUG] Algo no funciona

La app está rota.
```

---

## 🔄 Cómo iterar basado en análisis

1. Claude proporciona análisis
2. Revisa el análisis manualmente
3. Asigna el issue a alguien del equipo
4. Implementa las soluciones sugeridas
5. Cierra el issue con un commit que referencia el issue (#123)
6. GitHub vinculará automáticamente el commit

Ejemplo:
```bash
git commit -m "Fix goal form overflow on small screens

- Wrap form in SingleChildScrollView
- Use Flexible for inputs
- Test on iPhone 8

Closes #42"
```
