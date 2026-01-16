: << 'CMDBLOCK'
@echo off
REM Polyglot wrapper: runs .sh scripts cross-platform
REM Usage: run-hook.cmd <script-name>
REM On Windows: uses Git Bash to execute the .sh script
REM On Unix: falls through to the shell portion below
"C:\Program Files\Git\bin\bash.exe" -l "%~dp0%~1"
exit /b
CMDBLOCK

# Unix shell runs from here (the CMDBLOCK above is a no-op heredoc in bash)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME="$1"
"${SCRIPT_DIR}/${SCRIPT_NAME}"
