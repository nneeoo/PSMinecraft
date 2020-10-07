function Start-Minecraft {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $LogFile,

        [ValidateSet('Vanilla', 'Forge')]
        [string]
        $Type = 'Vanilla',

        [string]
        $MinecraftPath = "C:\Minecraft\",

        [switch]$StartPaymentListener
    )
    begin {
        $StopToken = Get-Random
        $ServerPropertiesFIle = (Join-Path $MinecraftPath server.properties)
        Import-Module (Join-Path $MinecraftPath config.ps1) -Force

        [array]$MinecraftPort = @{}
        $MinecraftPort = Get-Content $ServerPropertiesFIle | ConvertFrom-StringData | Select-Object server-port | Where-Object {
            $_ -match '\d' 
        }
        $MinecraftPort = $MinecraftPort | Select-Object -First 1 -ExpandProperty server-port

        $MinecrafNetFirewallRule = (Get-NetFirewallRule -DisplayName "Minecraft" -ErrorAction SilentlyContinue).DisplayName
        if ($null -eq $MinecrafNetFirewallRule) {
            New-NetFirewallRule -DisplayName "Minecraft" -Action Allow -Direction Inbound -Enabled True -LocalPort $MinecraftPort -Protocol TCP
        }
        else {
            Set-NetFirewallRule -DisplayName "Minecraft" -Action Allow -Direction Inbound -Enabled True -LocalPort $MinecraftPort -Protocol TCP
        }

        (Get-Content $ServerPropertiesFIle) -replace "enable-rcon=false", "enable-rcon=true" | Out-File $ServerPropertiesFIle
    }
    process {
        "A", "B" | ForEach-Object -Parallel {
            $PathToModule = Split-Path (Get-Module -ListAvailable Start-Minecraft).path
            switch ($_) {
                "A" {
                    if ($using:StartPaymentListener) {
                        Start-MinecraftWebListener -StopToken $using:StopToken -MinecraftPath $using:MinecraftPath
                    }
                }
                "B" {
                    Import-Module (Join-Path $using:MinecraftPath config.ps1) -Force
                    #Определяем саму регулярку. Тут мы ищем вход игрока в игру.
                    $Regex = [Regex]::new($RegExp)
    
                    if ($null -eq $LogFile) {
                        pwsh.exe -file (Join-Path $PathToModule Start-MinecraftHandler.ps1 ) -type $using:type -MinecraftPath $using:MinecraftPath -StopToken $using:StopToken | ForEach-Object {
                            Import-Module (Join-Path $PathToModule Complete-MinecraftPayment.ps1)
               
                            #Так как строка оказалась в конвейере,нам придется её писать таким вот образом.
                            Write-Host $_   
                    
                            #Класс Regex сам оповестит нас о срабатывании
                            if ($true -eq $Regex.Matches($_).Success) {
                                
                                #Удаляем все лишне и оставляем только ник игрока
                                $Player = $Regex.Matches($_).value -replace $RegExpCut
                                
                                #Вызываем команду, которая найдет платеж и передаст игроку предмет
                                Complete-MinecraftPayment -Player $Player -MinecraftPath $using:MinecraftPath
                            }
                        }
                    }
                    else {
                        pwsh.exe -file (Join-Path $PathToModule Start-MinecraftHandler.ps1 ) -type $using:type -MinecraftPath $using:MinecraftPath -StopToken $using:StopToken | Tee-Object $using:LogFile -Append | ForEach-Object {
                            Import-Module (Join-Path $PathToModule Complete-MinecraftPayment.ps1)
               
                            #Так как строка оказалась в конвейере,нам придется её писать таким вот образом.
                            Write-Host $_   
                    
                            #Класс Regex сам оповестит нас о срабатывании
                            if ($true -eq $Regex.Matches($_).Success) {
                                
                                #Удаляем все лишне и оставляем только ник игрока
                                $Player = $Regex.Matches($_).value -replace $RegExpCut
                                
                                #Вызываем команду, которая найдет платеж и передаст игроку предмет
                                Complete-MinecraftPayment -Player $Player -MinecraftPath $using:MinecraftPath
                            }
                        }
                    }
                }
            }
        }
    }
}