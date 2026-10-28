# 3. Instalar Android 5.1 (y la BIOS)

Android se instala **primero**: su instalador reparticiona toda la eMMC, actualiza la BIOS y deja reservado
el espacio para Windows.

## Pasos

1. Carga la tablet antes de empezar. Con el OTG conectado no carga.
2. En el PC, descomprime `V919_AIR_CH_DualOS-Android_ROM(V7)_20160429.rar` en una carpeta.
3. Prepara la tarjeta. Usa `Get-Disk` para ver qué número de disco es, porque **la tarjeta se borra entera**:
   ```powershell
   .\scripts\pc\preparar-sd-android.ps1 -Disco 7 -Rom 'D:\firmware\android-20160429'
   ```
   Crea una partición FAT32 de 8 GB llamada `ANDROID` con el contenido de la ROM (`startup.nsh`, `installer.efi`…).
4. Mete la tarjeta en la tablet y conecta el teclado por OTG.
5. Enciende la tablet pulsando **F7** repetidamente → aparece el **menú de arranque** → elige la tarjeta (UEFI).
6. Arranca el **shell EFI**, que ejecuta `startup.nsh` → `installer.efi`. Este instala la tabla de particiones,
   la BIOS y Android. No toques nada hasta que termine.
   - Si se queda en `Shell>` sin hacer nada, escribe `fs0:` + Intro, luego `startup.nsh` + Intro
     (si falla, prueba con `fs1:`).
7. Al terminar, quita la tarjeta y reinicia. Android arranca. **WiFi y BT funcionan** sin hacer nada más.

**No hace falta el modo DnX** (Volumen + y otras combinaciones). Lo intenté sin éxito y no fue necesario.

## Después de instalar

- El icono del WiFi muestra una **exclamación** aunque haya Internet. La comprobación de conectividad apunta a un
  servidor chino (`www.androidbak.net`). Se corrige con [`limpiar-android.sh`](../scripts/android/limpiar-android.sh)
  (ver [5. Limpieza de Android](05-android-limpieza.md)).

Siguiente: [4. Instalar Windows](04-instalar-windows.md)
