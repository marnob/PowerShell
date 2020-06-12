function FormatDisk {
    $disks = Get-Disk | Where-Object partitionstyle -eq 'raw' | Sort-Object number
    $letters = 70..89 | ForEach-Object { [char]$_ }
    $count = 0
    $labels = "data1","data2"
    foreach ($disk in $disks) {
        $driveLetter = $letters[$count].ToString()
        $disk | 
        Initialize-Disk -PartitionStyle MBR -PassThru |
        New-Partition -UseMaximumSize -DriveLetter $driveLetter |
        Format-Volume -FileSystem NTFS -NewFileSystemLabel $labels[$count] -Confirm:$false -Force
        $count++
    }
}
Function Install_BGInfo {
    $url = 'http://live.sysinternals.com/Bginfo.exe'
    $BGIFileURL = 'http://github.com/marnob/PowerShell/raw/master/Default.bgi'
    $dstPath = "$ENV:ProgramFiles\BgInfo"
    $TaskName = 'BgInfo'
    #$dstPath = "$env:USERPROFILE\Desktop"
    $EXE = "$dstPath\Bginfo.exe"
    $BGI = "$dstPath\Default.bgi"
    $ExeArguments = """$BGI"" /TIMER:0 /NOLICPROMPT"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    if (!(Test-Path -Path $dstPath)){
        New-Item -Path $dstPath -ItemType Directory | Out-Null
    }
    # Download BgInfo 
    try{
        Invoke-WebRequest -Uri $url -OutFile $EXE -ErrorAction Stop
    }
    catch [System.IO.DirectoryNotFoundException]{
        Exit 1
    }
    catch{
        Exit 1
    }
    # Download Default.bgi
    try{
        Invoke-WebRequest -Uri $BGIFileURL -OutFile $BGI -ErrorAction Stop
    }
    catch [System.IO.DirectoryNotFoundException]{
        Exit 1
    }
    catch{
        Exit 1
    }
    # Create Scheduled Task
    Try{
        $stateChangeTrigger = Get-CimClass -Namespace ROOT\Microsoft\Windows\TaskScheduler -ClassName MSFT_TaskSessionStateChangeTrigger -ErrorAction stop
        $triggers = @()
        $triggers += New-ScheduledTaskTrigger -AtLogOn -ErrorAction Stop
        $triggers += New-CimInstance -CimClass $stateChangeTrigger -Property @{StateChange = 3} -ClientOnly -ErrorAction stop
        $triggers += New-CimInstance -CimClass $stateChangeTrigger -Property @{StateChange = 1} -ClientOnly -ErrorAction stop
        $Action= New-ScheduledTaskAction -Execute """$EXE""" -Argument $ExeArguments -ErrorAction Stop
        $Principal = New-ScheduledTaskPrincipal -GroupId 'Users'
        $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries  -DontStopIfGoingOnBatteries
        Register-ScheduledTask -TaskName $TaskName -Trigger $triggers -Action $Action -Settings $Settings -force -Principal $Principal -ErrorAction stop | Out-Null -ErrorAction stop
    }
    Catch{
        Exit 1
    }
    Start-ScheduledTask -TaskName $TaskName
}
Function Install_SSMS {
    # Set file and folder path for SSMS installer .exe
    $folderpath="c:\windows\temp"
    $filepath="$folderpath\SSMS-Setup-ENU.exe"
    
    #If SSMS not present, download
    if (!(Test-Path $filepath)){
        #$URL = "https://download.microsoft.com/download/3/1/D/31D734E0-BFE8-4C33-A9DE-2392808ADEE6/SSMS-Setup-ENU.exe"
        $URL = "https://aka.ms/ssmsfullsetup"
        $clnt = New-Object System.Net.WebClient
        $clnt.DownloadFile($url,$filepath)
    }
    # start the SSMS installer
    $Parms = " /Install /Quiet /Norestart /Logs log.txt"
    $Prms = $Parms.Split(" ")
    & "$filepath" $Prms | Out-Null
}
new-item -Path c:\TestMarcel -ItemType Directory
FormatDisk
Install_BGInfo
Install_SSMS
