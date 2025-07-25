; 自动以管理员身份运行（根据ahk官方教程网站，此处代码如果被 UAC 禁止，脚本会进入无限重启的循环之中;使用前请修改 UAC 权限。懒得让AI再改了！！！）
;====================
;已经有人试过:ahk转圈/弹出窗口，无法关闭（只能重启电脑）,必须更改uac权限！！！
;====================
if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

#SingleInstance Force
Gui, Margin, 10, 10
Gui, Font, s10

; 第一部分:上次活动分钟 + 活动间隔分钟
Gui, Add, GroupBox, x10 w270 h170 Section, 一:上次分钟+间隔分钟-1分钟
Gui, Add, Text, xs+10 ys+30, 上次活动分钟（0-59）:
Gui, Add, Edit, vLastMin xs+180 ys+25 w80 Number Limit2
Gui, Add, Text, xs+10 ys+65, 活动间隔分钟（0-59）:
Gui, Add, Edit, vIntervalMin xs+180 ys+60 w80 Number Limit2
Gui, Add, Text, xs+25 ys+105, 提醒时间1:
Gui, Font, Bold ; 字体加粗
Gui, Add, Text, vResult1 xs+120 ys+105, 等待中...
Gui, Font, Norm ; 字体还原
Gui, Add, Button, gNetEventTimeFirst xs+170 ys+125 w90, 显示活动时间并提醒1
Gui, Add, Button, gDeleteTaskFirst xs+10 ys+130 w90, 删除提醒1

; 第二部分:下次活动分钟
Gui, Add, GroupBox, x10 w270 h145 Section, 二:下次活动分钟
Gui, Add, Text, xs+10 ys+30, 下次活动分钟（0-59）:
Gui, Add, Edit, vNextMin xs+180 ys+25 w80 Number Limit2
Gui, Add, Text, xs+25 ys+70, 提醒时间2:
Gui, Font, Bold ; 字体加粗
Gui, Add, Text, vResult2 xs+120 ys+70, 等待中...
Gui, Font, Norm ; 字体还原
Gui, Add, Button, gNetEventTimeSecond xs+170 ys+90 w90, 显示活动时间并提醒2
Gui, Add, Button, gDeleteTaskSecond xs+10 ys+95 w90, 删除提醒2

; 提示
Gui, Add, GroupBox, x10 w270 h105 Section, 脚本打开时间:%A_Hour%:%A_Min%
Gui, Add, Text, xs+5 ys+25, 第一部分,下次活动时间=提醒时间1+1分钟
Gui, Add, Text, xs+5 ys+45, 第二部分,下次活动时间=提醒时间2
Gui, Add, Text, xs+5 ys+65 w255, 建议:第二部分输入时-1分钟(下次活动时间=提醒时间2+1分钟),可以更早蹲活动

Gui, Show, , 活动提醒器（手动版）
return


NetEventTimeFirst:
    Gui, Submit, NoHide
    ; 输入验证
    if (LastMin = "" || IntervalMin = "") {
        MsgBox, 上次活动分钟 和 活动间隔分钟 不得为空！
        return
    }
    ; 转换前导零输入为数字
    LastMin := LastMin + 0
    IntervalMin := IntervalMin + 0

    if (LastMin < 0 || LastMin > 59) {
        MsgBox, 上次活动分钟 必须在0到59之间！
        return
    }
    if (IntervalMin < 0 || IntervalMin > 59) {
        MsgBox, 活动间隔分钟 必须在0到59之间！
        return
    }
    
    ; 计算下次活动分钟并处理进位
    totalMin := LastMin + IntervalMin - 1
    carryHours := totalMin // 60
    newMin := Mod(totalMin, 60)
    
    ; 获取当前时间并计算下次活动时间
    currentTime := A_Now
    currentHour := A_Hour
    currentMin := A_Min
    newHour := Mod(currentHour + carryHours, 24)
    
    ; 格式化显示结果
    formattedMin := newMin < 10 ? "0" newMin : newMin
    formattedHour := newHour < 10 ? "0" newHour : newHour
    newTime := formattedHour . ":" . formattedMin
    GuiControl,, Result1, % newTime
    
    ; 创建计划任务
    CreateTask(newTime, 1)
return


NetEventTimeSecond:
    Gui, Submit, NoHide
    ; 输入验证
    if (NextMin = "") {
        MsgBox, 下次活动分钟 不得为空！
        return
    }
    ; 转换前导零输入为数字
    NextMin := NextMin + 0
    
    if (NextMin < 0 || NextMin > 59) {
        MsgBox, 下次活动分钟 必须在0到59之间！
        return
    }
    
    ; 获取当前时间
    currentHour := A_Hour
    currentMin := A_Min
    
    ; 计算下次活动时间
    if (NextMin > currentMin) {
		; 如果输入分钟大于当前分钟，小时不变
        newHour := currentHour
        newMin := NextMin
    } else {
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
    GuiControl,, Result2, %  newTime
    
    ; 创建计划任务
    CreateTask(newTime, 2)
return


; 创建计划任务的函数（处理日期变更）
CreateTask(newTime, taskNum) {
    ; 分离小时和分钟
    newHour := SubStr(newTime, 1, 2)
    newMin := SubStr(newTime, 4, 2)
    
    ; 获取当前日期时间
    currentTime := A_Now
    currentYear := SubStr(currentTime, 1, 4)
    currentMonth := SubStr(currentTime, 5, 2)
    currentDay := SubStr(currentTime, 7, 2)
    currentHour := SubStr(currentTime, 9, 2)
    currentMin := SubStr(currentTime, 11, 2)
    
    ; 计算计划日期（默认为今天）
    planDate := currentYear . currentMonth . currentDay
    
    ; 检查是否需要推迟到明天
    if (newHour < currentHour || (newHour == currentHour && newMin <= currentMin)) {
        ; 如果新时间在当前时间之前，推迟到明天
        planDate += 1, Days
        FormatTime, planDate, %planDate%, yyyyMMdd
    }
    
    ; 格式化计划日期（任务计划程序要求的格式）
    formattedDate := SubStr(planDate, 1, 4) . "/" . SubStr(planDate, 5, 2) . "/" . SubStr(planDate, 7, 2)
    
    ; 任务计划程序名称
    TaskName := "EventTime" . taskNum
    
    ; PowerShell命令（播放系统提示音）
    psCommand := "powershell -windowstyle hidden -c (New-Object Media.SoundPlayer 'C:\Windows\Media\Alarm01.wav').PlaySync()"
    
	; 删除旧任务（如果存在）
    RunWait, %ComSpec% /c schtasks /Delete /TN %TaskName% /F, , Hide

    ; 创建计划任务（指定日期和时间）
    RunWait, %ComSpec% /c schtasks /Create /TN %TaskName% /TR "%psCommand%" /SC ONCE /SD %formattedDate% /ST %newTime% /F, , Hide
    
    ; 显示创建信息
    ;MsgBox, 已创建计划任务!`n任务名称: %TaskName%`n执行时间: %formattedDate% %newTime%
}


; 删除提醒任务1
DeleteTaskFirst:
	RunWait, %ComSpec% /c schtasks /Delete /TN EventTime1 /F, , Hide
	MsgBox, 删除提醒任务:EventTime1
return
; 删除提醒任务2
DeleteTaskSecond:
	RunWait, %ComSpec% /c schtasks /Delete /TN EventTime2 /F, , Hide
	MsgBox, 删除提醒任务:EventTime2
return


GuiClose:
ExitApp
