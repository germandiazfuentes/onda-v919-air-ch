# 43430r0nvram.txt para la Onda V919 Air CH

Es la calibración de radio del módulo **AMPAK AP6212 (Broadcom BCM43430 A0)**. Viene del paquete oficial
de Onda/Geekbuying, en `Replace NVrom file.rar` → `WIFI\43430r0nvram.txt`.

- Tamaño: 1005 bytes · MD5 `5e8ae8984e51032f378163a19e8db0fd`
- Valores clave: `xtalfreq=26000`, `ccode=AG/2`

Va en `C:\Windows\System32\drivers\43430r0nvram.txt`. Úsalo con
[`scripts/windows/restaurar-nvram-wifi.cmd`](../../scripts/windows/restaurar-nvram-wifi.cmd) si el WiFi
de Windows no ve redes. El motivo está en [docs/09](../../docs/09-problemas-y-soluciones.md#wifi-sin-redes).
