function Complete-MinecraftPayment {
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Player,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $MinecraftPath
    )
    begin {
        class Payment {
            $File
            $Payment
        }
        
        $PathToModule = Split-Path (Get-Module -ListAvailable Start-Minecraft).path
        Import-Module (Join-Path $PathToModule \Read-ServerProperties.ps1) -Force

        $JsonPath = Join-Path $MinecraftPath \payments\Pending 

        #Находим файл содержащий ник игрока
        $JsonPath = $JsonPath | Get-ChildItem | Where-Object { !$_.PSIsContainer } | Where-Object Name -Match "$Player-" 

        New-Variable -Name Payments -Value @()
        $JsonPath | Get-ChildItem | Where-Object { !$_.PSIsContainer } | Where-Object Name -Match "$Player-" | ForEach-Object {
            $Me = [Payment]::new() 
            $Me.File = $_.Name
            $Me.Payment = $_ | Get-Content | ConvertFrom-Json -ErrorVariable Errored

            $Payments += $me
        }
    }
    process {
        #Если файл был найден, выполняем процедуру зачисления
        if ($null -ne $Payments) {
            $Payments | ForEach-Object {
               
                #Составляем команду 
                $Command = '"' + "give " + $_.Payment.Player + " " + $_.Payment.Item + " " + $_.Payment.Quantity + '"'


                #Отправляем команду на сервер
                #Гитхаб автора mcrcon: 
                #https://github.com/Tiiffi/mcrcon
                if ($_.Payment.Completed -ne $true) {
                    Start-Process -FilePath (Join-Path $PathToModule mcrcon.exe) -ArgumentList "-H localhost -p $rconPassword  -w 1 $Command" -NoNewWindow
                    Write-Host $Command -ForegroundColor Green
                    Write-Host $rconPassword -BackgroundColor Green
                    #Экспортируем объект в джисонину
                    $_.Payment.Completed = $true
                    $_.Payment | ConvertTo-Json | Out-File (Join-Path $MinecraftPath \payments\Pending\ $_.File)
                }
                  
                #Перемещаем завершенный платеж в другую папку
                Move-Item -Path (Join-Path $MinecraftPath \payments\Pending\ $_.File)  -Destination (Join-Path $MinecraftPath \payments\Completed\) -Force
            }
        }
    }
  
}