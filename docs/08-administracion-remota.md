# 8. Administración remota desde el PC (WinRM)

Para no tener que mover la microSD o el pendrive en cada prueba, se activó **PowerShell Remoting (WinRM)** en la tablet.
Desde el PC se pueden lanzar actualizaciones, instalar programas o leer registros por la red local.

## En la tablet (una vez) → [`activar-remoto.cmd`](../scripts/windows/activar-remoto.cmd)

Clic derecho → **Ejecutar como administrador**. El script:
- Pide una contraseña y crea la cuenta de administrador **`soporte`**, **oculta** en la pantalla de inicio.
- Pone la red como **Privada**, ejecuta `Enable-PSRemoting`, desactiva la autenticación Basic y permite el
  **cortafuegos solo desde la subred local**.
- Activa `LocalAccountTokenFilterPolicy=1`, necesario para que una cuenta local sea administradora en remoto.
- Desactiva la suspensión con el cargador puesto.
- Muestra la **IP** de la tablet.

> Nota: la primera versión creaba la cuenta con `net user`. Con contraseñas de **más de 14 caracteres**, `net user`
> pregunta *"¿Desea continuar? (S/N)"*. Como la salida estaba oculta, **la ventana se quedaba en negro**. La versión
> actual usa ADSI y no pregunta nada.

## En el PC → [`conectar-tablet.ps1`](../scripts/pc/conectar-tablet.ps1)

```powershell
.\scripts\pc\conectar-tablet.ps1 -Ip 192.168.1.142                       # consola remota
.\scripts\pc\conectar-tablet.ps1 -Ip 192.168.1.142 -Script .\scripts\windows\windows-update.ps1
```
- La primera vez añade la IP a **TrustedHosts** del cliente WinRM (aviso de UAC) y arranca el servicio WinRM del PC.
  Es necesario porque el PC y la tablet no están en un dominio.
- Guarda la contraseña **cifrada con DPAPI** (`soporte-cred.xml`): solo tu usuario de Windows en ese PC puede leerla.
  **No la subas a ningún sitio.**
- **Reserva la IP** de la tablet en el router (DHCP estático por MAC) para que no cambie. Con el hub Ethernet tendrá **otra IP**.

## Limitaciones encontradas

| Qué | Solución |
|---|---|
| La API de Windows Update falla en sesión remota | Ejecutar como **tarea programada de SYSTEM** (lo hacen los scripts) |
| `Restart-Computer -ComputerName` falla con "El servidor RPC no está disponible" (usa DCOM) | `Invoke-Command { Restart-Computer -Force }` |
| `shutdown /r` desde la sesión remota a veces no se aplica | Comprobar la hora de arranque (`LastBootUpTime`) y repetir con `Restart-Computer -Force` |
| La tablet se suspende y desaparece de la red | `powercfg /change standby-timeout-ac 0` y tenerla al cargador |
| Tras la actualización a 22H2, WinRM queda parado | `Enable-PSRemoting -Force -SkipNetworkProfileCheck` en la tablet |
| Con el WiFi roto no hay conexión | Hub con Ethernet (AX88179): Windows lo reconoce solo |

## Desactivar → [`desactivar-remoto.cmd`](../scripts/windows/desactivar-remoto.cmd)

Borra la cuenta `soporte`, quita `LocalAccountTokenFilterPolicy`, desactiva PSRemoting y las reglas del cortafuegos, para
WinRM y restaura la suspensión. En el PC: `Set-Item WSMan:\localhost\Client\TrustedHosts -Value '' -Force`.

Siguiente: [9. Problemas y soluciones](09-problemas-y-soluciones.md)
