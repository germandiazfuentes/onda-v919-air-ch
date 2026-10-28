# 9. Problemas encontrados y soluciones

<a id="wifi-sin-redes"></a>
## WiFi de Windows: el adaptador está "OK" pero no ve NINGUNA red

**Cuándo:** después de actualizar de 1511 a 22H2. También puede pasar si Windows Update reinstala el driver Broadcom.

**Síntomas:** "Broadcom 802.11n Wireless SDIO Adapter" aparece con estado OK y driver 1.496.0.0, y al activar el WiFi sale
"Se encontraron redes Wi-Fi", pero la lista está vacía. `netsh wlan show networks` dice `0 redes visibles`.

**Causa:** el driver lee la calibración de radio de `C:\Windows\System32\drivers\43430r0nvram.txt`. La actualización lo
sustituyó por una versión **genérica** de 934 bytes:

| Parámetro | Correcto para la V919 Air CH (1005 bytes) | Genérico (934 bytes) |
|---|---|---|
| `xtalfreq` | **26000** | 37400 |
| `ccode` | AG/2 | ALL |
| `pa2ga0` | -168,6009,-726 | -168,7161,-820 |
| `maxp2ga0` | 78 | 90 |
| `rssicorrnorm` | 15 | (no está) |

El AP6212 de esta tablet tiene un **cristal de 26 MHz**. Con `xtalfreq=37400` la radio queda mal sintonizada y no recibe
nada. La versión de `WIFI-BTx64\WIFI` (1003 bytes) también vale para recibir, pero lleva `ccode=CN`. La buena es la de
**`Replace NVrom file`**.

**Solución:** [`restaurar-nvram-wifi.cmd`](../scripts/windows/restaurar-nvram-wifi.cmd) con el archivo de
[`drivers/wifi`](../drivers/wifi) (MD5 `5e8ae8984e51032f378163a19e8db0fd`). Después, desactivar y activar el adaptador
o reiniciar. Como no hay WiFi, el acceso remoto se recuperó conectando la **red por cable con el hub UGREEN**.

## WiFi de Windows apagado tras actualizar

`netsh wlan show interfaces` → "Estado de radio: Hardware Activado, **Software Desactivado**". Se arregla activando el
botón Wi-Fi del panel de red y quitando el modo avión si está puesto.

## WinPE no encuentra `main.cmd`

Al instalar Windows, WinPE arranca (`wpeinit`) pero no encuentra el script. **Causa:** la partición NTFS `WINPE` no era la
primera de la tarjeta, y el WinPE 1511 solo ve la primera partición de los discos extraíbles. **Solución:** WINPE en la
partición 1 y PEBOOT (FAT32) en la 2, y arrancar "Partition 2" (ver [04](04-instalar-windows.md)).

## diskpart: "Se eliminó el objeto" al preparar la tarjeta

Windows monta automáticamente la partición a mitad del script y diskpart pierde la referencia. **Solución:** separar
crear, formatear y asignar letra en pasos distintos, con reintentos (lo hace `preparar-sd-windows.ps1`).

## Pantalla azul en el primer arranque de Windows

Pasó una vez, justo después de aplicar la imagen. Al reiniciar, la instalación siguió con normalidad.

## Windows sin activar

Instalar la clave OA3 de la BIOS con `slmgr /ipk` + `slmgr /ato` (ver [04](04-instalar-windows.md#activar-windows-con-la-clave-de-la-bios)).

## Chrome no se instala en Windows 1511

`msiexec` devuelve 1603, y en el registro aparece `DoInstall` con el código `-1073741511` (`0xC0000139`, *entry point not found*).
El Chrome actual usa funciones que no existen en 1511. **Solución:** actualizar a 22H2. Mientras tanto, Firefox sí funciona.

## La tablet no carga

- Con el adaptador **OTG conectado no carga**. Quítalo y conecta el cargador directamente.
- Con un **cable fino o un cargador débil** tampoco: usa uno de 2 A o más y un cable bueno. Comprobación desde Windows:
  `Get-CimInstance -Namespace root\wmi -ClassName BatteryStatus` (`PowerOnline`, `Charging`).
- Con la batería casi vacía, a veces **solo empieza a cargar apagada**.

## La ventana de `activar-remoto` se queda en negro

Es `net user` con una contraseña de más de 14 caracteres, que espera una respuesta S/N que no se ve. Escribe `S` + Intro.
La versión actual del script ya no usa `net user`.

## Poco espacio en C: durante Windows Update

Liberador de espacio → "Instalaciones anteriores de Windows" (borra `Windows.old`, unos 10 GB) + archivos temporales de
instalación + Optimización de distribución. Ver [07](07-windows-actualizar-22H2.md#windows-update--windows-updateps1).

## Android: exclamación en el icono del WiFi

La comprobación de conectividad apuntaba a `www.androidbak.net`:
`adb shell settings put global captive_portal_server clients3.google.com`.

## Android: el escritorio JUI se descoloca

Pasó al poner un widget y accesos directos en la misma página. Se resolvió restaurando la copia de `launcher.db` y
dejando los widgets en una página propia (ver [05](05-android-limpieza.md#52-carpetas-en-chino--traducir-carpetassh)).

## Android: MinCal (widget de calendario) se cierra

Usa `getLocales()` (API 24) y Android 5.1 es API 22. Usa **Simple Calendar Pro** de F-Droid.

## Android: personalDNSfilter no descarga las listas

Android 5.1 no valida los certificados actuales de GitHub. Desactiva las listas públicas y usa solo `additionalHosts.txt`.

## Ubuntu: el WiFi falla de forma intermitente

El AP6212 a veces no se inicializa en Linux (WL_REG_ON, `SDHB._PS0`). No se resolvió de forma fiable, y por eso se
volvió al sistema original. También se vio un error de GRUB, `/boot/acpi_override not found`: se quita esa línea editando
la entrada de GRUB y regenerándolo con `update-grub`.
