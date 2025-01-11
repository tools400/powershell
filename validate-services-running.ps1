#===========================================================
# Script zur Prüfung der WIndows Server 2016 Dienste.
# Wenn diese Dienste nicht zur Verfügung stehen, wird
# der PC nicht mehr gesichert.
# Fehlerbehebung siehe:
# - https://sbsland.me/2022/10/03/windows-10-update-1903-und-der-essentials-connector-fix/
# - d:\_Installationsdaten\_Thomas PC\Win11\00. Backup Server\
#===========================================================

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


class Service {
    [String]$name
    [bool]$isRunning

    Service([string] $name, [bool] $isRunning){
        $this.name = $name
        $this.isRunning = $isRunning
    }
}


$services =
@(
  [Service]::new("WseClientMgmtSvc", $false),
  [Service]::new("WseClientMonitorSvc", $true),
  [Service]::new("WseHealthSvc", $false),
  [Service]::new("WseNtfSvc", $false),
  [Service]::new("ServiceProviderRegistry", $false)
)

$countErrors = 0
foreach ($service in $services) {
    $winService = Get-Service -name $service.name
    if ($winService -eq $null) {
        $countErrors++
    }
}


if ($countErrors -eq 0){
    $locale = Get-WinSystemLocale
    if ($locale.name.StartsWith('de')) {
        [System.Windows.Forms.MessageBox]::Show($msg_de,"Fehler!",'OK','Error')
    }
}
