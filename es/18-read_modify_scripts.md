# 18. Leyendo y Modificando Scripts de Otros

---

## 18.1 Por Qué Leer Scripts de Otros

- Asumir mantenimiento de proyecto
- Usar herramientas de código abierto
- Depurar problemas
- Aprender nuevas técnicas

La IA se encuentra con scripts desconocidos diariamente, por lo que aprender a entender rápidamente scripts de Shell escritos por otros es esencial.

---

## 18.2 Observación Inicial

### Paso 1: Verificar shebang

```bash
head -1 script.sh
```

```bash
#!/bin/bash      # Usar bash
#!/bin/sh        # Usar POSIX sh (más compatible)
```

### Paso 2: Verificar permisos y tamaño

```bash
ls -la script.sh
wc -l script.sh
```

### Paso 3: Verificación rápida de sintaxis

```bash
bash -n script.sh  # Verificar sintaxis nomas, no ejecutar
```

---

## 18.3 Entendiendo la Estructura

### Estructura Típica

```bash
#!/bin/bash
# Comentario: descripción del script

# Configuración
set -euo pipefail
VAR="valor"

# Definiciones de funciones
function ayuda() { ... }

# Flujo principal
principal() { ... }

# Ejecutar
principal "$@"
```

### Encontrar Flujo Principal

```bash
# Ver últimas líneas
tail -20 script.sh

# Encontrar definiciones de funciones
grep -n "^function\|^[[:space:]]*[a-z_]*\(" script.sh
```

---

## 18.4 Comandos Comunes de Análisis

```bash
# Encontrar todas las definiciones de funciones
grep -n "^[[:space:]]*function" script.sh

# Encontrar todos los condicionales
grep -n "if\|\[\[" script.sh

# Encontrar todos los bucles
grep -n "for\|while\|do\|done" script.sh

# Encontrar sustituciones de comandos
grep -n '\$(' script.sh

# Encontrar todas las salidas
grep -n "exit" script.sh
```

---

## 18.5 Verificaciones de Seguridad

```bash
# Encontrar comandos peligrosos
grep -n "rm -rf" script.sh
grep -n "sudo" script.sh
grep -n "eval" script.sh

# Verificar riesgos de inyección de variables
grep -n '\$[A-Za-z_][A-Za-z0-9_]*[^"}]' script.sh
```

---

## 18.6 Ejercicios

1. Analizar un script de Shell existente con `grep` y `awk`
2. Encontrar todas las variables en un script y entender su propósito
3. Usar `bash -n` para verificar la sintaxis de un script
4. Agregar comentarios a un script sin comentarios explicando cada sección
