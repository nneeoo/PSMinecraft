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
    
    Import-Module (Join-Path $MinecraftPath \config.ps1) -Force
    
    #Находим файл содержащий ник игрока
    $JsonPath = Join-Path $MinecraftPath \payments\Pending  $Player*
    $i = $JsonPath | Get-Item | Where-Object { !$_.PSIsContainer } | Get-Content | ConvertFrom-Json -ErrorVariable Errored

    #Если файл был найден, выполняем процедуру зачисления
    if ($null -ne $i) {

        #Составляем команду 
        $Command = '"' + "give " + $i.Player + " " + $i.Item + " " + $i.Quantity + '"'

    
        #Отправляем команду на сервер
        #Гитхаб автора mcrcon: 
        #https://github.com/Tiiffi/mcrcon
        Start-Process -FilePath "C:\Program Files\PowerShell\7\Modules\Ruvds\Start-MinecraftWebListener\mcrcon.exe" -ArgumentList "-H localhost -p $rconPassword  -w 1 $Command"
        Write-host $Command -ForegroundColor Green
        Write-Host $rconPassword -BackgroundColor Green
    
        #Экспортируем объект в джисонину
        $i | ConvertTo-Json | Out-File $JsonPath
    
        #Перемещаем завершенный платеж в другую папку
        Move-Item -Path $JsonPath -Destination (Join-Path $MinecraftPath \payments\Completed\) -Force
    }
}