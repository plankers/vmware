# Assumes system has cleanmgr /sageset:11 already set up.

# May need 
# Set-ExecutionPolicy -ExecutionPolicy Unrestricted

# Out-Null makes it wait for the command to end
cleanmgr.exe /sageset:11 | Out-Null

Install-Module -Name PSWindowsUpdate -Force -Confirm:$false

Get-AppxPackage *Teams* | Remove-AppxPackage
Get-AppxPackage *MicrosoftStickyNotes* | Remove-AppxPackage
Get-AppxPackage *YourPhone* | Remove-AppxPackage
Get-AppxPackage *WindowsSoundRecorder* | Remove-AppxPackage
Get-AppxPackage *SpotifyAB.SpotifyMusic* | Remove-AppxPackage
Get-AppxPackage *WindowsAlarms* | Remove-AppxPackage
Get-AppxPackage *WindowsCamera* | Remove-AppxPackage
Get-AppxPackage *Zune* | Remove-AppxPackage
Get-AppxPackage *549981C3F5F10* | Remove-AppxPackage
Get-AppxPackage *WindowsFeedbackHub* | Remove-AppxPackage
Get-AppxPackage *BingNews* | Remove-AppxPackage
Get-AppxPackage *WindowsMaps* | Remove-AppxPackage
Get-AppxPackage *SkypeApp* | Remove-AppxPackage
Get-AppxPackage *windowscommunicationsapps* | Remove-AppxPackage
Get-AppxPackage *GetHelp* | Remove-AppxPackage
Get-AppxPackage *Getstarted* | Remove-AppxPackage
Get-AppxPackage *MicrosoftOfficeHub* | Remove-AppxPackage
Get-AppxPackage *BingWeather* | Remove-AppxPackage
Get-AppxPackage *MicrosoftSolitaireCollection* | Remove-AppxPackage
Get-AppxPackage *WindowsAlarms* | Remove-AppxPackage