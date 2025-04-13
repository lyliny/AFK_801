# AFK_801       
### TFM活动挂机       
       
* **自动执行的操作：**             
1. 声音提醒       
2. 后台识别活动（非最小化）       
3. 弹出窗口（强制弹出TFM窗口 [无论在做什么] ，便于执行自动按键）       
4. 自动按键（防挂机死、~~全自动~~等）  
自行调整功能（在.ahk文件最底下,注意[设置语法](https://wyagd001.github.io/v2/docs/index.htm))       
       
* **关于脚本：**       
1. 由于后台识别活动，因此脚本要在指定版本中使用（见脚本开头,现行默认为20打包版）       
2. 如需换房：  
将脚本复制成2份，注释脚本底下的Reload命令，脚本1：Send后添加房名如vanilla2，Run后填入脚本2地址；脚本2：Send添加房名如vanilla1，Run后填入脚本1地址。（多份脚本也如此往复）  
    <details>
    <summary>点此看换房代码示例</summary>
    <pre><code>
    Send "{Enter}{NumpadDiv}room{Space}vanilla1{Enter}" ;换房
    </code></pre>
    </details>
3. 卡多次活动：       
在活动的前一分钟进行声音提醒；在事先准备好的AFK房间，疯狂跳过地图以快速进入活动，然后快速进入其他房间，可拿到多倍活动奖励。
    <details>
    <summary>点此看卡活动代码示例</summary>
    <pre><code>
    
    </code></pre>
    </details>
4. **重要：由于AutoHotkey的特殊性质，因此最好不要在脚本运行时玩竞技游戏，不然我也不知道会发生什么**
       
* **食用方法：**       
       1. 安装软件[AutoHotkey](https://autohotkey.com/)       
       2. 使用[指定版本](https://github.com/lyliny/AFK_801/releases/)来进行游戏       
       3. 下载对应活动脚本（.ahk文件）       
       4. 双击下载的脚本即可食用       
       
* **好用程序：**       
       1. FindText：[英文版](https://www.autohotkey.com/boards/viewtopic.php?f=83&t=116471) ，[中文版](https://www.autoahk.com/archives/44766)  >>>  制作本脚本的工具      
       2. [Clicker](https://gitee.com/fasterthanlight/automatic_clicker_2/releases)       
       3. [ButtonAssist](https://github.com/zclucas/ButtonAssist/releases/)       
