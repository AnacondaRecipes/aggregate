goto build
The build requires vs 2015 (>= update 2) but the generated binaries do not
depend on any vsruntime dll.

(root) F:\nwani\mongo>ntldd mongo*
mongo.exe:
        dbghelp.dll => C:\Windows\system32\dbghelp.dll (0x0000000001170000)
        PSAPI.DLL => C:\Windows\system32\PSAPI.DLL (0x0000000000260000)
        ADVAPI32.dll => C:\Windows\system32\ADVAPI32.dll (0x0000000001280000)
        bcrypt.dll => C:\Windows\system32\bcrypt.dll (0x0000000002d30000)
        KERNEL32.dll => C:\Windows\system32\KERNEL32.dll (0x0000000001280000)
        SHELL32.dll => C:\Windows\system32\SHELL32.dll (0x0000000001c40000)
        VERSION.dll => C:\Windows\system32\VERSION.dll (0x0000000000260000)
        WINMM.dll => C:\Windows\system32\WINMM.dll (0x0000000002f50000)
        WS2_32.dll => C:\Windows\system32\WS2_32.dll (0x0000000000550000)
        USER32.dll => C:\Windows\system32\user32.dll (0x0000000001690000)
mongobridge.exe:
mongod.exe:
        pdh.dll => C:\Windows\system32\pdh.dll (0x0000000000550000)
mongoperf.exe:
mongos.exe:

It seems impossible to:
  - have py27 as build dep... and
  - have msvc 14 as compiler... and
  - not require/track any vc feature
:build

call "%VS140COMNTOOLS%..\..\VC\vcvarsall.bat" x%ARCH%

scons install ^
    --prefix=%LIBRARY_PREFIX% ^
    --disable-minimum-compiler-version-enforcement ^
    --link-model=object ^
    all ^
    VERBOSE=on ^
    -j%CPU_COUNT%


:: TODO: Figure out why the tests below don't run (scons is a .bat file ?)

%PYTHON% buildscripts\resmoke.py --suites=unittests
if errorlevel 1 exit 1

%PYTHON% buildscripts\resmoke.py --suites=dbtest
if errorlevel 1 exit 1
