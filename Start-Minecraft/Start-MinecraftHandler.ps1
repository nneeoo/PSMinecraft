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

    Write-Out "=============== Starting godlike game server ============"

    if ($type -eq "Vanilla") {
        $type = ((Get-ChildItem | Where-Object Name -Like "*server*.jar").Name | Sort-Object -Descending) | Select-Object -First 1
    }
    else {
        $type = ((Get-ChildItem | Where-Object Name -Like "forge*").Name | Sort-Object -Descending) | Select-Object -First 1
    }

    $ram = ((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum / 1gb)
    $xmx = "-Xms" + $ram + "G"

    $JavaPath = Join-Path -Path $env:JAVA_HOME -ChildPath "bin\java.exe"
    $global:Process = Start-Process $JavaPath -ArgumentList "$xmx -server -jar $type nogui" -Wait -NoNewWindow -PassThru
    
}

function Write-MinecraftExitcode {
    Write-Out "Start time:" $global:Process.StartTime

    Write-Out "Exit code:" $global:Process.ExitCode
    
    Write-Out "Exit time:" $global:Process.ExitTime

    Write-Out "=============== Stopped godlike game server ============="
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