function Start-Minecraft {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $LogFile,

        [Parameter(Mandatory)]  
        [ValidateSet('Vanilla', 'Forge')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Type,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $MinecraftPath,

        [switch]$StartPaymentListener
    )
    
    $StopToken = Get-Random
    Import-Module (Join-Path $MinecraftPath config.ps1) -Force
   
    "A", "B" | ForEach-Object -Parallel {
    
        switch ($_) {
            "A" {
                if ($using:StartPaymentListener) {
                    Start-MinecraftWebListener -StopToken $using:StopToken -MinecraftPath $using:MinecraftPath
                }
            }
            "B" {
                #Определяем саму регулярку. Тут мы ищем вход игрока в игру.
                $Regex = [Regex]::new("of player ([^ ]+)")

                if ($null -eq $LogFile) {
                    pwsh.exe -file "C:\Program Files\PowerShell\7\Modules\Ruvds\Start-Minecraft\Start-MinecraftHandler.ps1" -type $using:type -MinecraftPath $using:MinecraftPath -StopToken $using:StopToken | ForEach-Object {
                        Import-Module "C:\Program Files\PowerShell\7\Modules\Ruvds\Start-MinecraftWebListener\Complete-MinecraftPayment.ps1"
           
                        #Так как строка оказалась в конвейере,нам придется её писать таким вот образом.
                        Write-host $_   
                
                        #Класс Regex сам оповестит нас о срабатывании
                        if ($true -eq $Regex.Matches($_).Success) {
                            
                            #Удаляем все лишне и оставляем только ник игрока
                            $Player = $Regex.Matches($_).value -replace "of player "
                            
                            #Вызываем команду, которая найдет платеж и передаст игроку предмет
                            Complete-MinecraftPayment -Player $Player -MinecraftPath $using:MinecraftPath
                        }
                    }
                }
                else {
                    pwsh.exe -file "C:\Program Files\PowerShell\7\Modules\Ruvds\Start-Minecraft\Start-MinecraftHandler.ps1" -type $using:type -MinecraftPath $using:MinecraftPath -StopToken $using:StopToken | Tee-Object $using:LogFile -Append | ForEach-Object {
                        Import-Module "C:\Program Files\PowerShell\7\Modules\Ruvds\Start-MinecraftWebListener\Complete-MinecraftPayment.ps1"
           
                        #Так как строка оказалась в конвейере,нам придется её писать таким вот образом.
                        Write-host $_   
                
                        #Класс Regex сам оповестит нас о срабатывании
                        if ($true -eq $Regex.Matches($_).Success) {
                            
                            #Удаляем все лишне и оставляем только ник игрока
                            $Player = $Regex.Matches($_).value -replace "of player "
                            
                            #Вызываем команду, которая найдет платеж и передаст игроку предмет
                            Complete-MinecraftPayment -Player $Player -MinecraftPath $using:MinecraftPath
                        }
                    }
                }
            }
        }
    }
}

Export-ModuleMember -Function Start-Minecraft