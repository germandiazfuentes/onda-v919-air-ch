#!/bin/bash
# Bloquea la telemetría china de las apps preinstaladas (lanzador JUI, etc.) con personalDNSfilter:
# un filtro DNS que funciona como "VPN" local, sin root y sin tocar /system.
# 1) Descarga personalDNSfilter (dnsfilter.android) del archivo de F-Droid y ponlo junto a este script
#    como dnsfilter.apk. Ábrelo una vez en la tablet, acepta el aviso de VPN y activa "Autostart".
# 2) Ejecuta este script: sube la lista de dominios bloqueados.
# Nota: en Android 5.1 las listas públicas (GitHub) fallan por certificados antiguos; desactívalas en la
# app (Configuración avanzada -> Filtros) y usa solo esta lista propia.
set -eu
ADB=${ADB:-adb}
cd "$(dirname "$0")"
[ -f dnsfilter.apk ] && $ADB install -r dnsfilter.apk
F=/sdcard/Android/data/dnsfilter.android/files/PersonalDNSFilter/additionalHosts.txt
$ADB shell "su 0 cat $F" | tr -d '\r' > /tmp/additionalHosts.actual.txt
grep -q 'Telemetria china' /tmp/additionalHosts.actual.txt || cat additionalHosts-bloqueo-china.txt >> /tmp/additionalHosts.actual.txt
$ADB push /tmp/additionalHosts.actual.txt "$F"
echo "Lista subida. En la app: parar y arrancar el filtro para recargarla."
