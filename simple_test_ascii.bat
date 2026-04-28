@echo off
echo ====================================
echo     Simple ASCII Test Script
echo ====================================
echo.
echo This script uses only ASCII characters
echo to avoid encoding issues.
echo.
echo Testing basic commands...
echo.
echo 1. Testing ECHO command:
echo Hello World
echo.
echo 2. Testing PAUSE command:
echo Press any key to continue...
pause > nul
echo.
echo 3. Testing directory change:
cd /d "E:\openclaw-data\.openclaw\workspace"
echo Current directory: %cd%
echo.
echo 4. Testing file existence:
if exist "test_english.bat" (
    echo OK: test_english.bat exists
) else (
    echo ERROR: test_english.bat not found
)
echo.
echo ====================================
echo Test completed successfully!
echo If you see all messages, script works.
echo ====================================
pause