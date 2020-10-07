function Approve-MinecraftEULA {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        [string]
        $MinecraftPath = "C:\Minecraft\"
    )
    $EULAfile = (Join-Path $MinecraftPath eula.txt)
    $Verb = (Get-Content $EULAfile -ErrorAction Stop) -split "\n"
    $Verb = $Verb[0].TrimStart('#')
    
    if ($PSCmdlet.ShouldProcess($EULAfile, $Verb, 'Approve-MinecraftEULA')) {

        (Get-Content $EULAfile) -replace "false", "true" | Out-File $EULAfile
        Write-Output ("Approved agreement on minecraft server EULA in ( " + $MinecraftPath + " ) folder")
    }
}