# Onda V919 Air CH: puesta a punto (dual boot Android 5.1 + Windows 10)

Guía y scripts para **reinstalar el arranque dual original** (Android 5.1 + Windows 10) en una tablet
**Onda V919 Air CH** con el **WiFi y el Bluetooth funcionando**. También explica cómo actualizar Windows
a la **22H2**, quitar las aplicaciones chinas y la telemetría, y mantener la tablet desde un PC por la red.

> *English summary:* step-by-step guide and scripts to restore the factory Android 5.1 + Windows 10 dual boot
> on the Onda V919 Air CH (Cherry Trail Z8300, AP6212 WiFi/BT), upgrade Windows 10 1511 → 22H2, fix the
> "WiFi sees no networks" problem caused by a generic `43430r0nvram.txt` (wrong 37.4 MHz crystal; this
> tablet needs `xtalfreq=26000`, file in [`drivers/wifi`](drivers/wifi)), debloat Android and block Chinese telemetry.

## Estado final conseguido

| | Android | Windows |
|---|---|---|
| Sistema | 5.1 (ROM V7 20160429), en español | **Windows 10 Home 22H2, compilación 19045.6456** (oct. 2025), activado con la clave de la BIOS |
| WiFi / Bluetooth | OK | OK |
| Apps chinas | 17 desinstaladas, 2 desactivadas | Tienda china "爱应用 (xapcn)" eliminada |
| Telemetría | Dominios chinos bloqueados (personalDNSfilter) | Ninguna hacia China (auditado); telemetría de Microsoft al mínimo |
| Navegadores | Chrome de la ROM | Firefox, Chrome y Edge actuales |

## Índice

1. [Situación inicial y diagnóstico](docs/01-situacion-inicial.md)
2. [Material necesario y firmware](docs/02-material-y-firmware.md)
3. [Instalar Android 5.1 (y BIOS)](docs/03-instalar-android.md)
4. [Instalar Windows 10 en dual boot y activarlo](docs/04-instalar-windows.md)
5. [Limpiar Android: apps chinas, carpetas, telemetría](docs/05-android-limpieza.md)
6. [Windows: auditoría de telemetría, app china y privacidad](docs/06-windows-privacidad.md)
7. [Actualizar Windows 1511 → 22H2 y Windows Update](docs/07-windows-actualizar-22H2.md)
8. [Administración remota desde el PC (WinRM)](docs/08-administracion-remota.md)
9. **[Problemas encontrados y soluciones](docs/09-problemas-y-soluciones.md)** ← empieza aquí si algo falla

## Lo más importante en 5 puntos

1. **Es Cherry Trail (Atom x5-Z8300), no Bay Trail.** Usa el firmware **V7**; el número de serie de las
   unidades V7 contiene `V7` (por ejemplo `P919CCG7V7A…`). El módulo WiFi/BT es un **AMPAK AP6212**
   (Broadcom BCM43430 por SDIO + BT por UART), no Realtek.
2. **No hace falta el modo DnX.** Basta con un teclado USB por OTG y **F7** al encender para abrir el menú
   de arranque y arrancar desde la microSD.
3. **Para Windows, la partición NTFS "WINPE" debe ser la PRIMERA de la tarjeta.** El WinPE de Onda solo ve la
   primera partición de un disco extraíble.
4. **Si el WiFi de Windows no ve ninguna red** (por ejemplo, tras actualizar), el problema es el archivo
   `C:\Windows\System32\drivers\43430r0nvram.txt`. Hay que poner el de [`drivers/wifi`](drivers/wifi)
   (1005 bytes, `xtalfreq=26000`) con [`restaurar-nvram-wifi.cmd`](scripts/windows/restaurar-nvram-wifi.cmd).
5. **En Android no toques `/system`.** Tiene dm-verity y la tablet podría no arrancar. Todo se hace por ADB
   en `/data`, que es reversible.

## Estructura del repositorio

```
docs/                      Documentación paso a paso
drivers/wifi/              43430r0nvram.txt correcto para esta tablet (del paquete oficial "Replace NVrom file")
scripts/pc/                Para ejecutar en el PC: preparar tarjetas SD, conectar a la tablet en remoto
scripts/windows/           Para ejecutar en el Windows de la tablet (auditoría, telemetría, WiFi, actualizaciones, remoto)
scripts/android/           Por ADB desde el PC: limpieza de apps, carpetas, bloqueo de telemetría
scripts/ubuntu/            Diagnóstico de WiFi/BT desde un Linux live (opcional)
```

## Aviso

El firmware y los drivers son propiedad de Onda/Microsoft/Broadcom y **no se incluyen** aquí (salvo el pequeño
archivo de calibración del WiFi). En [docs/02](docs/02-material-y-firmware.md) explico de dónde se descargan.
Estos pasos borran la memoria interna de la tablet. Úsalos bajo tu responsabilidad.
