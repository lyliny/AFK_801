; 自动以管理员身份运行（根据ahk官方教程网站，此处代码如果被 UAC 禁止，脚本会进入无限重启的循环之中;使用前请修改 UAC 权限。懒得让AI再改了！！！）
;====================
;已经有人试过：ahk转圈/弹出窗口，无法关闭（只能重启电脑）,必须更改uac权限！！！
;====================
if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

#SingleInstance Force
Gui, Margin, 10, 10
Gui, Font, s10

; 显示打开时间
Gui, Add, Text, w200, 脚本打开时间：%A_Hour%:%A_Min%

; 第一部分：上次活动分钟 + 活动间隔分钟
Gui, Add, GroupBox, w270 h180 Section, 上次活动分钟 + 活动间隔分钟(自动-1分钟)
Gui, Add, Text, xs+10 ys+30, 上次活动分钟（0-59）：
Gui, Add, Edit, vLastMin xs+180 ys+25 w80 Number Limit2
Gui, Add, Text, xs+10 ys+65, 活动间隔分钟（0-59）：
Gui, Add, Edit, vIntervalMin xs+180 ys+60 w80 Number
Gui, Add, Button, gCalculateFirst xs+10 ys+130 w90, 显示活动时间并提醒1
Gui, Add, Text, vResult1 xs+10 ys+105, 下次活动时间：等待...
Gui, Add, Button, gDeleteTaskFirst xs+170 ys+140 w90, 删除提醒1

; 第二部分：下次活动分钟
Gui, Add, GroupBox, x10 w270 h145 Section, 下次活动分钟
Gui, Add, Text, xs+10 ys+30, 下次活动分钟（0-59）：
Gui, Add, Edit, vNextMin xs+180 ys+25 w80 Number
Gui, Add, Button, gCalculateSecond xs+10 ys+95 w90, 显示活动时间并提醒2
Gui, Add, Text, vResult2 xs+10 ys+70, 下次活动时间：等待...
Gui, Add, Button, gDeleteTaskSecond xs+170 ys+105 w90, 删除提醒2

Gui, Show, , 活动提醒器(手动版)
return

CalculateFirst:
    Gui, Submit, NoHide

	; 验证输入范围
    If (LastMin = "" || IntervalMin = "")
    {
        MsgBox, 请输入上次分钟和间隔分钟！
        return
    }
    if (LastMin < 0 || LastMin > 59)
    {
        MsgBox, 上次分钟必须在0到59之间！
        return
    }
    if (IntervalMin < 0 || IntervalMin > 60)
    {
        MsgBox, 间隔分钟必须在0到60之间！
        return
    }
  
    ; 计算下次活动分钟并处理进位
    totalMin := LastMin + IntervalMin - 1
    carryHours := totalMin // 60
    newMin := Mod(totalMin, 60)
    
    ; 获取当前小时并计算新时间
    currentHour := A_Hour
    newHour := Mod(currentHour + carryHours, 24)
    
    ; 格式化显示结果
    formattedMin := newMin < 10 ? "0" newMin : newMin
    formattedHour := newHour < 10 ? "0" newHour : newHour
    newTime := formattedHour . ":" . formattedMin
    GuiControl,, Result1, % "下次活动时间：" newTime
    
    ; 创建计划任务
    TaskName := "eventtime1"
    psCommand := "powershell -windowstyle hidden -c (New-Object Media.SoundPlayer 'C:\Windows\Media\Alarm01.wav').PlaySync()"
    
    ; 删除旧任务（如果存在）
    RunWait, %ComSpec% /c schtasks /Delete /TN %TaskName% /F, , Hide
    
    ; 创建新任务
    RunWait, %ComSpec% /c schtasks /Create /TN %TaskName% /TR "%psCommand%" /SC ONCE /ST %newTime% /F, , Hide
    MsgBox, 已创建任务计划1! 将在 %newTime% 播放提醒音效。
return

CalculateSecond:
    Gui, Submit, NoHide
    If (NextMin = "")
    {
        MsgBox, 请输入下次分钟！
        return
    }
    
    ; 验证输入范围
    if (NextMin < 0 || NextMin > 59)
    {
        MsgBox, 下次分钟必须在0到59之间！
        return
    }
    
    ; 获取当前时间
    currentHour := A_Hour
    currentMin := A_Min
    
    ; 根据比较规则计算新时间
    if (NextMin > currentMin)
    {
        ; 如果输入分钟大于当前分钟，小时不变
        newHour := currentHour
        newMin := NextMin
    }
    else
    {
        ; 如果输入分钟小于等于当前分钟，小时加1
        newHour := currentHour + 1
        newMin := NextMin
        
        ; 处理24小时制循环
        if (newHour >= 24)
            newHour := 0
    }
    
    ; 格式化显示结果
    formattedMin := newMin < 10 ? "0" newMin : newMin
    formattedHour := newHour < 10 ? "0" newHour : newHour
    newTime := formattedHour . ":" . formattedMin
    GuiControl,, Result2, % "下次活动时间：" newTime
    
    ; 创建计划任务
    TaskName := "eventtime2"
    psCommand := "powershell -windowstyle hidden -c (New-Object Media.SoundPlayer 'C:\Windows\Media\Alarm01.wav').PlaySync()"
    
    ; 删除旧任务（如果存在）
    RunWait, %ComSpec% /c schtasks /Delete /TN %TaskName% /F, , Hide
    
    ; 创建新任务
    RunWait, %ComSpec% /c schtasks /Create /TN %TaskName% /TR "%psCommand%" /SC ONCE /ST %newTime% /F, , Hide
    MsgBox, 已创建任务计划2! 将在 %newTime% 播放提醒音效。
return

; 删除提醒任务1
DeleteTaskFirst:
	RunWait, %ComSpec% /c schtasks /Delete /TN eventtime1 /F, , Hide
return
; 删除提醒任务2
DeleteTaskSecond:
	RunWait, %ComSpec% /c schtasks /Delete /TN eventtime2 /F, , Hide
return

GuiClose:
ExitApp
