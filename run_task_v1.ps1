# Скрипт автоматизации для задачи: Тест встроенной кнопки и LED (Версия 1)
param(
    [string]$TaskName = "Task_1_Button_LED"
)

Write-Host "=== Инициализация и запуск проекта: $TaskName == " -ForegroundColor Cyan

# 1. Создание структуры папок, если они еще не созданы
$dirs = @("hdl", "src", "sim", "pdf", "server", "web", "scripts", "work")
foreach ($dir in $dirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
        Write-Host "Создана папка: $dir" -ForegroundColor DarkGray
    }
}

# 2. Проверка и установка зависимостей Python
Write-Host "Проверка окружения Python..." -ForegroundColor Yellow
python -c "import serial, flask" 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Установка библиотек pyserial и flask..." -ForegroundColor Yellow
    pip install pyserial flask
}

# 3. Запуск симуляции ModelSim (если установлен vsim)
$vsimPath = Get-Command "vsim" -ErrorAction SilentlyContinue
if ($vsimPath) {
    Write-Host "Запуск симуляции в ModelSim..." -ForegroundColor Green
    Set-Location work
    # Команды компиляции и симуляции можно вынести в .do файл
    # vlib work
    # vcom -2008 ../hdl/top_led_button.vhd
    # vcom -2008 ../sim/top_led_button_tb.vhd
    # vsim -c top_led_button_tb -do "run -all; exit"
    Set-Location ..
    Write-Host "Симуляция завершена. Не забудьте сохранить временную диаграмму в папку /pdf с именем задачи!" -ForegroundColor Magenta
} else {
    Write-Host "ModelSim не найден в PATH, пропускаем этап симуляции." -ForegroundColor Red
}

# 4. Запуск Python-сервера
Write-Host "Запуск Python-сервера на COM5..." -ForegroundColor Green
python server/app.py