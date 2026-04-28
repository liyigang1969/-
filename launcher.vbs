' OpenClaw Launcher VBScript
' Double-click to run

Set WshShell = CreateObject("WScript.Shell")

' Test Node.js
WshShell.Run "cmd /k echo Testing Node.js... && C:\nodejs\node.exe --version && pause", 1, True

' Test F drive
WshShell.Run "cmd /k echo Testing F drive... && dir F:\openclaw-data\.openclaw && pause", 1, True

' Start OpenClaw
WshShell.Run "cmd /k echo Starting OpenClaw Gateway... && echo. && set OPENCLAW_DATA=F:\openclaw-data\.openclaw && set OPENCLAW_STATE_DIR=F:\openclaw-data\.openclaw && cd /d C:\Users\lenovo\AppData\Local\Temp\openclaw-usb\openclaw && C:\nodejs\node.exe openclaw.mjs gateway --port 3003 --log-level info && pause", 1, True

MsgBox "OpenClaw launch completed. Check the command windows for output.", vbInformation, "OpenClaw Launcher"