# Conecta desde el PC a la tablet (después de ejecutar activar-remoto.cmd en ella).
#   .\conectar-tablet.ps1 -Ip 192.168.1.142            -> abre una consola remota en la tablet
#   .\conectar-tablet.ps1 -Ip 192.168.1.142 -Script x.ps1  -> ejecuta un script local en la tablet
# La primera vez pide la contraseña de "soporte" y la guarda cifrada (DPAPI: solo tu usuario
# de Windows en este PC puede leerla) en soporte-cred.xml junto a este script. NO subas ese archivo.
# Consejo: reserva la IP de la tablet en el router (DHCP estático) para que no cambie.
param([Parameter(Mandatory)][string]$Ip, [string]$Script)
$cred = Join-Path $PSScriptRoot 'soporte-cred.xml'

$th = (Get-Item WSMan:\localhost\Client\TrustedHosts -ErrorAction SilentlyContinue).Value
if ((Get-Service WinRM).Status -ne 'Running' -or ($th -split ',') -notcontains $Ip) {
  Write-Host "Autorizando $Ip en este PC (aparecerá un aviso de UAC)..."
  $nuevo = (@($th -split ',' | Where-Object { $_ }) + $Ip | Select-Object -Unique) -join ','
  Start-Process powershell -Verb RunAs -Wait -ArgumentList '-NoProfile','-Command',
    "Start-Service WinRM; Set-Item WSMan:\localhost\Client\TrustedHosts -Value '$nuevo' -Force"
}
if (Test-Path $cred) { $c = Import-Clixml $cred }
else { $c = Get-Credential -UserName "$Ip\soporte" -Message 'Contraseña de la cuenta soporte de la tablet'; $c | Export-Clixml $cred }
# El usuario se guarda como "<ip>\soporte"; si la IP cambió, se reutiliza la contraseña
if ($c.UserName -ne "$Ip\soporte") { $c = New-Object pscredential("$Ip\soporte", $c.Password) }

if ($Script) { Invoke-Command -ComputerName $Ip -Credential $c -FilePath $Script }
else { Enter-PSSession -ComputerName $Ip -Credential $c }
