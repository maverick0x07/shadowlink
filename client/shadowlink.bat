@echo off
chcp 65001 >nul
echo [31m                                                  				[0m
echo [31m    ▄▄▄▄▄    ▄  █ ██   ██▄   ████▄   ▄ ▄   █    ▄█    ▄   █  █▀ [0m
echo [31m   █     ▀▄ █   █ █ █  █  █  █   █  █   █  █    ██     █  █▄█   [0m
echo [31m ▄  ▀▀▀▀▄   ██▀▀█ █▄▄█ █   █ █   █ █ ▄   █ █    ██ ██   █ █▀▄   [0m
echo [31m  ▀▄▄▄▄▀    █   █ █  █ █  █  ▀████ █  █  █ ███▄ ▐█ █ █  █ █  █  [0m
echo [31m               █     █ ███▀         █ █ █      ▀ ▐ █  █ █   █   [0m
echo [31m              ▀     █                ▀ ▀           █   ██  ▀    [0m
echo [31m                   ▀                                            
echo [0m
setlocal enabledelayedexpansion
echo;
echo Fetching system network information
:: Function to get system network adapters and their IPs
call :get_system_adapters

:: Check if "env" file exists and compare entries
if exist env (
    call :check_env_file
)

:: Ask user to select adapters if entries do not match
:select_adapters
set count=0

:: Run PowerShell command to get sorted network adapters by name
for /f "tokens=*" %%A in ('powershell -Command "Get-NetAdapter | Sort-Object Name | Select-Object -ExpandProperty Name"') do (
    set /a count+=1
    set "nic[!count!]=%%A"
)

if %count%==0 (
    echo No network adapters found.
    exit /b
)

:: Ask user to select "Starlink" adapter
echo.
echo Select the network adapter for "[33mStarlink[0m":
echo;
for /l %%i in (1,1,%count%) do (
    echo %%i. !nic[%%i]!
)
echo;
set /p choice="Choose an option: "

:validate_starlink
if not defined nic[%choice%] (
    echo Invalid selection. Please enter a valid number from the list above.
    set /p choice="Choose an option: "
    goto validate_starlink
)
set "starlink_adapter=!nic[%choice%]!"
echo Starlink adapter selected: [34m!starlink_adapter![0m

:: Retrieve IPv4 address for Starlink adapter
for /f "tokens=*" %%B in ('powershell -Command "Get-NetIPAddress -InterfaceAlias '!starlink_adapter!' -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress"') do (
    set "starlink_ipv4=%%B"
)

if not defined starlink_ipv4 (
    echo Error: No IPv4 address found for [34m!starlink_adapter![0m..
    exit /b
)

echo Starlink IPv4 address: [34m!starlink_ipv4![0m

:: Ask user to select "Iran Internet" adapter
echo.
echo Select the network adapter for "[33mIran Internet[0m":
echo;
set /p choice="Choose an option: "

:validate_iran
if not defined nic[%choice%] (
    echo Invalid selection. Please enter a valid number from the list above.
    set /p choice="Choose an option: "
    goto validate_iran
)
set "iran_adapter=!nic[%choice%]!"
echo Iran Internet adapter selected: [34m!iran_adapter![0m

:: Retrieve IPv4 address for Iran Internet adapter
for /f "tokens=*" %%C in ('powershell -Command "Get-NetIPAddress -InterfaceAlias '!iran_adapter!' -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress"') do (
    set "iran_ipv4=%%C"
)

if not defined iran_ipv4 (
    echo Error: No IPv4 address found for !iran_adapter!..
    exit /b
)

echo Iran Internet IPv4 address: [34m!iran_ipv4![0m

:: Ask user to enter "Bridge Server" domain or IP address
:enter_bridge_server
echo.
set /p bridge_server="Enter "[33mBridge Server[0m" domain or IP address: "

:: Trim spaces and validate input
for /f "tokens=* delims= " %%X in ("!bridge_server!") do set "bridge_server=%%X"

if "!bridge_server!"=="" (
    echo Error: Bridge Server cannot be empty. Please enter a valid value.
    goto enter_bridge_server
)

:: Ask user to enter UUID
:enter_uuid
echo.
set /p uuid="Please enter the "[33mUUID[0m": "

:: Validate UUID (simple check for non-empty)
if "!uuid!"=="" (
    echo Please enter a valid UUID.
    goto enter_uuid
)

:: Save selections to "env" file
(
    echo starlink_nic=!starlink_adapter!
    echo starlink_ipv4=!starlink_ipv4!
    echo iran_internet_nic=!iran_adapter!
    echo iran_internet_ipv4=!iran_ipv4!
    echo bridge_server=!bridge_server!
    echo uuid=!uuid!
) > env
echo;
echo [34mSelections and IP addresses saved to "env" file.[0m
echo;
:: Ensure the env file is fully created before proceeding
timeout /t 2 >nul

:: Read values from the env file into variables, excluding NIC values
for /f "tokens=1,2 delims==" %%a in ('type env') do (
    set %%a=%%b
)

:: Use PowerShell to replace values in sample_config.json and create tunnel.json
powershell -Command "(Get-Content sample_config.json) -replace 'starlink_ipv4', '%starlink_ipv4%' -replace 'iran_internet_ipv4', '%iran_internet_ipv4%' -replace 'bridge_server', '%bridge_server%' -replace 'uuid', '%uuid%' | Set-Content tunnel.json"

:: Check if tunnel.json exists, then run Xray
if exist tunnel.json (
	echo Launching [31mShadowlink[0m Tunnel:
	echo;
    xray run -c tunnel.json
) else (
    echo tunnel.json not found.
)

goto :eof

:: Function to get system network adapters and their IPs
:get_system_adapters
set "system_adapters="

for /f "tokens=*" %%A in ('powershell -Command "Get-NetAdapter | Sort-Object Name | Select-Object -ExpandProperty Name"') do (
    set "system_nic=%%A"
    
    for /f "tokens=*" %%B in ('powershell -Command "Get-NetIPAddress -InterfaceAlias '%%A' -AddressFamily IPv4 | Select-Object -ExpandProperty IPAddress"') do (
        set "system_ipv4=%%B"
        set "system_adapters=!system_adapters!!system_nic!-!system_ipv4! "
    )
)
echo [32m DONE! [0m
echo;
goto :eof

:: Function to check if the env entries match the system's adapters and IPs
:check_env_file
setlocal enabledelayedexpansion

:: Read the "env" file
for /f "tokens=1,2 delims==" %%i in (env) do (
    if "%%i"=="starlink_nic" set "env_starlink_nic=%%j"
    if "%%i"=="starlink_ipv4" set "env_starlink_ipv4=%%j"
    if "%%i"=="iran_internet_nic" set "env_iran_nic=%%j"
    if "%%i"=="iran_internet_ipv4" set "env_iran_ipv4=%%j"
    if "%%i"=="bridge_server" set "env_bridge_server=%%j"
    if "%%i"=="uuid" set "env_uuid=%%j"
)

:: Trim spaces from the variables
for %%X in (env_starlink_nic env_starlink_ipv4 env_iran_nic env_iran_ipv4 env_bridge_server env_uuid) do (
    for /f "tokens=* delims= " %%Y in ("!%%X!") do set "%%X=%%Y"
)

set "starlink_found=false"
set "iran_found=false"

:: Check if Starlink NIC and IP exist in the system
for %%A in (!system_adapters!) do (
    if "%%A"=="!env_starlink_nic!-!env_starlink_ipv4!" set "starlink_found=true"
)

:: Check if Iran Internet NIC and IP exist in the system
for %%A in (!system_adapters!) do (
    if "%%A"=="!env_iran_nic!-!env_iran_ipv4!" set "iran_found=true"
)

:: Ensure Bridge Server is not empty
if not defined env_bridge_server (
    echo [31mBridge Server entry is missing in the env file. Please enter it again.[0m
    endlocal
    goto select_adapters
)

if "!env_bridge_server!"=="" (
    echo [31mBridge Server entry is empty. Please enter it again.[0m
    endlocal
    goto select_adapters
)

:: Ensure UUID is not empty
if not defined env_uuid (
    echo [31mUUID entry is missing in the env file. Please enter it again.[0m
    endlocal
    goto select_adapters
)

:: If adapters mismatch, ask for re-selection
if not "!starlink_found!"=="true" (
    echo [31mStarlink NIC and IPv4 do not match. Please select again.[0m
    endlocal
    goto select_adapters
)

if not "!iran_found!"=="true" (
    echo [31mIran Internet NIC and IPv4 do not match. Please select again.[0m
    endlocal
    goto select_adapters
)

:: Everything matches, exit script
echo [32m Env file entries match the system's network adapters and IPs. [0m
echo;
:: Read values from the env file into variables, excluding NIC values
for /f "tokens=1,2 delims==" %%a in ('type env') do (
    set %%a=%%b
)

:: Use PowerShell to replace values
powershell -Command "(Get-Content sample_config.json) -replace 'starlink_ipv4', '%starlink_ipv4%' -replace 'iran_internet_ipv4', '%iran_internet_ipv4%' -replace 'bridge_server', '%bridge_server%' -replace 'uuid', '%uuid%' | Set-Content tunnel.json"
if exist tunnel.json (
	echo Launching [31mShadowlink[0m Tunnel:
	echo;
    xray run -c tunnel.json
) else (
    echo tunnel.json not found.
)
echo Press any key to exit.
pause >nul
endlocal
exit