# Prepara una microSD/pendrive (>= 16 GB) para INSTALAR WINDOWS 10 en dual boot en la Onda V919 Air CH.
# BORRA EL DISCO INDICADO. Ejecutar en el PC como administrador (necesita 7-Zip instalado):
#   .\preparar-sd-windows.ps1 -Disco 7 -Usb 'D:\firmware\extraido\Windows10\usb'
# -Usb : carpeta "usb" obtenida al descomprimir "V919 AIR CH DualOS_Windows System Files_V7_20160304.part1.rar"
#        (contiene Boot, EFI, images\Install.wim, scripts, Sources, bootmgr y win10PE_th2_x64.iso)
#
# CLAVE: el WinPE 1511 de Onda solo ve la PRIMERA partición de un disco extraíble, así que la partición
# NTFS "WINPE" (con Scripts\main.cmd e Install.wim) debe ser la 1 y la FAT32 de arranque la 2.
# Con el orden al revés, WinPE arranca pero dice que no encuentra main.cmd.
param([Parameter(Mandatory)][int]$Disco, [Parameter(Mandatory)][string]$Usb,
      [string]$SieteZip = 'C:\Program Files\7-Zip\7z.exe')
$ErrorActionPreference = 'Stop'
foreach ($x in 'Boot','EFI','images','scripts','Sources','bootmgr','win10PE_th2_x64.iso') { if (-not (Test-Path (Join-Path $Usb $x))) { throw "Falta $x en $Usb" } }
$d = Get-Disk -Number $Disco
if ($d.BusType -notin 'USB','SD' -or $d.IsBoot -or $d.IsSystem) { throw "El disco $Disco ($($d.FriendlyName), $($d.BusType)) no parece una tarjeta/pendrive" }
if ($d.Size -lt 15GB) { throw 'Hace falta una tarjeta de al menos 16 GB' }
Write-Host "Se BORRARÁ el disco $Disco : $($d.FriendlyName) $([math]::Round($d.Size/1GB)) GB" -ForegroundColor Yellow
if ((Read-Host 'Escribe BORRAR para continuar') -ne 'BORRAR') { exit }

# diskpart a veces falla con "Se eliminó el objeto" porque Windows monta la partición a mitad:
# por eso se hace en pasos separados y con reintentos.
function DP($t) {
  $f = Join-Path $env:TEMP 'dp-step.txt'
  Set-Content $f ("select disk $Disco`r`n$t`r`nexit") -Encoding ASCII
  for ($i = 1; $i -le 3; $i++) { diskpart /s $f | Out-Null; if ($LASTEXITCODE -eq 0) { return }; Start-Sleep 5 }
  throw "diskpart falló: $t"
}
$mbWinpe = [int](($d.Size / 1MB) - 1100)          # todo menos ~1 GB para la partición de arranque
DP "clean`r`nconvert mbr`r`ncreate partition primary size=$mbWinpe`r`ncreate partition primary"
Start-Sleep 5
DP "select partition 1`r`nformat quick fs=ntfs label=WINPE`r`nassign"
Start-Sleep 3
DP "select partition 2`r`nformat quick fs=fat32 label=PEBOOT`r`nactive`r`nassign"
Start-Sleep 3
$vol = Get-Partition -DiskNumber $Disco | Get-Volume
$winpe = ($vol | Where-Object FileSystemLabel -eq 'WINPE').DriveLetter
$peboot = ($vol | Where-Object FileSystemLabel -eq 'PEBOOT').DriveLetter

& $SieteZip x -y "-o${peboot}:\" (Join-Path $Usb 'win10PE_th2_x64.iso') | Out-Null
foreach ($x in 'Boot','EFI','images','scripts','Sources','bootmgr','bootmgr.efi') {
  if (Test-Path (Join-Path $Usb $x)) { Copy-Item (Join-Path $Usb $x) "${winpe}:\" -Recurse -Force }
}
Write-Host "Listo: ${winpe}: = WINPE (partición 1), ${peboot}: = PEBOOT (partición 2)." -ForegroundColor Green
Write-Host 'En la tablet: F7 al encender y elegir la entrada "... Partition 2" de la tarjeta.'
Write-Host 'WinPE ejecuta Scripts\main.cmd, detecta Android ya instalado y aplica Windows al lado (dual boot).'
