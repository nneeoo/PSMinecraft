# Start-Minecraft

The script checks logs and displays statistics and IP addresses of attackers depending on the specified parameters.
Automatically restart server after crash.


``` Powershell
Start-Minecraft
[[-LogFile] <string>]
[[-Type] <string>]
[[-MinecraftPath] <string>]
[-StartPaymentListener]
```     

# Description

List of parameters for **Start-Minecraft**:

* LogFile
* Type
* MinecraftPath
* StartPaymentListener

_LogFile_ provides alternative logging for minecraft STDOUD.

_Last_ Vanilla or Forge. Run latest executable of forge.

_MinecraftPath_ specifies from which folder to run server.

_StartPaymentListener_ run paypal listener for IPN notifications.


## Examples

#### Example 1: information Output
Just start minecraft.

``` Powershell
Start-Minecraft
````