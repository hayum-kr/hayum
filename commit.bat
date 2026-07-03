@echo off
setlocal
REM == Move to this batch file's folder (repo root) ==
cd /d "%~dp0"

REM ============ Git: pull -> commit -> push ============
REM Commit message: from arg (commit.bat "msg"), else prompt, else date/time
set "MSG=%~1"
if "%MSG%"=="" set /p MSG=Commit message (Enter=auto):
if "%MSG%"=="" set "MSG=update %DATE% %TIME%"

call :clean

echo [git] 1/4 pull (rebase, autostash) - get remote changes first
git pull --rebase --autostash
if errorlevel 1 (
    echo [git] pull failed - re-cleaning Google Drive desktop.ini and retrying once...
    call :clean
    git pull --rebase --autostash || goto :error
)

echo [git] 2/4 add -A
git add -A

echo [git] 3/4 commit : %MSG%
git commit -m "%MSG%"
if errorlevel 1 echo [git] Nothing to commit, skipped

echo [git] 4/4 push
git push
if errorlevel 1 (
    echo [git] push failed - re-cleaning Google Drive desktop.ini and retrying once...
    call :clean
    git push || goto :error
)

echo.
echo [git] Done
pause
goto :eof

REM ---- Delete Google Drive desktop.ini junk from inside .git ----
:clean
echo [git] 0/4 clean Google Drive desktop.ini inside .git
for /r ".git" %%f in (desktop.ini) do @(attrib -s -h "%%f" >nul 2>&1 & del /f /q "%%f" >nul 2>&1)
exit /b 0

:error
echo.
echo [git] !!! Error - check messages above (conflict / auth / remote / network)
echo   - On conflict: fix files, then  git rebase --continue   OR   git rebase --abort
echo   - If it still says "bad object refs/desktop.ini", Google Drive keeps
echo     re-creating junk files. Consider moving this repo OUT of Google Drive.
pause
exit /b 1
