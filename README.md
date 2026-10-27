# NapCat Stall Recovery

**English**: Troubleshooting and one-click recovery for NapCat "connection alive but no messages" stalls when running with AstrBot — see the recovery script and the 10-case playbook.

**English keywords**: NapCat stall, QQ bot not replying, OneBot v11, AstrBot, restart script, watchdog.

> 处理大肥鱼掉线或 NapCat 假死问题

QQ 机器人"突然不回消息"的排查与恢复。

面向 **NapCat + AstrBot** 这套组合。不是教程，是一份踩坑记录——把「连接显示正常但就是不回话」这类问题怎么定位、怎么救，写成可执行的步骤。

## 先看这张表

| 现象 | 大概率原因 | 处理 |
|---|---|---|
| 发了消息不回，连接显示正常 | NapCat 收消息通道僵死 | 跑 `一键恢复.bat` |
| 发了消息不回，连接显示断开 | 真的掉线 | 跑 `一键恢复.bat` |
| 只有表情/图片的消息不回 | 框架把空文本消息当空消息丢了 | 看 [排查手册 §2](排查手册.md) |
| 恢复后仍然不回 | 问题在框架侧，不是协议端 | 查框架日志，别再重启 |
| 一切正常但经常被踢下线 | 同时跑了两个 QQ 实例 | 见 [排查手册 §3](排查手册.md) |

## 一键恢复

Windows 下双击 `一键恢复.bat`。

**先改脚本顶部的四个变量**，否则它找不到你的安装：

```bat
set "NAPCAT_HOME=D:\napcat"
set "NAPCAT_BAT=%NAPCAT_HOME%\launcher-user.bat"
set "ONEBOT_PORT=6199"
set "BOT_QQ=在这里填你的机器人QQ号"
```

脚本做四件事：

1. 杀掉 QQ 和 NapCat
2. 删掉旧二维码（避免弹出过期的那张）
3. 重启，等 30 秒
4. 检查结果：连上了就结束；需要扫码就自动把二维码弹出来

### 为什么要"无条件重启"

因为**「在线」这个判断不可靠**。

我们遇到过：WebSocket 连接还在、心跳正常、进程也在跑，但一条消息都收不到。这种情况任何"在线检测"都会判定为健康，然后什么都不做。

**判断一个机器人是否健康，唯一可靠的标准是它能不能回你一句话。** 既然你都来点这个脚本了，说明已经判定它不健康了，那就直接重启。

### 代价

- 中断 30–60 秒，期间消息可能丢（不会补发）
- 一半左右的概率要重新扫码
- 一天重启两三次没问题，**十几次可能触发风控**
- 对话记录、记忆、配置都在磁盘上，重启不影响

## 什么时候不用跑

- 它**刚主动说过话**——通道是通的，不回你可能是别的原因
- 深夜——它可能本来就话少
- 你**刚跑过一次**——等一分钟，别连点

## 需要扫码时

二维码两分钟内有效。过期了就重新双击脚本，会重新生成。

如果脚本弹不出二维码，用面板入口（地址和 token 在 NapCat 启动日志里，通常长得像）：

```
http://127.0.0.1:6099/webui?token=你的token
```

## 内容

- `一键恢复.bat` — 恢复脚本
- `排查手册.md` — 十个具体故障的原因与判断方法

## 协议

MIT。随便用，出事别找我。

## 免责

自用脚本。QQ 协议端和非官方客户端存在账号风险，自行判断。
