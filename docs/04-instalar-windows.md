# 4. Instalar Windows 10 en dual boot y activarlo

Con Android ya instalado, Windows se aplica en las particiones que dejó reservadas.

## Preparar la tarjeta (en el PC)

1. Descomprime el paquete de 3 partes (contraseña `geekbuying.com`) y, dentro,
   `Windows10\V919 AIR CH DualOS_Windows System Files_V7_20160304.part1.rar` → carpeta `usb`.
2. Con 7-Zip instalado:
   ```powershell
   .\scripts\pc\preparar-sd-windows.ps1 -Disco 7 -Usb 'D:\firmware\extraido\Windows10\usb'
   ```
   Resultado:

   | Partición | Formato / etiqueta | Contenido |
   |---|---|---|
   | **1** | NTFS **`WINPE`** | `Boot`, `EFI`, `images` (Install.wim), `scripts` (main.cmd), `Sources`, `bootmgr` |
   | **2** | FAT32 **`PEBOOT`** (activa) | Contenido de `win10PE_th2_x64.iso` |

   > ⚠️ **El orden importa.** El WinPE 1511 solo ve la **primera** partición de un disco extraíble. Si `WINPE` no es
   > la partición 1, WinPE arranca pero el script `startnet` **no encuentra `main.cmd`**.
3. Copia también a la tarjeta, en una carpeta `extras`, `WIFI-BTx64` y `Replace NVrom file`, por si acaso.

## Instalar (en la tablet)

1. Tarjeta dentro, teclado por OTG, **F7** al encender.
2. En el menú aparecen dos entradas para la tarjeta: **"… Partition 1"** y **"… Partition 2"**. Elige **Partition 2**.
3. Arranca WinPE → `wpeinit` → `startnet` busca el volumen `WINPE` y ejecuta `Scripts\main.cmd`. Este detecta
   Android y aplica `Install.wim` en modo dual ("Applying image… x %"). Tarda un buen rato.
4. Puede salir **una pantalla azul (BSOD) puntual** en el primer arranque. Al reiniciar continúa bien.
5. Windows arranca. **WiFi y Bluetooth funcionan**, porque la imagen ya trae los drivers Broadcom y el nvram.

## Activar Windows con la clave de la BIOS

La tablet lleva una licencia **OA3** de Windows 10 Home grabada en la BIOS. Si Windows aparece como "no activado",
abre PowerShell **como administrador**:

```powershell
$k = (Get-CimInstance SoftwareLicensingService).OA3xOriginalProductKey
slmgr /ipk $k     # instala la clave
slmgr /ato        # activa por Internet
```

## Cambiar entre sistemas

- **F7** al encender, con teclado, y eliges el sistema.
- Desde Windows: **`WinToAnd.exe`** (de `AMI Systems Switch.rar`) reinicia en Android.

Siguiente: [5. Limpieza de Android](05-android-limpieza.md)
