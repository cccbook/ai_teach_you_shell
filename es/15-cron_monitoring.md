# 15. Tareas Programadas y Monitoreo

---

## 15.1 Fundamentos de crontab

### Formato Básico

```
min hora dia mes dia_semana  comando
┬    ┬     ┬   ┬   ┬           ┬
│    │     │   │   │           │
│    │     │   │   │           └─ comando
│    │     │   │   └─ día de la semana (0-7, 0 y 7 son domingo)
│    │     │   └─ mes (1-12)
│    │     └─ día del mes (1-31)
│    └─ hora (0-23)
└─ minuto (0-59)
```

### Ejemplos Comunes

```bash
# Cada minuto
* * * * * /ruta/al/script.sh

# Cada hora en el minuto 30
30 * * * * /ruta/al/script.sh

# Diario a las 3 AM
0 3 * * * /ruta/al/script.sh

# Semanal el lunes a las 9 AM
0 9 * * 1 /ruta/al/script.sh

# Cada 5 minutos
*/5 * * * * /ruta/al/script.sh
```

---

## 15.2 Gestionando crontab

```bash
# Mostrar crontab actual
crontab -l

# Editar crontab
crontab -e

# Eliminar crontab
crontab -r

# Crear archivo crontab
cat > mycron << 'EOF'
# Respaldo diario
0 3 * * * /scripts/backup.sh >> /var/log/backup.log 2>&1

# Limpieza semanal
0 4 * * 0 /scripts/clean-logs.sh

# Verificación de salud cada 5 minutos
*/5 * * * * /scripts/health-check.sh
EOF

crontab mycron
crontab -l
```

---

## 15.3 Script de Verificación de Salud

```bash
cat > scripts/health-check.sh << 'EOF'
#!/bin/bash
set -euo pipefail

ALERT_EMAIL="admin@example.com"
WEB_URL="https://myapp.com/health"
LOG_FILE="/var/log/health-check.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $@" >> "$LOG_FILE"
}

check_web() {
    if curl -sf "$WEB_URL" &>/dev/null; then
        log "WEB: OK"
        return 0
    else
        log "WEB: FALLIDO"
        return 1
    fi
}

check_disk() {
    local uso=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [[ $uso -gt 90 ]]; then
        log "DISCO: ADVERTENCIA (${uso}%)"
        return 1
    fi
    log "DISCO: OK (${uso}%)"
    return 0
}

FALLIDOS=0

check_web || ((FALLIDOS++))
check_disk || ((FALLIDOS++))

if [[ $FALLIDOS -gt 0 ]]; then
    echo "Verificación de salud fallida, $FALLIDOS elementos anormales" | mail -s "Alerta" "$ALERT_EMAIL"
fi

exit $FALLIDOS
EOF

chmod +x scripts/health-check.sh
```

---

## 15.4 Script de Limpieza Automática

```bash
cat > scripts/clean-logs.sh << 'EOF'
#!/bin/bash
set -euo pipefail

LOG_DIR="/var/log"
MAX_AGE_DAYS=30

# Eliminar logs antiguos
find "$LOG_DIR" -name "*.log" -mtime +$MAX_AGE_DAYS -delete

# Comprimir logs antiguos
find "$LOG_DIR" -name "*.log" -mtime +7 -exec gzip {} \;

echo "Limpieza completa: $(date)"
EOF

chmod +x scripts/clean-logs.sh
```

---

## 15.5 Ejercicios

1. Configurar un crontab que muestre "hola" cada hora y registre en un archivo
2. Escribir un script de monitoreo de espacio en disco que alerte cuando supere el 80%
3. Crear un script que respalde automáticamente una base de datos MySQL
4. Usar systemd timer en lugar de cron para ejecutar verificación de salud cada minuto
