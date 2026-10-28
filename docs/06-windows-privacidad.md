# 6. Windows: auditoría de telemetría, app china y privacidad

## 6.1 Auditoría → [`auditoria-windows.cmd`](../scripts/windows/auditoria-windows.cmd)

Solo **lee** el sistema y genera la carpeta `informe-windows-<fecha>`:
- Programas, apps de la Tienda, servicios con su firma digital, tareas programadas e inicio.
- Drivers, procesos, `hosts`, proxy y caché DNS.
- **3 minutos vigilando las conexiones TCP** de cada proceso.

**Resultado en esta tablet: no hay telemetría hacia China.** Todas las conexiones iban a Microsoft, Google, Akamai u otras CDN.
- `ocsp.digicert.cn` aparece por una comprobación de certificado de Edge. Es un nodo de Alibaba Cloud **situado en España**
  y no es preocupante.
- El **único** elemento chino: la app de Tienda preinstalada **`3802www.xapcn.com.Win10-`** v5.4.0.0,
  "**爱应用Win10-昂达版**" ("iApp – edición Onda"), una tienda de apps china de 北京新锋艾普网络科技有限公司, con permisos
  `internetClient` e `internetClientServer`. No se le vio ninguna conexión, pero no sirve para nada.

## 6.2 Quitar la tienda china → [`quitar-app-xapcn.cmd`](../scripts/windows/quitar-app-xapcn.cmd)

Muestra la ficha de la app y la desinstala si escribes `S`, también para usuarios nuevos (`Remove-AppxProvisionedPackage`).

## 6.3 Reducir la telemetría de Microsoft → [`reducir-telemetria-microsoft.ps1`](../scripts/windows/reducir-telemetria-microsoft.ps1)

Válido para **Windows 10 Home**. No rompe Windows Update, la Tienda ni Defender. Se deshace con `-Deshacer`.
- Datos de diagnóstico al mínimo que permite Home (`AllowTelemetry=1`, "obligatorios"), sin nombre de equipo y sin
  peticiones de comentarios.
- Desactiva el identificador de publicidad, las experiencias personalizadas, las apps sugeridas o instaladas solas y el
  historial de actividad.
- Desactiva los servicios **DiagTrack** y **dmwappushservice**, y las tareas de Compatibility Appraiser, CEIP y Feedback.

> Nota técnica: en el registro, `New-Item -Force` sobre una clave que **ya existe** la vuelve a crear **vacía**.
> El script solo crea la clave si falta, para no borrar otros valores.

Siguiente: [7. Actualizar a 22H2](07-windows-actualizar-22H2.md)
