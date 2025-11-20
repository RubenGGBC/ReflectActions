# ✅ Setup Checklist - GitHub Actions + Claude API

Usa esta lista para verificar que todo está configurado correctamente.

## 📋 Pre-requisitos

- [ ] Tienes cuenta en GitHub (obviamente)
- [ ] Tienes permiso de admin en el repositorio
- [ ] Tienes cuenta en Anthropic (https://console.anthropic.com/)
- [ ] Tienes créditos en tu cuenta de Claude API

## 🔑 Configuración de API Key

- [ ] Has generado una API key en https://console.anthropic.com/api-keys
- [ ] La API key comienza con `sk-ant-`
- [ ] Copiaste la key (se muestra solo una vez)
- [ ] La key NO está en ningún archivo de código

### En GitHub:

- [ ] Vas a **Settings** → **Secrets and variables** → **Actions**
- [ ] Creaste un nuevo secret llamado `CLAUDE_API_KEY`
- [ ] Pegaste la API key como valor
- [ ] El secret aparece en la lista con ✓

## 📁 Archivos de Workflow

- [ ] Archivo `.github/workflows/analyze-issue-with-claude.yml` existe
- [ ] Archivo `.github/workflows/issue-auto-triage.yml` existe
- [ ] Ambos archivos tienen sintaxis YAML válida
- [ ] Los archivos tienen permiso de lectura

### Verifica con:
```bash
ls -la .github/workflows/
cat .github/workflows/analyze-issue-with-claude.yml | head -20
```

## 📝 Plantillas de Issues

- [ ] Archivo `.github/ISSUE_TEMPLATE/bug_report.md` existe
- [ ] Archivo `.github/ISSUE_TEMPLATE/ui_problem.md` existe
- [ ] Las plantillas tienen formato markdown válido
- [ ] Los frontmatter están correctos (entre ---)

### Verifica con:
```bash
ls -la .github/ISSUE_TEMPLATE/
head -10 .github/ISSUE_TEMPLATE/bug_report.md
```

## 📚 Documentación

- [ ] Archivo `.github/WORKFLOW_SETUP.md` existe
- [ ] Archivo `.github/QUICK_START.md` existe
- [ ] Archivo `.github/EXAMPLES.md` existe
- [ ] Archivo `.github/SETUP_CHECKLIST.md` existe (este archivo)

## 🧪 Prueba del Workflow

### Test 1: Verificar que los workflows aparecen en GitHub

- [ ] Vas a tu repositorio → **Actions**
- [ ] Ves **"Analyze Issue with Claude API"** en la lista
- [ ] Ves **"Auto-Triage Issues"** en la lista
- [ ] Ambos workflows tienen estado "ready"

### Test 2: Crear un issue de prueba

- [ ] Vas a **Issues** → **New Issue**
- [ ] Seleccionas plantilla **🎨 Problema de UI**
- [ ] Completas el formulario con información de prueba
- [ ] Das submit

### Test 3: Observar la ejecución

- [ ] Esperas 30 segundos
- [ ] Vas a **Actions**
- [ ] Ves ejecución de "Auto-Triage Issues" completada ✓
- [ ] Ves ejecución de "Analyze Issue with Claude API" completada ✓
- [ ] Ambas tienen checkmark verde

### Test 4: Verificar resultados

En el issue de prueba deberías ver:

- [ ] **Comentario automático** con análisis de Claude
  - Resumen del problema
  - Causa probable
  - Soluciones sugeridas
  - Prioridad

- [ ] **Labels automáticos** añadidos
  - Mínimo 2 labels (tipo + componente)
  - Posiblemente más según prioridad

- [ ] **Comentario de bienvenida** (si eres nuevo colaborador)

## 🔍 Troubleshooting

Si algo no funciona:

### ❌ Problema: Workflows no aparecen en Actions

**Solución**:
```bash
# Verifica que los archivos están en el lugar correcto
ls -la .github/workflows/

# Verifica sintaxis YAML
python3 -m yaml .github/workflows/analyze-issue-with-claude.yml
```

### ❌ Problema: Workflow ejecuta pero falla

**Causa común**: API key no configurada
- [ ] Vas a **Settings** → **Secrets and variables** → **Actions**
- [ ] Verifica que `CLAUDE_API_KEY` está listado
- [ ] Si no está, créalo nuevamente

**Causa común**: API key inválida
- [ ] Verifica en https://console.anthropic.com/api-keys
- [ ] La key debería estar activa
- [ ] Regenera si es necesario

**Causa común**: Sin créditos en Claude API
- [ ] Vs a https://console.anthropic.com/settings/billing
- [ ] Verifica que tienes créditos o tarjeta activa
- [ ] El modelo usado es `claude-3-5-sonnet-20241022`

### ❌ Problema: Workflow ejecuta pero no añade comentario

**Debug**:
- [ ] Haz click en el run fallido en **Actions**
- [ ] Expande el step "Analyze with Claude API"
- [ ] Lee el output/error
- [ ] Busca en la sección "Post comment on issue"

## 📊 Verificación de Costos

- [ ] Vas a https://console.anthropic.com/usage
- [ ] Ves el uso de tu cuenta
- [ ] Estimación: ~$0.003 por análisis
- [ ] Si tienes muchos issues: 100 issues = ~$0.30

## 🎯 Configuración Avanzada (Opcional)

- [ ] Quieres cambiar el modelo de Claude
  - Edita `.github/workflows/analyze-issue-with-claude.yml`
  - Busca: `"model": "claude-3-5-sonnet-20241022"`
  - Cambia a: `claude-opus-4-1`, `claude-sonnet-4`, etc.

- [ ] Quieres cambiar el prompt de análisis
  - Edita `.github/workflows/analyze-issue-with-claude.yml`
  - Busca la sección: `prompt = f"""`
  - Modifica el prompt según tus necesidades

- [ ] Quieres añadir más tipos de problemas
  - Edita `.github/workflows/issue-auto-triage.yml`
  - Busca la sección: `if fullText.includes(...)`
  - Añade nuevas condiciones

## 📌 Configuración Recomendada

### Para desarrollo:
```
├── Workflows activos: SÍ
├── Análisis automático: SÍ
├── Labels automáticos: SÍ
└── Notificaciones: Configura según preferencia
```

### Para producción:
```
├── Workflows activos: SÍ
├── Análisis automático: SÍ
├── Labels automáticos: SÍ
├── Asignación automática: NO (opcional)
└── Auto-close: NO (solo manual)
```

## 🔐 Checklist de Seguridad

- [ ] API key NO está en `.gitignore`
- [ ] API key NO está en `pubspec.yaml`
- [ ] API key NO está en archivos de código
- [ ] API key solo está en GitHub Secrets
- [ ] Los secrets no aparecen en los logs del workflow
- [ ] El workflow no imprime valores sensibles

## 📱 Verificación Multi-Plataforma

- [ ] Workflows funcionan en main branch
- [ ] Workflows NO funcionan en forks (esperado, secrets no se heredan)
- [ ] Issue templates funcionan en mobile
- [ ] Issue templates funcionan en desktop

## 🚀 Después de Setup Completo

- [ ] Todos los checkmarks están ✓
- [ ] Has hecho test con al menos 3 issues
- [ ] El equipo sabe cómo usar las plantillas
- [ ] Documentaste cambios en README principal
- [ ] Consideraste costos en tu presupuesto

## 📞 Soporte

Si después de este checklist algo aún no funciona:

1. Revisa los logs en **Actions** → selecciona el run fallido
2. Busca el error específico
3. Consulta [WORKFLOW_SETUP.md](./WORKFLOW_SETUP.md) troubleshooting
4. Crea un issue en el repositorio si es necesario

---

**Estado del setup**:

Conteo de checkmarks: `[ ]/[ ]`

Cuando tengas todo ✓, estás listo para ir. ¡A crear issues! 🚀
