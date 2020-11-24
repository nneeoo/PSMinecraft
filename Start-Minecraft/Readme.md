# Start-Minecraft

The script start minecraft, check if minecraft is still running, give items from paypal IPN payments, automatically restart server after crash.


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

#### Example 1:
Just start minecraft. Latest version forge will be selected automatically, otherwise, start vanilla server.

``` Powershell
Start-Minecraft
````

#### Example 2: start server from forge

Start minecraft from latest version of forge file present in folder.

``` Powershell
Start-Minecraft -type Forge
````