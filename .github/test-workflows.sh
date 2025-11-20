#!/bin/bash

# Script para verificar que los workflows están correctamente configurados
# Uso: bash .github/test-workflows.sh

echo "🔍 Verificando configuración de GitHub Actions + Claude API..."
echo ""

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contador de checks
CHECKS_PASSED=0
CHECKS_TOTAL=0

check() {
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $1"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} $1"
    fi
}

# 1. Verificar estructura de carpetas
echo "📁 Verificando estructura de carpetas..."
[ -d ".github" ]
check ".github/ existe"

[ -d ".github/workflows" ]
check ".github/workflows/ existe"

[ -d ".github/ISSUE_TEMPLATE" ]
check ".github/ISSUE_TEMPLATE/ existe"

echo ""

# 2. Verificar archivos de workflow
echo "📋 Verificando archivos de workflow..."

[ -f ".github/workflows/analyze-issue-with-claude.yml" ]
check "analyze-issue-with-claude.yml existe"

[ -f ".github/workflows/issue-auto-triage.yml" ]
check "issue-auto-triage.yml existe"

echo ""

# 3. Verificar plantillas de issues
echo "📝 Verificando plantillas de issues..."

[ -f ".github/ISSUE_TEMPLATE/bug_report.md" ]
check "bug_report.md existe"

[ -f ".github/ISSUE_TEMPLATE/ui_problem.md" ]
check "ui_problem.md existe"

echo ""

# 4. Verificar documentación
echo "📚 Verificando documentación..."

[ -f ".github/WORKFLOW_SETUP.md" ]
check "WORKFLOW_SETUP.md existe"

[ -f ".github/QUICK_START.md" ]
check "QUICK_START.md existe"

[ -f ".github/EXAMPLES.md" ]
check "EXAMPLES.md existe"

[ -f ".github/SETUP_CHECKLIST.md" ]
check "SETUP_CHECKLIST.md existe"

echo ""

# 5. Validar sintaxis YAML (si python está disponible)
echo "🔧 Validando sintaxis YAML..."

if command -v python3 &> /dev/null; then
    python3 -c "import yaml; yaml.safe_load(open('.github/workflows/analyze-issue-with-claude.yml'))" 2>/dev/null
    check "analyze-issue-with-claude.yml tiene sintaxis válida"

    python3 -c "import yaml; yaml.safe_load(open('.github/workflows/issue-auto-triage.yml'))" 2>/dev/null
    check "issue-auto-triage.yml tiene sintaxis válida"
else
    echo -e "${YELLOW}⚠${NC} Python3 no disponible, saltando validación YAML"
fi

echo ""

# 6. Verificar contenido de archivos críticos
echo "✍️ Verificando contenido de archivos..."

grep -q "CLAUDE_API_KEY" .github/workflows/analyze-issue-with-claude.yml
check "Workflow usa CLAUDE_API_KEY"

grep -q "anthropic.com/v1/messages" .github/workflows/analyze-issue-with-claude.yml
check "Workflow hace llamada a Claude API"

grep -q "github.rest.issues.createComment" .github/workflows/analyze-issue-with-claude.yml
check "Workflow crea comentarios en issues"

grep -q "github.rest.issues.addLabels" .github/workflows/analyze-issue-with-claude.yml
check "Workflow añade labels a issues"

echo ""

# 7. Resumen
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Resultados: ${CHECKS_PASSED}/${CHECKS_TOTAL} checks pasados"
echo ""

if [ $CHECKS_PASSED -eq $CHECKS_TOTAL ]; then
    echo -e "${GREEN}✓ ¡Configuración correcta!${NC}"
    echo ""
    echo "Próximos pasos:"
    echo "1. Configura el secret CLAUDE_API_KEY en GitHub"
    echo "2. Crea un issue de prueba"
    echo "3. Verifica que los workflows se ejecutan"
    echo ""
    echo "Más información:"
    echo "- QUICK_START.md: Inicio rápido"
    echo "- WORKFLOW_SETUP.md: Documentación completa"
    echo "- EXAMPLES.md: Ejemplos reales de uso"
    echo ""
else
    echo -e "${RED}✗ Hay problemas en la configuración${NC}"
    echo ""
    echo "Verifica:"
    echo "- Que todos los archivos estén en el lugar correcto"
    echo "- La sintaxis de archivos YAML"
    echo "- Los permisos de archivos"
    echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Exit con código apropiado
if [ $CHECKS_PASSED -eq $CHECKS_TOTAL ]; then
    exit 0
else
    exit 1
fi
