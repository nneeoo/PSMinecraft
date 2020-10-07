$ServerPropertiesFIle = (Join-Path $MinecraftPath server.properties)
$RconPassword = Get-Content $ServerPropertiesFIle | ConvertFrom-StringData | Select-Object rcon.password | Where-Object {
    $_ -match '\d' 
}
$RconPassword = $RconPassword | Select-Object -First 1 -ExpandProperty rcon.password

$RconPort = Get-Content $ServerPropertiesFIle | ConvertFrom-StringData | Select-Object rcon.port | Where-Object {
    $_ -match '\d' 
}
$RconPort = $RconPort | Select-Object -First 1 -ExpandProperty rcon.port 
       