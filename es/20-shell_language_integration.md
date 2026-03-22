# 20. Conectando Shell con Otros Lenguajes

---

## 20.1 ¿Qué Tareas Deben Usar Shell?

Tareas donde Shell destaca:
- Operaciones de archivos
- Administración de sistemas
- Flujos de trabajo de automatización
- Composición de pipelines
- Prototipos rápidos

Tareas más adecuadas para otros lenguajes:
- Procesamiento de datos complejo (Python, AWK)
- Programación web (JavaScript, Go)
- Cálculo numérico (Python, R, Julia)
- Programación de sistemas (C, Rust)

---

## 20.2 Shell Llama a Python

### Invocación Simple

```bash
#!/bin/bash

# Llamar script Python
python3 procesar_datos.py entrada.csv

# Pasar argumentos
python3 script.py arg1 arg2

# Obtener salida
resultado=$(python3 -c "print('hola desde python')")
echo "$resultado"
```

### Python Incrustado en Shell

```bash
#!/bin/bash

python3 << 'PYEOF'
import csv

with open('datos.csv', 'r') as f:
    reader = csv.DictReader(f)
    total = sum(int(row['monto']) for row in reader)
    print(f"Total: {total}")
PYEOF
```

---

## 20.3 Python Llama a Shell

### Usando `subprocess`

```python
import subprocess

# Ejecutar comando simple
resultado = subprocess.run(['ls', '-la'], capture_output=True, text=True)
print(resultado.stdout)

# Ejecutar comando complejo
resultado = subprocess.run(
    'find . -name "*.py" | wc -l',
    shell=True,
    capture_output=True,
    text=True
)
```

---

## 20.4 Shell Llama a JavaScript/Node.js

```bash
#!/bin/bash

# Ejecutar comando Node.js
node -e "console.log('hola desde node')"

# Ejecutar script Node.js
node procesar-json.js datos.json
```

---

## 20.5 Herramientas de Puente

### `jq`: Procesamiento de JSON

```bash
# Parsear JSON
echo '{"nombre": "Ana", "edad": 25}' | jq '.nombre'

# Leer de archivo
jq '.usuarios[] | select(.edad > 18)' datos.json
```

### `yq`: Procesamiento de YAML

```bash
# Parsear YAML
yq '.database.host' config.yaml

# Convertir YAML a JSON
yq -o=json config.yaml
```

---

## 20.6 Referencia Rápida

| Puente | Sintaxis |
|--------|----------|
| Shell→Python | `python3 script.py` o `python3 << PYEOF` |
| Python→Shell | `subprocess.run(['ls'])` |
| Shell→Node | `node script.js` o `node << JSEOF` |
| Parsear JSON | `jq '.clave' archivo.json` |
| Parsear YAML | `yq '.clave' archivo.yaml` |
| Orquestar | `make` |

---

## 20.7 Ejercicios

1. Usar Shell para llamar a Python para procesar un archivo CSV
2. Usar `subprocess` de Python para ejecutar comandos de Shell
3. Usar `jq` para parsear una respuesta JSON de API
4. Usar Makefile para orquestar tareas de Shell, Python y Node.js
