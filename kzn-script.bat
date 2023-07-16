@echo off
title KZN Script
setlocal EnableDelayedExpansion

:: Run as administrator
reg add HKLM /f >nul 2>&1
if %errorlevel% neq 0 start "" /wait /i /min powershell -NoProfile -Command start -verb runas "'%~s0'" && exit /b

call :Colors & call :StartMenu
set Page=MainMenuFirstPage & goto :CheckParameters

:CheckParameters
:: API
set "API=!GR!Installed   " & (reg query "HKCU\SOFTWARE\KZNScript" /v "API" || set "API=!RED!Need Install") >nul 2>&1
:: Disk Optimization
set "DO=!Y!SSD" & (reg query "HKLM\SYSTEM\CurrentControlSet\Services\SysMain" /v "Start" | find "0x4" || set "DO=!Y!HDD") >nul 2>&1
:: Alt-Tab
set "AT=!Y!10" & (reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "AltTabSettings" | find "0x0" || set "AT=!Y!7") >nul 2>&1
:: KeyboardDataQueueSize
for /f "tokens=2* delims=	 " %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize"') do set KDQS=%%j
set KDQSCON=!KDQS:~2!
:: MouseDataQueueSize
for /f "tokens=2* delims=	 " %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize"') do set MDQS=%%j
set MDQSCON=!MDQS:~2!
:: Win32PrioritySeparation
for /f "tokens=2* delims=	 " %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation"') do set W32=%%j
set WIN32=!W32:~2!
:: Nvidia driver
for /f "tokens=2 delims==" %%a in ('wmic path Win32_VideoController get VideoProcessor /value') do (for %%n in (GeForce NVIDIA RTX GTX) do echo %%a | find "%%n" >nul && set "GPU=!GR!Installed")
if "!GPU!" neq "!GR!Installed" set "GPU=!RED!Not Found"
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
for %%i in (SVC PT NPI NP WC ADAPTER TCP NETSH IAPT MMU) do (set "%%i=!GR!On ") & (
    :: SvcHostSplitThreshold
	for /f "tokens=2 delims==" %%i in ('wmic os get TotalVisibleMemorySize /value') do (set /a ram=%%i + 1024000)
    for /f "tokens=2* delims=	 " %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB"') do set /a regram=%%j
	if "!regram!" NEQ "!ram!" set "SVC=!RED!Off"
    :: PowerThrottling
    reg query "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" || set "PT=!RED!Off"
    :: Nvidia Profile Inspector
    reg query "HKCU\SOFTWARE\KZNScript" /v "NvidiaProfileInspector" || set "NPI=!RED!Off"
    :: NvidiaPreemption
    reg query "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" || set "NP=!RED!Off"
    :: WriteCombining
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" || set "WC=!RED!Off"
    :: NetworkCard
    reg query "HKCU\SOFTWARE\KZNScript" /v "Adapter" || set "ADAPTER=!RED!Off"
    :: TCP
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" || set "TCP=!RED!Off"
    :: Netsh
    reg query "HKCU\SOFTWARE\KZNScript" /v "Netsh" || set "NETSH=!RED!Off"
    :: InterruptAffinityPolicyTool
    reg query "HKCU\SOFTWARE\KZNScript" /v "InterruptAffinity" || set "IAPT=!RED!Off"
    ::MsiModeUtility
	for /f %%g in ('wmic path Win32_USBController get PNPDeviceID ^| findstr /L "VEN_"') do reg query "HKLM\System\CurrentControlSet\Enum\%%g\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" || set "MMU=!RED!Off"
) >nul 2>&1
for %%i in (USB HPET HAGS NVIDIA WU BLTH PRNT NETWORK FRWL WIFI VPN HID MBIOS WSET DISKDEF TRBL TASKM) do (set "%%i=!RED!Off") & (
    :: USBPowerSaving
    reg query "HKCU\SOFTWARE\KZNScript" /v "USBPowerSaving" || set "USB=!GR!On "
    :: High Precision Event Timer
    reg query "HKCU\SOFTWARE\KZNScript" /v "HPET" || set "HPET=!GR!On "
    :: HAGS
    reg query "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" | find "0x1" || set "HAGS=!GR!On "
    :: NvidiaPanel
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\NVDisplay.ContainerLocalSystem" /v "Start" | find "0x4" || set "NVIDIA=!GR!On "
    :: WindowsUpdate
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\wuauserv" /v "Start" | find "0x4" || set "WU=!GR!On "
    :: Bluetooth
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\bthserv" /v "Start" | find "0x4" || set "BLTH=!GR!On "
    :: Printing
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\Spooler" /v "Start" | find "0x4" || set "PRNT=!GR!On "
    :: Network
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\NcbService" /v "Start" | find "0x4" || set "NETWORK=!GR!On "
    :: Firewall
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\mpssvc" /v "Start" | find "0x4" || set "FRWL=!GR!On "
    :: Wi-Fi
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\WlanSvc" /v "Start" | find "0x4" || set "WIFI=!GR!On "
    :: VPN
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\RasMan" /v "Start" | find "0x4" || set "VPN=!GR!On "
    :: HumanInterfaceDevices
    reg query "HKLM\System\CurrentControlSet\Services\hidserv" /v "Start" | find "0x4" || set "HID=!GR!On "
    :: ManagementBios
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\mssmbios" /v "Start" | find "0x4" || set "MBIOS=!GR!On "
    :: WindowsSettings
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\ahcache" /v "Start" | find "0x4" || set "WSET=!GR!On "
    :: DiskDefragmentation
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\defragsvc" /v "Start" | find "0x4" || set "DISKDEF=!GR!On "
    :: TaskManager
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\pcw" /v "Start" | find "0x4" || set "TASKM=!GR!On "
) >nul 2>&1
goto %Page%

:MainMenuFirstPage
title KZN Script Page [1]
mode 142,38
echo.
echo.    !G!$.:k.:klk:.!R!                    .::....:::.                                            !S!Tweaks
echo.   !G!.knJzPkJnJYYJk\!R!            .:zKZNKZNKZNZ/:
echo.      !G!zkJzJ.   :kJYk\:!R!    .:/ZKn/.   :zZKz.     !S![!R!1!S!]!R! DiskOptimization !DO!        !S![!R!2!S!]!R! SvcHostSplitThreshold !SVC!    !S![!R!3!S!]!R! AltTab !AT!
echo.       !G!zzkkBYzklzKZNKzk!R!  :kzKzZnzKnnKZNzk/      !G!Disk optimization for           Change Svc Host Split            Personalization
echo.        !G!.knkKZNKZNkkkZzzk!R!kzJ:zKzKZNKzzk/        !G!specific type                   Threshold for service            Windows AltTab
echo.           !G!`````kJk. k?K!R!:Kn. :nnK````
echo.              !G!kNZn    kk !R!z.   .kKZ:             !S![!R!4!S!]!R! DisableThrottling !PT!       !S![!R!5!S!]!R! DisableUSBPowerSaving !USB!    !S![!R!6!S!]!R! HPET !HPET!
echo.             !G!Nzk/     kN.!R!z.     kZNk            !G!Disable Power Throttling        Disable Usb Power Saving         Disable High Precision
echo.            !G!?zzN     :Zk !R!kZ     .KZN:           !G!Dont disable on laptop                                           !G!Event Timer Device Manager
echo.            !G!KKZZ    nKZ: !R!kBY:   /KZNk
echo.            !G!KZkZ   nNkn   !R!JBP.  kKZN/           !S![!R!7!S!]!R! KeyboardDataQueueSize       !S![!R!8!S!]!R! MouseDataQueueSize           !S![!R!9!S!]!R! W32PrioritySeparation
echo.            !G!.ZNk  .Kkk     !R!nGk  .kNk            !G!Change the size of the          Change the size of the           Change value for
echo.             !G!nKZNKZ:       !R!kKZNKZ/              !G!keyboard data queue             mouse data queue                 Win32PrioritySeparation
echo.               !G!.kZk          !R!.KZ/               Current Value !Y!!KDQSCON!                !R!Current Value !Y!!MDQSCON!                 !R!Current Value !Y!!WIN32!
echo.
echo.                                                                                       !DG!NvidiaTweaks
echo.
echo.       !G!KZNScript is a free utility for          !DG![!R!10!DG!]!R! NvidiaDriver !GPU!     !DG![!R!11!DG!]!R! NvidiaProfileInspector !NPI!  !DG![!R!12!DG!]!R! HAGS !HAGS!
echo.       !G!configuring KZNOS system. KZNScript      !G!Install stripped Nvidia         Nvidia Control Panel settings    !G!Hardware-accelerated
echo.       simplifies system configuration by       Driver without Geforce          to optimize performance          !G!GPU Scheduling
echo.       tweaking parameters to meet users
echo.       specific needs.                          !DG![!R!13!DG!]!R! NvidiaTelemetry            !DG![!R!14!DG!]!R! NvidiaPreemption !NP!        !DG![!R!15!DG!]!R! WriteCombining !WC!
echo.                                                !G!Remove Nvidia                   Disable Nvidia                   Disable Write
echo.       Author: !W!!L!kazna2!R!                           !G!Telemetry                       Preemption                       Combining
echo.       discord.gg/emJ7ExzPht
echo.                                                !DG![!R!16!DG!]!R! DisablePState !PS!          !DG![!R!17!DG!]!R! DisableHDCP !HDCP!             !DG![!R!18!DG!]!R! ControlPanel !NVIDIA!
echo.                                                !G!Disable Nvidia GPU Idle         Disable High-bandwidth           Disable Nvidia services
echo.               !G![!R!0!G!]!R! API !API!             !G!state                           Digital Content Protection       Break Nvidia Control Panel
echo.               Install DirectX
echo.               and VCRedist                                                            !B!NetworkTweaks
echo.
echo.                                                !B![!R!19!B!]!R! NetworkCard !ADAPTER!            !B![!R!20!B!]!R! TCP/IP !TCP!                  !B![!R!21!B!]!R! Netch !NETSH!
echo.       !DRED![!R!R!DRED!]!R! Restart           !C![!R!P!C!]!R! Next Page      !G!Optimize Network Settings       Optimize TCP/IP                  Optimize Netch
echo.                                                !G!Dont use if using Wi-Fi         Dont use if using Wi-Fi          Dont use if using Wi-Fi

set /p menu=%del%             !R!Enter value to select:
if /i "!menu!" EQU "r" goto shutdown /r /f
if /i "!menu!" EQU "p" set "Page=MainMenuSecondPage" & goto MainMenuSecondPage
for %%i in (
    "0=API"
    "1=DiskOptimization"
    "2=SvcHostSplitThreshold"
    "3=AltTab"
    "4=PowerThrottling"
    "5=USBPowerSaving"
    "6=HPET"
    "7=KeyboardDataQueueSize"
    "8=MouseDataQueueSize"
    "9=Win32PrioritySeparation"
    "10=NvidiaDriver"
    "11=NvidiaProfileInspector"
    "12=HAGS"
    "13=NvidiaTelemetry"
    "14=NvidiaPreemption"
    "15=WriteCombining"
    "16=PState"
    "17=HDCP"
    "18=ControlPanel"
    "19=NetworkCard"
    "20=TCP"
    "21=Netsh"
) do for /f "tokens=1,2 delims==" %%a in ("%%~i") do (if "!menu!" EQU "%%~a" goto %%~b)
goto MainMenuFirstPage

:MainMenuSecondPage
title KZN Script Page [2]
mode 142,38
echo.
echo.    !G!$.:k.:klk:.!R!                    .::....:::.                                           !Y!Services
echo.   !G!.knJzPkJnJYYJk\!R!            .:zKZNKZNKZNZ/:
echo.      !G!zkJzJ.   :kJYk\:!R!    .:/ZKn/.   :zZKz.     !Y![!R!22!Y!]!R! WindowsUpdate !WU!          !Y![!R!23!Y!]!R! Bluetooth !BLTH!               !Y![!R!24!Y!]!R! Printing !PRNT!
echo.       !G!zzkkBYzklzKZNKzk!R!  :kzKzZnzKnnKZNzk/      !G!Disable after installing        Dont disable if using            Dont disable if using
echo.        !G!.knkKZNKZNkkkZzzk!R!kzJ:zKzKZNKzzk/        !G!languages                       Bluetooth                        Printing
echo.           !G!`````kJk. k?K!R!:Kn. :nnK````
echo.              !G!kNZn    kk !R!z.   .kKZ:             !Y![!R!25!Y!]!R! VPN !VPN!                    !Y![!R!26!Y!]!R! Firewall !FRWL!                !Y![!R!27!Y!]!R! Wi-Fi !WIFI!
echo.             !G!Nzk/     kN.!R!z.     kZNk            !G!Break Virtual                   Break Firewall                   Dont disable if using
echo.            !G!?zzN     :Zk !R!kZ     .KZN:           !G!Private Network                                                  Wi-Fi
echo.            !G!KKZZ    nKZ: !R!kBY:   /KZNk
echo.            !G!KZkZ   nNkn   !R!JBP.  kKZN/                                                  !S!ExtraServices
echo.            !G!.ZNk  .Kkk     !R!nGk  .kNk
echo.             !G!nKZNKZ:       !R!kKZNKZ/              !S![!R!28!S!]!R! Network !NETWORK!                !S![!R!29!S!]!R! HumanInterfaceDevices !HID!   !S![!R!30!S!]!R! ManagementBios !MBIOS!
echo.               !G!.kZk          !R!.KZ/               !G!Break network icon              Break scrollbar sound            Break Grand Theft
echo.                                                !G!and Epic Games                  menu                             Auto V
echo.
echo.                                                !S![!R!31!S!]!R! WindowsSettings !WSET!        !S![!R!32!S!]!R! DiskDefragmentation !DISKDEF!     !S![!R!33!S!]!R! TaskManager !TASKM!
echo.       !G!KZNScript is a free utility for          !G!Break Windows settings          Break shrink volume in           Break Task Manager
echo.       configuring KZNOS system. KZNScript                                      Disk Management
echo.       simplifies system configuration by
echo.       tweaking parameters to meet users                                                  !M!Utility
echo.       !G!specific needs.
echo.                                                !M![!R!34!M!]!R! InterruptAffinity !IAPT!      !M![!R!35!M!]!R! MsiModeUtility !MMU!          !M![!R!36!M!]!R! Autoruns
echo.       !G!Author: !W!!L!kazna2!R!                           !G!Bind CPU affinity interrupts    Enabling Message Signaled        Process and service
echo.       !G!discord.gg/emJ7ExzPht                    Dont use on less 4 cores        Interrupts Priority              management
echo.
echo.                                                                                           !B!Soft
echo.
echo.                                                !B![!R!37!B!]!R! OBS Studio                 !B![!R!38!B!]!R! Lightshot                   !B![!R!39!B!]!R! Office
echo.                                                !G!Settings OBS Studio             Install screen capture tool      !G!Install Office
echo.                                                Use after Install OBS           Replace Win+Shift+S              all Microsoft Apps
echo.
echo.       !DRED![!R!R!DRED!]!R! Restart           !C![!R!P!C!]!R! Next Page
echo.

set /p menu=%del%             !R!Enter value to select:
if /i "!menu!" EQU "R" goto shutdown /r /f
if /i "!menu!" EQU "p" set "Page=MainMenuFirstPage" & goto MainMenuFirstPage
for %%i in (
    "22=WindowsUpdate"
    "23=Bluetooth"
    "24=Printing"
    "25=VPN"
    "26=Firewall"
    "27=WIFI"
    "28=Network"
    "29=HumanInterfaceDevices"
    "30=ManagementBios"
    "31=WindowsSettings"
    "32=DiskDefragmentation"
    "33=TaskManager"
    "34=InterruptAffinity"
    "35=MsiModeUtility"
    "36=Autoruns"
    "37=OBS"
    "38=Lightshot"
    "39=Office"
) do for /f "tokens=1,2 delims==" %%a in ("%%~i") do (if "!menu!" EQU "%%~a" goto %%~b)
goto MainMenuSecondPage

:API
:: Installing DirectX
curl -g -L -# -o "%systemroot%\Files\directx_Jun2010_redist.exe" "https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe"
"%systemdrive%\Program Files\7-Zip\7z.exe" x -y -o"%systemroot%\Files\DirectX" "%systemroot%\Files\directx_Jun2010_redist.exe" >nul 2>&1 && %systemroot%\Files\DirectX\DXSETUP.exe /silent
:: Delete files DirectX
del /f /q "%systemroot%\Files\directx_Jun2010_redist.exe" >nul 2>&1 & rd /s /q "%systemroot%\Files\DirectX" >nul 2>&1
:: Installing VCRedist
curl -g -L -# -o "%systemroot%\Files\VisualCppRedist_AIO_x86_x64_73.zip" "https://github.com/abbodi1406/vcredist/releases/download/v0.73.0/VisualCppRedist_AIO_x86_x64_73.zip"
powershell -NoProfile Expand-Archive "%systemroot%\Files\VisualCppRedist_AIO_x86_x64_73.zip" -DestinationPath '%systemroot%\Files\' >nul 2>&1 && %systemroot%\Files\VisualCppRedist_AIO_x86_x64.exe /ai /gm2
:: Delete files VCRedist
del /f /q "%systemroot%\Files\VisualCppRedist_AIO_x86_x64_73.zip" >nul 2>&1 "%systemroot%\Files\VisualCppRedist_AIO_x86_x64.exe" >nul 2>&1
:: Check Parameters
reg add "HKCU\SOFTWARE\KZNScript" /v "API" /f >nul 2>&1
goto CheckParameters

:DiskOptimization
if "!DO!" EQU "!Y!SSD" (
    :: HDD Optimization
    for %%a in (Main PfApLog StoreLog) do reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Superfetch/%%a" /v "Enabled" /t REG_DWORD /d "1" /f
    for %%a in (FontCache SysMain) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "2" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d "3" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "DisableDeleteNotification" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
    :: SSD Optimization
    for %%a in (Main PfApLog StoreLog) do reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-Superfetch/%%a" /v "Enabled" /t REG_DWORD /d "0" /f
    for %%a in (FontCache SysMain) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
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
    :: Default value
    reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d "3670016" /f
) >nul 2>&1
goto CheckParameters

:AltTab
if "!AT!" EQU "!Y!10" (
    :: Windows 7 Alt-Tab
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "AltTabSettings" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
    :: Windows 10 Alt-Tab
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "AltTabSettings" /t REG_DWORD /d "0" /f
) >nul 2>&1
goto CheckParameters

:PowerThrottling
if "!PT!" EQU "!RED!Off" (
    :: Disable PowerThrottling
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
   :: Revert to default
    reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /f
) >nul 2>&1
goto CheckParameters

:USBPowerSaving
if "!USB!" EQU "!RED!Off" (
    :: Disable Power Saving
    for %%a in (
        "EnhancedPowerManagementEnabled"
        "AllowIdleIrpInD3"
        "EnableSelectiveSuspend"
        "DeviceSelectiveSuspended"
        "SelectiveSuspendEnabled"
        "SelectiveSuspendOn"
        "EnumerationRetryCount"
        "ExtPropDescSemaphore"
        "WaitWakeEnabled"
        "D3ColdSupported"
        "WdfDirectedPowerTransitionEnable"
        "EnableIdlePowerManagement"
        "IdleInWorkingState"
    ) do for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f %%a ^| findstr "HKEY"') do reg add "%%b" /v "%%a" /t REG_DWORD /d "0" /f
    :: Check parameters
    reg delete "HKCU\SOFTWARE\KZNScript" /v "USBPowerSaving" /f
) >nul 2>&1 else (
    :: Enable Power Saving
    for %%a in (
        "EnhancedPowerManagementEnabled"
        "AllowIdleIrpInD3"
        "EnableSelectiveSuspend"
        "DeviceSelectiveSuspended"
        "SelectiveSuspendEnabled"
        "SelectiveSuspendOn"
        "EnumerationRetryCount"
        "ExtPropDescSemaphore"
        "WaitWakeEnabled"
        "D3ColdSupported"
        "WdfDirectedPowerTransitionEnable"
        "EnableIdlePowerManagement"
        "IdleInWorkingState"
    ) do for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f %%a ^| findstr "HKEY"') do reg add "%%b" /v "%%a" /t REG_DWORD /d "1" /f
    :: Check parameters
    reg add "HKCU\SOFTWARE\KZNScript" /v "USBPowerSaving" /f
) >nul 2>&1
goto CheckParameters

:HPET
if "!HPET!" EQU "!RED!Off" (
    :: Enable High precision event timer
    DevManView /enable "High precision event timer" && reg delete "HKCU\SOFTWARE\KZNScript" /v "HPET" /f
) >nul 2>&1 else (
    :: Disable High precision event timer
    DevManView /disable "High precision event timer" && reg add "HKCU\SOFTWARE\KZNScript" /v "HPET" /f
) >nul 2>&1
goto CheckParameters

:KeyboardDataQueueSize
title KZN Script KeyboardDataQueueSize
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
title KZN Script MouseDataQueueSize
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
title KZN Script Win32PrioritySeparation
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
"%systemdrive%\Program Files\7-Zip\7z.exe" x -y -o"%systemroot%\Files\Nvidia" "%systemroot%\Files\NVIDIA.exe" >nul 2>&1
%systemroot%\Files\Nvidia\setup.exe /s
:: Delete files
del /f /q "%systemroot%\Files\NVIDIA.exe" >nul 2>&1 & rd /s /q "%systemroot%\Files\Nvidia" >nul 2>&1
goto CheckParameters

:NvidiaProfileInspector
if "!NPI!" EQU "!RED!Off" (
    :: Installing NvidiaProfileInspector
    curl -g -L -# -o "%systemroot%\Files\nvidiaProfileInspector.zip" "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/download/2.4.0.4/nvidiaProfileInspector.zip"
    powershell -NoProfile Expand-Archive "%systemroot%\Files\nvidiaProfileInspector.zip" -DestinationPath '%systemroot%\Files'
    :: Installing CustomProfile
    curl -g -L -# -o "%systemroot%\Files\CustomProfile.nip" "https://github.com/kaznaonx/kzn-script/releases/download/Files/CustomProfile.nip"
    :: Apply
    cd "%systemroot%\Files" && nvidiaProfileInspector.exe "CustomProfile.nip"
    :: Delete files
    del /f /q "%systemroot%\Files\nvidiaProfileInspector.exe.config" "%systemroot%\Files\nvidiaProfileInspector.zip" "%systemroot%\Files\Reference.xml" "%systemroot%\Files\nvidiaProfileInspector.exe" "%systemroot%\Files\CustomProfile.nip"
    :: Check Parameters
    reg add "HKCU\SOFTWARE\KZNScript" /v "NvidiaProfileInspector" /f
) >nul 2>&1 else (
    :: Installing NvidiaProfileInspector
    curl -g -L -# -o "%systemroot%\Files\nvidiaProfileInspector.zip" "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/download/2.4.0.4/nvidiaProfileInspector.zip"
    powershell -NoProfile Expand-Archive "%systemroot%\Files\nvidiaProfileInspector.zip" -DestinationPath '%systemroot%\Files'
    :: Installing CustomProfile
    curl -g -L -# -o "%systemroot%\Files\BaseProfile.nip" "https://github.com/kaznaonx/kzn-script/releases/download/Files/BaseProfile.nip"
    :: Apply
    cd "%systemroot%\Files" && nvidiaProfileInspector.exe "BaseProfile.nip"
    :: Delete files
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
:: Detele files
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
if "!ADAPTER!" EQU "!RED!Off" (
    :: Settings Network Card
    for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (
                for %%a in (FlowControl UDPChecksumOffloadIPv6 UDPChecksumOffloadIPv4 TCPChecksumOffloadIPv4 TCPChecksumOffloadIPv6 PriorityVLANTag IPChecksumOffloadIPv4 PMARPOffload PMNSOffload LsoV2IPv4 LsoV2IPv6 WakeOnMagicPacket WakeOnPattern) do (
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
    reg add "HKCU\SOFTWARE\KZNScript" /v "Adapter" /f
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
    reg delete "HKCU\SOFTWARE\KZNScript" /v "Adapter" /f
) >nul 2>&1
goto CheckParameters

:TCP
if "!TCP!" EQU "!RED!Off" (
    :: Settings TCP
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
    :: Settings netsh
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
    for %%a in (Microsoft_Bluetooth_AvrcpTransport RFCOMM BTAGService BTHPORT BTHUSB BluetoothUserService BthA2dp BthAvctpSvc BthEnum BthHFEnum BthLEEnum BthMini HidBth bthserv) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "3" /f
) >nul 2>&1 else (
    :: Disable Bluetooth services
    for %%a in (Microsoft_Bluetooth_AvrcpTransport RFCOMM BTAGService BTHPORT BTHUSB BluetoothUserService BthA2dp BthAvctpSvc BthEnum BthHFEnum BthLEEnum BthMini HidBth bthserv) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckParameters

:Printing
if "!PRNT!" EQU "!RED!Off" (
    :: Enable Printing services
    for %%a in (Spooler PrintNotify PrintWorkflowUserSvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "3" /f
) >nul 2>&1 else (
    :: Disable Printing services
    for %%a in (Spooler PrintNotify PrintWorkflowUserSvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckParameters

:VPN
if "!VPN!" EQU "!RED!Off" (
    :: Enable VPN Services
    for %%a in (RasMan BFE) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "2" /f
    for %%a in (SstpSvc PolicyAgent PptpMiniport RasAgileVpn Rasl2tp RasSstp RasPppoe iphlpsvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "3" /f
) >nul 2>&1 else (
    :: Disable VPN Services
    for %%a in (RasMan BFE SstpSvc PolicyAgent PptpMiniport RasAgileVpn Rasl2tp RasSstp RasPppoe iphlpsvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckParameters

:Firewall
if "!FRWL!" EQU "!RED!Off" (
    :: Enable Firewall
    for %%i in (PublicProfile StandardProfile DomainProfile) do (
        for %%x in ("DisableNotifications=1" "EnableFirewall=0") do (for /f "tokens=1,2 delims==" %%a in ("%%~x") do (reg add "HKLM\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\%%i" /v %%a /t REG_DWORD /d %%b /f)))
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mpssvc" /v "Start" /t REG_DWORD /d "2" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mpsdrv" /v "Start" /t REG_DWORD /d "3" /f
) >nul 2>&1 else (
    :: Disable Firewall
    for %%i in (PublicProfile StandardProfile DomainProfile) do (
        for %%x in ("DisableNotifications=0" "EnableFirewall=1") do (for /f "tokens=1,2 delims==" %%a in ("%%~x") do (reg add "HKLM\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\%%i" /v %%a /t REG_DWORD /d %%b /f)))
    for %%a in (mpssvc mpsdrv) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckParameters

:WIFI
if "!WIFI!" EQU "!RED!Off" (
    :: Enable Wi-Fi services
    for %%a in (WlanSvc vwifibus netprofm) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "3" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\vwififlt" /v "Start" /t REG_DWORD /d "1" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\NlaSvc" /v "Start" /t REG_DWORD /d "2" /f
) >nul 2>&1 else (
    :: Disable Wi-Fi services
    for %%a in (WlanSvc vwifibus vwifibus netprofm NlaSvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckParameters

:Network
if "!NETWORK!" EQU "!RED!Off" (
    :: Enable Network services
    for %%a in (NcbService Netman netprofm NetSetupSvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "3" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\NlaSvc" /v "Start" /t REG_DWORD /d "2" /f
) >nul 2>&1 else (
    :: Disable Network services
    for %%a in (NcbService Netman netprofm NetSetupSvc NlaSvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckParameters

:HumanInterfaceDevices
if "!HID!" EQU "!RED!Off" (
    :: Enable HID Service
    reg add "HKLM\System\CurrentControlSet\Services\hidserv" /v "Start" /t REG_DWORD /d "3" /f
) >nul 2>&1 else (
    :: Disable HID Service
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
if "!DISKDEF!" EQU "!RED!Off" (
    :: Enable DiskDefragmentation serivce
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\defragsvc" /v "Start" /t REG_DWORD /d "3" /f
) >nul 2>&1 else (
    :: Disable DiskDefragmentation serivce
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\defragsvc" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckParameters

:TaskManager
if "!TASKM!" EQU "!RED!Off" (
    :: Enable TaskManager serivce
    reg add "HKLM\SYSTEM\CurrentControlSet\services\pcw" /v "Start" /t REG_DWORD /d "0" /f
) >nul 2>&1 else (
    :: Disable TaskManager serivce
    reg add "HKLM\SYSTEM\CurrentControlSet\services\pcw" /v "Start" /t REG_DWORD /d "4" /f
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
    :: Settings MsiModeUtility
    for /f %%a in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /t REG_DWORD /d "3" /f
    for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /t REG_DWORD /d "3" /f
) >nul 2>&1 else (
    :: Revert to default
    for /f %%a in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "VEN_"') do reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
    for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
) >nul 2>&1
goto CheckParameters

:Autoruns
:: Installing Autoruns
curl -g -L -# -o "%systemroot%\Files\Autoruns64.exe" "https://live.sysinternals.com/Autoruns64.exe" >nul 2>&1
%systemroot%\Files\Autoruns64.exe >nul 2>&1
:: Delete file
del /f /q "%systemroot%\Files\Autoruns64.exe" >nul 2>&1
goto CheckParameters

:OBS
:: Installing settings files OBS
curl -g -L -# -o "%systemroot%\Files\OBS.zip" "https://github.com/kaznaonx/kzn-script/releases/download/Files/OBS.zip" >nul 2>&1
powershell -NoProfile Expand-Archive "%systemroot%\Files\OBS.zip" -DestinationPath '%systemroot%\Files' >nul 2>&1
:: Move
for %%a in (basic.ini recordEncoder.json streamEncoder.json) do move "%systemroot%\Files\OBS\%%a" "%userprofile%\AppData\Roaming\obs-studio\basic\profiles\Untitled" >nul 2>&1
move "%systemroot%\Files\OBS\global.ini" "%userprofile%\AppData\Roaming\obs-studio" >nul 2>&1
:: Delete files
del /f /q "%systemroot%\Files\OBS.zip" >nul 2>&1 & rd /s /q "%systemroot%\Files\OBS" >nul 2>&1
goto CheckParameters

:Lightshot
:: Installing Lightshot
curl -g -L -# -o "%systemroot%\Files\setup-lightshot.exe" "https://app.prntscr.com/build/setup-lightshot.exe" >nul 2>&1
%systemroot%\Files\setup-lightshot.exe /verysilent /norestart >nul 2>&1
:: Settings Lightshot
for %%a in ("ShowBubbles" "AutoClose" "AutoCopy") do reg add "HKCU\SOFTWARE\SkillBrains\Lightshot" /v %%a /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\SOFTWARE\SkillBrains\Lightshot" /v "ProxyType" /t REG_DWORD /d "1" /f >nul 2>&1
:: Delete file
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