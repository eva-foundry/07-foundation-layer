@echo off
pwsh -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "C:\AICOE\eva-foundry\07-foundation-layer\scripts\Push-CopilotInstructions.ps1" > "C:\AICOE\push-out.txt" 2>&1
echo EXIT_CODE=%ERRORLEVEL% >> "C:\AICOE\push-out.txt"
