# Deshace activar-remoto.ps1: borra la cuenta "soporte" y desactiva la administracion remota.
$ErrorActionPreference = 'Continue'
Start-Transcript -Path (Join-Path $PSScriptRoot 'desactivar-remoto.log') -Force | Out-Null
net user soporte /delete
Remove-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList' -Name soporte -ErrorAction SilentlyContinue
Remove-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name LocalAccountTokenFilterPolicy -ErrorAction SilentlyContinue
Disable-PSRemoting -Force
Get-NetFirewallRule -Name 'WINRM-HTTP-In-TCP*' | Disable-NetFirewallRule
Stop-Service WinRM
Set-Service WinRM -StartupType Manual
powercfg /change standby-timeout-ac 30
Write-Host "Administracion remota desactivada y cuenta 'soporte' eliminada." -ForegroundColor Green
Stop-Transcript | Out-Null
Read-Host 'Intro para cerrar' | Out-Null
