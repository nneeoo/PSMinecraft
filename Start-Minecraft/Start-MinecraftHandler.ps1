param (
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$type,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$MinecraftPath,

    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    $StopToken
)

Set-Location $MinecraftPath

function Restart-Minecraft {

    Write-host "=============== Starting godlike game server ============"

    if ($type -eq "Vanilla") {
        $forge = ((Get-ChildItem | Where-Object Name -Like "*server*.jar").Name | Sort-Object -Descending) | Select-Object -first 1
    }
    else {
        $forge = ((Get-ChildItem | Where-Object Name -Like "forge*").Name | Sort-Object -Descending) | Select-Object -first 1
    }

    $ram = ((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum / 1gb)
    $xmx = "-Xms" + $ram + "G"
    $global:Process = Start-Process -FilePath  "C:\Program Files (x86)\common files\Oracle\Java\javapath_target_*\java.exe" -ArgumentList "$xmx -server -jar $forge nogui" -Wait -NoNewWindow -PassThru
    
}

function Write-MinecraftExitcode {
    Write-host "Start time:" $global:Process.StartTime

    Write-host "Exit code:" $global:Process.ExitCode
    
    Write-host "Exit time:" $global:Process.ExitTime

    Write-host "=============== Stopped godlike game server ============="
}

function Get-MinecraftExitCode {
   
    do {

        if ($global:Process.ExitCode -ne 0) {
            #Действия на случай внештатной остановки сервера
            Restart-Minecraft
            Write-MinecraftExitcode
        }

    } until ($global:Process.ExitCode -eq 0)

    #Когда цилк завершен, завершает и листенер
    Invoke-WebRequest -Method Post -Uri localhost -Body $StopToken | Out-Null
}

Get-MinecraftExitCode
