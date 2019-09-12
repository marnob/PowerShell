<#
 Script:        BgInfo install - Server
 Description:   Downloads and installs BgInfo
 Author:        Marcel Nobel, Prodware
 Date:          06/20/2019 mm/dd/yyyy
 Version:       1.1
 Comments:           
#>
$url = 'https://live.sysinternals.com/Bginfo.exe'
$BGIFileURL = 'https://github.com/marnob/PowerShell/raw/master/Default.bgi'
$dstPath = "$ENV:ProgramFiles\BgInfo"
$TaskName = 'BgInfo'
#$dstPath = "$env:USERPROFILE\Desktop"
$EXE = "$dstPath\Bginfo.exe"
$BGI = "$dstPath\Default.bgi"
$ExeArguments = """$BGI"" /TIMER:0 /NOLICPROMPT"

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
Try{
    Write-Host "Creating scheduled task..." -NoNewline
    $stateChangeTrigger = Get-CimClass -Namespace ROOT\Microsoft\Windows\TaskScheduler -ClassName MSFT_TaskSessionStateChangeTrigger -ErrorAction stop
    $triggers = @()
    $triggers += New-ScheduledTaskTrigger -AtLogOn -ErrorAction Stop
    $triggers += New-CimInstance -CimClass $stateChangeTrigger -Property @{StateChange = 3} -ClientOnly -ErrorAction stop
    $triggers += New-CimInstance -CimClass $stateChangeTrigger -Property @{StateChange = 1} -ClientOnly -ErrorAction stop
    $Action= New-ScheduledTaskAction -Execute """$EXE""" -Argument $ExeArguments -ErrorAction Stop
    $Principal = New-ScheduledTaskPrincipal -GroupId 'Users'
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries  -DontStopIfGoingOnBatteries
    Register-ScheduledTask -TaskName $TaskName -Trigger $triggers -Action $Action -Settings $Settings -force -Principal $Principal -ErrorAction stop | Out-Null -ErrorAction stop
    Write-Host "Done!" -ForegroundColor Green
}
Catch{
    Write-Host "`nERROR: Unkonow error occured creating the Scheduled Task." -ForegroundColor Red
    Exit 1
}
Start-ScheduledTask -TaskName $TaskName
