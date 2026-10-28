#!/bin/bash
# Traduce al español los nombres de carpeta del escritorio JUI (com.jui.launcher3), que vienen en chino.
# ATENCIÓN: los _id de traducir-carpetas.sql son los de una instalación limpia de la ROM V7 20160429.
# Compruébalos primero con:
#   adb shell "su 0 sqlite3 /data/data/com.jui.launcher3/databases/launcher.db 'select _id,title,itemType from favorites where itemType=2;'"
# (itemType=2 son carpetas) y ajusta el .sql si no coinciden.
# Lecciones aprendidas editando esta base de datos:
#  - Haz copia antes:  adb shell "su 0 cp /data/data/com.jui.launcher3/databases/launcher.db /sdcard/launcher.db.bak"
#  - Las páginas de iconos usan una cuadrícula de 5 columnas.
#  - No mezcles un widget y accesos directos en la misma página: el lanzador descoloca todo.
#  - La tablet no tiene sed/tr/tail: edita en el PC y sube con adb push.
set -eu
ADB=${ADB:-adb}
DB=/data/data/com.jui.launcher3/databases/launcher.db
cd "$(dirname "$0")"
$ADB shell "su 0 cp $DB /sdcard/launcher.db.bak"
$ADB shell am force-stop com.jui.launcher3
$ADB push traducir-carpetas.sql /sdcard/traducir-carpetas.sql
$ADB shell "su 0 sh -c 'sqlite3 $DB < /sdcard/traducir-carpetas.sql'"
$ADB shell rm /sdcard/traducir-carpetas.sql
$ADB shell am start -a android.intent.action.MAIN -c android.intent.category.HOME
