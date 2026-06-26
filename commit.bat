@echo off
REM == Move to this batch file's folder (repo root) ==
cd /d "%~dp0"

REM ============ Git: pull -> commit -> push ============
REM Commit message: from arg (commit.bat "msg"), else prompt, else date/time
set "MSG=%~1"
if "%MSG%"=="" set /p MSG=Commit message (Enter=auto):
if "%MSG%"=="" set "MSG=update %DATE% %TIME%"

echo [git] 0/4 clean Google Drive desktop.ini inside .git
for /r ".git" %%f in (desktop.ini) do @(attrib -s -h "%%f" >nul 2>&1 & del /f /q "%%f" >nul 2>&1)

echo [git] 1/4 pull (rebase, autostash) - get remote changes first
git pull --rebase --autostash || goto :error

echo [git] 2/4 add -A
git add -A

echo [git] 3/4 commit : %MSG%
git commit -m "%MSG%"
if errorlevel 1 echo [git] Nothing to commit, skipped

echo [git] 4/4 push
git push || goto :error

echo.
echo [git] Done
pause
goto :eof

:error
echo.
echo [git] !!! Error - check messages above (conflict / auth / remote / network)
echo   - On conflict: fix files, then  git rebase --continue   OR   git rebase --abort
pause
exit /b 1
