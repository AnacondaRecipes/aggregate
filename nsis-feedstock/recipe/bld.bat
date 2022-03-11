robocopy nsis-zip "%PREFIX%"\NSIS /S
robocopy "%RECIPE_DIR%"\NSIS "%PREFIX%"\NSIS /S
robocopy access-control\Plugins\i386-unicode "%PREFIX%"\NSIS\Plugins\x86-unicode /S
:: Checking the ErrorLevel from robocopy is pointless.
exit /b 0
