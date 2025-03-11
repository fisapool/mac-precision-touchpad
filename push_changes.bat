@echo off
echo ===== Pushing Changes to GitHub Fork =====
echo.

set /p message=Enter commit message: 

echo.
echo Step 1: Adding all changes to staging...
cd mac-precision-touchpad
git add .
echo [OK] Changes staged

echo.
echo Step 2: Committing changes...
git commit -m "%message%"
echo [OK] Changes committed

echo.
echo Step 3: Pushing to remote repository...
git push
echo [OK] Changes pushed to remote repository

echo.
echo =======================================
echo   Push Complete
echo =======================================
echo Your changes have been successfully pushed to your fork.
echo.
pause 