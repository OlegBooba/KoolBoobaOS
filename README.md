# KoolBoobaOS

**KoolBoobaOS** — операционная система на базе **Debian GNU/Linux** с рабочим
столом **XFCE4**, оформленным в стиле **Windows 7** (панель задач снизу,
кнопка «Пуск», системный трей, часы, сине-зелёные обои, тема окон в духе Aero).

Это настоящий, полноценный Linux-дистрибутив:
- собирается официальным инструментом Debian — `live-build`;
- запускается как Live-ISO (можно опробовать без установки);
- устанавливается на жёсткий диск через графический установщик **Calamares**;
- полностью работает в **VirtualBox** (и на реальном железе).

## Структура репозитория

```
.github/workflows/build-iso.yml   GitHub Actions — автосборка ISO
build.sh                          Скрипт сборки (запускает live-build)
config/
  package-lists/                  Список пакетов системы
  includes.chroot/                Файлы, которые кладутся в систему
                                    (темы, обои, конфиги XFCE, Calamares)
  hooks/live/                     Хуки, выполняемые внутри chroot при сборке
```

## Сборка ISO через GitHub Actions (рекомендуется)

1. Создайте репозиторий на GitHub и залейте туда содержимое этой папки.
2. Откройте вкладку **Actions** → workflow **"Build KoolBoobaOS ISO"**.
3. Нажмите **Run workflow** (или просто запушьте изменения в `main` —
   сборка запустится автоматически).
4. Через 1–2.5 часа (сборка Debian live-образа — долгий процесс) в разделе
   **Artifacts** появится файл `KoolBoobaOS-ISO` с готовым
   `KoolBoobaOS-amd64.iso`.
5. При ручном запуске (`workflow_dispatch`) ISO также публикуется в
   **Releases** репозитория.

## Сборка локально (на Debian/Ubuntu)

```bash
git clone <ваш-репозиторий>
cd koolbooba
sudo ./build.sh
```

По итогу в корне появится `KoolBoobaOS-amd64.iso`.

> Для сборки нужно: Debian/Ubuntu-хост, ~4 ядра, ~20 ГБ свободного места,
> root-доступ (используется `debootstrap`/`chroot`).

## Запуск в VirtualBox

1. **Новая ВМ** → Тип: `Linux`, Версия: `Debian (64-bit)`.
2. Память: минимум 2048 МБ (рекомендуется 4096 МБ).
3. Диск: минимум 15 ГБ (для установки на диск).
4. В настройках ВМ → **Носители** → подключите `KoolBoobaOS-amd64.iso`
   как оптический привод.
5. Включите **Video Memory** 64+ МБ и **3D-ускорение** (по желанию, для плавности XFCE).
6. Запустите ВМ — загрузится Live-рабочий стол KoolBoobaOS.

## Установка на диск

На рабочем столе Live-системы есть ярлык **«Установить KoolBoobaOS»** —
он запускает графический установщик Calamares: разметка диска, часовой
пояс, создание пользователя, установка загрузчика GRUB. После завершения
перезагрузите ВМ и извлеките ISO — система загрузится с диска.

## Что внутри

- **База:** Debian GNU/Linux 12 (bookworm)
- **Рабочий стол:** XFCE4 (`xfce4`, `xfce4-goodies`, Whisker Menu вместо
  стандартного меню приложений — даёт эффект кнопки «Пуск»)
- **Тема оформления:** собственная тема `Win7-KoolBooba` (GTK3 CSS +
  xfwm4 themerc) — синие градиенты, скруглённые кнопки, заголовки окон
  в стиле Aero
- **Экран входа:** LightDM + lightdm-gtk-greeter с тем же фоном
- **Установщик:** Calamares с брендингом KoolBoobaOS
- **Браузер:** Firefox ESR
- **Офисные/базовые утилиты:** Mousepad, Ristretto, Parole, File Roller,
  GParted, Synaptic

## Изменение оформления / пакетов

- Список пакетов: `config/package-lists/koolbooba.list.chroot`
- Настройки панели/темы XFCE:
  `config/includes.chroot/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/`
- Тема окон: `config/includes.chroot/usr/share/themes/Win7-KoolBooba/`
- Обои: `config/includes.chroot/usr/share/backgrounds/koolbooba/`

После изменений просто запушьте — Actions пересоберёт ISO.
