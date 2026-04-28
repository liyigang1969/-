@echo off
echo ============================================
echo     Checking F Drive Access
echo ============================================
echo.

echo Testing F drive access...
echo.

echo Test 1: Basic directory listing
dir F:\ 2>nul
if errorlevel 1 (
    echo ❌ Cannot access F drive root
) else (
    echo ✅ F drive root accessible
)

echo.
echo Test 2: OpenClaw data directory
if exist "F:\openclaw-data\.openclaw" (
    echo ✅ OpenClaw directory exists
    dir "F:\openclaw-data\.openclaw" /b 2>nul
    if errorlevel 1 (
        echo ⚠️  Cannot list directory contents
    )
) else (
    echo ❌ OpenClaw directory not found
)

echo.
echo Test 3: File operations
echo Test > F:\access_test.txt 2>nul
if errorlevel 1 (
    echo ❌ Cannot write to F drive
) else (
    echo ✅ Can write to F drive
    del F:\access_test.txt 2>nul
    echo ✅ Can delete from F drive
)

echo.
echo ============================================
echo F Drive Status Summary
echo ============================================
echo.
echo If F drive is not accessible:
echo 1. Re-plug the USB drive
echo 2. Try different USB port
echo 3. Check Disk Management (diskmgmt.msc)
echo 4. Update USB drivers
echo.
echo For now, use E drive data directory
echo.
pause