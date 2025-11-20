# ⚡ Quick Start - GitHub Actions + Claude API

## 5 Pasos para comenzar

### 1️⃣ Obtener API Key de Claude

```bash
# Visita: https://console.anthropic.com/
# 1. Inicia sesión o crea cuenta
# 2. Ve a "API Keys"
# 3. Click en "Create Key"
# 4. Copia la key (se muestra solo una vez)
```

### 2️⃣ Añadir Secret a GitHub

```bash
# En tu repositorio GitHub:
# Settings → Secrets and variables → Actions
# Click "New repository secret"
# Name: CLAUDE_API_KEY
# Value: [pega tu key aquí]
# Click "Add secret"
```

### 3️⃣ Verifica la estructura de carpetas

```bash
.github/
├── workflows/
│   ├── analyze-issue-with-claude.yml
│   └── issue-auto-triage.yml
├── ISSUE_TEMPLATE/
│   ├── bug_report.md
│   └── ui_problem.md
├── WORKFLOW_SETUP.md
└── QUICK_START.md
```

### 4️⃣ Prueba creando un issue

Opción A - Usar plantilla de UI:
- Ve a **Issues** → **New Issue**
- Selecciona **🎨 Problema de UI**
- Completa el formulario
- Submite

Opción B - Usar plantilla de Bug:
- Ve a **Issues** → **New Issue**
- Selecciona **🐛 Reporte de Bug**
- Completa el formulario
- Submite

### 5️⃣ Observa la magia 🪄

```
┌──────────────────────────────┐
│ 1. Creas el issue            │
│ 2. GitHub Actions se activa  │
│ 3. Claude analiza el issue   │
│ 4. Ves un comentario automático
│ 5. Labels se añaden solos    │
└──────────────────────────────┘
```

## 🎯 Qué sucede automáticamente

### Dentro de 30 segundos:

✅ **Auto-Triage**
- Detecta tipo (UI bug, crash, performance, etc.)
- Detecta componente (moments, goals, analytics, etc.)
- Añade labels automáticos

✅ **Claude Analysis**
- Analiza el problema
- Sugiere soluciones
- Publica comentario en el issue
- Añade más labels basado en prioridad

## 📝 Ejemplo de lo que verás

### Tu issue:
```
Título: [UI] El botón "Guardar" no aparece en la pantalla de goals

Descripción: Cuando intento crear un nuevo goal en iOS,
el botón de guardar no aparece. Sin embargo, en Android funciona bien.
```

### Lo que verá después (comentario automático de Claude):

```
🤖 Análisis Automático con Claude AI

## Resumen del problema
El botón "Guardar" no aparece en la pantalla de crear goals en iOS.

## Causa probable
Posible overflow en el layout o incompatibilidad con SafeArea en iOS.

## Pasos para reproducir
1. Abre la app en iOS
2. Ve a Goals → Crear nuevo
3. Observa que falta el botón

## Soluciones sugeridas
1. Revisar el widget GoalCreationScreen para SafeArea
2. Verificar constraints de layout
3. Usar SingleChildScrollView si el contenido es largo

## Archivos probablemente afectados
- lib/presentation/screens/v4/goals_screen.dart
- lib/presentation/widgets/goal_creation_widget.dart

## Prioridad
Alta - Afecta funcionalidad crítica
```

### Labels añadidos automáticamente:
- 🏷️ `ui-problem`
- 🏷️ `priority-high`
- 🏷️ `component/goals`

## 🔧 Configuración avanzada

Edita los archivos YAML si quieres:

### `analyze-issue-with-claude.yml`
- Cambiar el modelo de Claude
- Ajustar el prompt
- Modificar cómo se procesan resultados

### `issue-auto-triage.yml`
- Añadir más tipos de problemas
- Detectar nuevos componentes
- Cambiar estructura de labels

## ❓ Preguntas frecuentes

**P: ¿Cuánto cuesta?**
R: Depende del volumen. Claude API es muy económica (alrededor de $0.003 por análisis).

**P: ¿Funciona en issues editados?**
R: Sí, también analiza cuando editas un issue existente.

**P: ¿Puedo desactivar los workflows?**
R: Sí. Ve a **Actions** → Selecciona el workflow → **Disable workflow**

**P: ¿Qué pasa si el análisis es incorrecto?**
R: Es IA, no es perfecta. Siempre verifica manualmente antes de actuar.

**P: ¿Cómo monitoreó el costo?**
R: Ve a https://console.anthropic.com/usage

## 🚀 Próximos pasos

1. Configura el secret de API Key
2. Crea algunos issues de prueba
3. Ajusta los prompts según tus necesidades
4. Considera añadir más tipos de plantillas

## 📚 Más información

- [Documentación completa](./WORKFLOW_SETUP.md)
- [Arquitectura de ReflectFlutter](../CLAUDE.md)
- [Documentación de Claude API](https://docs.anthropic.com/)

---

¡Listo! Tu setup de GitHub Actions + Claude está completo. 🎉
