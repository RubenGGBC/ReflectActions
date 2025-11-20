# 🤖 Configuración de GitHub Actions + Claude API

Este documento explica cómo configurar y usar los workflows automáticos para analizar issues con Claude AI.

## 📋 Workflows disponibles

### 1. `analyze-issue-with-claude.yml`
- **Trigger**: Cuando se crea o edita un issue
- **Función**: Analiza issues de bugs/UI con Claude API
- **Acciones automáticas**:
  - Envía análisis a Claude
  - Publica un comentario con sugerencias
  - Añade labels automáticos según el análisis

### 2. `issue-auto-triage.yml`
- **Trigger**: Cuando se crea o edita un issue
- **Función**: Clasifica automáticamente los issues
- **Acciones automáticas**:
  - Detecta tipo de problema (UI, crash, performance, etc.)
  - Detecta componente afectado
  - Añade labels automáticamente
  - Da bienvenida a nuevos colaboradores

## 🔑 Configuración de Secrets

### Paso 1: Obtener tu API Key de Claude

1. Ve a https://console.anthropic.com/
2. Inicia sesión o crea una cuenta
3. Navega a **API Keys**
4. Crea una nueva API key y cópiala

### Paso 2: Añadir el Secret a tu repositorio

1. Ve a tu repositorio en GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Clic en **New repository secret**
4. **Name**: `CLAUDE_API_KEY`
5. **Value**: Pega tu API key de Claude
6. Clic en **Add secret**

## 🚀 Cómo funciona

### Flujo del workflow de análisis

```
┌─────────────────────────┐
│ Se crea un issue nuevo  │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│ GitHub Actions trigger  │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│ Extrae datos del issue  │
└────────┬────────────────┘
         │
         ▼
┌──────────────────────────────┐
│ Envía a Claude API para      │
│ análisis automático          │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│ Claude responde con:         │
│ - Resumen del problema       │
│ - Causa probable             │
│ - Soluciones sugeridas       │
│ - Prioridad                  │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│ Publica comentario en issue  │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│ Añade labels automáticos     │
└──────────────────────────────┘
```

## 📝 Tipos de análisis

El workflow de Claude analiza automáticamente:

1. **Resumen del problema**: Qué está mal exactamente
2. **Causa probable**: Qué podría estar causándolo
3. **Pasos para reproducir**: Cómo se puede reproducir
4. **Soluciones sugeridas**: Cambios de código propuestos
5. **Archivos afectados**: Qué archivos están involucrados
6. **Prioridad**: Alta/Media/Baja

## 🏷️ Labels automáticos

Basado en el análisis de Claude, se añaden automáticamente:

- `priority-high` - Problemas críticos
- `priority-medium` - Problemas moderados
- `priority-low` - Problemas menores
- `ui-problem` - Problemas de interfaz
- `performance` - Problemas de rendimiento
- `crash` - Crashes o errores fatales

## 🎯 Componentes detectados

El workflow auto-triage detecta automáticamente:

- 🎨 **UI Bug**: Problemas visuales
- 💥 **Crash**: Errores y excepciones
- ⚡ **Performance**: Problemas de rendimiento
- 💾 **Database**: Problemas con SQLite/datos
- 🔔 **Notification**: Problemas con notificaciones
- 📦 **State Management**: Problemas con Provider/estado

## 🛑 Limitaciones y consideraciones

### Costos
- **Claude API**: Cada análisis tiene un costo
- Recomendación: Monitorear uso en https://console.anthropic.com/usage

### Rate limiting
- Claude API tiene límites de rate
- Si hay muchos issues, podrían encontrar rate limiting

### Precisión
- El análisis de Claude es aproximado
- Siempre verifica manualmente el análisis
- El equipo debe revisar antes de actuar

## 🔐 Seguridad

### Consideraciones importantes

1. **API Key**: Solo guardarla en GitHub Secrets, nunca en código
2. **Permisos**: El workflow tiene acceso limitado al repositorio
3. **Token**: El GITHUB_TOKEN se limpia automáticamente después de cada run

## 📊 Monitoreo

### Ver ejecuciones de workflows

1. Ve a tu repositorio
2. **Actions** → Selecciona el workflow
3. Haz clic en un run específico para ver detalles

### Troubleshooting

Si un workflow falla:

1. Haz clic en el run fallido
2. Expande los pasos para ver logs
3. Errores comunes:
   - **API Key inválida**: Verifica que el secret esté correcto
   - **API Key sin fondos**: Necesitas créditos en tu cuenta de Claude
   - **Network error**: Reintenta manualmente (GitHub lo hará automáticamente)

## 🎓 Ejemplo de uso

### Crear un issue y ver análisis automático

1. Abre una issue nueva: "UI: El botón de home no responde en iOS"
2. Selecciona la plantilla **🎨 Problema de UI**
3. Completa los campos
4. Envía el issue
5. En pocos segundos, Claude analizará y añadirá un comentario
6. Los labels se añadirán automáticamente

## 📚 Recursos

- [Documentación de Claude API](https://docs.anthropic.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [ReflectFlutter Architecture](../CLAUDE.md)

## 💬 Soporte

Si tienes problemas:

1. Verifica que el secret `CLAUDE_API_KEY` esté configurado
2. Revisa los logs del workflow en **Actions**
3. Asegúrate de tener créditos en Claude API
4. Crea un issue en el repositorio si el problema persiste
