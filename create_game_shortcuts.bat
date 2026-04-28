@echo off
chcp 65001 >nul

echo 正在创建游戏桌面快捷方式...

REM 创建逆水寒快捷方式
if exist "D:\Netease\逆水寒\Launcher.exe" (
    echo 创建逆水寒快捷方式...
    powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\逆水寒.lnk'); $shortcut.TargetPath = 'D:\Netease\逆水寒\Launcher.exe'; $shortcut.WorkingDirectory = 'D:\Netease\逆水寒'; $shortcut.Save()"
) else (
    echo 未找到逆水寒游戏文件
)

REM 创建梦幻西游快捷方式
if exist "D:\Program Files (x86)\梦幻西游\mhmain.exe" (
    echo 创建梦幻西游快捷方式...
    powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\梦幻西游.lnk'); $shortcut.TargetPath = 'D:\Program Files (x86)\梦幻西游\mhmain.exe'; $shortcut.WorkingDirectory = 'D:\Program Files (x86)\梦幻西游'; $shortcut.Save()"
) else (
    echo 未找到梦幻西游游戏文件
)

REM 创建剑侠世界.起源快捷方式
if exist "D:\SeasunJSQYos\SeasunGame.exe" (
    echo 创建剑侠世界.起源快捷方式...
    powershell -Command "$WshShell = New-Object -ComObject WScript.Shell; $shortcut = $WshShell.CreateShortcut('%USERPROFILE%\Desktop\剑侠世界.起源.lnk'); $shortcut.TargetPath = 'D:\SeasunJSQYos\SeasunGame.exe'; $shortcut.WorkingDirectory = 'D:\SeasunJSQYos'; $shortcut.Save()"
) else (
    echo 未找到剑侠世界.起源游戏文件
)

echo 完成!
pause
