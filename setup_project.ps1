# Полная инициализация структуры проекта для Tang Primer 20K
$root = "C:\Gowin_FPGA_Test"
Set-Location $root

Write-Host "=== Инициализация структуры проекта в $root ===" -ForegroundColor Cyan

# 1. Создание папок
$directories = @("hdl", "src", "sim", "pdf", "server", "web", "scripts", "work")
foreach ($dir in $directories) {
    $path = Join-Path $root $dir
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
        Write-Host "Создана папка: $dir" -ForegroundColor Green
    }
}

# 2. Создание скрипта компиляции и запуска ModelSim (scripts/compile.ps1)
$compileScript = @'
# Скрипт компиляции и симуляции в ModelSim
Set-Location ..
if (!(Test-Path "work")) { vlib work }
Set-Location work

Write-Host "Компиляция VHDL файлов..." -ForegroundColor Yellow
vcom -2008 ../hdl/top_led_button.vhd
vcom -2008 ../sim/top_led_button_tb.vhd

Write-Host "Запуск симуляции..." -ForegroundColor Green
vsim -c top_led_button_tb -do "run -all; exit"
Set-Location ..
Write-Host "Симуляция завершена. Сохраните диаграмму в папку /pdf!" -ForegroundColor Cyan
'
Set-Content -Path "scripts/compile.ps1" -Value $compileScript
'@

# 3. Создание общего скрипта задачи (scripts/run_task_v1.ps1)
$runTaskScript = @'
param([string]$TaskName = "Task_1_Button_LED")
Write-Host "Запуск задачи: $TaskName" -ForegroundColor Cyan

# Запуск ModelSim симуляции
& "scripts/compile.ps1"

# Запуск Python сервера
Write-Host "Запуск Python сервера на COM5..." -ForegroundColor Green
python server/app.py
'
Set-Content -Path "scripts/run_task_v1.ps1" -Value $runTaskScript

Write-Host "Проект успешно инициализирован! Готово к работе." -ForegroundColor Cyan
'@