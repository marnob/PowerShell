<#
 Script:        BgInfo install - Server
 Description:   Downloads and installs BgInfo
 Author:        Marcel Nobel, Prodware
 Date:          06/20/2019 mm/dd/yyyy
 Version:       1.0
 Comments:           
#>
$url = 'https://live.sysinternals.com/Bginfo.exe'
$BGIFileURL = 'https://github.com/marnob/PowerShell/raw/master/Default.bgi'
$dstPath = "$ENV:ProgramFiles\BgInfo"
#$dstPath = "$env:USERPROFILE\Desktop"
$EXE = "$dstPath\Bginfo.exe"
$BGI = "$dstPath\Default.bgi"

if (!(Test-Path -Path $dstPath)){
    New-Item -Path $dstPath -ItemType Directory | Out-Null
}
# Download BgInfo 
try{
    Write-Host "Downloading Bgingo.exe from https://live.sysinternals.com..." -NoNewline
    Invoke-WebRequest -Uri $url -OutFile $EXE -ErrorAction Stop
    Write-Host "Done!" -ForegroundColor Green
}
catch [System.IO.DirectoryNotFoundException]{
    Write-Host "`nERROR: No permissions to write to $dstPath." -ForegroundColor Red
    Exit 1
}
catch{
    Write-Host "`nERROR: Unkonow error occured." -ForegroundColor Red
    Exit 1
}
# Download Default.bgi
try{
    Write-Host "Downloading Default.bgi from GitHub..." -NoNewline
    Invoke-WebRequest -Uri $BGIFileURL -OutFile $BGI -ErrorAction Stop
    Write-Host "Done!" -ForegroundColor Green
}
catch [System.IO.DirectoryNotFoundException]{
    Write-Host "`nERROR: No permissions to write to $dstPath." -ForegroundColor Red
    Exit 1
}
catch{
    Write-Host "`nERROR: Unkonow error occured." -ForegroundColor Red
    Exit 1
}
# Create Scheduled Task
$stateChangeTrigger = Get-CimClass -Namespace ROOT\Microsoft\Windows\TaskScheduler -ClassName MSFT_TaskSessionStateChangeTrigger
$triggers = @()
$triggers += New-ScheduledTaskTrigger -AtLogOn
$triggers += New-CimInstance -CimClass $stateChangeTrigger -Property @{StateChange = 3} -ClientOnly
    $triggers += New-CimInstance -CimClass $stateChangeTrigger -Property @{StateChange = 1} -ClientOnly
$Action= New-ScheduledTaskAction -Execute """$EXE""" -Argument """$BGI"" /TIMER:0 /NOLICPROMPT" 
Register-ScheduledTask -TaskName "BgInfo" -Trigger $triggers -Action $Action -force | Out-Null