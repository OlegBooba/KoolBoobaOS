#!/bin/bash
# ============================================================
#  KoolBoobaOS build script
#  Собирает установочный Live/Install ISO на базе
#  Debian GNU/Linux + XFCE4 (оформлено под стиль Windows 7)
#  Использует стандартный Debian-инструмент live-build.
# ============================================================
set -euo pipefail

echo "=============================================="
echo "  KoolBoobaOS ISO Builder"
echo "=============================================="

if [ "$(id -u)" -ne 0 ]; then
    echo "[!] Этот скрипт нужно запускать от root (sudo ./build.sh)"
    exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$REPO_DIR/.lb-build"

echo "[*] Устанавливаю зависимости сборки..."
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y \
    live-build \
    debootstrap \
    xorriso \
    syslinux-utils \
    squashfs-tools \
    isolinux \
    dosfstools \
    mtools \
    ca-certificates \
    wget

echo "[*] Готовлю чистую рабочую директорию сборки: $BUILD_DIR"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "[*] Копирую конфигурацию проекта (пакеты, хуки, включаемые файлы)..."
mkdir -p config
cp -r "$REPO_DIR/config/package-lists" config/
cp -r "$REPO_DIR/config/includes.chroot" config/
cp -r "$REPO_DIR/config/hooks" config/

echo "[*] Готовлю auto/ скрипты для live-build..."
mkdir -p auto
cat > auto/config <<'EOF'
#!/bin/sh
set -e

lb config noauto \
    --distribution bookworm \
    --archive-areas "main contrib non-free non-free-firmware" \
    --mirror-bootstrap "http://deb.debian.org/debian/" \
    --mirror-binary "http://deb.debian.org/debian/" \
    --mirror-security "http://security.debian.org/debian-security/" \
    --binary-images iso-hybrid \
    --architecture amd64 \
    --linux-flavours amd64 \
    --debian-installer live \
    --debian-installer-gui true \
    --iso-application "KoolBoobaOS" \
    --iso-publisher "KoolBoobaOS Project" \
    --iso-volume "KoolBoobaOS" \
    --bootappend-live "boot=live components username=koolbooba hostname=koolbooba locales=ru_RU.UTF-8 keyboard-layouts=us,ru timezone=Europe/Moscow" \
    --memtest none \
    --win32-loader false \
    "${@}"
EOF
chmod +x auto/config

cat > auto/build <<'EOF'
#!/bin/sh
set -e
lb build "${@}" 2>&1 | tee build.log
EOF
chmod +x auto/build

echo "[*] Запускаю lb config..."
lb config

echo "[*] Запускаю сборку (lb build). Это займёт продолжительное время..."
lb build

ISO_FILE=$(ls live-image-*.hybrid.iso 2>/dev/null | head -n1 || true)
if [ -z "$ISO_FILE" ]; then
    ISO_FILE=$(ls *.iso 2>/dev/null | head -n1 || true)
fi

if [ -n "$ISO_FILE" ]; then
    mv "$ISO_FILE" "$REPO_DIR/KoolBoobaOS-amd64.iso"
    cp "$BUILD_DIR/build.log" "$REPO_DIR/build.log" 2>/dev/null || true
    echo "=============================================="
    echo "[OK] Сборка завершена: KoolBoobaOS-amd64.iso"
    echo "=============================================="
else
    echo "[!] ISO не найден после сборки. Проверьте build.log"
    cp "$BUILD_DIR/build.log" "$REPO_DIR/build.log" 2>/dev/null || true
    exit 1
fi
