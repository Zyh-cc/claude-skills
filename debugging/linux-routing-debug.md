---
领域: debugging
版本: v1.0
最后更新: 2026-04-03
适用工具: Claude Code
---

# Linux 多网卡路由排查与修复（流量走错网口）

## 版本日志
| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-04-03 | 初始版本，来自 MUST 项目 Jetson Nano 调试 |

## 问题场景

设备有多块网卡（如一块接路由器/外网，一块接局域网设备），外网请求全部失败，报 `No route to host` 或 `Destination Host Unreachable`，但网络配置看起来正常。

## 排查方法

### 第一步：确认流量从哪个网口出去

```bash
ping -c 3 目标域名或IP
```

看输出里的 `From` 行：
```
From luyang-desktop (172.16.0.100) icmp_seq=1 Destination Host Unreachable
```
`172.16.0.100` 是局域网设备网口的 IP，说明流量走错了。

### 第二步：查看路由表

```bash
ip route show
```

重点看 `default` 行：
```
default via 172.16.0.1 dev eth1  metric 20101  ← 数字小=优先级高
default via 192.168.1.1 dev eth0  metric 20102
```

metric 数字越小优先级越高。若内网设备网口的 metric 更小，外网流量就会走错。

### 第三步：查看所有网卡 IP

```bash
ip addr show
```

确认哪块网卡对应哪个网段。

## 解决方案

### 临时修复（立刻生效，重启失效）

```bash
sudo ip route del default via <错误网关IP> dev <错误网口>
# 例：
sudo ip route del default via 172.16.0.1 dev eth1
```

### 永久修复（NetworkManager，重启后保持）

```bash
# 查看连接名
nmcli connection show

# 设置该连接不作为默认出口
sudo nmcli connection modify "<连接名>" ipv4.never-default yes
sudo nmcli connection up "<连接名>"
```

撤销方法：
```bash
sudo nmcli connection modify "<连接名>" ipv4.never-default no
sudo nmcli connection up "<连接名>"
```

### 验证

```bash
ip route show       # 确认错误的 default 行消失
ping -c 3 目标域名  # 确认流量正常
```

## 踩过的坑

| 坑 | 原因 | 解决 |
|----|------|------|
| 局域网设备通信受影响 | 担心删默认路由影响局域网 | 不影响，局域网有专用子网路由条目（如 `172.16.0.0/16 dev eth1`）|
| 临时修复重启后失效 | `ip route del` 只改内存 | 用 nmcli 永久修改 |
| 不知道连接名 | nmcli 连接名和网口名不同 | 用 `nmcli connection show` 查 |

## 相关经验

- [whitelist-network-timesync.md](./whitelist-network-timesync.md) — 同一项目的网络受限校时方案
