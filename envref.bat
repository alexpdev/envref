@echo off
echo | set /p dummy="Refreshing environment variables..."
goto main
:SetEnvVars
    "%WinDir%\System32\Reg" QUERY "%~1" /v "%~2" > "%TEMP%\envset" 2>NUL
    for /f "usebackq skip=2 tokens=2,*" %%A IN ("%TEMP%\envset") do (
        echo/set "%~3=%%B"
    )
    goto :EOF
:GetEnvVars
    "%WinDir%\System32\Reg" QUERY "%~1" > "%TEMP%\envget"
    for /f "usebackq skip=2" %%A IN ("%TEMP%\envget") do (
        if /I not "%%~A"=="Path" (
            call :SetEnvVars "%~1" "%%~A" "%%~A"
        )
    )
    goto :EOF
:main
    echo/@echo off >"%TEMP%\_env.cmd"
    call :GetEnvVars "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" >> "%TEMP%\_env.cmd"
    call :GetEnvVars "HKCU\Environment">>"%TEMP%\_env.cmd" >> "%TEMP%\_env.cmd"
    call :SetEnvVars "HKLM\System\CurrentControlSet\Control\Session Manager\Environment" Path Path_HKLM >> "%TEMP%\_env.cmd"
    call :SetEnvVars "HKCU\Environment" Path Path_HKCU >> "%TEMP%\_env.cmd"
    echo/set "Path=%%Path_HKLM%%;%%Path_HKCU%%" >> "%TEMP%\_env.cmd"
    del /f /q "%TEMP%\envset" 2>nul
    del /f /q "%TEMP%\envget" 2>nul
    SET "OriginalUserName=%USERNAME%"
    SET "OriginalArchitecture=%PROCESSOR_ARCHITECTURE%"
    call "%TEMP%\_env.cmd"
    del /f /q "%TEMP%\_env.cmd" 2>nul
    SET "USERNAME=%OriginalUserName%"
    SET "PROCESSOR_ARCHITECTURE=%OriginalArchitecture%"
    echo | set /p dummy="Finished."
    echo .
