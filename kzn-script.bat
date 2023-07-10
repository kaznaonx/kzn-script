@echo off
title KZNScript
setlocal EnableDelayedExpansion

call :Colors & call :StartMenu

set PAGE=MainMenuFirstPage & goto CheckValue

:CheckValue
:: DiskOptimization
set "DO=%Y%SSD" & ( reg query "HKLM\SYSTEM\CurrentControlSet\Services\SysMain" /v "Start" | find "0x4" || set "DO=%Y%HDD" ) >nul 2>&1
:: AltTab
set "AT=%Y%10" & ( reg query "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "AltTabSettings" | find "0x0" || set "AT=%Y%7" ) >nul 2>&1
:: KeyboardDataQueueSize
for /f "tokens=2* delims=	 " %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize"') do set KDQS=%%j
set KDQSCON=%KDQS:~2%
:: MouseDataQueueSize
for /f "tokens=2* delims=	 " %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize"') do set MDQS=%%j
set MDQSCON=%MDQS:~2%
:: Win32PrioritySeparation
for /f "tokens=2* delims=	 " %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation"') do set W32=%%j
set WIN32=%W32:~2%
for %%i in (WC NP TCP SVC) do (set "%%i=%GR% On") & (
    :: WriteCombining
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" || set "WC=%RED%Off"
    :: NvidiaPreemption
    reg query "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" || set "NP=%RED%Off"
    :: TCP
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "Tcp1323Opts" || set "TCP=%RED%Off"
    :: SvcHostSplitThreshold
	for /f "tokens=2 delims==" %%i in ('wmic os get TotalVisibleMemorySize /value') do (set /a ram=%%i + 1024000)
    for /f "tokens=2* delims=	 " %%i in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB"') do set /a regram=%%j
	if "!regram!" NEQ "!ram!" set "SVC=%RED%Off"
) >nul 2>&1
for %%i in (PT USB HPET NPI GPUS NET MMU IAPT ADAPTER) do (set "%%i=%RED%Off") & (
    :: PowerThrottling
    reg query "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" | find "0x1" || set "PT=%GR% On"
    :: USBPowerSaves
    reg query "HKCU\SOFTWARE\KZNScript" /v "USBPowerSaves" | find "0x0" || set "USB=%GR% On"
    :: High Precision Event Timer
    reg query "HKCU\SOFTWARE\KZNScript" /v "HPET" | find "0x1" || set "HPET=%GR% On"
    :: Nvidia Profile Inspector
    reg query "HKCU\SOFTWARE\KZNScript" /v "NvidiaProfileInspector" | find "0x0" || set "NPI=%GR% On"
    :: GPUScheduling
    reg query "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" | find "0x1" || set "GPUS=%GR% On"
    :: Netsh
    reg query "HKCU\SOFTWARE\KZNScript" /v "Netsh" | find "0x0" || set "NET=%GR% On"
    :: MsiModeUtility
    reg query "HKCU\SOFTWARE\KZNScript" /v "MsiModeUtility" | find "0x0" || set "MMU=%GR% On"
    :: InterruptAffinity
    reg query "HKCU\SOFTWARE\KZNScript" /v "InterruptAffinity" | find "0x0" || set "IAPT=%GR% On"
    :: NetworkAdapter
    reg query "HKCU\SOFTWARE\KZNScript" /v "Adapter" | find "0x0" || set "ADAPTER=%GR% On"
) >nul 2>&1
for %%i in (WU BLTH PRNT NETSER FRWL WIFI VPN HID MBIOS WSET DISKDEF TRBL TASKM NULL NVIDIA) do (set "%%i=%RED%Off") & (
    :: WindowsUpdate
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\wuauserv" /v "Start" | find "0x4" || set "WU=%GR% On"
    :: Bluetooth
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\bthserv" /v "Start" | find "0x4" || set "BLTH=%GR% On"
    :: Printing
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\Spooler" /v "Start" | find "0x4" || set "PRNT=%GR% On"
    :: Network
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\NcbService" /v "Start" | find "0x4" || set "NETSER=%GR% On"
    :: Firewall
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\mpssvc" /v "Start" | find "0x4" || set "FRWL=%GR% On"
    :: Wi-Fi
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\WlanSvc" /v "Start" | find "0x4" || set "WIFI=%GR% On"
    :: VPN
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\RasMan" /v "Start" | find "0x4" || set "VPN=%GR% On"
    :: HumanInterfaceDevices
    reg query "HKLM\System\CurrentControlSet\Services\hidserv" /v "Start" | find "0x4" || set "HID=%GR% On"
    :: ManagementBios
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\mssmbios" /v "Start" | find "0x4" || set "MBIOS=%GR% On"
    :: WindowsSettings
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\ahcache" /v "Start" | find "0x4" || set "WSET=%GR% On"
    :: DiskDefragmentation
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\defragsvc" /v "Start" | find "0x4" || set "DISKDEF=%GR% On"
    :: Troubleshooting
    reg query "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DiagLog" /v "Start" | find "0x0" || set "TRBL=%GR% On"
    :: TaskManager
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\pcw" /v "Start" | find "0x4" || set "TASKM=%GR% On"
    :: Null
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\Null" /v "Start" | find "0x4" || set "NULL=%GR% On"
    :: NvidiaPanel
    reg query "HKLM\SYSTEM\CurrentControlSet\Services\NVDisplay.ContainerLocalSystem" /v "Start" | find "0x4" || set "NVIDIA=%GR% On"
) >nul 2>&1
goto %PAGE%

:MainMenuFirstPage
title KZNScript Page [1]
mode 142,40
echo.
echo.    %G%$.:k.:klk:.%R%                    .::....:::.                                             %S%Tweaks
echo.   %G%.knJzPkJnJYYJk\%R%            .:zKZNKZNKZNZ/:
echo.      %G%zkJzJ.   :kJYk\:%R%    .:/ZKn/.   :zZKz.     %S%[%R%1%S%]%R% DiskOptimization %DO%        %S%[%R%2%S%]%R% SvcHostSplitThreshold %SVC%    %S%[%R%3%S%]%R% AltTab %AT%
echo.       %G%zzkkBYzklzKZNKzk%R%  :kzKzZnzKnnKZNzk/      %G%Disk optimization for           Change Svc Host Split            Personalization
echo.        %G%.knkKZNKZNkkkZzzk%R%kzJ:zKzKZNKzzk/        %G%specific type                   Threshold for service            Windows AltTab
echo.           %G%`````kJk. k?K%R%:Kn. :nnK````
echo.              %G%kNZn    kk %R%z.   .kKZ:             %S%[%R%4%S%]%R% PowerThrottling %PT%         %S%[%R%5%S%]%R% USBPowerSaves %USB%            %S%[%R%6%S%]%R% HPET %HPET%
echo.             %G%Nzk/     kN.%R%z.     kZNk            %G%Dont disable on laptop          Disable Usb Power Saves          Disable High Precision
echo.            %G%?zzN     :Zk %R%kZ     .KZN:                                                                            %G%Event Timer Device Manager
echo.            %G%KKZZ    nKZ: %R%kBY:   /KZNk
echo.            %G%KZkZ   nNkn   %R%JBP.  kKZN/           %S%[%R%7%S%]%R% KeyboardDataQueueSize       %S%[%R%8%S%]%R% MouseDataQueueSize           %S%[%R%9%S%]%R% W32PrioritySeparation
echo.            %G%.ZNk  .Kkk     %R%nGk  .kNk            %G%Change the size of the          Change the size of the           Change value for
echo.             %G%nKZNKZ:       %R%kKZNKZ/              %G%keyboard data queue             mouse data queue                 Win32PrioritySeparation
echo.               %G%.kZk          %R%.KZ/               Current Value %Y%%KDQSCON%                %R%Current Value %Y%%MDQSCON%                 %R%Current Value %Y%%WIN32%
echo.
echo.                                                                                        %DG%NvidiaTweaks
echo.
echo.       %G%KZNScript is a free utility for          %DG%[%R%10%DG%]%R% NvidiaDriver               %DG%[%R%11%DG%]%R% NvidiaProfileInspector %NPI%  %DG%[%R%12%DG%]%R% NvidiaTelemetry
echo.       %G%configuring KZNOS system. KZNScript      %G%Install stripped                Tweaks Nvidia Control Panel      Remove Nvidia
echo.       simplifies system configuration by       Nvidia Driver                   and hidden options               Telemetry
echo.       tweaking parameters to meet users
echo.       specific needs.                          %DG%[%R%13%DG%]%R% GPUScheduling %GPUS%          %DG%[%R%14%DG%]%R% NvidiaPreemption %NP%        %DG%[%R%15%DG%]%R% WriteCombining %WC%
echo.                                                %G%GPUScheduling with              Disable Nvidia                   Disable Write
echo.       Author: %W%%L%kazna2%R%                           %G%hardware acceleration           Preemption                       Combining
echo.       discord.gg/emJ7ExzPht
echo.                                                                                        %B%NetworkTweaks
echo.
echo.             %DRED%Required to installation           %B%[%R%16%B%]%R% NetworkAdapter %ADAPTER%         %B%[%R%17%B%]%R% TCP/IP %TCP%                  %B%[%R%18%B%]%R% Netch %NET%
echo.                                                %G%Settings Network Adapters       Optimize TCP/IP                  Optimize Netch
echo.       %G%[%R%DX%G%]%R% DirectX          %G%[%R%VC%G%]%R% VCRedist      %G%Dont use if using Wi-Fi         Dont use if using Wi-Fi
echo.       %G%Install DirectX       Install Visual
echo.       libraries             C++ libraries                                                %M%Utility
echo.
echo.                                                %M%[%R%19%M%]%R% InterruptAffinity %IAPT%      %M%[%R%20%M%]%R% MsiModeUtility %MMU%          %M%[%R%21%M%]%R% Autoruns
echo.       %DRED%[%R%R%DRED%]%R% Restart           %C%[%R%P%C%]%R% Next Page      %G%Bind the CPU affinity           Set Interrupt Priority           Process and service
echo.                                                of the interrupts                                                management

set /p menu=%del%             %R%Enter value to select:
if "%menu%" EQU "DX" goto DirectX
if "%menu%" EQU "dx" goto DirectX
if "%menu%" EQU "VC" goto VCRedist
if "%menu%" EQU "vc" goto VCRedist
if "%menu%" EQU "R" goto shutdown /r /f
if "%menu%" EQU "r" goto shutdown /r /f
if "%menu%" EQU "P" set "PAGE=MainMenuSecondPage" & goto MainMenuSecondPage
if "%menu%" EQU "p" set "PAGE=MainMenuSecondPage" & goto MainMenuSecondPage
if "%menu%" EQU "1" goto DiskOptimization
if "%menu%" EQU "2" goto SvcHostSplitThreshold
if "%menu%" EQU "3" goto AltTab
if "%menu%" EQU "4" goto PowerThrottling
if "%menu%" EQU "5" goto USBPowerSaves
if "%menu%" EQU "6" goto HPET
if "%menu%" EQU "7" goto KeyboardDataQueueSize
if "%menu%" EQU "8" goto MouseDataQueueSize
if "%menu%" EQU "9" goto Win32PrioritySeparation
if "%menu%" EQU "10" goto NvidiaDriver
if "%menu%" EQU "11" goto NvidiaProfileInspector
if "%menu%" EQU "12" goto NvidiaTelemetry
if "%menu%" EQU "13" goto GPUScheduling
if "%menu%" EQU "14" goto NvidiaPreemption
if "%menu%" EQU "15" goto WriteCombining
if "%menu%" EQU "16" goto NetworkAdapter
if "%menu%" EQU "17" goto TCP/IP
if "%menu%" EQU "18" goto Netsh
if "%menu%" EQU "19" goto InterruptAffinity
if "%menu%" EQU "20" goto MsiModeUtility
if "%menu%" EQU "21" goto Autoruns
goto CheckValue

:MainMenuSecondPage
title KZNScript Page [2]
mode 142,40
echo.
echo.    %G%$.:k.:klk:.%R%                    .::....:::.                                            %S%Services
echo.   %G%.knJzPkJnJYYJk\%R%            .:zKZNKZNKZNZ/:
echo.      %G%zkJzJ.   :kJYk\:%R%    .:/ZKn/.   :zZKz.     %S%[%R%22%S%]%R% WindowsUpdate %WU%          %S%[%R%23%S%]%R% Bluetooth %BLTH%               %S%[%R%24%S%]%R% Printing %PRNT%
echo.       %G%zzkkBYzklzKZNKzk%R%  :kzKzZnzKnnKZNzk/      %G%Break installing                Break Bluetooth                  Break printing
echo.        %G%.knkKZNKZNkkkZzzk%R%kzJ:zKzKZNKzzk/        %G%languages
echo.           %G%`````kJk. k?K%R%:Kn. :nnK````
echo.              %G%kNZn    kk %R%z.   .kKZ:             %S%[%R%25%S%]%R% Network %NETSER%                %S%[%R%26%S%]%R% Firewall %FRWL%                %S%[%R%27%S%]%R% Wi-Fi %WIFI%
echo.             %G%Nzk/     kN.%R%z.     kZNk            %G%Break network icon              Break Firewall                   Break Wireless
echo.            %G%?zzN     :Zk %R%kZ     .KZN:           %G%and Epic Games                                                   Fidelity
echo.            %G%KKZZ    nKZ: %R%kBY:   /KZNk
echo.            %G%KZkZ   nNkn   %R%JBP.  kKZN/           %S%[%R%28%S%]%R% VPN %VPN%                    %S%[%R%29%S%]%R% HumanInterfaceDevices %HID%   %S%[%R%30%S%]%R% ManagementBios %MBIOS%
echo.            %G%.ZNk  .Kkk     %R%nGk  .kNk            %G%Break Virtual                   Break scrollbar sound            Break Grand Theft
echo.             %G%nKZNKZ:       %R%kKZNKZ/              %G%Private Network                 menu                             Auto V
echo.               %G%.kZk          %R%.KZ/
echo.                                                %S%[%R%31%S%]%R% WindowsSettings %WSET%        %S%[%R%32%S%]%R% DiskDefragmentation %DISKDEF%     %S%[%R%33%S%]%R% Troubleshooting %TRBL%
echo.                                                %G%Break Windows settings          Break shrink volume              Break Troubleshooting
echo.
echo.       KZNScript is a free utility for
echo.       configuring KZNOS system. KZNScript      %S%[%R%34%S%]%R% TaskManager %TASKM%            %S%[%R%35%S%]%R% Null %NULL%                    %S%[%R%36%S%]%R% NvidiaPanel %NVIDIA%
echo.       %G%simplifies system configuration by       Break Task Manager              Break Logitech G HUB and         Break Nvidia Control
echo.       tweaking parameters to meet users                                        Steelseries GG                   Panel
echo.       specific needs.
echo.                                                                                            %M%Soft
echo.       %G%Author: %W%%L%kazna2%R%
echo.       %G%discord.gg/emJ7ExzPht                    %M%[%R%37%M%]%R% Settings OBS Studio        %M%[%R%38%M%]%R% Lightshot                   %M%[%R%39%M%]%R% Office
echo.                                                %G%Set settings OBS Studio         Install screen capture tool      %G%Install Office
echo.                                                Use after Install OBS           Replace Win+Shift+S              all Microsoft Apps
echo.
echo.
echo.
echo.
echo.
echo.
echo.
echo.       %DRED%[%R%R%DRED%]%R% Restart           %C%[%R%P%C%]%R% Next Page
echo.

set /p menu=%del%             %R%Enter value to select:
if "%menu%" EQU "R" goto shutdown /r /f
if "%menu%" EQU "r" goto shutdown /r /f
if "%menu%" EQU "P" set "PAGE=MainMenuFirstPage" & goto MainMenuFirstPage
if "%menu%" EQU "p" set "PAGE=MainMenuFirstPage" & goto MainMenuFirstPage
if "%menu%" EQU "22" goto WindowsUpdate
if "%menu%" EQU "23" goto Bluetooth
if "%menu%" EQU "24" goto Printing
if "%menu%" EQU "25" goto Network
if "%menu%" EQU "26" goto Firewall
if "%menu%" EQU "27" goto Wi-Fi
if "%menu%" EQU "28" goto VPN
if "%menu%" EQU "29" goto HumanInterfaceDevices
if "%menu%" EQU "30" goto ManagementBios
if "%menu%" EQU "31" goto WindowsSettings
if "%menu%" EQU "32" goto DiskDefragmentation
if "%menu%" EQU "33" goto Troubleshooting
if "%menu%" EQU "34" goto TaskManager
if "%menu%" EQU "35" goto Null
if "%menu%" EQU "36" goto NvidiaPanel
if "%menu%" EQU "37" goto SettingsOBSStudio
if "%menu%" EQU "38" goto Lightshot
if "%menu%" EQU "39" goto Office
goto CheckValue

:: ### Tweaks ###
:: Install DirectX
:DirectX
curl -g -L -# -o "%systemroot%\Files\directx_Jun2010_redist.exe" "https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe"
"%systemdrive%\Program Files\7-Zip\7z.exe" x -y -o"%systemroot%\Files\DirectX" "%systemroot%\Files\directx_Jun2010_redist.exe" >nul 2>&1
%systemroot%\Files\DirectX\DXSETUP.exe /silent
del /f /q "%systemroot%\Files\directx_Jun2010_redist.exe" >nul 2>&1 & rd /s /q "%systemroot%\Files\DirectX" >nul 2>&1
goto CheckValue

:: Install VCRedist
:VCRedist
curl -g -L -# -o "%systemroot%\Files\VisualCppRedist_AIO_x86_x64_73.zip" "https://github.com/abbodi1406/vcredist/releases/download/v0.73.0/VisualCppRedist_AIO_x86_x64_73.zip"
powershell -NoProfile Expand-Archive "%systemroot%\Files\VisualCppRedist_AIO_x86_x64_73.zip" -DestinationPath '%systemroot%\Files\' >nul 2>&1
%systemroot%\Files\VisualCppRedist_AIO_x86_x64.exe /ai /gm2
del /f /q "%systemroot%\Files\VisualCppRedist_AIO_x86_x64_73.zip" >nul 2>&1 & del /f /q "%systemroot%\Files\VisualCppRedist_AIO_x86_x64.exe" >nul 2>&1
goto CheckValue

:: DiskOptimization
:DiskOptimization
if "%DO%" EQU "%Y%SSD" (
    for %%a in (FontCache SysMain) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "2" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d "3" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "DisableDeleteNotification" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
    for %%a in (FontCache SysMain) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v "EnablePrefetcher" /t REG_DWORD /d "0" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v "DisableDeleteNotification" /t REG_DWORD /d "0" /f
) >nul 2>&1
goto CheckValue

:: SvcHostSplitThreshold
:SvcHostSplitThreshold
for /f "tokens=2 delims==" %%i in ('wmic os get TotalVisibleMemorySize /value') do set /a ram=%%i + 1024000
if "%SVC%" EQU "%RED%Off" ( reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d %ram% /f ) >nul 2>&1 else ( reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v "SvcHostSplitThresholdInKB" /t REG_DWORD /d "3670016" /f ) >nul 2>&1
goto CheckValue

:: AltTab
:AltTab
if "%AT%" EQU "%Y%10" ( reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "AltTabSettings" /t REG_DWORD /d "1" /f ) >nul 2>&1 else ( reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" /v "AltTabSettings" /t REG_DWORD /d "0" /f ) >nul 2>&1
goto CheckValue

:: PowerThrottling
:PowerThrottling
if "%PT%" EQU "%RED%Off" ( reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "0" /f ) >nul 2>&1 else ( reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v "PowerThrottlingOff" /t REG_DWORD /d "1" /f ) >nul 2>&1
goto CheckValue

:: USBPowerSaves
:USBPowerSaves
if "%USB%" EQU "%RED%Off" (
    for %%a in (EnhancedPowerManagementEnabled AllowIdleIrpInD3 EnableSelectiveSuspend DeviceSelectiveSuspended SelectiveSuspendEnabled SelectiveSuspendOn EnumerationRetryCount ExtPropDescSemaphore WaitWakeEnabled D3ColdSupported WdfDirectedPowerTransitionEnable EnableIdlePowerManagement IdleInWorkingState) do for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f "%%a" ^| findstr "HKEY"') do reg.exe add "%%b" /v "%%a" /t REG_DWORD /d "1" /f & reg add "HKCU\SOFTWARE\KZNScript" /v "USBPowerSaves" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
    for %%a in (EnhancedPowerManagementEnabled AllowIdleIrpInD3 EnableSelectiveSuspend DeviceSelectiveSuspended SelectiveSuspendEnabled SelectiveSuspendOn EnumerationRetryCount ExtPropDescSemaphore WaitWakeEnabled D3ColdSupported WdfDirectedPowerTransitionEnable EnableIdlePowerManagement IdleInWorkingState) do for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum" /s /f "%%a" ^| findstr "HKEY"') do reg.exe add "%%b" /v "%%a" /t REG_DWORD /d "0" /f & reg add "HKCU\SOFTWARE\KZNScript" /v "USBPowerSaves" /t REG_DWORD /d "0" /f
) >nul 2>&1
goto CheckValue

:: High precision event timer
:HPET
if "%HPET%" EQU "%RED%Off" ( reg add "HKCU\SOFTWARE\KZNScript" /v "HPET" /t REG_DWORD /d "0" /f & DevManView.exe /enable "High precision event timer") >nul 2>&1 else ( reg add "HKCU\SOFTWARE\KZNScript" /v "HPET" /t REG_DWORD /d "1" /f & DevManView.exe /disable "High precision event timer" ) >nul 2>&1
goto CheckValue

:: KeyboardDataQueueSize
:KeyboardDataQueueSize
title KZNScript
mode 29,12
cls
echo.
echo.  %S%[%R%7%S%]%R% KeyboardDataQueueSize
echo.  %G%Change the size of the
echo.  keyboard data queue
echo.
echo.  %R%Default value: %Y%64
echo.  %R%Current value: %Y%%KDQSCON%
echo.  %R%Recommendation values:
echo.  %Y%10 12 14 16 19 20 25 32%R%
echo.

set /p KeyboardDataQueueSize=%del%  Enter value:
set KeyboardDataQueueSize=%KeyboardDataQueueSize: =%
for /f %%a in ('powershell -command [uint32]'0x%KeyboardDataQueueSize%'') do set KeyboardDataQueueSizeConvert=%%a
reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d "%KeyboardDataQueueSizeConvert%" /f >nul 2>&1
goto CheckValue

:: MouseDataQueueSize
:MouseDataQueueSize
title KZNScript
mode 27,12
cls
echo.
echo.  %S%[%R%8%S%]%R% MouseDataQueueSize
echo.  %G%Change the size of the
echo.  mouse data queue
echo.
echo.  %R%Default value: %Y%64
echo.  %R%Current value: %Y%%MDQSCON%
echo.  %R%Recommendation values:
echo.  %Y%10 12 14 16 19 20 25 32%R%
echo.

set /p MouseDataQueueSize=%del%  Enter value:
set MouseDataQueueSize=%MouseDataQueueSize: =%
for /f %%a in ('powershell -command [uint32]'0x%MouseDataQueueSize%'') do set MouseDataQueueSizeConvert=%%a
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d "%MouseDataQueueSizeConvert%" /f >nul 2>&1
goto CheckValue

:: Win32PrioritySeparation
:Win32PrioritySeparation
title KZNScript
mode 41,13
cls
echo.
echo.  %S%[%R%9%S%]%R% W32PrioritySeparation
echo.  %G%Change value for
echo.  W32PrioritySeparation
echo.
echo.  %R%Default value: %Y%26
echo.  %R%Current value: %Y%%WIN32%
echo.  %R%Recommendation values:
echo.  %Y%2 14 15 16 18 19 1a 24 25 28 29
echo.  2a fff9887 ffff3f91 fff55555 fffff311%R%
echo.

set /p Win32PrioritySeparation=%del%  Enter value:
set Win32PrioritySeparation=%Win32PrioritySeparation: =%
for /f %%a in ('powershell -command [uint32]'0x%Win32PrioritySeparation%'') do set Win32PrioritySeparationConvert=%%a
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d "%Win32PrioritySeparationConvert%" /f >nul 2>&1
goto CheckValue

:: Install Nvidia Driver
:NvidiaDriver
curl -g -L -# -o "%systemroot%\Files\NVIDIA.exe" "https://github.com/kaznaonx/KZNOSScript/releases/download/2.0/NvidiaDriver.exe"
"%systemdrive%\Program Files\7-Zip\7z.exe" x -y -o"%systemroot%\Files\Nvidia" "%systemroot%\Files\NVIDIA.exe" >nul 2>&1
%systemroot%\Files\Nvidia\setup.exe /s
del /f /q "%systemroot%\Files\NVIDIA.exe" >nul 2>&1 & rd /s /q "%systemroot%\Files\Nvidia" >nul 2>&1
goto CheckValue

:: Install Nvidia Profile Inspector & settings Nvidia
:NvidiaProfileInspector
if "%NPI%" EQU "%RED%Off" (
    reg add "HKCU\SOFTWARE\KZNScript" /v "NvidiaProfileInspector" /t REG_DWORD /d "1" /f
    curl -g -L -# -o "%systemroot%\Files\CustomProfile.nip" "https://github.com/kaznaonx/KZNOSScript/releases/download/2.0/CustomProfile.nip"
    curl -g -L -# -o "%systemroot%\Files\nvidiaProfileInspector.zip" "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/download/2.4.0.4/nvidiaProfileInspector.zip"
    powershell -NoProfile Expand-Archive "%systemroot%\Files\nvidiaProfileInspector.zip" -DestinationPath '%systemroot%\Files'
    cd "%systemroot%\Files"
    nvidiaProfileInspector.exe "CustomProfile.nip"
    del /f /q "%systemroot%\Files\nvidiaProfileInspector.exe.config" & del /f /q "%systemroot%\Files\nvidiaProfileInspector.zip" & del /f /q "%systemroot%\Files\Reference.xml" & del /f /q "%systemroot%\Files\nvidiaProfileInspector.exe" & del /f /q "%systemroot%\Files\CustomProfile.nip"
) >nul 2>&1 else (
    reg add "HKCU\SOFTWARE\KZNScript" /v "NvidiaProfileInspector" /t REG_DWORD /d "0" /f
    curl -g -L -# -o "%systemroot%\Files\BaseProfile.nip" "https://github.com/kaznaonx/KZNOSScript/releases/download/2.0/BaseProfile.nip"
    curl -g -L -# -o "%systemroot%\Files\nvidiaProfileInspector.zip" "https://github.com/Orbmu2k/nvidiaProfileInspector/releases/download/2.4.0.4/nvidiaProfileInspector.zip"
    powershell -NoProfile Expand-Archive "%systemroot%\Files\nvidiaProfileInspector.zip" -DestinationPath '%systemroot%\Files'
    cd "%systemroot%\Files"
    nvidiaProfileInspector.exe "BaseProfile.nip"
    del /f /q "%systemroot%\Files\nvidiaProfileInspector.exe.config" & del /f /q "%systemroot%\Files\nvidiaProfileInspector.zip" & del /f /q "%systemroot%\Files\Reference.xml" & del /f /q "%systemroot%\Files\nvidiaProfileInspector.exe" & del /f /q "%systemroot%\Files\BaseProfile.nip"
) >nul 2>&1
goto CheckValue

:: Delete Nvidia Telemetry
:NvidiaTelemetry
rmdir /s /q "%systemroot%\System32\drivers\NVIDIA Corporation" >nul 2>&1
cd /d "%systemroot%\System32\DriverStore\FileRepository\" >nul 2>&1
dir NvTelemetry64.dll /a /b /s >nul 2>&1
del NvTelemetry64.dll /a /s >nul 2>&1
goto CheckValue

:: GPUScheduling
:GPUScheduling
if "%GPUS%" EQU "%RED%Off" ( reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "2" /f ) >nul 2>&1 else ( reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d "1" /f ) >nul 2>&1
goto CheckValue

:: NvidiaPreemption
:NvidiaPreemption
if "%NP%" EQU "%RED%Off" (
    for %%a in (EnableMidGfxPreemption EnableMidGfxPreemptionVGPU EnableMidBufferPreemptionForHighTdrTimeout EnableMidBufferPreemption EnableAsyncMidBufferPreemption EnableCEPreemption ComputePreemption) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "%%a" /t REG_DWORD /d "0" /f
    for %%a in (DisablePreemption DisableCudaContextPreemption DisablePreemptionOnS3S4) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "%%a" /t REG_DWORD /d "1" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /t REG_DWORD /d "0" /f
    reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\NVTweak" /v "DisplayPowerSaving" /t REG_DWORD /d "0" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /t REG_DWORD /d "0" /f
) >nul 2>&1 else (
    for %%a in (EnableMidGfxPreemption EnableMidGfxPreemptionVGPU EnableMidBufferPreemptionForHighTdrTimeout EnableMidBufferPreemption EnableAsyncMidBufferPreemption EnableCEPreemption ComputePreemption DisablePreemption DisableCudaContextPreemption DisablePreemptionOnS3S4) do reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "%%a" /f
    reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\NVTweak" /v "DisplayPowerSaving" /f
    reg delete "HKLM\SOFTWARE\NVIDIA Corporation\Global\NVTweak" /v "DisplayPowerSaving" /f
    reg delete "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v "EnablePreemption" /f
) >nul 2>&1
goto CheckValue

:: WriteCombining
:WriteCombining
if "%WC%" EQU "%RED%Off" ( reg add "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" /t REG_DWORD /d "1" /f ) >nul 2>&1 else ( reg delete "HKLM\SYSTEM\CurrentControlSet\Services\nvlddmkm" /v "DisableWriteCombining" /f ) >nul 2>&1
goto CheckValue

:: Settings Network Adapter
:NetworkAdapter
if "%ADAPTER%" EQU "%RED%Off" (
    reg add "HKCU\SOFTWARE\KZNScript" /v "Adapter" /t REG_DWORD /d "1" /f
    for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (
                for %%a in (FlowControl UDPChecksumOffloadIPv6 UDPChecksumOffloadIPv4 TCPChecksumOffloadIPv4 TCPChecksumOffloadIPv6 PriorityVLANTag IPChecksumOffloadIPv4 PMARPOffload PMNSOffload LsoV2IPv4 LsoV2IPv6 WakeOnMagicPacket WakeOnPattern) do for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%i" /s /f "*%%a" ^| findstr "HKEY"') do reg add "%%b" /v "*%%a" /t REG_SZ /d "0" /f >nul 2>&1)))

    for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (
                for %%a in (EnablePME EEELinkAdvertisement ULPMode ReduceSpeedOnPowerDown WaitAutoNegComplete WakeOnLink) do for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%i" /s /f "%%a" ^| findstr "HKEY"') do reg add "%%b" /v "%%a" /t REG_SZ /d "0" /f >nul 2>&1)))
) >nul 2>&1 else (
    reg add "HKCU\SOFTWARE\KZNScript" /v "Adapter" /t REG_DWORD /d "0" /f
    for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (
                for %%a in (PMARPOffload PMNSOffload LsoV2IPv4 LsoV2IPv6 WakeOnMagicPacket WakeOnPattern) do for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%i" /s /f "*%%a" ^| findstr "HKEY"') do reg add "%%b" /v "*%%a" /t REG_SZ /d "1" /f >nul 2>&1)))

    for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (
                for %%a in (EnablePME EEELinkAdvertisement ULPMode ReduceSpeedOnPowerDown WaitAutoNegComplete) do for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%i" /s /f "%%a" ^| findstr "HKEY"') do reg add "%%b" /v "%%a" /t REG_SZ /d "1" /f >nul 2>&1)))

    for /f %%i in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "PCI\VEN_"') do (
        for /f "tokens=3" %%a in ('reg query "HKLM\SYSTEM\CurrentControlSet\Enum\%%i" /v "Driver"') do (
            for /f %%i in ('echo %%a ^| findstr "{"') do (
                for %%a in (FlowControl IPChecksumOffloadIPv4 PriorityVLANTag UDPChecksumOffloadIPv6 UDPChecksumOffloadIPv4 TCPChecksumOffloadIPv4 TCPChecksumOffloadIPv6) do for /f "delims=" %%b in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Class\%%i" /s /f "*%%a" ^| findstr "HKEY"') do reg add "%%b" /v "*%%a" /t REG_SZ /d "3" /f >nul 2>&1)))
) >nul 2>&1
goto CheckValue

:: TCP/IP
:TCP/IP
if "%TCP%" EQU "%RED%Off" (
    for %%a in (EnablePMTUDiscovery TcpMaxConnectRetransmissions Tcp1323Opts) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "%%a" /t REG_DWORD /d "1" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "IGMPLevel" /t REG_DWORD /d "0" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "DefaultTTL" /t REG_DWORD /d "64" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "MaxUserPort" /t REG_DWORD /d "65534" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpTimedWaitDelay" /t REG_DWORD /d "32" /f
    for /f %%i in ('wmic path win32_networkadapter get GUID ^| findstr "{"') do reg add "HKLM\System\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%i" /v "TcpAckFrequency" /t REG_DWORD /d "1" /f
    for /f %%i in ('wmic path win32_networkadapter get GUID ^| findstr "{"') do reg add "HKLM\System\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%i" /v "TcpDelAckTicks" /t REG_DWORD /d "0" /f
    for /f %%i in ('wmic path win32_networkadapter get GUID ^| findstr "{"') do reg add "HKLM\System\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%i" /v "TCPNoDelay" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
    for %%a in (DefaultTTL EnablePMTUDiscovery IGMPLevel MaxUserPort TcpTimedWaitDelay TcpMaxConnectRetransmissions Tcp1323Opts) do reg delete "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "%%a" /f
    for /f %%i in ('wmic path win32_networkadapter get GUID ^| findstr "{"') do reg delete "HKLM\System\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%i" /v "TcpAckFrequency" /f
    for /f %%i in ('wmic path win32_networkadapter get GUID ^| findstr "{"') do reg delete "HKLM\System\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%i" /v "TcpDelAckTicks" /f
    for /f %%i in ('wmic path win32_networkadapter get GUID ^| findstr "{"') do reg delete "HKLM\System\CurrentControlSet\services\Tcpip\Parameters\Interfaces\%%i" /v "TCPNoDelay" /f
) >nul 2>&1
goto CheckValue

:: Netsh
:Netsh
if "%NET%" EQU "%RED%Off" (
    reg add "HKCU\SOFTWARE\KZNScript" /v "Netsh" /t REG_DWORD /d "1" /f
    netsh int tcp set global dca=enabled
    netsh interface isatap set state disabled
    netsh int tcp set global timestamps=disabled
    netsh int tcp set global nonsackrttresiliency=disabled
    netsh int tcp set global initialRto=2000
    netsh int tcp set supplemental template=custom icw=10
    netsh interface ip set interface ethernet currenthoplimit=64
    netsh int tcp set global chimney=enabled
    netsh int tcp set global ecncapability=disabled
    netsh int tcp set global rsc=disabled
    netsh int ip set global icmpredirects=disabled
    netsh int ip set global neighborcachelimit=4096
    netsh int ip set global routecachelimit=4096
    netsh int tcp set heuristics disabled
    netsh int tcp set heuristics wsh=disabled
    netsh int tcp set security profiles=disabled
    netsh int tcp set security mpp=disabled profiles=disabled
    netsh interface 6to4 set state disabled
    netsh interface teredo set state disabled
    netsh int tcp set global maxsynretransmissions=2
    netsh int tcp set global hystart=disable
) >nul 2>&1 else (
    reg add "HKCU\SOFTWARE\KZNScript" /v "Netsh" /t REG_DWORD /d "0" /f
    netsh int ip reset
    netsh winsock reset
) >nul 2>&1
goto CheckValue

:: InterruptAffinity
:InterruptAffinity
title KZNScript
mode 26,10
cls
echo.
echo.  %M%[%R%19%M%]%R% InterruptAffinity
echo.  %G%Bind the CPU affinity
echo.  of the interrupts
echo.
echo.  %R%Apply value: %GR%1%R%
echo.  Reset value: %RED%2%R%
echo.

set /p menu=%del%  Enter value:
if "%menu%" EQU "1" goto Apply
if "%menu%" EQU "2" goto Reset
goto Tweaks

:Apply
if "%IAPT%" EQU "%RED%Off" (
    for /f "tokens=*" %%a in ('wmic cpu get NumberOfCores /value ^| find "="') do set %%a
    for /f "tokens=*" %%a in ('wmic cpu get NumberOfLogicalProcessors /value ^| find "="') do set %%a
    reg add "HKCU\SOFTWARE\KZNScript" /v "InterruptAffinity" /t REG_DWORD /d "1" /f >nul 2>&1
    if !NumberOfLogicalProcessors! GTR !NumberOfCores! (
        for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "10" /f
        for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
    ) >nul 2>&1 else (
        for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /t REG_BINARY /d "04" /f
        for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /t REG_DWORD /d "4" /f
    ) >nul 2>&1
)
goto CheckValue

:Reset
reg add "HKCU\SOFTWARE\KZNScript" /v "InterruptAffinity" /t REG_DWORD /d "0" /f >nul 2>&1
for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "AssignmentSetOverride" /f >nul 2>&1
for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePolicy" /f >nul 2>&1
goto CheckValue

:: MsiModeUtility
:MsiModeUtility
if "%MMU%" EQU "%RED%Off" (
    reg add "HKCU\SOFTWARE\KZNScript" /v "MsiModeUtility" /t REG_DWORD /d "1" /f
    for /f %%a in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /t REG_DWORD /d "3" /f
    for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do reg add "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /t REG_DWORD /d "3" /f
) >nul 2>&1 else (
    reg add "HKCU\SOFTWARE\KZNScript" /v "MsiModeUtility" /t REG_DWORD /d "0" /f
    for /f %%a in ('wmic path Win32_NetworkAdapter get PNPDeviceID^| findstr /L "VEN_"') do reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
    for /f %%a in ('wmic path Win32_USBController get PNPDeviceID^| findstr /L "VEN_"') do reg delete "HKLM\SYSTEM\CurrentControlSet\Enum\%%a\Device Parameters\Interrupt Management\Affinity Policy" /v "DevicePriority" /f
) >nul 2>&1
goto CheckValue

:: Autoruns
:Autoruns
curl -g -L -# -o "%systemroot%\Files\Autoruns64.exe" "https://live.sysinternals.com/Autoruns64.exe" >nul 2>&1
%systemroot%\Files\Autoruns64.exe >nul 2>&1
del /f /q "%systemroot%\Files\Autoruns64.exe" >nul 2>&1
goto CheckValue

:: Windows Update Services
:WindowsUpdate
if "%WU%" EQU "%RED%Off" (
    for %%a in (wuauserv BITS DmEnrollmentSvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "3" /f
    for %%a in (UsoSvc DoSvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "2" /f
    reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DoNotConnectToWindowsUpdateInternetLocations" /f
) >nul 2>&1 else (
    for %%a in (wuauserv BITS DmEnrollmentSvc UsoSvc DoSvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "DoNotConnectToWindowsUpdateInternetLocations" /t REG_DWORD /d "1" /f
) >nul 2>&1
goto CheckValue

:: Bluetooth Services
:Bluetooth
if "%BLTH%" EQU "%RED%Off" ( for %%a in (Microsoft_Bluetooth_AvrcpTransport RFCOMM BTAGService BTHPORT BTHUSB BluetoothUserService BthA2dp BthAvctpSvc BthEnum BthHFEnum BthLEEnum BthMini HidBth bthserv) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "3" /f ) >nul 2>&1 else ( for %%a in (Microsoft_Bluetooth_AvrcpTransport RFCOMM BTAGService BTHPORT BTHUSB BluetoothUserService BthA2dp BthAvctpSvc BthEnum BthHFEnum BthLEEnum BthMini HidBth bthserv) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f ) >nul 2>&1
goto CheckValue

:: Printing Services
:Printing
if "%PRNT%" EQU "%RED%Off" ( for %%a in (Spooler PrintNotify PrintWorkflowUserSvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "3" /f ) >nul 2>&1 else ( for %%a in (Spooler PrintNotify PrintWorkflowUserSvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f ) >nul 2>&1
goto CheckValue

:: Network Services
:Network
if "%NETSER%" EQU "%RED%Off" (
    for %%a in (NcbService Netman netprofm NetSetupSvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "3" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\NlaSvc" /v "Start" /t REG_DWORD /d "2" /f
) >nul 2>&1 else (
    for %%a in (NcbService Netman netprofm NetSetupSvc NlaSvc) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckValue

:: Firewall Services
:Firewall
if "%FRWL%" EQU "%RED%Off" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mpssvc" /v "Start" /t REG_DWORD /d "2" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mpsdrv" /v "Start" /t REG_DWORD /d "3" /f
) >nul 2>&1 else (
    for %%a in (mpssvc mpsdrv) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckValue

:: Wi-Fi Services
:Wi-Fi
if "%WIFI%" EQU "%RED%Off" (
    for %%a in (WlanSvc vwifibus) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "3" /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\vwififlt" /v "Start" /t REG_DWORD /d "1" /f
) >nul 2>&1 else (
    for %%a in (WlanSvc vwifibus vwifibus) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckValue

:: VPN Services
:VPN
if "%VPN%" EQU "%RED%Off" (
    for %%a in (RasMan BFE) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "2" /f
    for %%a in (SstpSvc PolicyAgent PptpMiniport RasAgileVpn Rasl2tp RasSstp RasPppoe) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "3" /f
) >nul 2>&1 else (
    for %%a in (RasMan BFE SstpSvc PolicyAgent PptpMiniport RasAgileVpn Rasl2tp RasSstp RasPppoe) do reg add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckValue

:: Human Interface Devices Services
:HumanInterfaceDevices
if "%HID%" EQU "%RED%Off" ( reg add "HKLM\System\CurrentControlSet\Services\hidserv" /v "Start" /t REG_DWORD /d "3" /f ) >nul 2>&1 else ( reg add "HKLM\System\CurrentControlSet\Services\hidserv" /v "Start" /t REG_DWORD /d "4" /f ) >nul 2>&1
goto CheckValue

:: Management Bios Services
:ManagementBios
if "%MBIOS%" EQU "%RED%Off" ( reg add "HKLM\SYSTEM\CurrentControlSet\Services\mssmbios" /v "Start" /t REG_DWORD /d "1" /f ) >nul 2>&1 else ( reg add "HKLM\SYSTEM\CurrentControlSet\Services\mssmbios" /v "Start" /t REG_DWORD /d "4" /f ) >nul 2>&1
goto CheckValue

:: Windows Settings Services
:WindowsSettings
if "%WSET%" EQU "%RED%Off" ( reg add "HKLM\SYSTEM\CurrentControlSet\Services\ahcache" /v "Start" /t REG_DWORD /d "1" /f ) >nul 2>&1 else ( reg add "HKLM\SYSTEM\CurrentControlSet\Services\ahcache" /v "Start" /t REG_DWORD /d "4" /f ) >nul 2>&1
goto CheckValue

:: Disk Defragmentation Services
:DiskDefragmentation
if "%DISKDEF%" EQU "%RED%Off" ( reg add "HKLM\SYSTEM\CurrentControlSet\Services\defragsvc" /v "Start" /t REG_DWORD /d "3" /f ) >nul 2>&1 else ( reg add "HKLM\SYSTEM\CurrentControlSet\Services\defragsvc" /v "Start" /t REG_DWORD /d "4" /f ) >nul 2>&1
goto CheckValue

:: Troubleshooting Services
:Troubleshooting
if "%TRBL%" EQU "%RED%Off" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DiagLog" /v "Start" /t REG_DWORD /d "1" /f
    PowerRun.exe reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\DPS" /v "Start" /t REG_DWORD /d "2" /f
    for %%a in (WdiServiceHost WdiSystemHost pla) do PowerRun.exe reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "3" /f
) >nul 2>&1 else (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\WMI\Autologger\DiagLog" /v "Start" /t REG_DWORD /d "0" /f
    for %%a in (DPS WdiServiceHost WdiSystemHost pla) do PowerRun.exe reg.exe add "HKLM\SYSTEM\CurrentControlSet\Services\%%a" /v "Start" /t REG_DWORD /d "4" /f
) >nul 2>&1
goto CheckValue

:: Task Manager Services
:TaskManager
if "%TASKM%" EQU "%RED%Off" ( reg add "HKLM\SYSTEM\CurrentControlSet\services\pcw" /v "Start" /t REG_DWORD /d "0" /f ) >nul 2>&1 else ( reg add "HKLM\SYSTEM\CurrentControlSet\services\pcw" /v "Start" /t REG_DWORD /d "4" /f ) >nul 2>&1
goto CheckValue

:: Null Services
:Null
if "%NULL%" EQU "%RED%Off" ( reg add "HKLM\SYSTEM\CurrentControlSet\Services\Null" /v "Start" /t REG_DWORD /d "1" /f ) >nul 2>&1 else ( reg add "HKLM\SYSTEM\CurrentControlSet\Services\Null" /v "Start" /t REG_DWORD /d "4" /f ) >nul 2>&1
goto CheckValue

:: Nvidia Panel Services
:NvidiaPanel
if "%NVIDIA%" EQU "%RED%Off" ( reg add "HKLM\SYSTEM\CurrentControlSet\Services\NVDisplay.ContainerLocalSystem" /v "Start" /t REG_DWORD /d "2" /f ) >nul 2>&1 else ( reg add "HKLM\SYSTEM\CurrentControlSet\Services\NVDisplay.ContainerLocalSystem" /v "Start" /t REG_DWORD /d "4" /f ) >nul 2>&1
goto CheckValue

:: Settings OBS Studio
:SettingsOBSStudio
curl -g -L -# -o "%systemroot%\Files\OBS.zip" "https://github.com/kaznaonx/KZNOSScript/raw/main/OBS.zip" >nul 2>&1
powershell -NoProfile Expand-Archive "%systemroot%\Files\OBS.zip" -DestinationPath '%systemroot%\Files' >nul 2>&1
for %%a in (basic.ini recordEncoder.json streamEncoder.json) do move "%systemroot%\Files\OBS\%%a" "%userprofile%\AppData\Roaming\obs-studio\basic\profiles\Untitled" >nul 2>&1
move "%systemroot%\Files\OBS\global.ini" "%userprofile%\AppData\Roaming\obs-studio" >nul 2>&1
del /f /q "%systemroot%\Files\OBS.zip" >nul 2>&1 & rd /s /q "%systemroot%\Files\OBS" >nul 2>&1
goto CheckValue

:: Settings Lightshot
:Lightshot
curl -g -L -# -o "%systemroot%\Files\setup-lightshot.exe" "https://app.prntscr.com/build/setup-lightshot.exe" >nul 2>&1
%systemroot%\Files\setup-lightshot.exe /verysilent /norestart >nul 2>&1
del /f /q "%systemroot%\Files\setup-lightshot.exe" >nul 2>&1
for %%a in (ShowBubbles AutoClose AutoCopy) do reg add "HKCU\SOFTWARE\SkillBrains\Lightshot" /v "%%a" /t REG_DWORD /d "0" /f >nul 2>&1
reg add "HKCU\SOFTWARE\SkillBrains\Lightshot" /v "ProxyType" /t REG_DWORD /d "1" /f >nul 2>&1
goto CheckValue

:: Install Office
:Office
explorer https://drive.google.com/file/d/1a49CJtg9H4dZe3ZtF_xpxjuVDHmcqwz0/view
goto CheckValue

:StartMenu
    mode 49,16
    echo.
    echo.    %G%$.:k.:klk:.%R%                    .::....:::.
    echo.   %G%.knJzPkJnJYYJk\%R%            .:zKZNKZNKZNZ/:
    echo.      %G%zkJzJ.   :kJYk\:%R%    .:/ZKn/.   :zZKz.
    echo.       %G%zzkkBYzklzKZNKzk  :kzKzZnzKnnKZNzk/
    echo.        %G%.knkKZNKZNkkkZzzkkzJ:zKzKZNKzzk/
    echo.           %G%`````kJk. k?K:Kn. :nnK````
    echo.              %G%kNZn    kk z.   .kKZ:
    echo.             %G%Nzk/     kN.z.     kZNk
    echo.            %G%?zzN     :Zk kZ     .KZN:
    echo.            %G%KKZZ    nKZ: kBY:   /KZNk
    echo.            %G%KZkZ   nNkn   JBP.  kKZN/
    echo.            %G%.ZNk  .Kkk     nGk  .kNk
    echo.             %G%nKZNKZ:       kKZNKZ/
    echo.               %G%.kZk          .KZ/
    timeout /t 1 /nobreak >nul
    cls
    echo.
    echo.    %G%$.:k.:klk:.%R%                    .::....:::.
    echo.   %G%.knJzPkJnJYYJk\%R%            .:zKZNKZNKZNZ/:
    echo.      %G%zkJzJ.   :kJYk\:%R%    .:/ZKn/.   :zZKz.
    echo.       %G%zzkkBYzklzKZNKzk%R%  :kzKzZnzKnnKZNzk/
    echo.        %G%.knkKZNKZNkkkZzzk%R%kzJ:zKzKZNKzzk/
    echo.           %G%`````kJk. k?K%R%:Kn. :nnK````
    echo.              %G%kNZn    kk %R%z.   .kKZ:
    echo.             %G%Nzk/     kN.%R%z.     kZNk
    echo.            %G%?zzN     :Zk %R%kZ     .KZN:
    echo.            %G%KKZZ    nKZ: kBY:   /KZNk
    echo.            %G%KZkZ   nNkn   JBP.  kKZN/
    echo.            %G%.ZNk  .Kkk     nGk  .kNk
    echo.             %G%nKZNKZ:       kKZNKZ/
    echo.               %G%.kZk          .KZ/
    timeout /t 1 /nobreak >nul
    cls
    echo.
    echo.    %G%$.:k.:klk:.%R%                    .::....:::.
    echo.   %G%.knJzPkJnJYYJk\%R%            .:zKZNKZNKZNZ/:
    echo.      %G%zkJzJ.   :kJYk\:%R%    .:/ZKn/.   :zZKz.
    echo.       %G%zzkkBYzklzKZNKzk%R%  :kzKzZnzKnnKZNzk/
    echo.        %G%.knkKZNKZNkkkZzzk%R%kzJ:zKzKZNKzzk/
    echo.           %G%`````kJk. k?K%R%:Kn. :nnK````
    echo.              %G%kNZn    kk %R%z.   .kKZ:
    echo.             %G%Nzk/     kN.%R%z.     kZNk
    echo.            %G%?zzN     :Zk %R%kZ     .KZN:
    echo.            %G%KKZZ    nKZ: %R%kBY:   /KZNk
    echo.            %G%KZkZ   nNkn   %R%JBP.  kKZN/
    echo.            %G%.ZNk  .Kkk     %R%nGk  .kNk
    echo.             %G%nKZNKZ:       %R%kKZNKZ/
    echo.               %G%.kZk          %R%.KZ/

:Colors
    for /f "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set del=%%a
	set "cmdline=W=[97m,G=[90m,DRED=[31m,RED=[91m,B=[36m,C=[96m,S=[33m,Y=[93m,DG=[32m,M=[35m,GR=[92m,L=[4m,R=[0m,CYAN=[96m"
    set "%cmdline:,=" & set "%"
