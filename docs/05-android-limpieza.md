# 5. Limpiar Android: apps chinas, carpetas y telemetría

Todo por **ADB** desde el PC: [platform-tools de Google](https://developer.android.com/tools/releases/platform-tools).
En la tablet: Ajustes → Información → pulsar 7 veces en "Número de compilación" → Opciones de desarrollador →
**Depuración USB**. La ROM es *userdebug* y hay root con `su 0` desde `adb shell`.

> ⚠️ **Nunca modifiques `/system`** (por ejemplo, el archivo `hosts`). Está protegido con **dm-verity** y la tablet
> podría no arrancar. Todo lo de abajo trabaja en `/data` y se puede deshacer.

En Git Bash para Windows, ejecuta antes `export MSYS_NO_PATHCONV=1`. Si no, las rutas `/data/...` se convierten mal.

## 5.1 Apps chinas → [`limpiar-android.sh`](../scripts/android/limpiar-android.sh)

Desinstaladas para el usuario 0 (`pm uninstall --user 0`; se recuperan con `pm install-existing <paquete>`):

| Paquete | App |
|---|---|
| com.UCMobile.x86 | Navegador UC |
| com.qiyi.video.pad | iQIYI (vídeo) |
| cn.kuwo.player | Kuwo (música) |
| com.sankuai.meituan | Meituan |
| com.vip.hd | Vipshop |
| com.readingjoy.read.hd | Lector de libros |
| cn.keyshare.learningcenter, com.yibai.android.student | Apps educativas |
| cn.wps.moffice | WPS Office (versión china) |
| com.cleanmaster.mguard_cn | Clean Master CN |
| com.cs.appstore, com.pada.gamecenter, com.pada.padasf, umido.ugamestore | Tiendas y centros de juegos chinos |
| com.amazon.windowshop | Amazon China |
| com.google.android.inputmethod.pinyin, jp.co.omronsoft.openwnn | Teclados chino y japonés |

El mismo script:
- **Desactiva** (`pm disable`) el explorador de archivos JUI (`com.jianui.filemanager`) y la grabadora
  (`com.myrecorder.voicerecorderpro.pro`), que llevan SDKs de telemetría. Se sustituyeron por **Simple File Manager Pro**
  y **Simple Voice Recorder**, descargados del archivo de F-Droid.
- Cambia `captive_portal_server` de `www.androidbak.net` a `clients3.google.com`, lo que **quita la exclamación del WiFi**.
- Pone el teclado LatinIME por defecto.

Los widgets "Game Center" y "Top Apps" se quitaron del escritorio. Para el calendario con la **semana empezando en lunes**:
Calendario → Ajustes → Primer día de la semana = lunes, y como widget **Simple Calendar Pro**, de F-Droid. MinCal falla en
Android 5.1 porque usa `getLocales()`, una API 24.

## 5.2 Carpetas en chino → [`traducir-carpetas.sh`](../scripts/android/traducir-carpetas.sh)

El escritorio es el **lanzador JUI** (`com.jui.launcher3`). Su base de datos está en
`/data/data/com.jui.launcher3/databases/launcher.db` y se edita con `su 0 sqlite3`. El SQL renombra las carpetas
como "Herramientas", "Juegos", "Internet", "Música y vídeo"… Comprueba antes los `_id` en tu tablet.

Organización final: **página 1** = buscador + widget de calendario; **página 2** (la principal, `default_screen=1`) = todos los iconos y carpetas.

Lecciones aprendidas:
- **Haz copia** de `launcher.db` antes de tocarla.
- Las páginas de iconos usan una cuadrícula de **5 columnas**.
- **No mezcles un widget con accesos directos en la misma página**: el lanzador lo descoloca todo.
  Me pasó y tuve que restaurar la copia.
- La tablet no tiene `sed`, `tr` ni `tail`: edita en el PC y súbelo.
- Para arrastres que no se pueden hacer desde la base de datos, se puede simular el dedo con `sendevent` en
  `/dev/input/event3` (pantalla goodix-ts, multitouch tipo A).

## 5.3 Telemetría china → [`bloquear-telemetria.sh`](../scripts/android/bloquear-telemetria.sh)

Analizando las apps preinstaladas, el **lanzador JUI**, su explorador y la grabadora contactaban con:
**Umeng** (analítica de Alibaba), **Getui/igexin** (notificaciones push), **Eaglenet** (JUI), Pada, UC/Shenma/Taobao,
atuyou y awbase.

Como no se puede tocar `/system/etc/hosts`, se instaló **personalDNSfilter** (`dnsfilter.android`, de F-Droid). Funciona
como una VPN local que filtra DNS, sin root, y se configuró con **arranque automático**. Lleva la lista propia
[`additionalHosts-bloqueo-china.txt`](../scripts/android/additionalHosts-bloqueo-china.txt).

- Desactiva las listas públicas de la app: **Android 5.1 no valida los certificados actuales de GitHub** y la descarga falla.
- Si un dominio parece no bloquearse, es la **caché DNS**. Reinicia el filtro o la tablet. Bloquea también el dominio base,
  no solo `*.dominio`.

Siguiente: [6. Privacidad en Windows](06-windows-privacidad.md)
