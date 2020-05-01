function Receive-MinecraftPayment {
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        $i
    )
    
    class Payment {
        #Дата прихода платежа.
        [datetime]$Date = [datetime]::ParseExact($i.payment_date, "HH:mm:ss MMM dd, yyyy PDT", [System.Globalization.CultureInfo]::InvariantCulture)
        #Приорбетенная вещь
        [string]$Item = $i.item_name
        #Количество вещей
        [UInt16]$Quantity = $i.Quantity
        #Какую сумму мы действительно получили
        [UInt16]$AmountPaid = $AmountPaid -as [UInt16]
        #В какой валюте был принят платеж
        [string]$Currency = $i.mc_currency
        #Никнейм игрока, который получит вещь
        [string]$Player = $i.option_selection1
    
        [bool]$Completed = $false
        [UInt16]$ItemId = $i.item_number
    }
    
    #Создаем новый объект по классу Payment, чтобы его легко можно было запихнуть в файл.
    $Payment = [Payment]::new()
    $Payment | Format-Table
    #Человекопонятно обзываем файл, в формате ЧЧ-ММ-ДД-ММ-ГГГГ
    $FileName = $Payment.Player + "-" + $Payment.date.Hour + "-" + $Payment.date.Minute + "-" + $Payment.date.Day + "-" + $Payment.date.Month + "-" + $Payment.date.Year + ".json"
    
    Write-Host "Payment Received!" -ForegroundColor Green
    Write-Host File: $FileName -ForegroundColor Green
    
    #Составляем путь, по которому наш объект будет экспортирован
    $JsonPath = Join-Path C:\mc.fern\payments\Pending -ChildPath $FileName
    
    #Экспортируем объект в джисонину
    $Payment | ConvertTo-Json | Out-File $JsonPath
}