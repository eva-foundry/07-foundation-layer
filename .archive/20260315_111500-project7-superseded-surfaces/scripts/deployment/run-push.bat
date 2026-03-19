@echo off
pwsh -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "C:\eva-foundry\07-foundation-layer\scripts\Push-CopilotInstructions.ps1" > "C:\eva-foundry\push-out.txt" 2>&1
echo EXIT_CODE=%ERRORLEVEL% >> "C:\eva-foundry\push-out.txt"
