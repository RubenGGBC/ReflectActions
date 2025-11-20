# 📖 Referencia Rápida - GitHub Actions + Claude

Guía de referencia rápida para consultas frecuentes.

## 🎯 Matriz de Decisión

### "Necesito hacer X, ¿dónde empiezo?"

| Necesito... | Ir a... | Paso |
|---|---|---|
| **Configurar todo rápido** | [QUICK_START.md](./QUICK_START.md) | 5 minutos |
| **Documentación completa** | [WORKFLOW_SETUP.md](./WORKFLOW_SETUP.md) | Lectura detallada |
| **Ver ejemplos reales** | [EXAMPLES.md](./EXAMPLES.md) | Copy-paste |
| **Verificar setup** | Ejecutar `bash .github/test-workflows.sh` | Automático |
| **Entender arquitectura** | [ARCHITECTURE.md](./ARCHITECTURE.md) | Diagramas |
| **Checklist paso a paso** | [SETUP_CHECKLIST.md](./SETUP_CHECKLIST.md) | Verificación |
| **Comprender cómo funciona** | Este archivo (REFERENCE.md) | Referencia rápida |

## 🔑 Configuración Inicial (Copiar & Pegar)

### 1. Obtener API Key
```bash
# URL: https://console.anthropic.com/api-keys
# Click: Create Key
# Copia: sk-ant-...
```

### 2. Añadir a GitHub
```
Repositorio → Settings → Secrets and variables → Actions
+ New repository secret
Name: CLAUDE_API_KEY
Value: sk-ant-...
```

### 3. Crear issue de prueba
Usa plantilla: **🎨 Problema de UI**

### 4. Verificar
Espera 30 segundos y verás labels + comentario automático

## 📋 Checklist de Setup

```
☐ API Key generada
☐ Secret añadido a GitHub
☐ .github/workflows/ contiene 2 archivos yml
☐ .github/ISSUE_TEMPLATE/ contiene 2 archivos md
☐ test-workflows.sh pasa todos los checks
☐ Problema de prueba creado
☐ Labels automáticos añadidos
☐ Comentario de Claude aparece
```

## 🏷️ Label Reference

### Por Tipo (Auto-Triage)
```
ui-bug               → Problema visual
crash               → App se cae
performance         → Lento
database            → Datos SQLite
notification        → Notificaciones
state-management    → Provider/State
```

### Por Prioridad (Claude Analysis)
```
priority-high       → Crítico
priority-medium     → Importante
priority-low        → Mejora menor
```

### Por Componente (Auto-Triage)
```
component/moments   → Feature momentos
component/goals     → Feature goals
component/analytics → Analytics
component/profile   → Perfil
component/home      → Home
```

### Por Plataforma (Detectado)
```
android             → Android específico
ios                 → iOS específico
web                 → Web específico
desktop             → Desktop específico
```

## 🚀 Flujo Rápido para el Equipo

### Para reportar un bug:
```
1. Ve a Issues → New Issue
2. Selecciona 🐛 Reporte de Bug
3. Completa todos los campos
4. Submite
5. En 30 segundos: Claude analiza automáticamente
```

### Para reportar problema de UI:
```
1. Ve a Issues → New Issue
2. Selecciona 🎨 Problema de UI
3. Adjunta screenshot/video
4. Submite
5. En 30 segundos: Análisis + labels automáticos
```

### Para revisar un issue:
```
1. Abre el issue
2. Revisa los labels (tipo, componente, prioridad)
3. Lee el comentario de Claude para sugerencias
4. Verifica si el análisis es correcto
5. Asigna a alguien para implementar
```

## 🔧 Personalización Común

### Cambiar el modelo de Claude
Edita: `.github/workflows/analyze-issue-with-claude.yml`
Busca: `"model": "claude-3-5-sonnet-20241022"`
Cambia a:
- `claude-opus-4-1` (más potente, más caro)
- `claude-haiku-3-5` (más barato, menos potente)

### Cambiar max_tokens
Edita: `.github/workflows/analyze-issue-with-claude.yml`
Busca: `"max_tokens": 1024`
Cambia a lo que necesites (mayor = más caro)

### Añadir más tipos de problemas
Edita: `.github/workflows/issue-auto-triage.yml`
Busca: `if (fullText.includes('crash')...`
Añade: `} else if (fullText.includes('tupalabra')) {`

### Cambiar el prompt
Edita: `.github/workflows/analyze-issue-with-claude.yml`
Busca: `prompt = f"""Analiza...`
Modifica completamente el prompt

## 📊 Costos & Monitoreo

### Monitorear uso
URL: https://console.anthropic.com/usage

### Estimación de costos
- 10 issues/mes: ~$0.03
- 100 issues/mes: ~$0.30
- 1000 issues/mes: ~$3.00

### Limitar gastos
1. Reduce `max_tokens` (default: 1024)
2. Usa modelo más barato (`claude-haiku`)
3. Desactiva workflows si necesitas

## 🐛 Troubleshooting Rápido

| Problema | Causa | Solución |
|---|---|---|
| Workflows no aparecen en Actions | Archivos en lugar incorrecto | Verifica estructura de `.github/` |
| Workflow ejecuta pero falla | Secret no configurado | Añade `CLAUDE_API_KEY` en GitHub |
| API error | API Key inválida | Regenera en console.anthropic.com |
| Sin fondos | Sin créditos | Añade tarjeta en console.anthropic.com |
| No crea comentarios | Permisos insuficientes | Verifica permisos del token |
| Labels no se añaden | Syntax error en YAML | Valida con `python3 -m yaml` |

## 🎓 Comandos Útiles

### Verificar todo está bien
```bash
bash .github/test-workflows.sh
```

### Validar YAML manualmente
```bash
python3 -c "import yaml; yaml.safe_load(open('.github/workflows/analyze-issue-with-claude.yml'))"
```

### Listar archivos creados
```bash
find .github -type f \( -name "*.yml" -o -name "*.md" -o -name "*.sh" \)
```

### Ver logs en GitHub
```
Repositorio → Actions → Selecciona workflow → Click en run → Expande steps
```

## 📚 Documentación por Temas

### Setup & Configuración
- [QUICK_START.md](./QUICK_START.md) - 5 min setup
- [SETUP_CHECKLIST.md](./SETUP_CHECKLIST.md) - Verificación
- [WORKFLOW_SETUP.md](./WORKFLOW_SETUP.md) - Detalles técnicos

### Entender el Sistema
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Diagramas
- [README.md](./README.md) - Resumen general

### Usar en Práctica
- [EXAMPLES.md](./EXAMPLES.md) - Casos reales
- [REFERENCE.md](./REFERENCE.md) - Este archivo

### Código
- `.github/workflows/analyze-issue-with-claude.yml` - Análisis con Claude
- `.github/workflows/issue-auto-triage.yml` - Auto-clasificación
- `.github/ISSUE_TEMPLATE/bug_report.md` - Plantilla bugs
- `.github/ISSUE_TEMPLATE/ui_problem.md` - Plantilla UI
- `.github/test-workflows.sh` - Script de verificación

## 💡 Tips Profesionales

### Para obtener mejor análisis de Claude:
✓ Describe bien el problema
✓ Incluye pasos claros para reproducir
✓ Adjunta screenshots/videos
✓ Menciona qué dispositivos/versiones afectan
✗ Evita "no funciona" sin detalles

### Para usar labels efectivamente:
✓ Combina tipo + prioridad + componente
✓ Usa labels para filtering en issues
✓ Crea vistas/projects por prioridad
✗ No ignores los labels automáticos

### Para integrar con flujo de trabajo:
✓ Asigna issues después del análisis
✓ Cierra issues con commits que las referencian (#123)
✓ Usa labels para tracking automático
✗ No ignores el análisis de Claude completamente

## 🔐 Seguridad

### ✓ Seguro
- API Key en GitHub Secrets
- No se imprime en logs
- Se limpia después de cada run
- HTTPS a Claude API

### ✗ NO hagas
- Guardar API Key en código
- Compartir API Key por email/Slack
- Guardar API Key en variables de env locales (sin encriptar)
- Usar API Key en repositorios públicos sin protección

## 📞 Soporte Rápido

### Si algo falla:
1. Ejecuta `bash .github/test-workflows.sh`
2. Lee los logs en GitHub → Actions
3. Consulta [WORKFLOW_SETUP.md](./WORKFLOW_SETUP.md) troubleshooting
4. Crea un issue en el repo

### Recursos:
- [Claude API Docs](https://docs.anthropic.com/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [ReflectFlutter Architecture](../CLAUDE.md)

## 🎉 Checklist de Éxito

Cuando esto esté completo:
- ✅ API Key configurada
- ✅ Workflows activos
- ✅ Issues de prueba analizados
- ✅ Labels automáticos funcionando
- ✅ Comentarios de Claude apareciendo
- ✅ Equipo entiende cómo usar

¡Ahora sí, a reportar bugs! 🚀
