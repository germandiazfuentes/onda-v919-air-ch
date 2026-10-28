# Restaura el archivo de calibración del WiFi (AP6212 / BCM43430) propio de la Onda V919 Air CH.
# Síntoma que arregla: el WiFi aparece "OK" en el Administrador de dispositivos pero no ve NINGUNA red
# (suele pasar tras una actualización de Windows, que pone un 43430r0nvram.txt genérico).
# Uso: copiar junto a este script el 43430r0nvram.txt bueno (carpeta drivers/wifi del repositorio)
#      y ejecutar restaurar-nvram-wifi.cmd como administrador.
$ErrorActionPreference = 'Stop'
$bueno = Join-Path $PSScriptRoot '43430r0nvram.txt'
if (-not (Test-Path $bueno)) { $bueno = Join-Path $PSScriptRoot '..\..\drivers\wifi\43430r0nvram.txt' }
$dest = "$env:windir\System32\drivers\43430r0nvram.txt"

if (-not (Select-String -Path $bueno -Pattern '^xtalfreq=26000' -Quiet)) { throw "El archivo $bueno no es el de la V919 Air CH (debe tener xtalfreq=26000)" }
if (Test-Path $dest) {
  $actual = Select-String -Path $dest -Pattern '^xtalfreq=\d+' | ForEach-Object { $_.Line }
  Write-Host "Archivo actual: $((Get-Item $dest).Length) bytes, $actual"
  Copy-Item $dest "$dest.anterior" -Force
}
Copy-Item $bueno $dest -Force
Write-Host "Copiado el nvram correcto ($((Get-Item $dest).Length) bytes, xtalfreq=26000)." -ForegroundColor Green

$wifi = Get-NetAdapter | Where-Object InterfaceDescription -match 'Broadcom 802\.11' | Select-Object -First 1
if ($wifi) {
  Write-Host "Reiniciando el adaptador $($wifi.Name)..."
  Disable-NetAdapter -Name $wifi.Name -Confirm:$false; Start-Sleep 3
  Enable-NetAdapter -Name $wifi.Name -Confirm:$false; Start-Sleep 15
  netsh wlan show networks | Select-String 'SSID'
} else { Write-Host 'No se encontró el adaptador Broadcom: reinicia la tablet.' -ForegroundColor Yellow }
Read-Host 'Intro para cerrar' | Out-Null
