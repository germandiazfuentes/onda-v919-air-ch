# 7. Actualizar Windows 10 1511 → 22H2 y Windows Update

La imagen de fábrica es **Windows 10 1511 (compilación 10586, diciembre de 2015)**. Lleva sin soporte desde 2017
y trae el Edge antiguo (25). **Chrome actual no se instala en 1511**: el instalador falla con `1603` / `0xC0000139`
(*entry point not found*). **Firefox sí funciona.**

La última versión posible es **Windows 10 22H2**. Esta tablet no admite Windows 11. Las actualizaciones gratuitas de
Windows 10 terminaron en **octubre de 2025** (KB5066791, compilación 19045.6456).

## Antes de empezar

1. **Cargador conectado y batería por encima del 40 %.** Con el OTG puesto no carga, así que quítalo.
2. **Copia de los drivers**: [`copia-drivers.ps1`](../scripts/windows/copia-drivers.ps1), y guárdala fuera de la tablet.
3. **Espacio**: hacen falta unos 20 GB libres en C: (de 38 GB). `powercfg /h off` libera unos 4 GB de hibernación.

## Actualizar → [`actualizar-a-22H2.ps1`](../scripts/windows/actualizar-a-22H2.ps1)

Usa el **Asistente de actualización oficial** (`Windows10Upgrade.exe`, comprobando su firma) en modo
`/quietinstall /skipeula /auto upgrade`, lanzado **como tarea de SYSTEM**. Así funciona también desde una sesión remota.

Duración en esta tablet, como referencia:

| Fase | Tiempo | Dónde mirar |
|---|---|---|
| Descarga de la ESD `19045.2006 … es-es.esd` (3,8 GB) | ~40 min | `C:\Windows\Temp` |
| Preparación (SetupHost) | ~30 min | `C:\$GetCurrent`, `C:\$Windows.~BT` |
| Fin de la fase 1 | — | `setupact.log` dice `Rebooting system... prevented by command line override` → **reiniciar a mano** |
| Instalación tras reiniciar | ~60-90 min | Pantalla azul con porcentaje, varios reinicios |

El espacio libre bajó de 23,5 GB a unos 10 GB al terminar (por `Windows.old`).

## Después de la actualización: comprobar SIEMPRE

1. **WinRM** (si usas la [administración remota](08-administracion-remota.md)) vuelve a quedar **parado**. Ejecuta en la
   tablet, como administrador: `Enable-PSRemoting -Force -SkipNetworkProfileCheck`.
2. **El WiFi no ve ninguna red**: la actualización puso un `43430r0nvram.txt` **genérico**. Ejecuta
   [`restaurar-nvram-wifi.cmd`](../scripts/windows/restaurar-nvram-wifi.cmd) como administrador. Detalles en
   [problemas](09-problemas-y-soluciones.md#wifi-sin-redes). Mientras tanto, usa red por cable con el hub.
3. Además, **el WiFi aparece apagado** (*radio de software desactivada*): actívalo en el panel de red.
4. La actualización **deshace los ajustes de suspensión**. Si la mantienes en remoto: `powercfg /change standby-timeout-ac 0`.
5. La **activación se conserva**.

## Windows Update → [`windows-update.ps1`](../scripts/windows/windows-update.ps1)

La API de Windows Update **no funciona desde una sesión remota**, así que el script se registra como tarea de SYSTEM y
deja un registro en `C:\ProgramData\soporte-dl\wu.log`. Repítelo hasta que diga `Encontradas: 0`.

Primera pasada tras la 22H2 (8 actualizaciones, ~1,5 h instalando):
- KB5066791, acumulativa de 2025-10 (19045.2006 → **19045.6456**)
- .NET Framework 4.8.1 y la acumulativa de .NET 2025-10
- Plataforma e inteligencia de Defender
- Actualizaciones de la pila de servicio

Segunda pasada: 5 más (paquetes de idioma de .NET, Defender, preparación de licencias ESU).

> ⚠️ **Espacio**: durante la instalación de la acumulativa, C: llegó a tener **solo 2 GB libres**. Se resolvió con el
> **Liberador de espacio** (`cleanmgr /sagerun`), quitando **"Instalaciones anteriores de Windows" (`Windows.old`)**,
> los archivos temporales de instalación y los de Optimización de distribución. Quedaron **15,5 GB libres**.
> Ojo: `cleanmgr` lanzado como SYSTEM puede quedarse colgado al final esperando una ventana invisible. Si su CPU deja
> de subir y `Windows.old` ya no existe, ciérralo.

## Navegadores

- **Firefox**: `https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=es-ES`, instalación silenciosa con `/S`.
- **Chrome** (solo tras la 22H2): MSI empresarial
  `https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi`, con `msiexec /i … /qn`.
- **Edge**: la 22H2 trae Edge Chromium 92. Se actualiza con el MSI de `https://go.microsoft.com/fwlink/?LinkID=2093437`.

Los tres se actualizan solos después.

## Dual boot tras la actualización

La actualización a 22H2 **no afecta al dual boot**. Después de todo el proceso (22H2, actualizaciones acumulativas y
limpieza), Android sigue arrancando con normalidad.

Siguiente: [8. Administración remota](08-administracion-remota.md)
