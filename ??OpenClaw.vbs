Set WshShell = CreateObject("WScript.Shell")

' 检查E盘上的OpenClaw-U盘版.exe
If FileExists("E:\OpenClaw-U盘版.exe") Then
    WshShell.Run "E:\OpenClaw-U盘版.exe", 1, False
    MsgBox "OpenClaw 正在启动...", vbInformation, "OpenClaw 启动器"
Else
    MsgBox "错误：未找到 E:\OpenClaw-U盘版.exe" & vbCrLf & "请确保文件存在于E盘根目录", vbCritical, "启动错误"
End If

Function FileExists(filePath)
    Set fso = CreateObject("Scripting.FileSystemObject")
    FileExists = fso.FileExists(filePath)
End Function