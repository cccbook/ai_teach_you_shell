# 16. Técnicas de Depuración

---

## 16.1 Mentalidad de Depuración de la IA

Cuando los humanos encuentran errores: pánico, búsqueda en internet, copiar-pegar
Cuando la IA encuentra errores: analizar mensaje, inferir causa, ejecutar solución

Flujo de depuración de la IA:
```
Observar salida de error → Entender tipo de error → Localizar problema → Corregir → Verificar
```

---

## 16.2 `bash -x`: Seguimiento de Ejecución

Depuración más simple: agregar flag `-x`

```bash
bash -x script.sh
```

Muestra cada línea ejecutada con prefijo `+`:

```bash
+ mkdir -p test
+ cd test
+ echo 'Hola'
Hola
```

### Depurar Solo una Sección

```bash
#!/bin/bash

echo "Esto no se mostrará"
set -x
# La depuración comienza aquí
nombre="Ana"
echo "Hola, $nombre"
set +x
# La depuración termina aquí
echo "Esto no se mostrará"
```

---

## 16.3 Errores Comunes y Soluciones

### Error 1: Permiso Denegado

```bash
# Error
./script.sh
# Salida: Permission denied

# Solución
chmod +x script.sh
./script.sh
```

### Error 2: Comando No Encontrado

```bash
# Error
python script.py
# Salida: command not found: python

# Solución: usar ruta completa
/usr/bin/python3 script.py
```

### Error 3: Variable No Definida

```bash
#!/bin/bash
set -u

echo $variable_no_definida
# Salida: bash: variable_no_definida: unbound variable

# Solución: dar valor por defecto
echo ${variable_no_definida:-predeterminado}
```

---

## 16.4 Depuración con `echo`

Cuando `-x` no es suficiente, agregar `echo` manualmente:

```bash
#!/bin/bash

echo "DEBUG: Entrando a la función"
echo "DEBUG: Parámetros = $@"

procesar() {
    echo "DEBUG: En procesar"
    local resultado=$(comando_costoso)
    echo "DEBUG: resultado = $resultado"
}
```

---

## 16.5 Referencia Rápida

| Comando | Descripción |
|---------|-------------|
| `bash -n script.sh` | Verificar sintaxis nomas |
| `bash -x script.sh` | Seguimiento de ejecución |
| `set -x` | Habilitar modo depuración |
| `set +x` | Deshabilitar modo depuración |
| `trap 'echo cmd' DEBUG` | Seguimiento de cada comando |

---

## 16.6 Ejercicios

1. Ejecutar un script con `bash -x` y observar el formato de salida
2. Usar `set -x` en un script para depurar solo una función específica
3. Encontrar un comando que falle, analizar el mensaje de error y corregirlo
4. Crear manejo de errores elegante con `trap`
