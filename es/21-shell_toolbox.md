# 21. Construyendo Tu Caja de Herramientas Shell de IA

---

## 21.1 Por Qué Necesitas una Caja de Herramientas

Cuando te encuentras haciendo lo mismo repetidamente, es hora de automatizar y recopilarlo en una caja de herramientas.

La IA es especialmente buena para:
- Crear herramientas rápidamente
- Envolver flujos de trabajo complejos en comandos simples
- Mejorar continuamente scripts comúnmente usados

---

## 21.2 Estructura del Directorio de la Caja de Herramientas

```
~/bin/
├── lib/              # Bibliotecas compartidas
│   ├── logging.sh
│   ├── utils.sh
│   └── colors.sh
├── proyecto/         # Plantillas de proyecto
│   ├── python/
│   ├── nodejs/
│   └── sitio-estatico/
├── scripts/          # Scripts de herramientas
│   ├── git-clean
│   ├── docker-clean
│   ├── backup
│   └── log-parse
└── bin/
    ├── greet         # Herramienta ejecutable
    └── monitor       # Herramienta ejecutable
```

---

## 21.3 Crea Tu Biblioteca

### logging.sh

```bash
cat > ~/bin/lib/logging.sh << 'EOF'
#!/bin/bash

ROJO='\033[0;31m'
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${VERDE}[INFO]${NC} $@"; }
log_warn() { echo -e "${AMARILLO}[WARN]${NC} $@"; }
log_error() { echo -e "${ROJO}[ERROR]${NC} $@" >&2; }
EOF

source ~/bin/lib/logging.sh
```

### utils.sh

```bash
cat > ~/bin/lib/utils.sh << 'EOF'
#!/bin/bash

necesita_comando() {
    command -v "$1" &>/dev/null || {
        echo "Comando requerido: $1"
        exit 1
    }
}

necesita_archivo() {
    [[ -f "$1" ]] || {
        echo "Archivo requerido: $1"
        exit 1
    }
}

necesita_directorio() {
    [[ -d "$1" ]] || {
        echo "Directorio requerido: $1"
        exit 1
    }
}
EOF
```

---

## 21.4 Herramienta Práctica: git-clean

```bash
cat > ~/bin/git-clean << 'EOF'
#!/bin/bash
set -euo pipefail

MODO_PRUEBA=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run) MODO_PRUEBA=true; shift ;;
        *) shift ;;
    esac
done

if $MODO_PRUEBA; then
    echo "[MODO-PRUEBA] Eliminaría:"
fi

git branch --merged main | grep -v "main\|master\|develop" | while read branch; do
    if $MODO_PRUEBA; then
        echo "  Eliminar rama: $branch"
    else
        git branch -d "$branch"
        echo "Eliminada: $branch"
    fi
done

git clean -n -d
EOF

chmod +x ~/bin/git-clean
```

---

## 21.5 Herramienta Práctica: docker-clean

```bash
cat > ~/bin/docker-clean << 'EOF'
#!/bin/bash
set -euo pipefail

echo "Deteniendo todos los contenedores..."
docker stop $(docker ps -aq) 2>/dev/null || true

echo "Eliminando contenedores detenidos..."
docker container prune -f

echo "Eliminando imágenes sin usar..."
docker image prune -af

echo "Eliminando redes sin usar..."
docker network prune -f

echo "Eliminando caché de construcción..."
docker builder prune -af

echo "✅ Limpieza de Docker completa"
docker system df
EOF

chmod +x ~/bin/docker-clean
```

---

## 21.6 Hacer las Herramientas Disponibles en PATH

```bash
# Verificar si ~/bin está en PATH
echo $PATH | grep -q "$HOME/bin" && echo "Configurado" || echo "No configurado"

# Agregar a PATH (agregar a ~/.bashrc o ~/.zshrc)
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## 21.7 Dejar que la IA Ayude a Expandir la Caja de Herramientas

```bash
# Humano: ayúdame a crear una herramienta para analizar logs de acceso de Nginx

# IA:
cat > ~/bin/nginx-analizar << 'EOF'
#!/bin/bash

if [[ $# -lt 1 ]]; then
    echo "Uso: $0 <archivo_log_acceso>"
    exit 1
fi

ARCHIVO=$1

echo "=== Análisis de Nginx: $ARCHIVO ==="
echo ""

echo "Tamaño del archivo: $(du -h "$ARCHIVO" | cut -f1)"
echo "Total de líneas: $(wc -l < "$ARCHIVO")"
echo ""

echo "=== Top 10 IPs ==="
awk '{print $1}' "$ARCHIVO" | sort | uniq -c | sort -rn | head -10
echo ""

echo "=== Top 10 URLs ==="
awk '{print $7}' "$ARCHIVO" | sort | uniq -c | sort -rn | head -10
echo ""

echo "=== Distribución de Códigos de Estado ==="
awk '{print $9}' "$ARCHIVO" | sort | uniq -c | sort -rn
EOF

chmod +x ~/bin/nginx-analizar
```

---

## 21.8 Mejora Continua

```bash
# Revisar caja de herramientas anualmente
# - ¿Qué herramientas se usan poco? Eliminar
# - ¿Qué herramientas pueden mejorarse?
# - ¿Qué tareas repetitivas pueden automatizarse?

# Controlar versión de tu caja de herramientas
cd ~/bin
git init
git add .
git commit -m "Versión inicial"
```

---

## 21.9 Ejercicios

1. Crear tu estructura de directorio ~/bin
2. Escribir funciones comúnmente usadas en bibliotecas reutilizables
3. Escribir una herramienta para tareas que repites diariamente
4. Hacer que la IA ayude a crear una herramienta de análisis de logs de Nginx
5. Poner tu caja de herramientas bajo control de versiones Git
