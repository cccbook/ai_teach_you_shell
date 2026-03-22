# 19. Modo de Colaboración IA + Shell

---

## 19.1 Nueva Forma de Colaboración Humano-Máquina

Programación tradicional:
- Humanos escriben con teclado
- Humanos usan mouse para operar IDE
- Humanos ejecutan y prueban

Programación en la era de la IA:
- Humanos describen requisitos
- IA genera comandos de Shell y scripts
- Humanos revisan y ejecutan
- Humanos e IA depuran juntos

---

## 19.2 Describiendo Requisitos a la IA

### Descripciones Buenas

```bash
# Tarea clara
"Buscar todos los archivos .log mayores de 100MB en /var/log"

# Incluir formato de salida esperado
"Listar todos los archivos .py, mostrando: número_de_líneas nombre_archivo por línea"

# Indicar restricciones
"Comprimir todos los archivos .txt, pero omitir cualquiera que contenga 'test'"
```

### Descripciones Malas

```bash
# Demasiado vaga
"ayúdame a procesar logs"

# Irrealista
"ayúdame a escribir un sistema operativo"
```

---

## 19.3 Patrones de Comandos Shell Generados por IA

### Patrón 1: Comando Único

```bash
# Humano pregunta: encontrar top 10 archivos Python con más líneas
find . -name "*.py" -exec wc -l {} + | sort -rn | head -10
```

### Patrón 2: Script de Shell

```bash
# Humano pregunta: procesar imágenes por lotes
cat > procesar_imagenes.sh << 'EOF'
#!/bin/bash
for img in *.jpg; do
    convert "$img" -resize 800x600 "thumb_$img"
done
EOF
```

---

## 19.4 Desarrollo Iterativo

### Ronda 1: Generar Versión Inicial

```bash
# Humano: escribir un script de respaldo
# IA genera versión inicial, luego humano prueba, señala problemas:

# Humano: bien, pero necesito modo --dry-run
```

### Ronda 2: Agregar Funcionalidades

```bash
# Humano: también agregar manejo de errores y registro
```

### Ronda 3: Depurar

```bash
# Humano: obtuve error de 'Permiso denegado' después de ejecutar
# IA: corrige el problema...
```

---

## 19.5 Dejar que la IA Ayude a Depurar

```bash
# Humano: obtuve error después de ejecutar este comando
$ ./desplegar.sh
# Salida: /bin/bash^M: bad interpreter: No such file or directory

# IA: esto es un problema de fin de línea de Windows. Ejecutar:
sed -i 's/\r$//' desplegar.sh
```

---

## 19.6 Herramientas Recomendadas de Colaboración

### Multiplexor de Terminal

```bash
# tmux: dividir ventanas
tmux new -s misession
# Ctrl+b %  # división vertical
# Ctrl+b "  # división horizontal
```

---

## 19.7 Ejercicios

1. Describir una tarea compleja y que la IA genere comandos de Shell
2. Hacer que la IA revise un script existente en busca de problemas de seguridad
3. Usar iteración para que la IA ayude a escribir una herramienta práctica
4. Hacer que la IA explique código de Shell que no entiendas
