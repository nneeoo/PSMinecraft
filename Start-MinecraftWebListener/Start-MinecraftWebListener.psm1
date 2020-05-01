function Start-MinecraftWebListener {
  [CmdletBinding()]
  param (
    [Parameter()]
    [String]
    $MinecraftPath,

    [string[]]
    $StopToken
  )

  Write-host "=================== Starting weblistener ================"
  Import-Module (Join-Path $MinecraftPath config.ps1) -Force
  Import-Module "C:\Program Files\PowerShell\7\Modules\Ruvds\Start-MinecraftWebListener\Receive-MinecraftPayment.ps1" -Force

  #Сначала нужно проверить, существует ли папка с платежами
  $FolderExists = Test-Path $MinecraftPath\payments -PathType Container

  #Если папка несуществует, создаем её и подпапки в ней
  if ($false -eq $FolderExists) {
    New-Item (Join-Path $MinecraftPath \Payments) -ItemType Directory
    New-Item (Join-Path $MinecraftPath \Payments\Pending) -ItemType Directory
    New-Item (Join-Path $MinecraftPath \Payments\Completed) -ItemType Directory
  }

  ##Запускаем лисенер
  $http = [System.Net.HttpListener]::new() 

  #Указываем домены, которые мы слушаем
  #А слушать мы будем домен указанный в config.ps1 и локальный хост
  $http.Prefixes.Add("http://localhost/")
  $http.Prefixes.Add("http://$DomainName/")
  $http.Prefixes.Add("https://$DomainName/")

  $http.Start()
  
  while ($http.IsListening) {
  
    $context = $http.GetContext()
  
    if ($context.Request.HttpMethod -eq 'POST' -and $context.Request.RawUrl -eq '/') {

      #Читаем содержимое POST запроса
      $Reader = [System.IO.StreamReader]::new($context.Request.InputStream).ReadToEnd()

      #Фиксим странные руны.
      $DecodedContent = [System.Web.HttpUtility]::UrlDecode($Reader)

      #Если нам прислали токен на остановку, то останавливаем листенер
      if ($DecodedContent -eq $StopToken) {
        Write-host "=================== Stopping weblistener ================"
        $context.Response.Headers.Add("Content-Type", "text/plain")
        $context.Response.StatusCode = 200
        $ResponseBuffer = [System.Text.Encoding]::UTF8.GetBytes("")
        $context.Response.ContentLength64 = $ResponseBuffer.Length
        $context.Response.OutputStream.Write($ResponseBuffer, 0, $ResponseBuffer.Length)
        $context.Response.Close()
        $http.Close()
        break
      }

      #Преобразуем вермишель из IPN в массив строк
      $Payment = $DecodedContent -split "&" | ConvertFrom-StringData

      #Конвертируем String в float и вычитаем комиссию из суммы, которую заплатил игрок
      $AmountPaid = $Payment.mc_gross - $Payment.mc_fee -as [float]

      #Передать массив таким образом, по неведомой причине не получилось, пришлось делать много отдельных переменных.
      Receive-MinecraftPayment -i $Payment

      #Отвечаем клиенту 200 OK и закрываем стрим.
      $context.Response.Headers.Add("Content-Type", "text/plain")
      $context.Response.StatusCode = 200
      $ResponseBuffer = [System.Text.Encoding]::UTF8.GetBytes("")
      $context.Response.ContentLength64 = $ResponseBuffer.Length
      $context.Response.OutputStream.Write($ResponseBuffer, 0, $ResponseBuffer.Length)
      $context.Response.Close()
    }
  }
}

Export-ModuleMember -Function Start-MinecraftWebListener