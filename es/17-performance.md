# 17. Optimización de Rendimiento

---

## 17.1 Por Qué Importa el Rendimiento en Shell

Los scripts de shell se usan frecuentemente para:
- Procesamiento por lotes de grandes cantidades de archivos
- Tareas de automatización
- Pipelines de CI/CD

Un script lento puede retrasar todo el proceso por horas. Optimizar scripts de Shell puede mejorar enormemente la eficiencia.

---

## 17.2 Evitar Comandos Externos

```bash
# Lento: comandos externos
for f in *.txt; do
    nombre=$(basename "$f")
    echo "$nombre"
done

# Rápido: comandos internos del shell
for f in *.txt; do
    echo "${f##*/}"
done
```

### Interno vs Externo

| Lento | Rápido | Descripción |
|-------|--------|-------------|
| `$(cat archivo)` | `$(<archivo)` | Lectura directa |
| `$(basename $f)` | `${f##*/}` | Expansión de parámetros |
| `$(expr $a + $b)` | `$((a + b))` | Aritmética |
| `$(echo $var)` | `"$var"` | Uso directo |

---

## 17.3 Usar `while read` en Lugar de `for`

```bash
# Lento: for + sustitución de comando
for linea in $(cat archivo.txt); do
    procesar "$linea"
done

# Rápido: while read
while IFS= read -r linea; do
    procesar "$linea"
done < archivo.txt
```

---

## 17.4 Procesamiento en Paralelo

### Usar `&` y `wait`

```bash
#!/bin/bash

tarea1 &
tarea2 &
tarea3 &

wait

echo "Todas las tareas completadas"
```

### Usar `xargs -P`

```bash
# Secuencial
cat archivos.txt | xargs -I {} procesar {}

# Paralelo (4 simultáneos)
cat archivos.txt | xargs -P 4 -I {} procesar {}
```

---

## 17.5 Evitar Subshells

```bash
# Lento: subshell por iteración
for f in *.txt; do
    contenido=$(cat "$f")
    echo "$contenido" | wc -l
done

# Rápido: un solo subshell
while IFS= read -r f; do
    wc -l "$f"
done < <(ls *.txt)
```

---

## 17.6 Referencia Rápida

| Optimización | Lento | Rápido |
|--------------|-------|--------|
| Leer archivo | `$(cat archivo)` | `$(<archivo)` o `while read` |
| Ruta | `$(basename $f)` | `${f##*/}` |
| Matemáticas | `$(expr $a + $b)` | `$((a + b))` |
| Paralelo | secuencial | `&` + `wait` o `xargs -P` |

---

## 17.7 Ejercicios

1. Usar `time` para medir cuánto tarda un bucle procesando 1000 archivos
2. Convertir un script secuencial a procesamiento paralelo
3. Comparar rendimiento de `$(cat archivo)` vs `while read`
4. Usar `xargs -P` para acelerar procesamiento por lotes de imágenes
