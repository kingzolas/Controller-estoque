@echo off
setlocal

REM Caminhos dos arquivos
set "APP_PATH=C:\Program Files\Velocity Estoque"
set "UPDATE_PATH=%APPDATA%\VelocityUpdate"

REM Verificar se o aplicativo está fechado
tasklist /FI "IMAGENAME eq Velocity.exe" | find /I "Velocity.exe" >nul
if not errorlevel 1 (
    echo Aguardando o aplicativo ser fechado...
    timeout /t 5
    goto :retry
)
:retry
tasklist /FI "IMAGENAME eq Velocity.exe" | find /I "Velocity.exe" >nul
if not errorlevel 1 (
    goto :retry
)

REM Substituir arquivos
xcopy /E /Y /I "%UPDATE_PATH%\*" "%APP_PATH%"

REM Reiniciar o aplicativo
start "" "%APP_PATH%\Velocity.exe"

exit
