# 🤖 GitHub Actions + Claude API Integration

Automatiza el análisis de issues en tu repositorio ReflectFlutter usando Claude AI.

## 🎯 ¿Qué hace?

Cuando alguien crea un issue de bug o problema de UI:

1. **Auto-Triage** 🏷️
   - Detecta automáticamente el tipo de problema
   - Asigna componente afectado
   - Añade labels relevantes

2. **Claude Analysis** 🤖
   - Analiza el problema con IA
   - Sugiere soluciones
   - Estima prioridad
   - Identifica archivos afectados

3. **Auto-Comment** 💬
   - Publica análisis como comentario
   - Visible para todo el equipo
   - Acelera la resolución

## 🚀 Quick Start (5 minutos)

### 1. Obtén tu API Key
```bash
# Visita: https://console.anthropic.com/api-keys
# Click: Create Key
# Copia la key (comienza con sk-ant-)
```

### 2. Configura en GitHub
```
Tu repositorio → Settings → Secrets and variables → Actions
+ New repository secret
  Name: CLAUDE_API_KEY
  Value: sk-ant-... (tu key)
```

### 3. Crea un issue de prueba
```
Issues → New Issue → 🎨 Problema de UI
Completa el formulario y submite
```

### 4. Observa la magia ✨
En ~30 segundos verás:
- Labels automáticos
- Comentario con análisis

## 📁 Estructura

```
.github/
├── workflows/
│   ├── analyze-issue-with-claude.yml    ← Análisis con Claude
│   └── issue-auto-triage.yml            ← Auto-clasificación
│
├── ISSUE_TEMPLATE/
│   ├── bug_report.md                    ← Plantilla de bugs
│   └── ui_problem.md                    ← Plantilla de UI
│
├── README.md                             ← Este archivo
├── QUICK_START.md                        ← Inicio rápido
├── WORKFLOW_SETUP.md                     ← Documentación completa
├── EXAMPLES.md                           ← Ejemplos reales
├── SETUP_CHECKLIST.md                    ← Checklist de setup
└── test-workflows.sh                     ← Script de verificación
```

## 📖 Documentación

- **[QUICK_START.md](./QUICK_START.md)** - Configuración rápida (5 min)
- **[WORKFLOW_SETUP.md](./WORKFLOW_SETUP.md)** - Documentación completa
- **[EXAMPLES.md](./EXAMPLES.md)** - Ejemplos reales de análisis
- **[SETUP_CHECKLIST.md](./SETUP_CHECKLIST.md)** - Verificación paso a paso

## 🧪 Verificar Setup

```bash
bash .github/test-workflows.sh
```

Esto verifica:
- ✓ Estructura de carpetas
- ✓ Archivos de workflow
- ✓ Plantillas de issues
- ✓ Sintaxis YAML
- ✓ Contenido de archivos

## 💡 Cómo funciona

### Workflow 1: Auto-Triage
```
Issue creado
    ↓
Detecta palabras clave
    ↓
Clasifica tipo (ui-bug, crash, performance, etc.)
    ↓
Detecta componente (moments, goals, analytics, etc.)
    ↓
Añade labels automáticamente
```

### Workflow 2: Claude Analysis
```
Issue creado/editado
    ↓
Extrae título y descripción
    ↓
Envía a Claude API
    ↓
Claude retorna:
  - Resumen del problema
  - Causa probable
  - Pasos para reproducir
  - Soluciones sugeridas
  - Archivos afectados
  - Prioridad
    ↓
Publica como comentario
    ↓
Añade más labels según análisis
```

## 🏷️ Labels Automáticos

### Por Tipo:
- `ui-problem` - Problema visual
- `crash` - App se cae
- `performance` - Rendimiento lento
- `database` - Problema con datos
- `notification` - Problema con notificaciones
- `state-management` - Problema de estado

### Por Prioridad:
- `priority-high` - Crítico/bloqueador
- `priority-medium` - Importante pero no bloqueador
- `priority-low` - Mejora menor

### Por Componente:
- `component/moments` - Feature de momentos
- `component/goals` - Feature de goals
- `component/analytics` - Analytics
- `component/profile` - Perfil
- `component/home` - Home

## 📊 Costos

Estimado: **~$0.003 por análisis**

Ejemplo:
- 100 issues/mes = ~$0.30/mes
- 1000 issues/mes = ~$3/mes

Monitorea en: https://console.anthropic.com/usage

## 🔒 Seguridad

- ✓ API Key guardada en GitHub Secrets (no en código)
- ✓ No se imprime en logs
- ✓ Se limpia automáticamente después de cada run
- ✓ Solo acceso a crear comentarios y añadir labels

## ❓ FAQ

**P: ¿Funciona en forks?**
R: No. Los secrets no se heredan en forks. El equipo debe usar el repo principal.

**P: ¿Qué pasa si el análisis es incorrecto?**
R: Es IA, no es perfecta. Siempre verifica manualmente.

**P: ¿Puedo usar otro modelo de Claude?**
R: Sí. Edita `analyze-issue-with-claude.yml` y cambia el modelo.

**P: ¿Cómo desactivo los workflows?**
R: Actions → Selecciona workflow → Disable workflow

**P: ¿Necesito tener Flutter/Dart instalado?**
R: No. Los workflows corren en GitHub, no en tu máquina.

## 🚀 Próximos Pasos

1. **Setup** (5 min): Sigue [QUICK_START.md](./QUICK_START.md)
2. **Verifica**: Corre `bash .github/test-workflows.sh`
3. **Prueba**: Crea 2-3 issues de prueba
4. **Ajusta**: Modifica prompts/labels según necesites
5. **Documenta**: Comparte con tu equipo

## 📞 Soporte

Problemas?

1. Verifica [SETUP_CHECKLIST.md](./SETUP_CHECKLIST.md)
2. Revisa logs en **Actions** → selecciona run fallido
3. Consulta [WORKFLOW_SETUP.md](./WORKFLOW_SETUP.md) sección troubleshooting
4. Crea un issue si el problema persiste

## 🎓 Aprender Más

- [Documentación de Claude API](https://docs.anthropic.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Arquitectura de ReflectFlutter](../CLAUDE.md)

## 📝 Cambios Locales

Si quieres ajustar:

### Cambiar el prompt de Claude
Edita `.github/workflows/analyze-issue-with-claude.yml`, sección:
```python
prompt = f"""Analiza el siguiente issue..."""
```

### Cambiar tipos de problemas detectados
Edita `.github/workflows/issue-auto-triage.yml`, sección:
```javascript
if (fullText.includes('crash') || ...
```

### Cambiar labels automáticos
Edita la sección de `addLabels` en ambos workflows

## 🎉 Configuración Completa

Cuando veas esto en tu terminal, ¡estás listo!

```
✓ Configuración correcta!

Próximos pasos:
1. Configura el secret CLAUDE_API_KEY en GitHub
2. Crea un issue de prueba
3. Verifica que los workflows se ejecutan
```

---

Made with 🤖 Claude AI para ReflectFlutter

**¡Happy issue tracking! 🚀**
