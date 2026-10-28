#!/bin/bash
# Limpieza de la ROM Android 5.1 de Onda (V919 Air CH, V7 20160429) desde un PC con ADB.
# Requisitos: Opciones de desarrollador -> Depuración USB activada, tablet conectada por USB, "adb devices" la ve.
# En Git Bash para Windows ejecutar antes:  export MSYS_NO_PATHCONV=1
# La ROM es userdebug: hay root con "su 0" desde adb shell.
# IMPORTANTE: /system está protegido con dm-verity. NO modificar /system (ni el archivo hosts):
# la tablet podría no volver a arrancar. Todo lo de aquí se hace en /data y es reversible.
set -u
ADB=${ADB:-adb}

echo "== Teclado: pasar a LatinIME (el pinyin chino se desinstala) =="
$ADB shell ime set com.android.inputmethod.latin/.LatinIME

echo "== Desinstalar apps chinas para el usuario 0 (reversible con: pm install-existing <paquete>) =="
for p in \
  com.UCMobile.x86 com.qiyi.video.pad cn.kuwo.player com.sankuai.meituan com.vip.hd \
  com.readingjoy.read.hd cn.keyshare.learningcenter com.yibai.android.student cn.wps.moffice \
  com.cleanmaster.mguard_cn com.cs.appstore com.pada.gamecenter com.pada.padasf umido.ugamestore \
  com.amazon.windowshop com.google.android.inputmethod.pinyin jp.co.omronsoft.openwnn; do
  printf '%s: ' "$p"; $ADB shell pm uninstall --user 0 "$p" | tr -d '\r'
done

echo "== Desactivar explorador y grabadora JUI (llevan SDK de telemetría Umeng/Getui/Eaglenet) =="
$ADB shell "su 0 pm disable com.jianui.filemanager" | tr -d '\r'
$ADB shell "su 0 pm disable com.myrecorder.voicerecorderpro.pro" | tr -d '\r'

echo "== Quitar la exclamación del WiFi: comprobación de conectividad contra Google, no un servidor chino =="
$ADB shell settings put global captive_portal_server clients3.google.com
$ADB shell settings get global captive_portal_server

echo "Hecho. Reinicia la tablet (adb reboot)."
