# Ejecutar desde la carpeta raiz del proyecto: powershell -ExecutionPolicy Bypass -File .\scripts\preparar_web.ps1
$ErrorActionPreference = 'Stop'
$version = 'drift-2.35.4'
$base = "https://github.com/simolus3/drift/releases/download/$version"
New-Item -ItemType Directory -Force -Path 'web' | Out-Null

Write-Host 'Descargando soporte SQLite WebAssembly para Drift...'
Invoke-WebRequest -Uri "$base/sqlite3.wasm" -OutFile 'web/sqlite3.wasm'
Invoke-WebRequest -Uri "$base/drift_worker.dart.js" -OutFile 'web/drift_worker.dart.js'

if ((Get-Item 'web/sqlite3.wasm').Length -lt 10000) { throw 'sqlite3.wasm no parece correcto.' }
if ((Get-Item 'web/drift_worker.dart.js').Length -lt 1000) { throw 'drift_worker.dart.js no parece correcto.' }
Write-Host 'Archivos descargados. Ya puedes ejecutar flutter run -d chrome --web-port=7357'
