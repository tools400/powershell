# Script for remapping unavailable network drives..
# Can be execute with a .LNK from the autostart folder with the following
# parameters, presuming 'Mappen Laufwerke.ps1' has been stored in '%HOMEPATH%\AppData\Local\Mappen Laufwerke':
#
# Target: C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe "& ""%HOMEPATH%\AppData\Local\Mappen Laufwerke\Mappen Laufwerke.ps1"""
# Directory: %HOMEPATH%
#
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
#  Start of main script
# ------------------------------------
$ScriptHomeDir=$PSScriptRoot
if ($ScriptHomeDir -eq '') {
    $ScriptHomeDir = 'c:\temp'
}

If(!(Test-Path $ScriptHomeDir))
{
    New-Item -ItemType Directory -Force -Path $ScriptHomeDir 1> $null
}

$LogFile = "$ScriptHomeDir\Mappen Laufwerke.log"
Write-LogEntry('Reconnecting unavailable network drives ...')

# ------------------------------------
#  Re-map unavailable network drives
# ------------------------------------
$i=3

while($True){
    $Error.Clear()
    $MappedDrives = Get-SmbMapping |where -property Status -Value Unavailable -EQ | select LocalPath,RemotePath
    if ($MappedDrives -eq $null) {
        Write-LogEntry('All network drives are available.')
        break
    }
    foreach( $MappedDrive in $MappedDrives)
    {
        try {
            Write-LogEntry("Attempting to map drive: $($MappedDrive) ...")
            New-SmbMapping -LocalPath $MappedDrive.LocalPath -RemotePath $MappedDrive.RemotePath -Persistent $True
            Write-LogEntry("Successfully map drive: $($MappedDrive) ...")
        } catch {
            Write-LogEntry "There was an error mapping $MappedDrive.RemotePath to $MappedDrive.LocalPath"
        }
    }

    $i = $i - 1
    if($Error.Count -eq 0 -Or $i -eq 0) {
        break
    }

    Start-Sleep -Seconds 30
}

Write-LogEntry('Finished reconnecting unavailable network drives.')
