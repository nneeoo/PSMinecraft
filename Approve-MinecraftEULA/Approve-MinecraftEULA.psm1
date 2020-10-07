function Accept-MinecraftEULA {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $MinecraftPath = "C:\Minecraft\",

        [switch]$StartPaymentListener
    )
  
    $StopToken = Get-Random
    Import-Module (Join-Path $MinecraftPath config.ps1) -Force
        
    $File = Join-Path $MinecraftPath eula.txt
    (Get-Content $File) -replace "false", "true" | Out-File $File
      
    
}