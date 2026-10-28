# Prepara una microSD/pendrive para INSTALAR ANDROID 5.1 (y la BIOS) en la Onda V919 Air CH.
# BORRA EL DISCO INDICADO. Ejecutar en el PC como administrador:
#   .\preparar-sd-android.ps1 -Disco 7 -Rom 'D:\firmware\android-20160429'
# -Disco : número de disco de la tarjeta (mírelo con Get-Disk; el script se niega si no es USB/extraíble)
# -Rom   : carpeta con el CONTENIDO descomprimido de "V919_AIR_CH_DualOS-Android_ROM(V7)_20160429.rar"
#          (debe contener startup.nsh e installer.efi)
param([Parameter(Mandatory)][int]$Disco, [Parameter(Mandatory)][string]$Rom)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path (Join-Path $Rom 'startup.nsh'))) { throw "No encuentro startup.nsh en $Rom" }
$d = Get-Disk -Number $Disco
if ($d.BusType -notin 'USB','SD' -or $d.IsBoot -or $d.IsSystem) { throw "El disco $Disco ($($d.FriendlyName), $($d.BusType)) no parece una tarjeta/pendrive" }
Write-Host "Se BORRARÁ el disco $Disco : $($d.FriendlyName) $([math]::Round($d.Size/1GB)) GB" -ForegroundColor Yellow
if ((Read-Host 'Escribe BORRAR para continuar') -ne 'BORRAR') { exit }

$f = Join-Path $env:TEMP 'dp-android.txt'
@"
select disk $Disco
clean
convert mbr
create partition primary size=8000
format quick fs=fat32 label=ANDROID
active
assign
exit
"@ | Set-Content $f -Encoding ASCII
diskpart /s $f | Out-Null
Start-Sleep 5
$letra = (Get-Partition -DiskNumber $Disco | Get-Volume | Where-Object FileSystemLabel -eq 'ANDROID').DriveLetter
Copy-Item (Join-Path $Rom '*') "${letra}:\" -Recurse -Force
Write-Host "Listo en ${letra}: . En la tablet: insertar, encender pulsando F7 (teclado USB por OTG) y elegir la tarjeta (UEFI)." -ForegroundColor Green
Write-Host "El shell EFI ejecuta startup.nsh -> installer.efi, que reparticiona la eMMC, actualiza BIOS e instala Android."
