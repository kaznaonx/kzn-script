@echo off
title KznScript
setlocal EnableDelayedExpansion

call :Colors & call :StartMenu
set Page=MainMenuFirstPage & goto :CheckParameters

:CheckParameters
:: API
if exist "%systemroot%\DirectX.log" (set "API=!GR!Installed   ") else (set "API=!RED!Need Install") >nul 2>&1
:: Windows start menu
if exist "%systemroot%\SystemApps\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\StartMenuExperienceHost.exe" (set "SM=!GR!On ") else (set "SM=!RED!Off") >nul 2>&1
:: Search
if exist "%systemroot%\SystemApps\Microsoft.Windows.Search_cw5n1h2txyewy\searchapp.exe" (set "SRCH=!GR!On ") else (set "SRCH=!RED!Off") >nul 2>&1
:: Runtime Broker
if exist "%systemroot%\System32\RuntimeBroker.exe" (set "RB=!GR!On ") else (set "RB=!RED!Off") >nul 2>&1
:: OBS
if exist "%programfiles%\obs-studio" (set "OBS=!GR!Installed    ") else (set "OBS=!RED!Not Installed") >nul 2>&1
:: Lightshot
if exist "%programfiles(x86)%\Skillbrains\lightshot\Lightshot.exe" (set "LGHTSHT=!GR!Installed    ") else (set "LGHTSHT=!RED!Not Installed") >nul 2>&1
:: Disk optimization
set "DO=!Y!SSD" & (reg query "HKLM\SYSTEM\CurrentControlSet\Services\SysMain" /v "Start" | find "0x4" || set "DO=!Y!HDD") >nul 2>&1
:: AltTab
set "AT=!Y!10" & (reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "AltTabSettings" | find "0x0" || set "AT=!Y!7") >nul 2>&1
:: KeyboardDataQueueSize
for /f "tokens=2* delims=	 " %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize"') do set KDQS=%%j && set KDQSCON=!KDQS:~2!
:: MouseDataQueueSize
for /f "tokens=2* delims=	 " %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize"') do set MDQS=%%j && set MDQSCON=!MDQS:~2!
:: Win32PrioritySeparation
for /f "tokens=2* delims=	 " %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation"') do set W32=%%j && set WIN32=!W32:~2!
:: Nvidia driver
for /f "tokens=2 delims==" %%a in ('wmic path Win32_VideoController get VideoProcessor /value') do (for %%n in (GeForce NVIDIA RTX GTX) do echo %%a | find "%%n" >nul && set "GPU=!GR!Installed")
if "!GPU!" NEQ "!GR!Installed" set "GPU=!RED!Not Found"
for %%i in (HDCP PS) do (set "%%i=!GR!On ") & (
    ::HDCP
    for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /L "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\ControlSet001\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%i" /v "RMHdcpKeyglobZero" || set "HDCP=!RED!Off")))
    ::PState
    for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\ControlSet001\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%i" /v "DisableDynamicPstate" || set "PS=!RED!Off")))
) >nul 2>&1
for %%i in (SVC PT NPI NP WC NC TCP NETSH IAPT MMU CSRSS STRS) do (set "%%i=!GR!On ") & (
    :: SvcHostSplitThreshold
	for /f "tokens=2 delims==" %%i in ('wmic os get TotalVisibleMemorySize /value') do (set /a ram=%%i + 1024000)
    for /f "tokens=2* delims=	 " %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB"') do set /a regram=%%j
	if "!regram!" NEQ "!ram!" set "SVC=!RED!Off"
    :: PowerThrottling
    reg query "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" || set "PT=!RED!Off"
    :: Nvidia profile inspector
    reg query "HKCU\SOFTWARE\KZNScript" /v "NvidiaProfileInspector" || set "NPI=!RED!Off"
    :: Nvidia preemption
    reg query "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" || set "NP=!RED!Off"
    :: Write combining
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" || set "WC=!RED!Off"
    :: Network card
    reg query "HKCU\SOFTWARE\KZNScript" /v "NetworkCard" || set "NC=!RED!Off"
    :: TCP
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpMaxConnectRetransmissions" || set "TCP=!RED!Off"
    :: Netsh
    reg query "HKCU\SOFTWARE\KZNScript" /v "Netsh" || set "NETSH=!RED!Off"
    :: Interrupt affinity policy tool
    reg query "HKCU\SOFTWARE\KZNScript" /v "InterruptAffinity" || set "IAPT=!RED!Off"
    :: Msi mode utility
	for /f %%a in ('wmic path Win32_USBController get PNPDeviceID ^| findstr /L "VEN_"') do reg query "HKLM\System\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" || set "MMU=!RED!Off"
    :: CSRSS
    reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" || set "CSRSS=!RED!Off"
    :: Timer resolution
    bcdedit | find "disabledynamictick" || set "STRS=!RED!Off"
) >nul 2>&1
for %%i in (MS HAGS NVIDIA WU BLTH NK FRWL WIFI VPN HID MBIOS WSET DD TM) do (set "%%i=!RED!Off") & (
    :: Microsoft store
    reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\InstallService" /v "Start" | find "0x4" || set "MS=!GR!On "
    :: HAGS
    reg query "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" | find "0x1" || set "HAGS=!GR!On "
    :: Nvidia panel
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\NVDisplay.ContainerLocalSystem" || set "NVIDIA=!RED!Not Found"
    if "!NVIDIA!" NEQ "!RED!Not Found" reg query "HKLM\SYSTEM\CurrentControlSet\Services\NVDisplay.ContainerLocalSystem" /v "Start" | find "0x4" || set "NVIDIA=!GR!On "
    :: Windows update
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\wuauserv" /v "Start" | find "0x4" || set "WU=!GR!On "
    :: Bluetooth
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\bthserv" /v "Start" | find "0x4" || set "BLTH=!GR!On "
    :: Network
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\NcbService" /v "Start" | find "0x4" || set "NK=!GR!On "
    :: Firewall
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\mpssvc" /v "Start" | find "0x4" || set "FRWL=!GR!On "
    :: WiFi
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\WlanSvc" /v "Start" | find "0x4" || set "WIFI=!GR!On "
    :: VPN
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\RasMan" /v "Start" | find "0x4" || set "VPN=!GR!On "
    :: Human interface devices
    reg query "HKLM\System\CurrentControlSet\Services\hidserv" /v "Start" | find "0x4" || set "HID=!GR!On "
    :: Management bios
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\mssmbios" /v "Start" | find "0x4" || set "MBIOS=!GR!On "
    :: Windows settings
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\ahcache" /v "Start" | find "0x4" || set "WSET=!GR!On "
    :: Disk defragmentation
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\defragsvc" /v "Start" | find "0x4" || set "DD=!GR!On "
    :: Task manager
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\pcw" /v "Start" | find "0x4" || set "TM=!GR!On "
) >nul 2>&1
goto %Page%

:MainMenuFirstPage
title KznScript Page [1]
mode 142,46
echo.
echo.    !G!$.:k.:klk:.!R!                    .::....:::.                                            !S!Tweaks
echo.   !G!.knJzPkJnJYYJk\!R!            .:zKZNKZNKZNZ/:
echo.      !G!zkJzJ.   :kJYk\:!R!    .:/ZKn/.   :zZKz.     !S![!R!1!S!]!R! DiskOptimization !DO!        !S![!R!2!S!]!R! SvcHostSplitThreshold !SVC!    !S![!R!3!S!]!R! AltTab !AT!
echo.       !G!zzkkBYzklzKZNKzk!R!  :kzKzZnzKnnKZNzk/      !G!Disk optimization for           Change Svc Host Split            Personalization
echo.        !G!.knkKZNKZNkkkZzzk!R!kzJ:zKzKZNKzzk/        !G!specific type                   Threshold for service            Windows AltTab
echo.           !G!`````kJk. k?K!R!:Kn. :nnK````
echo.              !G!kNZn    kk !R!z.   .kKZ:             !S![!R!4!S!]!R! DisableThrottling !PT!       !S![!R!5!S!]!R! TimerResolution !STRS!          !S![!R!6!S!]!R! CSRSS !CSRSS!
echo.             !G!Nzk/     kN.!R!z.     kZNk            !G!Disable Power Throttling        Disable HPET and set             !G!Set Client/Server Runtime
echo.            !G!?zzN     :Zk !R!kZ     .KZN:           !G!Dont disable on laptop          timer to 0.5ms                   Subsystem High Priority
echo.            !G!KKZZ    nKZ: !R!kBY:   /KZNk
echo.            !G!KZkZ   nNkn   !R!JBP.  kKZN/           !S![!R!7!S!]!R! SearchApp !SRCH!               !S![!R!8!S!]!R! StartMenu !SM!                !S![!R!9!S!]!R! RuntimeBroker !RB!
echo.            !G!.ZNk  .Kkk     !R!nGk  .kNk            !G!Break search Windows            Break Windows start menu         !G!Break taskbar, network
echo.             !G!nKZNKZ:       !R!kKZNKZ/              !G!Start Menu                                                       icon and Windows start menu
echo.               !G!.kZk          !R!.KZ/
echo.                                                !S![!R!10!S!]!R! MicrosoftStore !MS!         !S![!R!11!S!]!R! InterruptAffinity !IAPT!       !S![!R!12!S!]!R! MsiMode !MMU!
echo.                                                !G!Delete Microsoft Store          !G!Bind CPU affinity interrupts     Enable message signaled
echo.                                                and Xbox                        Dont use on less 4 cores         interrupts priority
echo.       KZNScript is a free utility for
echo.       configuring KZNOS system. KZNScript      !S![!R!13!S!]!R! KeyboardDataQueueSize      !S![!R!14!S!]!R! MouseDataQueueSize          !S![!R!15!S!]!R! W32PrioritySeparation
echo.       !G!simplifies system configuration by       !G!Change the size of the          Change the size of the           Change value for
echo.       tweaking parameters to meet users        !G!keyboard data queue             mouse data queue                 Win32PrioritySeparation
echo.       specific needs.                          !R!Current Value !Y!!KDQSCON!               !R!Current Value !Y!!MDQSCON!                !R!Current Value !Y!!WIN32!
echo.
echo.       !G!Author: !W!!L!kazna2!R!                                                                  !DG!NvidiaTweaks
echo.       !G!discord.gg/emJ7ExzPht
echo.                                                !DG![!R!16!DG!]!R! NvidiaDriver !GPU!     !DG![!R!17!DG!]!R! NvidiaProfileInspector !NPI!  !DG![!R!18!DG!]!R! HAGS !HAGS!
echo.                                                !G!Install stripped Nvidia         Nvidia Control Panel settings    !G!Hardware-accelerated
echo.                                                driver without Geforce          to optimize performance          !G!GPU scheduling
echo.
echo.                                                !DG![!R!19!DG!]!R! NvidiaTelemetry            !DG![!R!20!DG!]!R! NvidiaPreemption !NP!        !DG![!R!21!DG!]!R! WriteCombining !WC!
echo.                                                !G!Remove Nvidia                   Disable Nvidia                   Disable write
echo.                                                !G!telemetry                       preemption                       combining
echo.
echo.               !G![!R!0!G!]!R! API !API!             !DG![!R!22!DG!]!R! DisablePState !PS!          !DG![!R!23!DG!]!R! DisableHDCP !HDCP!             !DG![!R!24!DG!]!R! ControlPanel !NVIDIA!
echo.               !G!Install DirectX                  !G!Disable Nvidia GPU Idle         Disable high-bandwidth           Disable Nvidia services
echo.               and VCRedist                     !G!state                           digital content protection       Break Nvidia Control Panel
echo.
echo.                                                                                       !B!NetworkTweaks
echo.
echo.                                                !B![!R!25!B!]!R! NetworkCard !NC!            !B![!R!26!B!]!R! TCP/IP !TCP!                  !B![!R!27!B!]!R! Netch !NETSH!
echo.       !DRED![!R!R!DRED!]!R! Reboot            !C![!R!P!C!]!R! Next page      !G!Optimize network settings       Optimize TCP/IP                  Optimize netch
echo.                                                !G!Dont use if using Wi-Fi         Dont use if using Wi-Fi          Dont use if using Wi-Fi

set /p menu=%del%             !R!Enter value to select:
if /i "!menu!" EQU "r" shutdown /r /f /t 3 /c "Rebooting..."
if /i "!menu!" EQU "p" set "Page=MainMenuSecondPage" & goto MainMenuSecondPage
for %%i in (
    "0=API"
    "1=DiskOptimization"
    "2=SvcHostSplitThreshold"
    "3=AltTab"
    "4=PowerThrottling"
    "5=TimerResolution"
    "6=CSRSS"
    "7=Search"
    "8=Menu"
    "9=RuntimeBroker"
    "10=MicrosoftStore"
    "11=InterruptAffinity"
    "12=MsiModeUtility"
    "13=KeyboardDataQueueSize"
    "14=MouseDataQueueSize"
    "15=Win32PrioritySeparation"
    "16=NvidiaDriver"
    "17=NvidiaProfileInspector"
    "18=HAGS"
    "19=NvidiaTelemetry"
    "20=NvidiaPreemption"
    "21=WriteCombining"
    "22=PState"
    "23=HDCP"
    "24=NvidiaPanel"
    "25=NetworkCard"
    "26=TCP"
    "27=Netsh"
) do for /f "tokens=1,2 delims==" %%a in ("%%~i") do (if "!menu!" EQU "%%~a" goto %%~b)
goto MainMenuFirstPage

:MainMenuSecondPage
title KznScript Page [2]
mode 142,46
echo.
echo.    !G!$.:k.:klk:.!R!                    .::....:::.                                           !Y!Services
echo.   !G!.knJzPkJnJYYJk\!R!            .:zKZNKZNKZNZ/:
echo.      !G!zkJzJ.   :kJYk\:!R!    .:/ZKn/.   :zZKz.     !S![!R!28!S!]!R! WindowsUpdate !WU!          !S![!R!29!S!]!R! Bluetooth !BLTH!               !G![30] Printing %RED%Stripped
echo.       !G!zzkkBYzklzKZNKzk!R!  :kzKzZnzKnnKZNzk/      !G!Break installing                Dont disable if using            Dont disable if using
echo.        !G!.knkKZNKZNkkkZzzk!R!kzJ:zKzKZNKzzk/        !G!languages                       bluetooth                        printing
echo.           !G!`````kJk. k?K!R!:Kn. :nnK````
echo.              !G!kNZn    kk !R!z.   .kKZ:             !S![!R!31!S!]!R! VPN !VPN!                    !S![!R!32!S!]!R! Firewall !FRWL!                !S![!R!33!S!]!R! Wi-Fi !WIFI!
echo.             !G!Nzk/     kN.!R!z.     kZNk            !G!Break virtual                   Break firewall, VPN              Dont disable if using
echo.            !G!?zzN     :Zk !R!kZ     .KZN:           !G!private network                 and microsoft store              Wi-Fi
echo.            !G!KKZZ    nKZ: !R!kBY:   /KZNk
echo.            !G!KZkZ   nNkn   !R!JBP.  kKZN/           !S![!R!34!S!]!R! Network !NK!                !S![!R!35!S!]!R! HumanInterfaceDevices !HID!   !S![!R!36!S!]!R! ManagementBios !MBIOS!
echo.            !G!.ZNk  .Kkk     !R!nGk  .kNk            !G!Break network icon              Break scrollbar sound            Break Grand Theft
echo.             !G!nKZNKZ:       !R!kKZNKZ/              !G!and Epic Games                  menu                             Auto V
echo.               !G!.kZk          !R!.KZ/
echo.                                                !S![!R!37!S!]!R! WindowsSettings !WSET!        !S![!R!38!S!]!R! DiskDefragmentation !DD!     !S![!R!39!S!]!R! TaskManager !TM!
echo.                                                !G!Break Windows settings          Break shrink volume in           Break Task Manager
echo.                                                                                Disk Management
echo.       KZNScript is a free utility for
echo.       configuring KZNOS system. KZNScript                                                 !M!Apps
echo.       !G!simplifies system configuration by
echo.       tweaking parameters to meet users        !M![!R!40!M!]!R! OBS !OBS!          !M![!R!41!M!]!R! Lightshot !LGHTSHT!     !M![!R!42!M!]!R! Autoruns
echo.       !G!specific needs.                          Setting OBS Studio              Install screen capture tool      Process and service
echo.                                                Use after install OBS           Replace Win+Shift+S              management
echo.       !G!Author: !W!!L!kazna2!R!
echo.       !G!discord.gg/emJ7ExzPht                    !M![!R!43!M!]!R! Office
echo.                                                !G!Install office
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.       !DRED![!R!R!DRED!]!R! Reboot            !C![!R!P!C!]!R! Next page
echo.

set /p menu=%del%             !R!Enter value to select:
if /i "!menu!" EQU "r" shutdown /r /f /t 3 /c "Rebooting..."
if /i "!menu!" EQU "p" set "Page=MainMenuFirstPage" & goto MainMenuFirstPage
for %%i in (
    "28=WindowsUpdate"
    "29=Bluetooth"
    "30=Printing"
    "31=VPN"
    "32=Firewall"
    "33=WIFI"
    "34=Network"
    "35=HumanInterfaceDevices"
    "36=ManagementBios"
    "37=WindowsSettings"
    "38=DiskDefragmentation"
    "39=TaskManager"
    "40=OBS"
    "41=Lightshot"
    "42=Autoruns"
    "43=Office"
) do for /f "tokens=1,2 delims==" %%a in ("%%~i") do (if "!menu!" EQU "%%~a" goto %%~b)
goto MainMenuSecondPage

:API
:: Installing DirectX
curl -g -L -# -o "%systemroot%\Files\directx_Jun2010_redist.exe" "https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe"
"%systemdrive%\Program Files\7-Zip\7z.exe" x -y -o"%systemroot%\Files\DirectX" "%systemroot%\Files\directx_Jun2010_redist.exe" >nul 2>&1 && %systemroot%\Files\DirectX\DXSETUP.exe /silent >nul 2>&1
:: Removing files DirectX
del /f /q "%systemroot%\Files\directx_Jun2010_redist.exe" >nul 2>&1 & rd /s /q "%systemroot%\Files\DirectX" >nul 2>&1
:: Installing VCRedist
curl -g -L -# -o "%systemroot%\Files\VisualCppRedist_AIO_x86_x64_73.zip" "https://github.com/abbodi1406/vcredist/releases/download/v0.73.0/VisualCppRedist_AIO_x86_x64_73.zip"
powershell -NoProfile Expand-Archive "%systemroot%\Files\VisualCppRedist_AIO_x86_x64_73.zip" -DestinationPath '%systemroot%\Files\' >nul 2>&1 && %systemroot%\Files\VisualCppRedist_AIO_x86_x64.exe /ai /gm2
:: Removing files VCRedist
del /f /q "%systemroot%\Files\VisualCppRedist_AIO_x86_x64_73.zip" >nul 2>&1 "%systemroot%\Files\VisualCppRedist_AIO_x86_x64.exe" >nul 2>&1
goto CheckParameters

:DiskOptimization
if "!DO!" EQU "!Y!SSD" (
    :: HDD Optimization
    for %%a in (FontCache SysMain) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "2" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\FontCache3.0.0.0" /v "Start" /t REG_DWORD /d "3" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d "3" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "DisableDeleteNotification" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
    :: SSD Optimization
    for %%a in (FontCache SysMain FontCache3.0.0.0) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d "0" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "DisableDeleteNotification" /t REG_DWORD /d "0" /f
) >nul 2>&1
goto CheckParameters

:SvcHostSplitThreshold
for /f "tokens=2 delims==" %%i in ('wmic os get TotalVisibleMemorySize /value') do set /a ram=%%i + 1024000
if "!SVC!" EQU "!RED!Off" (
    :: Custom value
    reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d %ram% /f
) >nul 2>&1 else (
    :: Revert to default
    reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d "3670016" /f
) >nul 2>&1
goto CheckParameters

:AltTab
if "!AT!" EQU "!Y!10" (
    :: Windows 7 AltTab
    taskkill /f /im explorer.exe
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "AltTabSettings" /t REG_DWORD /d "1" /f
    start explorer.exe
) >nul 2>&1 else (
    :: Windows 10 AltTab
    taskkill /f /im explorer.exe
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "AltTabSettings" /t REG_DWORD /d "0" /f
    start explorer.exe
) >nul 2>&1
goto CheckParameters

:PowerThrottling
if "!PT!" EQU "!RED!Off" (
    :: Disable Power Throttling
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
   :: Revert to default
    reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /f
) >nul 2>&1
goto CheckParameters

:TimerResolution
if "!STRS!" EQU "!RED!Off" (
    :: Disable HPET devmgmt
    DevManView /disable "High precision event timer"
    :: Installing Timer Resolution
    curl -g -L -# -o "%systemroot%\SetTimerResolutionService.exe" "https://github.com/kaznaonx/kzn-script/releases/download/Files/SetTimerResolutionService.exe"
    SetTimerResolutionService -install
    sc config "STR" start=auto
    start /b net start STR
    :: Set bcdedit
    bcdedit /set useplatformtick Yes
    bcdedit /set disabledynamictick Yes
) >nul 2>&1 else (
    :: Enable HPET devmgmt
    DevManView /enable "High precision event timer
    :: Removing Timer Resolution
    sc config "STR" start=disabled
	start /b net stop STR
    del /f /q "%systemroot%\SetTimerResolutionService.exe"
    :: Remove bcdedit
    bcdedit /deletevalue disabledynamictick
    bcdedit /deletevalue useplatformtick
) >nul 2>&1
goto CheckParameters

:CSRSS
if "!CSRSS!" EQU "!RED!Off" (
    :: Enable CSRSS High Priority
    for %%a in (CpuPriorityClass IoPriority) do reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe\PerfOptions" /v "%%a" /t REG_DWORD /d "3" /f
) >nul 2>&1 else (
    :: Revert to default
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\csrss.exe" /f
) >nul 2>&1
goto CheckParameters

:Search
if "!SRCH!" EQU "!RED!Off" (
    :: Enable search
    taskkill /f /im explorer.exe && taskkill /f /im searchapp.exe
    cd %systemroot%\SystemApps\Microsoft.Windows.Search_cw5n1h2txyewy && takeown /f "searchapp.exe"
    icacls "%systemroot%\SystemApps\Microsoft.Windows.Search_cw5n1h2txyewy\searchapp.exe" /grant Administrators:F
    ren searchapp.old searchapp.exe
    start explorer.exe
) >nul 2>&1 else (
    :: Disable search
    taskkill /f /im explorer.exe && taskkill /f /im searchapp.exe
    cd %systemroot%\SystemApps\Microsoft.Windows.Search_cw5n1h2txyewy && takeown /f "searchapp.exe"
    icacls "%systemroot%\SystemApps\Microsoft.Windows.Search_cw5n1h2txyewy\searchapp.exe" /grant Administrators:F
    ren searchapp.exe searchapp.old
    start explorer.exe
) >nul 2>&1
goto CheckParameters

:Menu
if "!SM!" EQU "!RED!Off" (
    :: Enable start menu
    taskkill /f /im explorer.exe
    cd %systemroot%\SystemApps\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy && takeown /f "StartMenuExperienceHost.old"
    icacls "%systemroot%\SystemApps\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\StartMenuExperienceHost.old" /grant Administrators:F
    ren StartMenuExperienceHost.old StartMenuExperienceHost.exe
    start explorer.exe && start StartMenuExperienceHost.exe
) >nul 2>&1 else (
    :: Disable start menu
    taskkill /f /im explorer.exe && taskkill /f /im StartMenuExperienceHost.exe
    cd %systemroot%\SystemApps\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy && takeown /f "StartMenuExperienceHost.exe"
    icacls "%systemroot%\SystemApps\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\StartMenuExperienceHost.exe" /grant Administrators:F
    ren StartMenuExperienceHost.exe StartMenuExperienceHost.old
    start explorer.exe
) >nul 2>&1
goto CheckParameters

:RuntimeBroker
if "!RB!" EQU "!RED!Off" (
    :: Enable runtime broker
    taskkill /f /im explorer.exe
    cd %systemroot%\System32 && takeown /f "runtimebroker.old"
    icacls "%systemroot%\System32\RuntimeBroker.old" /grant Administrators:F
    ren runtimebroker.old runtimebroker.exe
    start explorer.exe && start runtimebroker.exe
) >nul 2>&1 else (
    :: Disable runtime broker
    taskkill /f /im explorer.exe && taskkill /f /im runtimebroker.exe
    cd %systemroot%\System32 && takeown /f "runtimebroker.exe"
    icacls "%systemroot%\System32\RuntimeBroker.exe" /grant Administrators:F
    ren runtimebroker.exe runtimebroker.old
    start explorer.exe
) >nul 2>&1
goto CheckParameters

:MicrosoftStore
if "!MS!" EQU "!RED!Off" (
    :: Enable services
    for %%a in (InstallService wlidsvc AppXSvc TokenBroker LicenseManager ClipSVC WinHttpAutoProxySvc Appinfo XblAuthManager XblGameSave xboxgip XboxGipSvc XboxNetApiSvc xinputhid) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "3" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\FileInfo" /v "Start" /t REG_DWORD /d "0" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\FileCrypt" /v "Start" /t REG_DWORD /d "1" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\StorSvc" /v "Start" /t REG_DWORD /d "2" /f
    :: Revert Microsoft Store
    PowerShell.exe -Command "Get-AppxPackage *WindowsStore* -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register ""$($_.InstallLocation)\AppxManifest.xml\"}"
    :: Revert Xbox
    PowerShell.exe -Command "Get-AppxPackage *XboxApp* -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register ""$($_.InstallLocation)\AppxManifest.xml\"}"
) >nul 2>&1 else (
    :: Disable services
    for %%a in (InstallService wlidsvc AppXSvc TokenBroker LicenseManager ClipSVC FileInfo FileCrypt StorSvc WinHttpAutoProxySvc Appinfo XblAuthManager XblGameSave xboxgip XboxGipSvc XboxNetApiSvc xinputhid) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
    :: Remove Microsoft Store
    PowerShell.exe -Command "Get-AppxPackage *WindowsStore* | Remove-AppxPackage"
    :: Remove Xbox
    PowerShell.exe -Command "Get-AppxPackage *XboxApp* | Remove-AppxPackage"
) >nul 2>&1
goto CheckParameters

:InterruptAffinity
if "!IAPT!" EQU "!RED!Off" (
    for /f "tokens=*" %%a in ('wmic cpu get NumberOfCores /value ^| find "="') do set %%a
    for /f "tokens=*" %%a in ('wmic cpu get NumberOfLogicalProcessors /value ^| find "="') do set %%a
    :: Check parameters
    reg add "HKCU\SOFTWARE\KZNScript" /v "InterruptAffinity" /f >nul 2>&1
    if !NumberOfLogicalProcessors! GTR !NumberOfCores! (
        :: MT
        for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "30" /f
        for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
    ) else (
        :: Not MT
        for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "04" /f
        for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f)
) >nul 2>&1 else (
    :: Revert to default
    for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f
    for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /f
    :: Check parameters
    reg delete "HKCU\SOFTWARE\KZNScript" /v "InterruptAffinity" /f >nul 2>&1
) >nul 2>&1
goto CheckParameters

:MsiModeUtility
if "!MMU!" EQU "!RED!Off" (
    :: High Priority
    for /f %%a in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /t REG_DWORD /d "3" /f
    for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /t REG_DWORD /d "3" /f
) >nul 2>&1 else (
    :: Revert to default
    for /f %%a in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "VEN_"') do reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
    for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
) >nul 2>&1
goto CheckParameters

:KeyboardDataQueueSize
title KznScript KeyboardDataQueueSize
mode 49,18
cls
echo.
echo.    !G!$.:k.:klk:.!R!                    .::....:::.
echo.   !G!.knJzPkJnJYYJk\!R!            .:zKZNKZNKZNZ/:
echo.      !G!zkJzJ.   :kJYk\:!R!    .:/ZKn/.   :zZKz.
echo.       !G!zzkkBYzklzKZNKzk!R!  :kzKzZnzKnnKZNzk/
echo.        !G!.knkKZNKZNkkkZzzk!R!kzJ:zKzKZNKzzk/
echo.           !G!`````kJk. k?K!R!:Kn. :nnK````
echo.              !G!kNZn    kk !R!z.   .kKZ:
echo.             !G!Nzk/     kN.!R!z.     kZNk
echo.            !G!?zzN     :Zk !R!kZ     .KZN:
echo.            !G!KKZZ    nKZ: !R!kBY:   /KZNk
echo.            !G!KZkZ   nNkn   !R!JBP.  kKZN/
echo.            !G!.ZNk  .Kkk     !R!nGk  .kNk
echo.             !G!nKZNKZ:       !R!kKZNKZ/
echo.               !G!.kZk          !R!.KZ/
echo.

:: Input
set /p KeyboardDataQueueSize=%del%              !W!Enter value in !M!HEX!R!:
set KeyboardDataQueueSize=%KeyboardDataQueueSize: =%
:: Convert Dec to Hex
for /f %%a in ('powershell -command [uint32]'0x%KeyboardDataQueueSize%'') do set KeyboardDataQueueSizeConvert=%%a
reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d "%KeyboardDataQueueSizeConvert%" /f >nul 2>&1
call :StartMenu
goto CheckParameters

:MouseDataQueueSize
title KznScript MouseDataQueueSize
mode 49,18
cls
echo.
echo.    !G!$.:k.:klk:.!R!                    .::....:::.
echo.   !G!.knJzPkJnJYYJk\!R!            .:zKZNKZNKZNZ/:
echo.      !G!zkJzJ.   :kJYk\:!R!    .:/ZKn/.   :zZKz.
echo.       !G!zzkkBYzklzKZNKzk!R!  :kzKzZnzKnnKZNzk/
echo.        !G!.knkKZNKZNkkkZzzk!R!kzJ:zKzKZNKzzk/
echo.           !G!`````kJk. k?K!R!:Kn. :nnK````
echo.              !G!kNZn    kk !R!z.   .kKZ:
echo.             !G!Nzk/     kN.!R!z.     kZNk
echo.            !G!?zzN     :Zk !R!kZ     .KZN:
echo.            !G!KKZZ    nKZ: !R!kBY:   /KZNk
echo.            !G!KZkZ   nNkn   !R!JBP.  kKZN/
echo.            !G!.ZNk  .Kkk     !R!nGk  .kNk
echo.             !G!nKZNKZ:       !R!kKZNKZ/
echo.               !G!.kZk          !R!.KZ/
echo.

:: Input
set /p MouseDataQueueSize=%del%              !W!Enter value in !M!HEX!R!:
set MouseDataQueueSize=%MouseDataQueueSize: =%
:: Convert Dec to Hex
for /f %%a in ('powershell -command [uint32]'0x%MouseDataQueueSize%'') do set MouseDataQueueSizeConvert=%%a
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d "%MouseDataQueueSizeConvert%" /f >nul 2>&1
call :StartMenu
goto CheckParameters

:Win32PrioritySeparation
title KznScript Win32PrioritySeparation
mode 49,18
cls
echo.
echo.    !G!$.:k.:klk:.!R!                    .::....:::.
echo.   !G!.knJzPkJnJYYJk\!R!            .:zKZNKZNKZNZ/:
echo.      !G!zkJzJ.   :kJYk\:!R!    .:/ZKn/.   :zZKz.
echo.       !G!zzkkBYzklzKZNKzk!R!  :kzKzZnzKnnKZNzk/
echo.        !G!.knkKZNKZNkkkZzzk!R!kzJ:zKzKZNKzzk/
echo.           !G!`````kJk. k?K!R!:Kn. :nnK````
echo.              !G!kNZn    kk !R!z.   .kKZ:
echo.             !G!Nzk/     kN.!R!z.     kZNk
echo.            !G!?zzN     :Zk !R!kZ     .KZN:
echo.            !G!KKZZ    nKZ: !R!kBY:   /KZNk
echo.            !G!KZkZ   nNkn   !R!JBP.  kKZN/
echo.            !G!.ZNk  .Kkk     !R!nGk  .kNk
echo.             !G!nKZNKZ:       !R!kKZNKZ/
echo.               !G!.kZk          !R!.KZ/
echo.

:: Input
set /p Win32PrioritySeparation=%del%              !W!Enter value in !M!HEX!R!:
set Win32PrioritySeparation=%Win32PrioritySeparation: =%
:: Convert Dec to Hex
for /f %%a in ('powershell -command [uint32]'0x%Win32PrioritySeparation%'') do set Win32PrioritySeparationConvert=%%a
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "%Win32PrioritySeparationConvert%" /f >nul 2>&1
call :StartMenu
goto CheckParameters

:NvidiaDriver
:: Installing Nvidia Driver
curl -g -L -# -o "%systemroot%\Files\NVIDIA.exe" "https://github.com/kaznaonx/kzn-script/releases/download/Files/NvidiaDriver.exe"
"%systemdrive%\Program Files\7-Zip\7z.exe" x -y -o"%systemroot%\Files\Nvidia" "%systemroot%\Files\NVIDIA.exe" >nul 2>&1 && %systemroot%\Files\Nvidia\setup.exe /s
:: Removing files
del /f /q "%systemroot%\Files\NVIDIA.exe" >nul 2>&1 & rd /s /q "%systemroot%\Files\Nvidia" >nul 2>&1
goto CheckParameters

:NvidiaProfileInspector
if "!NPI!" EQU "!RED!Off" (
    :: Installing Nvidia Profile Inspector
    curl -g -L -# -o "%systemroot%\Files\nvidiaProfileInspector.zip" "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/download/2.4.0.4/nvidiaProfileInspector.zip"
    powershell -NoProfile Expand-Archive "%systemroot%\Files\nvidiaProfileInspector.zip" -DestinationPath '%systemroot%\Files'
    :: Installing Custom Profile
    curl -g -L -# -o "%systemroot%\Files\CustomProfile.nip" "https://github.com/kaznaonx/kzn-script/releases/download/Files/CustomProfile.nip"
    cd "%systemroot%\Files" && nvidiaProfileInspector.exe "CustomProfile.nip"
    :: Removing files
    del /f /q "%systemroot%\Files\nvidiaProfileInspector.exe.config" "%systemroot%\Files\nvidiaProfileInspector.zip" "%systemroot%\Files\Reference.xml" "%systemroot%\Files\nvidiaProfileInspector.exe" "%systemroot%\Files\CustomProfile.nip"
    :: Check Parameters
    reg add "HKCU\SOFTWARE\KZNScript" /v "NvidiaProfileInspector" /f
) >nul 2>&1 else (
    :: Installing NvidiaProfileInspector
    curl -g -L -# -o "%systemroot%\Files\nvidiaProfileInspector.zip" "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/download/2.4.0.4/nvidiaProfileInspector.zip"
    powershell -NoProfile Expand-Archive "%systemroot%\Files\nvidiaProfileInspector.zip" -DestinationPath '%systemroot%\Files'
    :: Installing CustomProfile
    curl -g -L -# -o "%systemroot%\Files\BaseProfile.nip" "https://github.com/kaznaonx/kzn-script/releases/download/Files/BaseProfile.nip"
    cd "%systemroot%\Files" && nvidiaProfileInspector.exe "BaseProfile.nip"
    :: Removing files
    del /f /q "%systemroot%\Files\nvidiaProfileInspector.exe.config" "%systemroot%\Files\nvidiaProfileInspector.zip" "%systemroot%\Files\Reference.xml" "%systemroot%\Files\nvidiaProfileInspector.exe" "%systemroot%\Files\BaseProfile.nip"
    :: Check Parameters
    reg delete "HKCU\SOFTWARE\KZNScript" /v "NvidiaProfileInspector" /f
) >nul 2>&1
goto CheckParameters

:HAGS
if "!HAGS!" EQU "!RED!Off" (
    :: Enable Hardware-accelerated Gpu Scheduling
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f
) >nul 2>&1 else (
    :: Disable Hardware-accelerated Gpu Scheduling
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "1" /f
) >nul 2>&1
goto CheckParameters

:NvidiaTelemetry
rmdir /s /q "%systemroot%\System32\drivers\NVIDIA Corporation" >nul 2>&1
cd /d "%systemroot%\System32\DriverStore\FileRepository\" >nul 2>&1
dir NvTelemetry64.dll /a /b /s >nul 2>&1 && del NvTelemetry64.dll /a /s >nul 2>&1
goto CheckParameters

:NvidiaPreemption
if "!NP!" EQU "!RED!Off" (
    :: Enable Nvidia Preemption
    for %%x in (
        "EnableMidGfxPreemption=0"
        "EnableMidGfxPreemptionVGPU=0"
        "EnableMidBufferPreemptionForHighTdrTimeout=0"
        "EnableMidBufferPreemption=0"
        "EnableAsyncMidBufferPreemption=0"
        "EnableCEPreemption=0"
        "ComputePreemption=0"
        "DisablePreemption=1"
        "DisableCudaContextPreemption=1"
        "DisablePreemptionOnS3S4=1"
    ) do (for /f "tokens=1,2 delims==" %%a in ("%%~x") do (reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v %%a /t REG_DWORD /d %%b /f))
    for %%a in ("HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" "HKLM\SOFTWARE\NVIDIA Corporation\Global\NVTweak") do reg add %%a /v "DisplayPowerSaving" /t REG_DWORD /d "0" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t REG_DWORD /d "0" /f
) >nul 2>&1 else (
    :: Revert to default
    for %%a in (
        "EnableMidGfxPreemption"
        "EnableMidGfxPreemptionVGPU"
        "EnableMidBufferPreemptionForHighTdrTimeout"
        "EnableMidBufferPreemption"
        "EnableAsyncMidBufferPreemption"
        "EnableCEPreemption"
        "ComputePreemption"
        "DisablePreemption"
        "DisableCudaContextPreemption"
        "DisablePreemptionOnS3S4"
    ) do reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v %%a /f
    for %%a in ("HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" "HKLM\SOFTWARE\NVIDIA Corporation\Global\NVTweak") do reg delete %%a /v "DisplayPowerSaving" /f
    reg delete "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /f
) >nul 2>&1
goto CheckParameters

:WriteCombining
if "!WC!" EQU "!RED!Off" (
    :: Disable Write Combining
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
   :: Revert to default
    reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" /f
) >nul 2>&1
goto CheckParameters

:PState
if "!PS!" EQU "!RED!Off" (
    :: Disable PState
    for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\ControlSet001\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%i" /v "DisableDynamicPstate" /t REG_DWORD /d "1" /f)))
) >nul 2>&1 else (
    :: Revert to default
    for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /l "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\ControlSet001\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%i" /v "DisableDynamicPstate" /f)))
) >nul 2>&1
goto CheckParameters

:HDCP
if "!HDCP!" EQU "!RED!Off" (
    :: Disable HDCP
    for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /L "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\ControlSet001\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%i" /v "RMHdcpKeyglobZero" /t REG_DWORD /d "1" /f)))
) >nul 2>&1 else (
    :: Revert to default
    for /f %%i in ('wmic path Win32_VideoController get PNPDeviceID^| findstr /L "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\ControlSet001\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%i" /v "RMHdcpKeyglobZero" /f)))
) >nul 2>&1
goto CheckParameters

:NvidiaPanel
if "!NVIDIA!" EQU "!RED!Off" (
    :: Enable Nvidia Control Panel
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\NVDisplay.ContainerLocalSystem" /v "Start" /t REG_DWORD /d "2" /f
) >nul 2>&1 else (
    :: Disable Nvidia Control Panel
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\NVDisplay.ContainerLocalSystem" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckParameters

:NetworkCard
if "!NC!" EQU "!RED!Off" (
    :: Setting Network Card
    for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (
                for %%a in (PowerSavingMode FlowControl UDPChecksumOffloadIPv6 UDPChecksumOffloadIPv4 TCPChecksumOffloadIPv4 TCPChecksumOffloadIPv6 PriorityVLANTag IPChecksumOffloadIPv4 PMARPOffload PMNSOffload LsoV2IPv4 LsoV2IPv6 WakeOnMagicPacket WakeOnPattern) do (
                    for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%i" /s /f "*%%a" ^| findstr "HKEY"') do reg add "%%b" /v "*%%a" /t REG_SZ /d "0" /f))))

    for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (
                for %%a in (EnablePME EEELinkAdvertisement ULPMode ReduceSpeedOnPowerDown WaitAutoNegComplete WakeOnLink) do (
                    for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%i" /s /f "%%a" ^| findstr "HKEY"') do reg add "%%b" /v "%%a" /t REG_SZ /d "0" /f))))

    for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (
                for %%a in (LogLinkStateEvent) do (
                    for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%i" /s /f "%%a" ^| findstr "HKEY"') do reg add "%%b" /v "%%a" /t REG_SZ /d "16" /f))))
    :: Check parameters
    reg add "HKCU\SOFTWARE\KZNScript" /v "NetworkCard" /f
) >nul 2>&1 else (
    :: Revert to default
    for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (
                for %%a in (PMARPOffload PMNSOffload LsoV2IPv4 LsoV2IPv6 WakeOnMagicPacket WakeOnPattern) do (
                    for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%i" /s /f "*%%a" ^| findstr "HKEY"') do reg add "%%b" /v "*%%a" /t REG_SZ /d "1" /f))))

    for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (
                for %%a in (EnablePME EEELinkAdvertisement ULPMode ReduceSpeedOnPowerDown WaitAutoNegComplete) do (
                    for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%i" /s /f "%%a" ^| findstr "HKEY"') do reg add "%%b" /v "%%a" /t REG_SZ /d "1" /f))))

    for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (
                for %%a in (FlowControl IPChecksumOffloadIPv4 PriorityVLANTag UDPChecksumOffloadIPv6 UDPChecksumOffloadIPv4 TCPChecksumOffloadIPv4 TCPChecksumOffloadIPv6) do (
                    for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%i" /s /f "*%%a" ^| findstr "HKEY"') do reg add "%%b" /v "*%%a" /t REG_SZ /d "3" /f))))

    for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (
                for %%a in (LogLinkStateEvent) do (
                    for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%i" /s /f "%%a" ^| findstr "HKEY"') do reg add "%%b" /v "%%a" /t REG_SZ /d "51" /f))))
    :: Check parameters
    reg delete "HKCU\SOFTWARE\KZNScript" /v "NetworkCard" /f
) >nul 2>&1
goto CheckParameters

:TCP
if "!TCP!" EQU "!RED!Off" (
    :: Setting TCP
    for %%x in ("EnablePMTUDiscovery=1" "TcpMaxConnectRetransmissions=1" "Tcp1323Opts=1" "IGMPLevel=0" "DefaultTTL=64" "MaxUserPort=65534" "TcpTimedWaitDelay=32") do (
        for /f "tokens=1,2 delims==" %%a in ("%%~x") do (reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v %%a /t REG_DWORD /d %%b /f))
    for /f %%i in ('wmic path Win32_NetworkAdapter get GUID ^| findstr "{"') do reg add "HKLM\System\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%i" /v "TcpAckFrequency" /t REG_DWORD /d "1" /f
    for /f %%i in ('wmic path Win32_NetworkAdapter get GUID ^| findstr "{"') do reg add "HKLM\System\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%i" /v "TcpDelAckTicks" /t REG_DWORD /d "0" /f
    for /f %%i in ('wmic path Win32_NetworkAdapter get GUID ^| findstr "{"') do reg add "HKLM\System\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%i" /v "TCPNoDelay" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
    :: Revert to default
    for %%a in (DefaultTTL EnablePMTUDiscovery IGMPLevel MaxUserPort TcpTimedWaitDelay TcpMaxConnectRetransmissions Tcp1323Opts) do reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "%%a" /f
    for /f %%i in ('wmic path Win32_NetworkAdapter get GUID ^| findstr "{"') do reg delete "HKLM\System\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%i" /v "TcpAckFrequency" /f
    for /f %%i in ('wmic path Win32_NetworkAdapter get GUID ^| findstr "{"') do reg delete "HKLM\System\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%i" /v "TcpDelAckTicks" /f
    for /f %%i in ('wmic path Win32_NetworkAdapter get GUID ^| findstr "{"') do reg delete "HKLM\System\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%i" /v "TCPNoDelay" /f
) >nul 2>&1
goto CheckParameters

:Netsh
if "!NETSH!" EQU "!RED!Off" (
    :: Setting netsh
    netsh int ip set global dhcpmediasense=disabled
    netsh int ip set global neighborcachelimit=4096
    netsh int ip set global routecachelimit=4096
    netsh int ip set global mediasenseeventlog=disabled
    netsh int ip set global mldlevel=none
    netsh int tcp set global dca=enabled
    netsh int tcp set global netdma=disabled
    netsh int tcp set global rsc=disabled
    netsh int tcp set global maxsynretransmissions=2
    netsh int tcp set global timestamps=disabled
    netsh int tcp set global ecncapability=disabled
    netsh int tcp set heuristics disabled
    netsh int tcp set heuristics wsh=disabled
    netsh int tcp set security profiles=disabled mpp=disabled
    netsh int tcp set global initialRto=2000
    netsh int tcp set global nonsackrttresiliency=disabled
    netsh int isatap set state disable
    netsh interface teredo set state disabled
    netsh interface 6to4 set state disabled
    :: Check parameters
    reg add "HKCU\SOFTWARE\KZNScript" /v "Netsh" /f
) >nul 2>&1 else (
    :: Revert to default
    netsh int ip reset
    :: Check parameters
    reg delete "HKCU\SOFTWARE\KZNScript" /v "Netsh" /f
) >nul 2>&1
goto CheckParameters

:WindowsUpdate
if "!WU!" EQU "!RED!Off" (
    :: Enable Windows Update services
    for %%a in (wuauserv BITS DmEnrollmentSvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "3" /f
    for %%a in (UsoSvc DoSvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "2" /f
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DoNotConnectToWindowsUpdateInternetLocations" /f
) >nul 2>&1 else (
    :: Disable Windows Update services
    for %%a in (wuauserv BITS DmEnrollmentSvc UsoSvc DoSvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DoNotConnectToWindowsUpdateInternetLocations" /t REG_DWORD /d "1" /f
) >nul 2>&1
goto CheckParameters

:Bluetooth
if "!BLTH!" EQU "!RED!Off" (
    :: Enable Bluetooth services
    for %%a in (RFCOMM BTAGService BTHPORT BTHUSB BluetoothUserService BthA2dp BthAvctpSvc BthEnum BthHFEnum BthLEEnum BthMini HidBth bthserv) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "3" /f
) >nul 2>&1 else (
    :: Disable Bluetooth services
    for %%a in (RFCOMM BTAGService BTHPORT BTHUSB BluetoothUserService BthA2dp BthAvctpSvc BthEnum BthHFEnum BthLEEnum BthMini HidBth bthserv) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckParameters

:Printing
@REM if "!PRNT!" EQU "!RED!Off" (
@REM     :: Enable Printing services
@REM     for %%a in (Spooler PrintNotify PrintWorkflowUserSvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "3" /f
@REM ) >nul 2>&1 else (
@REM     :: Disable Printing services
@REM     for %%a in (Spooler PrintNotify PrintWorkflowUserSvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
@REM ) >nul 2>&1
goto CheckParameters

:VPN
if "!VPN!" EQU "!RED!Off" (
    :: Enable VPN services
    for %%a in (SstpSvc PolicyAgent PptpMiniport RasAgileVpn Rasl2tp RasSstp RasPppoe RasMan) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "3" /f
) >nul 2>&1 else (
    :: Disable VPN services
    for %%a in (SstpSvc PolicyAgent PptpMiniport RasAgileVpn Rasl2tp RasSstp RasPppoe RasMan) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckParameters

:Firewall
if "!FRWL!" EQU "!RED!Off" (
    :: Enable Firewall services
    for %%i in (PublicProfile StandardProfile DomainProfile) do (for %%x in ("DisableNotifications=1" "EnableFirewall=0") do (for /f "tokens=1,2 delims==" %%a in ("%%~x") do (reg add "HKLM\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\%%i" /v %%a /t REG_DWORD /d %%b /f)))
    for %%a in (mpssvc BFE) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "2" /f
    @REM reg add "HKLM\SYSTEM\CurrentControlSet\Services\mpsdrv" /v "Start" /t REG_DWORD /d "3" /f
) >nul 2>&1 else (
    :: Disable Firewall services
    for %%i in (PublicProfile StandardProfile DomainProfile) do (for %%x in ("DisableNotifications=0" "EnableFirewall=1") do (for /f "tokens=1,2 delims==" %%a in ("%%~x") do (reg add "HKLM\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\%%i" /v %%a /t REG_DWORD /d %%b /f)))
    for %%a in (mpssvc BFE) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckParameters

:WIFI
if "!WIFI!" EQU "!RED!Off" (
    :: Enable Wi-Fi services
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\WlanSvc" /v "Start" /t REG_DWORD /d "3" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\vwififlt" /v "Start" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
    :: Disable Wi-Fi services
    for %%a in (WlanSvc vwifibus) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckParameters

:Network
if "!NK!" EQU "!RED!Off" (
    :: Enable Network services
    for %%a in (NlaSvc NcbService Netman netprofm NetSetupSvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "3" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\WpnUserService" /v "Start" /t REG_DWORD /d "2" /f
) >nul 2>&1 else (
    :: Disable Network services
    for %%a in (NlaSvc NcbService Netman netprofm NetSetupSvc WpnUserService) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckParameters

:HumanInterfaceDevices
if "!HID!" EQU "!RED!Off" (
    :: Enable HID service
    reg add "HKLM\System\CurrentControlSet\Services\hidserv" /v "Start" /t REG_DWORD /d "3" /f
) >nul 2>&1 else (
    :: Disable HID service
    reg add "HKLM\System\CurrentControlSet\Services\hidserv" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckParameters

:ManagementBios
if "!MBIOS!" EQU "!RED!Off" (
    :: Enable ManagementBios service
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mssmbios" /v "Start" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
    :: Disable ManagementBios service
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mssmbios" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckParameters

:WindowsSettings
if "!WSET!" EQU "!RED!Off" (
    :: Enable Windows settings serivce
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\ahcache" /v "Start" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
    :: Disable Windows settings serivce
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\ahcache" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckParameters

:DiskDefragmentation
if "!DD!" EQU "!RED!Off" (
    :: Enable DiskDefragmentation serivce
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\defragsvc" /v "Start" /t REG_DWORD /d "3" /f
) >nul 2>&1 else (
    :: Disable DiskDefragmentation serivce
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\defragsvc" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckParameters

:TaskManager
if "!TM!" EQU "!RED!Off" (
    :: Enable TaskManager serivce
    reg add "HKLM\SYSTEM\CurrentControlSet\services\pcw" /v "Start" /t REG_DWORD /d "0" /f
) >nul 2>&1 else (
    :: Disable TaskManager serivce
    reg add "HKLM\SYSTEM\CurrentControlSet\services\pcw" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckParameters

:Autoruns
:: Installing Autoruns
curl -g -L -# -o "%systemroot%\Files\Autoruns64.exe" "https://live.sysinternals.com/Autoruns64.exe" >nul 2>&1
%systemroot%\Files\Autoruns64.exe >nul 2>&1
:: Removing file
del /f /q "%systemroot%\Files\Autoruns64.exe" >nul 2>&1
goto CheckParameters

:OBS
(for %%i in (
    "[General]"
    "BrowserHWAccel=false"
    "FirstRun=true"
    ""
    "[BasicWindow]"
    "ShowListboxToolbars=false"
    "ShowContextToolbars=false"
    "WarnBeforeStartingStream=true"
    "WarnBeforeStoppingStream=true"
    "WarnBeforeStoppingRecord=true"
    "SysTrayMinimizeToTray=false"
    "geometry=AdnQywADAAAAAAEeAAAAMwAABhEAAAPQAAABHgAAAFIAAAYRAAAD0AAAAAAAAAAAB4AAAAEeAAAAUgAABhEAAAPQ"
    "DockState=AAAA/wAAAAD9AAAAAQAAAAMAAAT0AAABK/wBAAAABvsAAAAUAHMAYwBlAG4AZQBzAEQAbwBjAGsBAAAAAAAAATEAAACgAP////sAAAAWAHMAbwB1AHIAYwBlAHMARABvAGMAawEAAAE1AAABJgAAAKAA////+wAAABIAbQBpAHgAZQByAEQAbwBjAGsBAAACXwAAAXUAAADeAP////sAAAAeAHQAcgBhAG4AcwBpAHQAaQBvAG4AcwBEAG8AYwBrAAAAAs8AAACcAAAAggD////7AAAAGABjAG8AbgB0AHIAbwBsAHMARABvAGMAawEAAAPYAAABHAAAAJ4A////+wAAABIAcwB0AGEAdABzAEQAbwBjAGsCAAACYgAAAdcAAAK8AAAAyAAABPQAAAIfAAAABAAAAAQAAAAIAAAACPwAAAAA"
    ""
    "[Accessibility]"
    "SelectRed=255"
    "SelectGreen=65280"
    "SelectBlue=16744192"
    "MixerGreen=2522918"
    "MixerYellow=2523007"
    "MixerRed=2500223"
    "MixerGreenActive=5046092"
    "MixerYellowActive=5046271"
    "MixerRedActive=5000447"
    ""
    "[ScriptLogWindow]"
    "geometry=AdnQywADAAAAAAAAAAAAFAAAAlcAAAGjAAAAAAAAABQAAAJXAAABowAAAAAAAAAAB4AAAAAAAAAAFAAAAlcAAAGj"
) do echo.%%~i) > "%appdata%\obs-studio\global.ini"

(for %%i in (
    "[General]"
    "OpenStatsOnStartup=false"
    ""
    "[Output]"
    "Mode=Advanced"
    ""
    "[AdvOut]"
    "Encoder=jim_nvenc"
    "RecFormat2=mp4"
    "RecEncoder=jim_nvenc"
    "RecRB=true"
    "RecRBTime=30"
    "RecSplitFileType=Time"
    "FFFormat="
    "FFFormatMimeType="
    "FFVEncoderId=0"
    "FFVEncoder="
    "FFAEncoderId=0"
    "FFAEncoder="
    ""
    "[Video]"
    "FPSCommon=60"
    "ColorSpace=sRGB"
) do echo.%%~i) > "%appdata%\obs-studio\basic\profiles\Untitled\basic.ini"

echo {"bitrate":6000,"keyint_sec":2,"lookahead":false} > "%appdata%\obs-studio\basic\profiles\Untitled\recordEncoder.json"
echo {"bitrate":6000,"keyint_sec":2,"lookahead":false} > "%appdata%\obs-studio\basic\profiles\Untitled\streamEncoder.json"
goto CheckParameters

:Lightshot
:: Installing Lightshot
curl -g -L -# -o "%systemroot%\Files\setup-lightshot.exe" "https://app.prntscr.com/build/setup-lightshot.exe" >nul 2>&1
%systemroot%\Files\setup-lightshot.exe /verysilent /norestart >nul 2>&1
:: Setting Lightshot
for %%x in ("ShowBubbles=0" "AutoClose=0" "AutoCopy=0" "ProxyType=1") do (for /f "tokens=1,2 delims==" %%a in ("%%~x") do (reg add "HKCU\SOFTWARE\SkillBrains\Lightshot" /v %%a /t REG_DWORD /d %%b /f)) >nul 2>&1
:: Removing file
del /f /q "%systemroot%\Files\setup-lightshot.exe" >nul 2>&1
goto CheckParameters

:Office
explorer "https://drive.google.com/file/d/1a49CJtg9H4dZe3ZtF_xpxjuVDHmcqwz0/view"
goto CheckParameters

:StartMenu
    mode 49,16
    echo.
    echo.    !G!$.:k.:klk:.!R!                    .::....:::.
    echo.   !G!.knJzPkJnJYYJk\!R!            .:zKZNKZNKZNZ/:
    echo.      !G!zkJzJ.   :kJYk\:!R!    .:/ZKn/.   :zZKz.
    echo.       !G!zzkkBYzklzKZNKzk  :kzKzZnzKnnKZNzk/
    echo.        !G!.knkKZNKZNkkkZzzkkzJ:zKzKZNKzzk/
    echo.           !G!`````kJk. k?K:Kn. :nnK````
    echo.              !G!kNZn    kk z.   .kKZ:
    echo.             !G!Nzk/     kN.z.     kZNk
    echo.            !G!?zzN     :Zk kZ     .KZN:
    echo.            !G!KKZZ    nKZ: kBY:   /KZNk
    echo.            !G!KZkZ   nNkn   JBP.  kKZN/
    echo.            !G!.ZNk  .Kkk     nGk  .kNk
    echo.             !G!nKZNKZ:       kKZNKZ/
    echo.               !G!.kZk          .KZ/
    timeout /t 1 /nobreak >nul
    cls
    echo.
    echo.    !G!$.:k.:klk:.!R!                    .::....:::.
    echo.   !G!.knJzPkJnJYYJk\!R!            .:zKZNKZNKZNZ/:
    echo.      !G!zkJzJ.   :kJYk\:!R!    .:/ZKn/.   :zZKz.
    echo.       !G!zzkkBYzklzKZNKzk!R!  :kzKzZnzKnnKZNzk/
    echo.        !G!.knkKZNKZNkkkZzzk!R!kzJ:zKzKZNKzzk/
    echo.           !G!`````kJk. k?K!R!:Kn. :nnK````
    echo.              !G!kNZn    kk !R!z.   .kKZ:
    echo.             !G!Nzk/     kN.!R!z.     kZNk
    echo.            !G!?zzN     :Zk !R!kZ     .KZN:
    echo.            !G!KKZZ    nKZ: kBY:   /KZNk
    echo.            !G!KZkZ   nNkn   JBP.  kKZN/
    echo.            !G!.ZNk  .Kkk     nGk  .kNk
    echo.             !G!nKZNKZ:       kKZNKZ/
    echo.               !G!.kZk          .KZ/
    timeout /t 1 /nobreak >nul
    cls
    echo.
    echo.    !G!$.:k.:klk:.!R!                    .::....:::.
    echo.   !G!.knJzPkJnJYYJk\!R!            .:zKZNKZNKZNZ/:
    echo.      !G!zkJzJ.   :kJYk\:!R!    .:/ZKn/.   :zZKz.
    echo.       !G!zzkkBYzklzKZNKzk!R!  :kzKzZnzKnnKZNzk/
    echo.        !G!.knkKZNKZNkkkZzzk!R!kzJ:zKzKZNKzzk/
    echo.           !G!`````kJk. k?K!R!:Kn. :nnK````
    echo.              !G!kNZn    kk !R!z.   .kKZ:
    echo.             !G!Nzk/     kN.!R!z.     kZNk
    echo.            !G!?zzN     :Zk !R!kZ     .KZN:
    echo.            !G!KKZZ    nKZ: !R!kBY:   /KZNk
    echo.            !G!KZkZ   nNkn   !R!JBP.  kKZN/
    echo.            !G!.ZNk  .Kkk     !R!nGk  .kNk
    echo.             !G!nKZNKZ:       !R!kKZNKZ/
    echo.               !G!.kZk          !R!.KZ/

:Colors
    for /f "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set del=%%a
    set "cmdline=W=[97m,G=[90m,DRED=[31m,RED=[91m,B=[36m,C=[96m,S=[33m,Y=[93m,DG=[32m,M=[35m,GR=[92m,L=[4m,R=[0m,CYAN=[96m"
    set "%cmdline:,=" & set "%"