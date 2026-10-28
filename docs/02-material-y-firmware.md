# 2. Material necesario y firmware

## Hardware

| Qué | Para qué | Notas |
|---|---|---|
| **Adaptador OTG micro-USB macho → USB-A hembra** | Conectar cosas a la tablet | El primero que probé era defectuoso: si no se enciende nada, cambia de adaptador. |
| **Hub USB con Ethernet**, por ejemplo **UGREEN 60554** (chips GL3510 + ASIX AX88179) | Teclado + red por cable a la vez | Windows 10 trae driver para el AX88179. Imprescindible si se rompe el WiFi. |
| **Teclado USB** | Pulsar **F7** (menú de arranque) y escribir en WinPE | |
| **microSD de al menos 16 GB** y un lector en el PC | Llevar los instaladores | Se usó una de 128 GB. Se **borra** entera. |
| Cargador de **2 A** o más y un buen cable | Cargar | Con cables finos o cargadores débiles no carga. Por el puerto OTG no carga. |

## Firmware oficial (V7)

Lo publicó Geekbuying (distribuidor de Onda):
<https://www.geekbuying.com/geekgiz/2016/03/onda-v919-air-ch-dual-os-windows10-android-5-1-firmwares_202792/>

| Archivo | Contenido | Contraseña |
|---|---|---|
| `V919_AIR_CH_DUALOS(WIN10+Android5.1).part1/2/3.rar` (unos 8,6 GB) | Android 5.1 (20160216), Windows 10 1511 (Install.wim + WinPE), drivers, **`WIFI-BTx64.rar`**, **`Replace NVrom file.rar`**, **`AMI Systems Switch.rar`** (WinToAnd.exe) | `geekbuying.com` |
| `V919_AIR_CH_DualOS-Android_ROM(V7)_20160429.rar` (690 MB) | Android **más reciente** (20160429), que **incluye una BIOS nueva** (`afu.bin`). Es la que conviene usar. | — |

Los enlaces de descarga son de MediaFire. Si alguno ha caducado, busca los nombres exactos de los archivos.

### Qué hay dentro que importa

- `Windows10\V919 AIR CH DualOS_Windows System Files_V7_20160304.part*.rar` → carpeta **`usb`**, con `Boot`,
  `EFI`, `images\Install.wim` (6,9 GB, Windows 10 Home 1511 multilenguaje con **es-ES** y en-US), `scripts`,
  `Sources`, `bootmgr` y **`win10PE_th2_x64.iso`**.
- `WIFI-BTx64.rar`: drivers Broadcom de WiFi (`bcmwdidhdsdio`) y BT (`bcmfn2`, `btwserialbus`) más `install.cmd`,
  que los instala con `pnputil` y copia `WIFI\43430r0nvram.txt` a `System32\drivers`.
- `Replace NVrom file.rar`: **el `43430r0nvram.txt` correcto** para esta tablet (`xtalfreq=26000`, `ccode=AG/2`).
  Es el que hay en [`drivers/wifi`](../drivers/wifi).
- `AMI Systems Switch.rar` → **`WinToAnd.exe`**, para cambiar de Windows a Android sin teclado.

Siguiente: [3. Instalar Android](03-instalar-android.md)
