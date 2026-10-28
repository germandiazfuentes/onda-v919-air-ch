# 1. Situación inicial y diagnóstico

## Cómo estaba la tablet

- **Onda V919 Air CH, 64 GB**, hardware **V7**: placa IP3Y05, BIOS 1.14, Intel Atom x5-Z8300 (Cherry Trail), 4 GB de RAM.
- De fábrica traía arranque dual Android 5.1 + Windows 10, pero **el sistema original se había borrado**.
  Tenía instalado **Ubuntu**, que arrancaba pero **sin WiFi**.
- La tablet **solo tiene un micro-USB**. El teclado, el ratón, el pendrive o la red por cable van por un adaptador
  **OTG**, y mientras está conectado **la tablet no carga**.

## Diagnóstico (desde Ubuntu)

Con [`scripts/ubuntu/diag-wifi.sh`](../scripts/ubuntu/diag-wifi.sh) se identificó el hardware real:

| Componente | Detalle |
|---|---|
| WiFi | **AMPAK AP6212** = Broadcom **BCM43430 A0** por SDIO (`SD\VID_02D0&PID_A9A6`) |
| Bluetooth | El mismo módulo, por UART, con ID ACPI **BCM2E9B** |
| Cristal del módulo | **26 MHz** (dato clave, ver [problemas](09-problemas-y-soluciones.md#wifi-sin-redes)) |

Muchas guías hablan de Realtek RTL8723BS porque otras revisiones de la V919 lo llevan. **Esta no.**

En Linux, el WiFi del AP6212 resultó **intermitente**: la señal de encendido del módulo (WL_REG_ON, pin GPO2 16,
`SDHB._PS0` / `BRCM._PS0` en ACPI) a veces no lo inicializa. Por eso se descartó Ubuntu y se volvió al sistema
original, que trae sus drivers.

## Objetivo

1. Reinstalar el **dual boot original** (Android 5.1 + Windows 10) con el firmware oficial **V7**.
2. **WiFi y Bluetooth** funcionando en los dos sistemas.
3. Windows **activado** con la licencia de la BIOS (OA3), sin licencia aparte.
4. Quitar las apps chinas y la telemetría, y actualizar Windows y los navegadores.

Siguiente: [2. Material y firmware](02-material-y-firmware.md)
