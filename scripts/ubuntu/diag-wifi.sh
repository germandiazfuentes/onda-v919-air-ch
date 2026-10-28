#!/bin/bash
# Diagnostico WiFi/Bluetooth para Onda V919 Air CH (Ubuntu)
# Uso: copiar a un pendrive, abrir terminal en esa carpeta y ejecutar:
#   sudo bash diag-wifi.sh
# Genera diag-wifi-<fecha>.txt en la misma carpeta que el script.

OUT="$(cd "$(dirname "$0")" && pwd)/diag-wifi-$(date +%Y%m%d-%H%M%S).txt"

sec() { echo; echo "===== $1 ====="; }
run() { sec "$*"; eval "$@" 2>&1; }

{
  run "cat /etc/os-release"
  run "uname -a"
  sec "DMI"
  for f in sys_vendor product_name product_version board_name board_vendor bios_version bios_date; do
    echo "$f: $(cat /sys/class/dmi/id/$f 2>/dev/null)"
  done

  sec "SDIO devices"
  for d in /sys/bus/sdio/devices/*; do
    [ -e "$d" ] || continue
    echo "$d vendor=$(cat $d/vendor) device=$(cat $d/device) modalias=$(cat $d/modalias) driver=$(basename "$(readlink $d/driver 2>/dev/null)")"
  done
  run "ls -l /sys/bus/mmc/devices/"
  for d in /sys/bus/mmc/devices/*; do echo "$d type=$(cat $d/type 2>/dev/null) name=$(cat $d/name 2>/dev/null)"; done

  sec "ACPI devices (WiFi/BT HIDs)"
  for d in /sys/bus/acpi/devices/*; do
    h=$(cat $d/hid 2>/dev/null); s=$(cat $d/status 2>/dev/null)
    case "$h" in OBDA*|BCM*|INT33*|80860F14|PNP*) ;; *) continue;; esac
    echo "$(basename $d) hid=$h status=$s path=$(cat $d/path 2>/dev/null)"
  done

  run "lsmod"
  run "modinfo r8723bs | head -20"
  run "modinfo brcmfmac | head -5"
  run "rfkill list"
  run "ip link"
  run "iw dev"
  run "nmcli general; nmcli device"
  run "lsusb"
  run "lspci -nn"
  run "ls -l /lib/firmware/rtlwifi/ | grep -i 8723"
  run "ls -l /lib/firmware/rtl_bt/ | grep -i 8723"
  run "ls -l /lib/firmware/brcm/ | grep -i -E '43430|43455|43341|4324|2e'"
  run "hciconfig -a; bluetoothctl list"
  run "dmesg | grep -i -E 'sdio|mmc|r8723|rtl|brcm|wlan|wifi|bluetooth|hci|firmware|80211|rfkill'"
  run "journalctl -b -k --no-pager | tail -400"
} > "$OUT" 2>&1

echo "Diagnostico guardado en: $OUT"
