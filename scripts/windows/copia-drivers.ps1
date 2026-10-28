# Copia de seguridad de TODOS los drivers instalados + los archivos de firmware del WiFi/BT.
# Hazla ANTES de actualizar Windows. Uso (como administrador):
#   powershell -ExecutionPolicy Bypass -File copia-drivers.ps1 -Destino E:\copia-drivers
param([string]$Destino = (Join-Path $PSScriptRoot 'copia-drivers'))
New-Item -ItemType Directory -Force "$Destino\drivers", "$Destino\system32-drivers" | Out-Null
dism /online /export-driver /destination:"$Destino\drivers"
# Firmware/calibración del AP6212 que el instalador del driver deja en System32\drivers
Get-ChildItem "$env:windir\System32\drivers" | Where-Object { -not $_.PSIsContainer -and $_.Name -match '43430|bcm|brcm|nvram|\.hcd$' } |
  Copy-Item -Destination "$Destino\system32-drivers" -PassThru | ForEach-Object Name
"Paquetes exportados: $((Get-ChildItem "$Destino\drivers" | Where-Object PSIsContainer).Count) -> $Destino"
