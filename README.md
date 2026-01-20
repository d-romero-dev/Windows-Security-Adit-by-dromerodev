
# 🔒 Windows Security Audit Script by d-romero.dev

Herramienta automatizada de auditoría de seguridad para endpoints Windows que verifica configuraciones críticas y genera reportes detallados con recomendaciones de remediación.
Análisis, diagnostico y reporte final, mediante PowerShell.

📋 Descripción:

Windows Security Audit Script es una solución práctica desarrollada en PowerShell para realizar auditorías de seguridad en sistemas Windows de forma automatizada. El script ejecuta 15 verificaciones de configuración basadas en mejores prácticas de seguridad, identifica vulnerabilidades y genera reportes en formato texto con clasificación de hallazgos y acciones recomendadas priorizadas.

✨ Características Principales:

- ✅ 15 verificaciones de seguridad automatizadas.
- 🎯 Sistema de clasificación (PASS / WARNING / FAIL).
- 📊 Reportes detallados en formato TXT.
- ⚡ Ejecución rápida (menos de 1 minuto).
- 🔍 Priorización de hallazgos (CRÍTICO / IMPORTANTE).
- 💡 Recomendaciones específicas de remediación.
- 📁 Sin dependencias externas - solo PowerShell nativo.
- 🖥️ Compatible con Windows 10 y Windows 11.

<br>

🛡️ Verificaciones de Seguridad:

El script audita las siguientes configuraciones:

1. Verificación Windows Defender: Estado de protección en tiempo real.
2. Windows Firewall: Configuración en perfiles de red.
3. Actualizaciones: Updates pendientes de instalación.
4. UAC: Control de Cuentas de Usuario.
5. Cuenta Administrator: Estado de cuenta de administrador local.
6. Cuenta Guest: Estado de cuenta de invitado.
7. Política de Contraseñas: Longitud mínima de contraseñas.
8. BitLocker: Estado de cifrado de disco.
9. Servicios Innecesarios: Telnet y FTP.
10. Espacio en Disco: Disponibilidad en disco C:
11. Usuarios Administradores: Cantidad de usuarios con privilegios.
12. Escritorio Remoto: Estado de RDP.
13. Protección: RansomwareControlled Folder Access.
14. SMBv1: Protocolo inseguro (vulnerabilidad WannaCry).
15. Bloqueo de Pantalla: Timeout de bloqueo automático.

<br>
🎯 Casos de Uso:

- IT Support: Auditorías rápidas de endpoints antes de entregar equipos.
- Compliance: Verificar cumplimiento de políticas de seguridad.
- Hardening: Identificar configuraciones inseguras en nuevos equipos.
- Troubleshooting: Diagnóstico de problemas de configuración de seguridad.
- Documentación: Generar reportes de estado de seguridad para auditorías.
<br>
🚀 Instalación:

-Requisitos Previos

* Sistema Operativo: Windows 10 o Windows 11.

* PowerShell: Versión 5.1 o superior (incluido por defecto).

* Privilegios: Ejecutar como Administrador.

Pasos de Instalación:
- Descarga directamente el archivo SecurityAudit.ps1
No requiere instalación adicional - es un script standalone.
<br>

💻 Uso
Ejecución Básica:

1. Abrir PowerShell como Administrador:

2. Busca "PowerShell" en el menú Inicio.
3. Click derecho → "Ejecutar como administrador".

4. Navegar a la carpeta donde se guardó el script.
5. Click derecho en el archivo "SecurityAudit".
6. Copiar Como Ruta de Acceso.


7. Ejecutar el script:
Pegar el siguiente comando en la consola de Powershell (sustituir el contenido de -File por la ruta de acceso copiada anteriormente)

powershellpowershell.exe -ExecutionPolicy Bypass -File ".\SecurityAudit.ps1"

---> Ejemplo de Salida: Puede consultarse en la carpeta /Ejemplo

<br>

📊 Reportes:
- Los reportes se guardan automáticamente en:
- C:\SecurityAudit\audit_[FECHA]_[HORA].txt
- Formato del nombre: audit_20260120_143015.txt

<br>

🔧 Personalización:
- El script puede ser fácilmente personalizado modificando las verificaciones según las necesidades específicas de la organización:
 - -powershell# Ejemplo: Cambiar umbral de actualizaciones pendientes
if ($pendingCount -le 5) { # Modificar el valor 5 según la política}

<br>


🤝 Contribuciones:
Las contribuciones son bienvenidas. Si deseas mejorar el proyecto:

- Fork el repositorio.
- Crea una rama para tu feature (git checkout -b feature/nueva-verificacion).
- Commit tus cambios (git commit -m 'Agregar verificación de X').
- Push a la rama (git push origin feature/nueva-verificacion).
- Abre un Pull Request.
<br>
  
👤 Autor:
d-romero-dev

- GitHub: https://github.com/d-romero-dev

- LinkedIn: www.linkedin.com/in/damian-romero-dev

- Email: d.romero.dev.contact@gmail.com

<br>

🙏 Agradecimientos

- Inspirado en frameworks de seguridad como CIS Benchmarks y NIST.
- Desarrollado como proyecto de portafolio técnico.
- Agradecimientos a la comunidad de PowerShell, Windows y documentación técnica consultada para la realización de este proyecto.

<br>

⚠️ Disclaimer

- | Este script se proporciona "tal cual" sin garantías de ningún tipo.
- | Úsalo bajo tu propio riesgo.
- |Siempre prueba en entornos de desarrollo antes de aplicar en producción.
   
<br>

📄 Licencia
- Este proyecto está licenciado bajo la Licencia MIT - buscar en la web LICENSE MIT para más detalles.

<br>

⭐ Si este proyecto te resultó útil, considera darle una estrella en GitHub!
