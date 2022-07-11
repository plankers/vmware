# Assumes system has cleanmgr /sageset:11 already set up.
# Out-Null makes it wait for the command to end

Write-Host "Running cleanmgr.exe" -ForegroundColor Yellow
cleanmgr.exe /sagerun:11 | Out-Null

Write-Host "TRIMming disks" -ForegroundColor Yellow
for ($letter = 2; $letter -lt 26; $letter++) {
    $driveletter = [char](65+$letter)
    Optimize-Volume -DriveLetter $driveletter -ReTrim -SlabConsolidate -Defrag | Out-Null
}

Write-Host "Running Windows Update" -ForegroundColor Yellow
Get-WindowsUpdate -Install -MicrosoftUpdate -AcceptAll -Verbose

Write-Host "Updating Windows Store Apps" -ForegroundColor Yellow
Get-CimInstance -Namespace "Root\cimv2\mdm\dmmap" -ClassName "MDM_EnterpriseModernAppManagement_AppManagement01" | Invoke-CimMethod -MethodName UpdateScanMethod | Out-Null