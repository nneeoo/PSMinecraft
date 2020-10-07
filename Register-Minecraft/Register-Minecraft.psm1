function Register-Minecraft {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]
        $LogFile,

        [Parameter(Mandatory)]  
        [ValidateSet('Vanilla', 'Forge')]
        [ValidateNotNullOrEmpty()]
        [string]$Type,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$MinecraftPath = 'C:\Minecraft',

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$User,

        [Parameter(Mandatory)]
        [string]$TaskName = $env:USERNAME
    )

    $Trigger = New-ScheduledTaskTrigger -AtLogOn
    $arguments = "Start-Minecraft -Type $Type -LogFile $LogFile -MinecraftPath $MinecraftPath"
    $PS = New-ScheduledTaskAction -Execute "PowerShell" -Argument "-noexit -command $arguments"
    Register-ScheduledTask -TaskName $TaskName -Trigger $Trigger -User $User -Action $PS -RunLevel Highest
    
}