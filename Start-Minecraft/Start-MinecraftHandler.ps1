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

    Write-Output "=============== Starting godlike game server ============"

    if ($type -eq "Vanilla") {
        $type = ((Get-ChildItem | Where-Object Name -Like "*server*.jar").Name | Sort-Object -Descending) | Select-Object -First 1
    }
    else {
        $Forge = (Get-ChildItem | Where-Object Name -Like "forge*").Name

        if ($null -eq $Forge) {
            Write-Error "Forge file was not found in foilder"
            break
        }
        else {
            $type = ((Get-ChildItem | Where-Object Name -Like "forge*").Name | Sort-Object -Descending) | Select-Object -First 1
        }
    }

    $ram = ((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum / 1gb)
    $xmx = "-Xms" + $ram + "G"

    $JavaPath = Join-Path -Path $env:JAVA_HOME -ChildPath "bin\java.exe"
    $global:Process = Start-Process $JavaPath -ArgumentList "$xmx -server -jar $type nogui" -Wait -NoNewWindow -PassThru
    
}

function Write-MinecraftExitcode {
    Write-Output "Start time:" $global:Process.StartTime

    Write-Output "Exit code:" $global:Process.ExitCode
    
    Write-Output "Exit time:" $global:Process.ExitTime

    Write-Output "=============== Stopped godlike game server ============="
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
    if ($StartPaymentListener) {
        Invoke-WebRequest -Method Post -Uri localhost -Body $StopToken | Out-Null
    }
}

Get-MinecraftExitCode