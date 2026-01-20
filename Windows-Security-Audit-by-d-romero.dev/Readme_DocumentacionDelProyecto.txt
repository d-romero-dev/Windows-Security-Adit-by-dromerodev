🔒 Windows Security Audit Script by d-romero.dev

Herramienta automatizada de auditoría de seguridad para endpoints Windows que verifica configuraciones críticas y genera reportes detallados con recomendaciones de remediación.

📋 Descripción:

Windows Security Audit Script es una solución práctica desarrollada en PowerShell para realizar auditorías de seguridad en sistemas Windows de forma automatizada. El script ejecuta 15 verificaciones de configuración basadas en mejores prácticas de seguridad, identifica vulnerabilidades y genera reportes en formato texto con clasificación de hallazgos y acciones recomendadas priorizadas.

✨ Características Principales:

✅ 15 verificaciones de seguridad automatizadas.
🎯 Sistema de clasificación (PASS / WARNING / FAIL).
📊 Reportes detallados en formato TXT.
⚡ Ejecución rápida (menos de 1 minuto).
🔍 Priorización de hallazgos (CRÍTICO / IMPORTANTE).
💡 Recomendaciones específicas de remediación.
📁 Sin dependencias externas - solo PowerShell nativo.
🖥️ Compatible con Windows 10 y Windows 11.


🛡️ Verificaciones de Seguridad:

El script audita las siguientes configuraciones:

1. #VerificaciónDescripción1Windows DefenderEstado de protección en tiempo real.
2. Windows FirewallConfiguración en perfiles de red.
3. ActualizacionesUpdates pendientes de instalación.
4. UACControl de Cuentas de Usuario.
5. Cuenta AdministratorEstado de cuenta de administrador local.
6. Cuenta GuestEstado de cuenta de invitado.
7. Política de ContraseñasLongitud mínima de contraseñas.
8. BitLockerEstado de cifrado de disco.
9. Servicios InnecesariosTelnet y FTP.
10. Espacio en DiscoDisponibilidad en disco C:
11. Usuarios AdministradoresCantidad de usuarios con privilegios.
12. Escritorio RemotoEstado de RDP.
13. Protección RansomwareControlled Folder Access.
14. SMBv1Protocolo inseguro (vulnerabilidad WannaCry).
15. Bloqueo de PantallaTimeout de bloqueo automático.

🚀 Instalación

-Requisitos Previos

Sistema Operativo: Windows 10 o Windows 11
PowerShell: Versión 5.1 o superior (incluido por defecto)
Privilegios: Ejecutar como Administrador

Pasos de Instalación:

- Descarga directamente el archivo SecurityAudit.ps1

No requiere instalación adicional - es un script standalone.


💻 Uso
Ejecución Básica:

Abrir PowerShell como Administrador:

Busca "PowerShell" en el menú Inicio.
Click derecho → "Ejecutar como administrador".


Navegar a la carpeta donde se guardó el script.
Click derecho en el archivo "SecurityAudit".
Copiar Como Ruta de Acceso.


Ejecutar el script:
Pegar el siguiente comando en la consola de Powershell (sustituir el contenido de -File por la ruta de acceso copiada anteriormente)

powershellpowershell.exe -ExecutionPolicy Bypass -File ".\SecurityAudit.ps1"


---> Ejemplo de Salida:

=================================================================
   WINDOWS SECURITY AUDIT - Reporte de Auditoría
=================================================================
Equipo: DESKTOP-USER
Fecha: 2026-01-20 14:30:15
Usuario: admin.user
Sistema: Windows 10 Pro - Build 19045

-----------------------------------------------------------------
                    RESUMEN EJECUTIVO
-----------------------------------------------------------------
Total de Verificaciones: 15
✅ PASS:    10 (67%)
⚠️ WARNING: 3 (20%)
❌ FAIL:    2 (13%)

Estado General: REQUIERE ATENCIÓN

=================================================================
                  HALLAZGOS DETALLADOS
=================================================================

[1] Windows Defender - Estado
    Estado: ❌ FAIL
    Detalle: Windows Defender está DESACTIVADO
    Recomendación: Activar Windows Defender inmediatamente

[2] Windows Firewall
    Estado: ✅ PASS
    Detalle: Firewall activo en todos los perfiles

[3] Actualizaciones de Windows
    Estado: ⚠️ WARNING
    Detalle: 8 actualizaciones pendientes
    Última actualización: 2026-01-10
    Recomendación: Instalar actualizaciones pendientes

...

=================================================================
                  ACCIONES RECOMENDADAS
=================================================================
[CRÍTICO - Atención Inmediata]
  1. Activar Windows Defender
  2. Habilitar BitLocker en disco del sistema

[IMPORTANTE - Próximas 48 horas]
  3. Instalar 8 actualizaciones pendientes
  4. Revisar necesidad de cuenta Administrator habilitada
  5. Aumentar longitud mínima de contraseña a 12 caracteres

=================================================================
Reporte guardado en: C:\SecurityAudit\audit_20260120_143015.txt
=================================================================

📂 Estructura del Proyecto
windows-security-audit/
├── README.md                    # Este archivo
├── SecurityAudit.ps1           # Script principal
├── LICENSE                     # Licencia MIT
├── ejemplos/
│   └── ejemplo_reporte.txt     # Ejemplo de reporte generado
└── docs/
    └── INSTALACION.md          # Guía de instalación detallada

🎯 Casos de Uso:

- IT Support: Auditorías rápidas de endpoints antes de entregar equipos.
- Compliance: Verificar cumplimiento de políticas de seguridad.
- Hardening: Identificar configuraciones inseguras en nuevos equipos.
- Troubleshooting: Diagnóstico de problemas de configuración de seguridad.
- Documentación: Generar reportes de estado de seguridad para auditorías.


🔧 Personalización:
El script puede ser fácilmente personalizado modificando las verificaciones según las necesidades específicas de tu organización:
powershell# Ejemplo: Cambiar umbral de actualizaciones pendientes
if ($pendingCount -le 5) {
    # Modificar el valor 5 según tu política
}

📊 Reportes:
Los reportes se guardan automáticamente en:
C:\SecurityAudit\audit_[FECHA]_[HORA].txt
Formato del nombre: audit_20260120_143015.txt

🤝 Contribuciones:
Las contribuciones son bienvenidas. Si deseas mejorar el proyecto:

*Fork el repositorio.
*Crea una rama para tu feature (git checkout -b feature/nueva-verificacion).
*Commit tus cambios (git commit -m 'Agregar verificación de X').
*Push a la rama (git push origin feature/nueva-verificacion).
*Abre un Pull Request.

📄 Licencia
Este proyecto está licenciado bajo la Licencia MIT - buscar en la web LICENSE MIT para más detalles.

👤 Autor
d-romero-dev

GitHub: https://github.com/d-romero-dev

LinkedIn: www.linkedin.com/in/damian-romero-dev

Email: d.romero.dev.contact@gmail.com


🙏 Agradecimientos

Inspirado en frameworks de seguridad como CIS Benchmarks y NIST.
Desarrollado como proyecto de portafolio técnico.
Agradecimientos a la comunidad de PowerShell, Windows y documentación técnica consultada para la realización de este proyecto.


⚠️ Disclaimer

|Este script se proporciona "tal cual" sin garantías de ningún tipo.
 |Úsalo bajo tu propio riesgo.
  |Siempre prueba en entornos de desarrollo antes de aplicar en producción.

📞 Soporte

Si encuentras algún bug o tienes sugerencias:

🐛 Reportar un bug en GitHub.
💡 Solicitar una feature.


⭐ Si este proyecto te resultó útil, considera darle una estrella en GitHub! Gracias por leer!