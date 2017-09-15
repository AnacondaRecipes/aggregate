robocopy nsis-zip "%PREFIX%"\NSIS /S
robocopy "%RECIPE_DIR%"\NSIS "%PREFIX%"\NSIS /S
:: Checking the ErrorLevel from robocopy is pointless.
exit /b 0
