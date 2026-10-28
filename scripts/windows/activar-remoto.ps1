# Activa la administración remota por la red local (PowerShell Remoting / WinRM) con una cuenta
# de administrador oculta "soporte". Pensado para mantener la tablet desde un PC de la misma red
# sin tener que ir con pendrives. Deshacer: desactivar-remoto.cmd
#
# SEGURIDAD: solo admite conexiones desde la subred local; usa autenticación NTLM (Basic desactivado).
# Elige una contraseña larga y guárdala en el PC (ver scripts/pc/conectar-tablet.ps1).
$ErrorActionPreference = 'Continue'
Start-Transcript -Path (Join-Path $PSScriptRoot 'activar-remoto.log') -Force | Out-Null
$user = 'soporte'

$s1 = Read-Host "Contraseña para la cuenta '$user' (mín. 15 caracteres)" -AsSecureString
$s2 = Read-Host 'Repítela' -AsSecureString
$p1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($s1))
$p2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($s2))
if ($p1 -ne $p2 -or $p1.Length -lt 15) { Write-Host 'No coinciden o es demasiado corta.' -ForegroundColor Red; Read-Host; exit 1 }

# Cuenta local por ADSI: funciona en 1511 y 22H2 y no pregunta nada aunque la contraseña supere
# 14 caracteres (net user sí pregunta "¿Desea continuar?" y deja la ventana esperando).
$pc = [ADSI]"WinNT://$env:COMPUTERNAME"
$u = $pc.Children | Where-Object { $_.SchemaClassName -eq 'User' -and $_.Name -eq $user }
if (-not $u) { $u = $pc.Create('User', $user) }
$u.SetPassword($p1)
$u.Put('Description', 'Administracion remota')
$u.Put('UserFlags', 0x10000)   # la contraseña no caduca
$u.SetInfo()
$adm = (New-Object Security.Principal.SecurityIdentifier 'S-1-5-32-544').Translate([Security.Principal.NTAccount]).Value.Split('\')[1]
try { ([ADSI]"WinNT://$env:COMPUTERNAME/$adm,group").Add("WinNT://$env:COMPUTERNAME/$user,user") } catch { }

# Ocultar la cuenta en la pantalla de inicio de sesión (sin vaciar la clave si ya existe)
$ul = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList'
if (-not (Test-Path $ul)) { New-Item $ul -Force | Out-Null }
Set-ItemProperty $ul -Name $user -Value 0 -Type DWord

Get-NetConnectionProfile | Where-Object { $_.NetworkCategory -ne 'DomainAuthenticated' } | Set-NetConnectionProfile -NetworkCategory Private
Enable-PSRemoting -Force -SkipNetworkProfileCheck
Set-Item WSMan:\localhost\Service\Auth\Basic -Value $false
Set-Service WinRM -StartupType Automatic
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name LocalAccountTokenFilterPolicy -Value 1 -Type DWord
Get-NetFirewallRule -Name 'WINRM-HTTP-In-TCP*' | Set-NetFirewallRule -RemoteAddress LocalSubnet -Enabled True -Profile Any
Restart-Service WinRM
powercfg /change standby-timeout-ac 0
powercfg /change hibernate-timeout-ac 0

Write-Host ''
Write-Host '=== LISTO ===' -ForegroundColor Green
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*' } | ForEach-Object { Write-Host "IP: $($_.IPAddress) ($($_.InterfaceAlias))" -ForegroundColor Yellow }
if (Test-WSMan -ErrorAction SilentlyContinue) { Write-Host 'WinRM funcionando' -ForegroundColor Green }
Stop-Transcript | Out-Null
Read-Host 'Intro para cerrar' | Out-Null
