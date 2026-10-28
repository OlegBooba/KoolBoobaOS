#!/bin/bash
# Запуск установщика KoolBoobaOS на жёсткий диск.
# Используется Calamares — графический установщик,
# который переносит live-систему (включая тему XFCE Win7-like) на диск.

if command -v calamares >/dev/null 2>&1; then
    echo "Запускаю графический установщик KoolBoobaOS (Calamares)..."
    exec calamares
else
    echo "Calamares не найден. Попытка запуска Debian-installer..."
    if [ -x /usr/lib/debian-installer-launcher/launcher ]; then
        exec /usr/lib/debian-installer-launcher/launcher
    else
        echo "Установщик не найден в системе."
        exit 1
    fi
fi
