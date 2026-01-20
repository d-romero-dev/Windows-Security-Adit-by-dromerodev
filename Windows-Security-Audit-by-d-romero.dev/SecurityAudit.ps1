<#
.SYNOPSIS
    Script de auditoría de seguridad para endpoints Windows
.DESCRIPTION
    Realiza 15 verificaciones de seguridad en sistemas Windows y genera reporte en formato TXT
.AUTHOR
    Desarrollado como proyecto de portafolio técnico
.VERSION
    1.0
.DATE
    Enero 2026
#>

# Requiere ejecución como Administrador
#Requires -RunAsAdministrator

# Variables globales
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$computerName = $env:COMPUTERNAME
$userName = $env:USERNAME
$reportPath = "C:\SecurityAudit"
$reportFile = "$reportPath\audit_$timestamp.txt"

# Contadores de resultados
$passCount = 0
$warningCount = 0
$failCount = 0
$totalChecks = 15

# Crear directorio si no existe
if (-not (Test-Path $reportPath)) {
    New-Item -ItemType Directory -Path $reportPath -Force | Out-Null
}

# Función para escribir en consola y archivo
function Write-Report {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
    Add-Content -Path $reportFile -Value $Message
}

# Función para formatear línea separadora
function Write-Separator {
    param([string]$char = "=", [int]$length = 65)
    $line = $char * $length
    Write-Report $line
}

# Iniciar reporte
Clear-Host
Write-Separator
Write-Report "   WINDOWS SECURITY AUDIT - Reporte de Auditoría by d-romero.dev" "Cyan"
Write-Separator
Write-Report "Equipo: $computerName"
Write-Report "Fecha: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Report "Usuario: $userName"

# Obtener información del SO
$osInfo = Get-CimInstance -ClassName Win32_OperatingSystem
Write-Report "Sistema: $($osInfo.Caption) - Build $($osInfo.BuildNumber)"
Write-Report ""

# Array para almacenar hallazgos críticos
$criticalFindings = @()
$importantFindings = @()

Write-Report "-----------------------------------------------------------------" "Gray"
Write-Report "                EJECUTANDO VERIFICACIONES..." "Yellow"
Write-Report "-----------------------------------------------------------------" "Gray"
Write-Report ""

# ============================================================================
# CHECK 1: Windows Defender
# ============================================================================
Write-Host "[1/15] Verificando Windows Defender..." -ForegroundColor Yellow
try {
    $defender = Get-MpComputerStatus -ErrorAction Stop
    if ($defender.RealTimeProtectionEnabled -eq $true -and $defender.AntivirusEnabled -eq $true) {
        $status = "PASS"
        $passCount++
        $detail = "Windows Defender está ACTIVO y protección en tiempo real habilitada"
    } else {
        $status = "FAIL"
        $failCount++
        $detail = "Windows Defender está DESACTIVADO o protección en tiempo real deshabilitada"
        $criticalFindings += "Activar Windows Defender y protección en tiempo real"
    }
} catch {
    $status = "WARNING"
    $warningCount++
    $detail = "No se pudo verificar el estado de Windows Defender"
}

$check1 = @"
[1] Windows Defender - Estado
    Estado: $status
    Detalle: $detail
    $(if($status -eq "FAIL"){"Recomendación: Activar Windows Defender inmediatamente"})
"@
Write-Report $check1
Write-Report ""

# ============================================================================
# CHECK 2: Windows Firewall
# ============================================================================
Write-Host "[2/15] Verificando Windows Firewall..." -ForegroundColor Yellow
try {
    $firewallProfiles = Get-NetFirewallProfile
    $allEnabled = ($firewallProfiles | Where-Object { $_.Enabled -eq $false }).Count -eq 0
    
    if ($allEnabled) {
        $status = "PASS"
        $passCount++
        $detail = "Firewall activo en todos los perfiles (Dominio, Privado, Público)"
    } else {
        $status = "FAIL"
        $failCount++
        $detail = "Firewall DESACTIVADO en uno o más perfiles"
        $criticalFindings += "Activar Windows Firewall en todos los perfiles"
    }
} catch {
    $status = "WARNING"
    $warningCount++
    $detail = "No se pudo verificar estado del Firewall"
}

$check2 = @"
[2] Windows Firewall
    Estado: $status
    Detalle: $detail
    $(if($status -eq "FAIL"){"Recomendación: Habilitar Firewall en todos los perfiles de red"})
"@
Write-Report $check2
Write-Report ""

# ============================================================================
# CHECK 3: Actualizaciones de Windows
# ============================================================================
Write-Host "[3/15] Verificando actualizaciones pendientes..." -ForegroundColor Yellow
try {
    $updateSession = New-Object -ComObject Microsoft.Update.Session
    $updateSearcher = $updateSession.CreateUpdateSearcher()
    $updates = $updateSearcher.Search("IsInstalled=0 and Type='Software'").Updates
    $pendingCount = $updates.Count
    
    # Última actualización instalada
    $lastUpdate = Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 1
    
    if ($pendingCount -eq 0) {
        $status = "PASS"
        $passCount++
        $detail = "Sistema actualizado - 0 actualizaciones pendientes"
    } elseif ($pendingCount -le 5) {
        $status = "WARNING"
        $warningCount++
        $detail = "$pendingCount actualizaciones pendientes"
        $importantFindings += "Instalar $pendingCount actualizaciones pendientes"
    } else {
        $status = "FAIL"
        $failCount++
        $detail = "$pendingCount actualizaciones pendientes (cantidad elevada)"
        $criticalFindings += "Instalar $pendingCount actualizaciones pendientes urgentemente"
    }
    
    $lastUpdateDate = if ($lastUpdate) { $lastUpdate.InstalledOn.ToString("yyyy-MM-dd") } else { "Desconocido" }
} catch {
    $status = "WARNING"
    $warningCount++
    $detail = "No se pudo verificar actualizaciones"
    $lastUpdateDate = "No disponible"
}

$check3 = @"
[3] Actualizaciones de Windows
    Estado: $status
    Detalle: $detail
    Última actualización: $lastUpdateDate
    $(if($status -ne "PASS"){"Recomendación: Instalar actualizaciones pendientes"})
"@
Write-Report $check3
Write-Report ""

# ============================================================================
# CHECK 4: Control de Cuentas de Usuario (UAC)
# ============================================================================
Write-Host "[4/15] Verificando UAC..." -ForegroundColor Yellow
try {
    $uacKey = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ErrorAction Stop
    $uacLevel = $uacKey.ConsentPromptBehaviorAdmin
    
    if ($uacLevel -ge 2) {
        $status = "PASS"
        $passCount++
        $detail = "UAC configurado correctamente (Nivel: $uacLevel)"
    } else {
        $status = "FAIL"
        $failCount++
        $detail = "UAC deshabilitado o en nivel muy bajo (Nivel: $uacLevel)"
        $criticalFindings += "Configurar UAC en nivel seguro (mínimo 2)"
    }
} catch {
    $status = "WARNING"
    $warningCount++
    $detail = "No se pudo verificar configuración de UAC"
}

$check4 = @"
[4] Control de Cuentas de Usuario (UAC)
    Estado: $status
    Detalle: $detail
    $(if($status -eq "FAIL"){"Recomendación: Habilitar UAC en nivel recomendado"})
"@
Write-Report $check4
Write-Report ""

# ============================================================================
# CHECK 5: Cuenta de Administrador Local
# ============================================================================
Write-Host "[5/15] Verificando cuenta Administrator..." -ForegroundColor Yellow
try {
    $adminAccount = Get-LocalUser -Name "Administrator" -ErrorAction Stop
    
    if ($adminAccount.Enabled -eq $false) {
        $status = "PASS"
        $passCount++
        $detail = "Cuenta Administrator está DESHABILITADA"
    } else {
        $status = "WARNING"
        $warningCount++
        $detail = "Cuenta Administrator está HABILITADA"
        $importantFindings += "Deshabilitar cuenta Administrator si no es necesaria"
    }
} catch {
    $status = "PASS"
    $passCount++
    $detail = "Cuenta Administrator no encontrada o ya deshabilitada"
}

$check5 = @"
[5] Cuenta de Administrador Local
    Estado: $status
    Detalle: $detail
    $(if($status -eq "WARNING"){"Recomendación: Deshabilitar cuenta si no es necesaria"})
"@
Write-Report $check5
Write-Report ""

# ============================================================================
# CHECK 6: Cuenta de Invitado
# ============================================================================
Write-Host "[6/15] Verificando cuenta Guest..." -ForegroundColor Yellow
try {
    $guestAccount = Get-LocalUser -Name "Guest" -ErrorAction Stop
    
    if ($guestAccount.Enabled -eq $false) {
        $status = "PASS"
        $passCount++
        $detail = "Cuenta Guest está DESHABILITADA"
    } else {
        $status = "FAIL"
        $failCount++
        $detail = "Cuenta Guest está HABILITADA (riesgo de seguridad)"
        $criticalFindings += "Deshabilitar cuenta Guest inmediatamente"
    }
} catch {
    $status = "PASS"
    $passCount++
    $detail = "Cuenta Guest no encontrada o ya deshabilitada"
}

$check6 = @"
[6] Cuenta de Invitado
    Estado: $status
    Detalle: $detail
    $(if($status -eq "FAIL"){"Recomendación: Deshabilitar cuenta Guest"})
"@
Write-Report $check6
Write-Report ""

# ============================================================================
# CHECK 7: Política de Contraseñas
# ============================================================================
Write-Host "[7/15] Verificando política de contraseñas..." -ForegroundColor Yellow
try {
    $passwordPolicy = net accounts | Select-String "Longitud mínima de la contraseña"
    $minLength = [int]($passwordPolicy -replace '\D+(\d+).*','$1')
    
    if ($minLength -ge 12) {
        $status = "PASS"
        $passCount++
        $detail = "Longitud mínima: $minLength caracteres (seguro)"
    } elseif ($minLength -ge 8) {
        $status = "WARNING"
        $warningCount++
        $detail = "Longitud mínima: $minLength caracteres (aceptable)"
        $importantFindings += "Aumentar longitud mínima de contraseña a 12 caracteres"
    } else {
        $status = "FAIL"
        $failCount++
        $detail = "Longitud mínima: $minLength caracteres (inseguro)"
        $criticalFindings += "Configurar longitud mínima de contraseña a 12+ caracteres"
    }
} catch {
    $status = "WARNING"
    $warningCount++
    $detail = "No se pudo verificar política de contraseñas"
}

$check7 = @"
[7] Política de Contraseñas
    Estado: $status
    Detalle: $detail
    $(if($status -ne "PASS"){"Recomendación: Configurar longitud mínima de 12 caracteres"})
"@
Write-Report $check7
Write-Report ""

# ============================================================================
# CHECK 8: BitLocker
# ============================================================================
Write-Host "[8/15] Verificando BitLocker..." -ForegroundColor Yellow
try {
    $bitlocker = Get-BitLockerVolume -MountPoint "C:" -ErrorAction Stop
    
    if ($bitlocker.ProtectionStatus -eq "On") {
        $status = "PASS"
        $passCount++
        $detail = "BitLocker ACTIVO en disco C: (Cifrado: $($bitlocker.EncryptionPercentage)%)"
    } else {
        $status = "FAIL"
        $failCount++
        $detail = "BitLocker NO está activo en disco C:"
        $criticalFindings += "Habilitar cifrado BitLocker en disco del sistema"
    }
} catch {
    $status = "WARNING"
    $warningCount++
    $detail = "BitLocker no disponible o no se pudo verificar"
}

$check8 = @"
[8] BitLocker - Cifrado de Disco
    Estado: $status
    Detalle: $detail
    $(if($status -eq "FAIL"){"Recomendación: Habilitar BitLocker para proteger datos"})
"@
Write-Report $check8
Write-Report ""

# ============================================================================
# CHECK 9: Servicios Innecesarios (Telnet, FTP)
# ============================================================================
Write-Host "[9/15] Verificando servicios innecesarios..." -ForegroundColor Yellow
try {
    $telnet = Get-Service -Name "TlntSvr" -ErrorAction SilentlyContinue
    $ftp = Get-Service -Name "FTPSVC" -ErrorAction SilentlyContinue
    
    $telnetStatus = if ($telnet) { $telnet.Status } else { "No instalado" }
    $ftpStatus = if ($ftp) { $ftp.Status } else { "No instalado" }
    
    if (($telnetStatus -eq "No instalado" -or $telnetStatus -eq "Stopped") -and 
        ($ftpStatus -eq "No instalado" -or $ftpStatus -eq "Stopped")) {
        $status = "PASS"
        $passCount++
        $detail = "Telnet y FTP deshabilitados/no instalados"
    } else {
        $status = "WARNING"
        $warningCount++
        $detail = "Servicios potencialmente inseguros activos (Telnet: $telnetStatus, FTP: $ftpStatus)"
        $importantFindings += "Deshabilitar servicios Telnet y/o FTP"
    }
} catch {
    $status = "PASS"
    $passCount++
    $detail = "Servicios no encontrados (deshabilitados)"
}

$check9 = @"
[9] Servicios Innecesarios
    Estado: $status
    Detalle: $detail
    $(if($status -eq "WARNING"){"Recomendación: Deshabilitar Telnet y FTP"})
"@
Write-Report $check9
Write-Report ""

# ============================================================================
# CHECK 10: Espacio en Disco
# ============================================================================
Write-Host "[10/15] Verificando espacio en disco..." -ForegroundColor Yellow
try {
    $disk = Get-PSDrive -Name C
    $freeSpacePercent = [math]::Round(($disk.Free / $disk.Used) * 100, 2)
    $freeSpaceGB = [math]::Round($disk.Free / 1GB, 2)
    
    if ($freeSpacePercent -ge 20) {
        $status = "PASS"
        $passCount++
        $detail = "Disco C: - $freeSpacePercent% libre ($freeSpaceGB GB disponibles)"
    } elseif ($freeSpacePercent -ge 10) {
        $status = "WARNING"
        $warningCount++
        $detail = "Disco C: - $freeSpacePercent% libre ($freeSpaceGB GB) - Espacio bajo"
        $importantFindings += "Liberar espacio en disco C:"
    } else {
        $status = "FAIL"
        $failCount++
        $detail = "Disco C: - $freeSpacePercent% libre ($freeSpaceGB GB) - Espacio crítico"
        $criticalFindings += "Liberar espacio urgentemente en disco C:"
    }
} catch {
    $status = "WARNING"
    $warningCount++
    $detail = "No se pudo verificar espacio en disco"
}

$check10 = @"
[10] Espacio en Disco
    Estado: $status
    Detalle: $detail
    $(if($status -ne "PASS"){"Recomendación: Liberar espacio en disco"})
"@
Write-Report $check10
Write-Report ""

# ============================================================================
# CHECK 11: Usuarios con privilegios administrativos
# ============================================================================
Write-Host "[11/15] Verificando usuarios administradores..." -ForegroundColor Yellow
try {
    $adminGroup = Get-LocalGroupMember -Group "Administrators" -ErrorAction Stop
    $adminCount = $adminGroup.Count
    
    if ($adminCount -le 2) {
        $status = "PASS"
        $passCount++
        $detail = "$adminCount usuarios con privilegios de administrador"
    } elseif ($adminCount -le 4) {
        $status = "WARNING"
        $warningCount++
        $detail = "$adminCount usuarios con privilegios de administrador (revisar necesidad)"
        $importantFindings += "Revisar usuarios con privilegios administrativos"
    } else {
        $status = "FAIL"
        $failCount++
        $detail = "$adminCount usuarios con privilegios de administrador (excesivo)"
        $criticalFindings += "Reducir número de usuarios administradores"
    }
} catch {
    $status = "WARNING"
    $warningCount++
    $detail = "No se pudo verificar grupo de administradores"
}

$check11 = @"
[11] Usuarios Administradores
    Estado: $status
    Detalle: $detail
    $(if($status -ne "PASS"){"Recomendación: Aplicar principio de mínimo privilegio"})
"@
Write-Report $check11
Write-Report ""

# ============================================================================
# CHECK 12: Configuración de Escritorio Remoto
# ============================================================================
Write-Host "[12/15] Verificando Escritorio Remoto..." -ForegroundColor Yellow
try {
    $rdpKey = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -ErrorAction Stop
    $rdpEnabled = $rdpKey.fDenyTSConnections
    
    if ($rdpEnabled -eq 1) {
        $status = "PASS"
        $passCount++
        $detail = "Escritorio Remoto está DESHABILITADO"
    } else {
        $status = "WARNING"
        $warningCount++
        $detail = "Escritorio Remoto está HABILITADO"
        $importantFindings += "Revisar necesidad de Escritorio Remoto habilitado"
    }
} catch {
    $status = "WARNING"
    $warningCount++
    $detail = "No se pudo verificar configuración de RDP"
}

$check12 = @"
[12] Escritorio Remoto (RDP)
    Estado: $status
    Detalle: $detail
    $(if($status -eq "WARNING"){"Recomendación: Deshabilitar si no es necesario o usar VPN"})
"@
Write-Report $check12
Write-Report ""

# ============================================================================
# CHECK 13: Protección contra Ransomware (Controlled Folder Access)
# ============================================================================
Write-Host "[13/15] Verificando protección contra ransomware..." -ForegroundColor Yellow
try {
    $cfa = Get-MpPreference -ErrorAction Stop | Select-Object -ExpandProperty EnableControlledFolderAccess
    
    if ($cfa -eq 1) {
        $status = "PASS"
        $passCount++
        $detail = "Acceso controlado a carpetas HABILITADO"
    } else {
        $status = "WARNING"
        $warningCount++
        $detail = "Acceso controlado a carpetas DESHABILITADO"
        $importantFindings += "Habilitar protección contra ransomware"
    }
} catch {
    $status = "WARNING"
    $warningCount++
    $detail = "No se pudo verificar protección contra ransomware"
}

$check13 = @"
[13] Protección contra Ransomware
    Estado: $status
    Detalle: $detail
    $(if($status -eq "WARNING"){"Recomendación: Habilitar Controlled Folder Access"})
"@
Write-Report $check13
Write-Report ""

# ============================================================================
# CHECK 14: SMBv1 (Protocolo inseguro)
# ============================================================================
Write-Host "[14/15] Verificando SMBv1..." -ForegroundColor Yellow
try {
    $smbv1 = Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -ErrorAction Stop
    
    if ($smbv1.State -eq "Disabled") {
        $status = "PASS"
        $passCount++
        $detail = "SMBv1 está DESHABILITADO (protocolo inseguro removido)"
    } else {
        $status = "FAIL"
        $failCount++
        $detail = "SMBv1 está HABILITADO (vulnerabilidad conocida - WannaCry)"
        $criticalFindings += "Deshabilitar SMBv1 inmediatamente"
    }
} catch {
    $status = "WARNING"
    $warningCount++
    $detail = "No se pudo verificar estado de SMBv1"
}

$check14 = @"
[14] Protocolo SMBv1
    Estado: $status
    Detalle: $detail
    $(if($status -eq "FAIL"){"Recomendación: Deshabilitar SMBv1 para prevenir exploits"})
"@
Write-Report $check14
Write-Report ""

# ============================================================================
# CHECK 15: Tiempo de bloqueo de pantalla
# ============================================================================
Write-Host "[15/15] Verificando bloqueo automático de pantalla..." -ForegroundColor Yellow
try {
    $screenSaver = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -ErrorAction Stop
    $screenSaverTimeout = [int]$screenSaver.ScreenSaveTimeOut
    $timeoutMinutes = $screenSaverTimeout / 60
    
    if ($timeoutMinutes -le 15 -and $screenSaverTimeout -gt 0) {
        $status = "PASS"
        $passCount++
        $detail = "Bloqueo automático configurado a $timeoutMinutes minutos"
    } elseif ($timeoutMinutes -le 30) {
        $status = "WARNING"
        $warningCount++
        $detail = "Bloqueo automático a $timeoutMinutes minutos (recomendado: 15 min)"
        $importantFindings += "Reducir tiempo de bloqueo de pantalla a 15 minutos"
    } else {
        $status = "FAIL"
        $failCount++
        $detail = "Bloqueo automático no configurado o tiempo excesivo"
        $criticalFindings += "Configurar bloqueo automático de pantalla a 15 minutos"
    }
} catch {
    $status = "WARNING"
    $warningCount++
    $detail = "No se pudo verificar configuración de bloqueo de pantalla"
}

$check15 = @"
[15] Bloqueo Automático de Pantalla
    Estado: $status
    Detalle: $detail
    $(if($status -ne "PASS"){"Recomendación: Configurar bloqueo automático a 15 minutos"})
"@
Write-Report $check15
Write-Report ""

# ============================================================================
# RESUMEN EJECUTIVO
# ============================================================================
Write-Report ""
Write-Separator "-"
Write-Report "                    RESUMEN EJECUTIVO d-romero.dev" "Cyan"
Write-Separator "-"

$passPercent = [math]::Round(($passCount / $totalChecks) * 100, 0)
$warningPercent = [math]::Round(($warningCount / $totalChecks) * 100, 0)
$failPercent = [math]::Round(($failCount / $totalChecks) * 100, 0)

Write-Report "Total de Verificaciones: $totalChecks"
Write-Report "✅ PASS:    $passCount ($passPercent%)" "Green"
Write-Report "⚠️ WARNING: $warningCount ($warningPercent%)" "Yellow"
Write-Report "❌ FAIL:    $failCount ($failPercent%)" "Red"
Write-Report ""

# Determinar estado general
if ($failCount -eq 0 -and $warningCount -eq 0) {
    $generalStatus = "EXCELENTE - Sistema seguro"
    $statusColor = "Green"
} elseif ($failCount -eq 0 -and $warningCount -le 3) {
    $generalStatus = "BUENO - Mejoras menores recomendadas"
    $statusColor = "Green"
} elseif ($failCount -le 2) {
    $generalStatus = "REQUIERE ATENCIÓN - Problemas de seguridad detectados"
    $statusColor = "Yellow"
} else {
    $generalStatus = "CRÍTICO - Acción inmediata requerida"
    $statusColor = "Red"
}

Write-Report "Estado General: $generalStatus" $statusColor
Write-Report ""

# ============================================================================
# ACCIONES RECOMENDADAS
# ============================================================================
Write-Separator
Write-Report "                  ACCIONES RECOMENDADAS" "Cyan"
Write-Separator

if ($criticalFindings.Count -gt 0) {
    Write-Report "[CRÍTICO - Atención Inmediata]" "Red"
    for ($i = 0; $i -lt $criticalFindings.Count; $i++) {
        Write-Report "  $($i + 1). $($criticalFindings[$i])" "Red"
    }
    Write-Report ""
}

if ($importantFindings.Count -gt 0) {
    Write-Report "[IMPORTANTE - Próximas 48 horas]" "Yellow"
    $startNum = $criticalFindings.Count + 1
    for ($i = 0; $i -lt $importantFindings.Count; $i++) {
        Write-Report "  $($startNum + $i). $($importantFindings[$i])" "Yellow"
    }
    Write-Report ""
}

if ($criticalFindings.Count -eq 0 -and $importantFindings.Count -eq 0) {
    Write-Report "No se detectaron hallazgos críticos. Sistema en buen estado." "Green"
    Write-Report ""
}

# ============================================================================
# FINALIZACIÓN
# ============================================================================
Write-Separator
Write-Report "Reporte guardado en: $reportFile" "Green"
Write-Separator
Write-Report ""
Write-Host "Presione cualquier tecla para salir..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")