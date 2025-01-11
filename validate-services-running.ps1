#===========================================================
# Script for testing the services that are required
# for backups by Windows Server 2016 Essentials.
# If these services are not available, the PC will no
# longer be backed up.
# Fixing the issue:
# - https://sbsland.me/2022/10/03/windows-10-update-1903-und-der-essentials-connector-fix/
# - d:\_Installationsdaten\_Thomas PC\Win11\00. Backup Server\
#===========================================================

# ------------------------------------
#  Message text for different locales.
# ------------------------------------
$msg_de = @'
Ein oder mehrere für das automatische Backup erforderlichen Dienste wurden nicht gefunden!

Das Backup ist gefährdet. Bitte dringend prüfen.

Siehe:
https://sbsland.me/2022/10/03/windows-10-update-1903-und-der-essentials-connector-fix/
'@

$msg_en = @'
One or more services required for automatic backup were not found!

The backup is at risk. Please check urgently.

Siehe:
https://sbsland.me/2022/10/03/windows-10-update-1903-und-der-essentials-connector-fix/
'@


#  Helper class.
class Service {
    [String]$name
    [bool]$isRunning

    Service([string] $name, [bool] $isRunning){
        $this.name = $name
        $this.isRunning = $isRunning
    }
}

#  Services to check.
$services =
@(
  [Service]::new("WseClientMgmtSvc", $false),
  [Service]::new("WseClientMonitorSvc", $true),
  [Service]::new("WseHealthSvc", $false),
  [Service]::new("WseNtfSvc", $false),
  [Service]::new("ServiceProviderRegistry", $false)
)

# ------------------------------------
#  Appends a new message to the log
# ------------------------------------
function Write-LogEntry {
    param (
        $Message
    )

    "$(Get-Date -format yyyy-MM-dd-HH-mm-ss): $Message" | Out-File -Append $LogFile
} 

# ------------------------------------
#  Display error dialog.
# ------------------------------------
function displayErrorDialog {
    $locale = Get-WinSystemLocale
    if ($locale.name.StartsWith('de')) {
        Add-Type -AssemblyName "System.Windows.Forms"
        $rc = [System.Windows.Forms.MessageBox]::Show($msg_de,"Fehler!",'OK','Error')
    }
}

# ------------------------------------
#  Start of main script.
# ------------------------------------

$ScriptHomeDir=$PSScriptRoot
if ($ScriptHomeDir -eq '') {
    $ScriptHomeDir = 'c:\temp'
}

If(!(Test-Path $ScriptHomeDir))
{
    New-Item -ItemType Directory -Force -Path $ScriptHomeDir 1> $null
}

$LogFile = "$ScriptHomeDir\Validate Windows Services.log"
Write-LogEntry('Validating Windows backup services ...')

$countErrors = 0
foreach ($service in $services) {
    $winService = Get-Service -name $service.name
    if ($winService -eq $null) {
        $countErrors++
        Write-LogEntry("Service: $($service.name) => ERROR, not found!")
    } else {
        if ($service.isRunning -and $winService.Status -ne [System.ServiceProcess.ServiceControllerStatus]::Running) {
            $countErrors++
            Write-LogEntry("Service: $($service.name) => ERROR, not running!")
        } else {
            Write-LogEntry("Service: $($service.name) => OK")
        }
    }
}

if ($countErrors -gt 0){
    displayErrorDialog
    Write-LogEntry('An error occurred while checking Windows services.')
} else {
    Write-LogEntry('Windows Services successfully tested.')
}
