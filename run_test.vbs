Set WshShell = CreateObject("WScript.Shell")
WshShell.Run "cmd /k echo Test VBScript wrapper && echo This window should stay open && pause", 1, True
WScript.Sleep 3000
MsgBox "Test complete! If you see command window stay open, VBScript works."