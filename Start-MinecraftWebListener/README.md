# PSMinecraft

## PaypalModule

Аддон для Start-Minecraft для приема платежей через кнопки PayPal.


## Подготовка к использованию
1. Скачать и установить [Powershell 7](https://github.com/PowerShell/PowerShell/releases)

2. Переместить модули скриптов по пути:
```
 C:\Program Files\PowerShell\7\Modules\Ruvds\
```

3. Установить модули 
```Powershell
Install-Module "C:\Program Files\PowerShell\7\Modules\Ruvds\Start-Minecraft\Start-Minecraft.psd1"

Install-Module "C:\Program Files\PowerShell\7\Modules\Ruvds\Start-MinecraftWebListener\Start-MinecraftWebListener.psd1"
```

4. Включить rcon на сервере


# Как пользоваться

## Start-Minecraft

Запускает майнкрафт из указанной директории и перезапускает в случае сбоя.
```Powershell
Start-Minecraft
    [-Type] <String>
    [-MinecraftPath] <String>
    [-LogFile] <String>
    [-StartPaymentListener] <bool>
```

## Примеры
#### Пример 1: Запуск ванильного сервера
Скрит запустит сервер из файла Server.Jar и будет перезапускать его в случае если Excitcode не равен 0.
```Powershell
Start-Minecraft -Type Vanilla -MinecraftPath C:\minecraft\
````

#### Пример 2: Запуск сервера Forge
Сервер запустит сервер c самого нового файла forge.
```Powershell
Start-Minecraft -Type Forge -MinecraftPath C:\minecraft\
````

#### Пример 3: Запуск сервера Forge с премом платежей
Сервер запустит сервер c самого нового файла forge.
```Powershell
Start-Minecraft -Type Forge -MinecraftPath C:\mc.fern\ -StartPaymentListener
````

## Start-Weblistener

Запускает модуль приема платежей отдельно от сервера.

```Powershell
Start-Minecraft
    [-MinecraftPath] <String>
    [-StopToken] <String>
```

## Примеры
#### Пример 1
Скрипт будет искать файл config.ps1 в указанной папке, а так же создаст папку куда будет складывать проведенные платежи.
```Powershell
Start-Minecraft -Type Vanilla -MinecraftPath C:\minecraft\
````

## Благодарность

Большое спасибо Tiffi за [mcrcon](https://github.com/Tiiffi/mcrcon), без которого этого скрипта не было бы.