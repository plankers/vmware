sfc /scannow

dism.exe /online /cleanup-image /restorehealth

Get-AppXPackage | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}

for ($letter = 2; $letter -lt 5; $letter++) {
    $driveletter = [char](65+$letter)
    $driveletter = $driveletter + ":"
    Start-Process -FilePath "C:\Windows\system32\chkdsk.exe" -ArgumentList "$driveletter /scan /forceofflinefix" -Wait
}