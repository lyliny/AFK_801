; CHATGPT
; 自动以管理员身份运行（根据ahk官方教程网站，此处代码如果 UAC 禁止，脚本会进入无限重启的循环之中;懒得让AI再改了！！！）
if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
    ExitApp
}

; 获取当前时间
FormatTime, currentTime, %A_Now%, HH:mm:ss
StringSplit, timeArray, currentTime, :

; 提取小时、分钟、秒
hours := timeArray1
minutes := timeArray2
seconds := timeArray3

; 如果秒数小于3，减去1分钟（去除脚本运行导致的秒数偏差）
if (seconds < 3)
{
    minutes -= 1
    if (minutes < 0)
    {
        minutes := 59
        hours -= 1
        if (hours < 0)
            hours := 23
    }
}

; 加？分钟[（活动时间间隔-1）分钟]
minutes += 14

; 处理分钟进位
if (minutes >= 60)
{
    minutes -= 60
    hours += 1
    if (hours >= 24)
        hours := 0
}

; 格式化小时和分钟
FormatTimeStr(val) {
    return (val < 10 ? "0" : "") . val
}
newTime := FormatTimeStr(hours) . ":" . FormatTimeStr(minutes)

; 定义任务名称
TaskName := "eventtime"
; 播放声音的 PowerShell 命令（隐藏执行）
psCommand := "powershell -windowstyle hidden -c (New-Object Media.SoundPlayer 'C:\Windows\Media\Alarm01.wav').PlaySync()"

; 创建计划任务命令
RunWait, %ComSpec% /c schtasks /Create /TN %TaskName% /TR "%psCommand%" /SC ONCE /ST %newTime% /F, , Hide

; 显示时间提示（调试）
;MsgBox, 已成功创建任务计划程序任务! 任务将在 %newTime% 播放声音。
