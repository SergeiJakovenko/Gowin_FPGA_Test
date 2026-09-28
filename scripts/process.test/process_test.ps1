# Динамическое определение путей относительно расположения скрипта
$ScriptDir    = $PSScriptRoot
$ServerDir    = Join-Path $ScriptDir "..\..\server"
$ServerScript = Join-Path $ServerDir "serv_process.py"
$WebFile      = Join-Path $ScriptDir "..\..\web\web_process.html"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host " Запуск тестового стенда: ПЛИС -> WS -> Web" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Проверка существования файлов
if (-not (Test-Path $ServerScript)) {
    Write-Host "[ОШИБКА] Не найден файл сервера: $ServerScript" -ForegroundColor Red
    Write-Host "Убедитесь, что файл serv_process.py создан в папке /server/" -ForegroundColor Yellow
    return
}

if (-not (Test-Path $WebFile)) {
    Write-Host "[ОШИБКА] Не найден файл веб-страницы: $WebFile" -ForegroundColor Red
    Write-Host "Убедитесь, что файл web_process.html создан в папке /web/" -ForegroundColor Yellow
    return
}

# 2. Поиск интерпретатора Python (проверяем py.exe, затем python.exe)
$PythonCmd = "py"
if (-not (Get-Command "py" -ErrorAction SilentlyContinue)) {
    if (Get-Command "python" -ErrorAction SilentlyContinue) {
        $PythonCmd = "python"
    } else {
        Write-Host "[ОШИБКА] Python не найден в системе!" -ForegroundColor Red
        Write-Host "Установите Python или добавьте его в переменную окружения PATH." -ForegroundColor Yellow
        return
    }
}

# 3. Запуск Python-сервера в отдельном окне
Write-Host "[1/2] Запуск WebSocket сервера ($PythonCmd)..." -ForegroundColor Yellow
Start-Process $PythonCmd -ArgumentList "`"$ServerScript`"" -WorkingDirectory $ServerDir

# Пауза для инициализации COM-порта и WS-сервера
Start-Sleep -Seconds 2

# 4. Открытие веб-страницы в браузере по умолчанию
Write-Host "[2/2] Открытие интерфейса в браузере..." -ForegroundColor Yellow
Start-Process "$WebFile"

Write-Host "`nГотово! Стенд успешно запущен." -ForegroundColor Green