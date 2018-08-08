goto build
Doesn't link to vc runtime dll. Checked with dependency walker too.
$ ldd /f/nwani/aggregate/redis-feedstock/recipe/Library/bin/redis-server.exe
        ntdll.dll => /c/Windows/SYSTEM32/ntdll.dll (0x77720000)
        kernel32.dll => /c/Windows/system32/kernel32.dll (0x77600000)
        KERNELBASE.dll => /c/Windows/system32/KERNELBASE.dll (0x7fefd680000)
        dbghelp.dll => /c/Windows/system32/dbghelp.dll (0x7fef8a20000)
        msvcrt.dll => /c/Windows/system32/msvcrt.dll (0x7fefe690000)
        SHLWAPI.dll => /c/Windows/system32/SHLWAPI.dll (0x7feff650000)
        GDI32.dll => /c/Windows/system32/GDI32.dll (0x7fefe7f0000)
        USER32.dll => /c/Windows/system32/USER32.dll (0x77500000)
        LPK.dll => /c/Windows/system32/LPK.dll (0x7fefd870000)
        USP10.dll => /c/Windows/system32/USP10.dll (0x7fefd880000)
        PSAPI.DLL => /c/Windows/system32/PSAPI.DLL (0x778f0000)
        ADVAPI32.dll => /c/Windows/system32/ADVAPI32.dll (0x7feff8d0000)
        sechost.dll => /c/Windows/SYSTEM32/sechost.dll (0x7fefe730000)
        RPCRT4.dll => /c/Windows/system32/RPCRT4.dll (0x7fefe4c0000)
        SHELL32.dll => /c/Windows/system32/SHELL32.dll (0x7fefe8c0000)
:build

if "%ARCH%" == "32" (
  set ARCH=Win32
) else (
  set ARCH=x64
)

msbuild /p:Platform=%ARCH% /p:Configuration=Release /p:PlatformToolset=v%VS_VERSION:.=% %SRC_DIR%\msvs\RedisServer.sln
if errorlevel 1 exit 1

xcopy /s /y %SRC_DIR%\msvs\%ARCH%\Release\*.exe %LIBRARY_BIN%\
