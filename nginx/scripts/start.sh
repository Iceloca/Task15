#!/bin/sh

# Путь к текущей директории
DIR=$(pwd)

# Пути к логам
RED_LOG="$DIR/red/server.log"
BLUE_LOG="$DIR/blue/server.log"
CPU_LOG="$DIR/cpu-load/server.log"

# Очистим старые логи
> "$RED_LOG"
> "$BLUE_LOG"
> "$CPU_LOG"

# Запускаем сервер для папки red на порту 9091 и логируем
php -S localhost:9091 "$DIR/red/color.php" > "$RED_LOG" 2>&1 &
PID_RED=$!

# Запускаем сервер для папки blue на порту 9092 и логируем
php -S localhost:9092 "$DIR/blue/color.php" > "$BLUE_LOG" 2>&1 &
PID_BLUE=$!

# Запускаем сервер для папки cpu на порту 9093 и логируем
php -S localhost:9093 "$DIR/cpu-load/cpu.php" > "$CPU_LOG" 2>&1 &
PID_CPU=$!



# Сохраняем PID-файл (по желанию)
echo "$PID_RED" > "$DIR/red/server.pid"
echo "$PID_BLUE" > "$DIR/blue/server.pid"
echo "$PID_CPU" > "$DIR/cpu-load/server.pid"

echo "Red server running on http://localhost:9091"
echo "     Log: $RED_LOG"
echo "     PID: $PID_RED"

echo "Blue server running on http://localhost:9092"
echo "     Log: $BLUE_LOG"
echo "     PID: $PID_BLUE"

echo "CPU server running on http://localhost:9093"
echo "     Log: $CPU_LOG"
echo "     PID: $PID_CPU"
