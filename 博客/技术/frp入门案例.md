
经典的内网穿透方案

什么是内网穿透？举个栗子

假设你在家里，突然想连公司内网的一台 MySQL 数据库——但它压根没暴露在公网上，防火墙一关，外人连端口都扫不到。

怎么办？  
你可以让公司那台机器主动“打个洞”，把本地的 3306 端口（MySQL 默认端口）映射到一台你掌控的公网服务器上。比如：  
👉 公司机器 → 主动连上你的云服务器 → 把自己的 3306 暴露成云服务器的 6306。

然后你在家里，连 `your-server-ip:6306`，就等于连上了公司内网的数据库。

听起来很方便？  
**但——这真的很危险！**  
等于你亲手给内网开了一扇没上锁的后门。要是没做身份验证、流量加密、访问控制，黑客顺着这个洞摸进来，轻则数据泄露，重则整台机器沦陷。

### 那为啥还有人用内网穿透？

道理很简单：**穷 + 爱折腾 😅**
比如：
- 你有台 4 核 8G 的老笔记本，想跑个 Spring Boot + PostgreSQL 项目；
- 但你没有公网 IP（家里宽带是 NAT 后的，连路由器管理页都进不去）；
- 云服务器又贵——买台轻量应用服务器还要几十块一个月。
这时候，内网穿透就成了“低成本上云”的曲线救国方案：


实操
这里需要被准备一台有公网ip的服务器，也有不需要公网ip的方案，我之前写过通过cloudeflare 和一个域名就能实现内网穿透，当然这有点慢。

下面是需要公网地址的代理方案。

## frp 服务端

在frp服务端启动服务，做好tocken校验，防止谁都能用你的frp server

[frp下载地址](https://github.com/fatedier/frp/releases)

下载好后解压

在服务端你可以这么写

```toml
# 监听地址 & 控制端口（客户端靠这个连上来）
bindAddr = "0.0.0.0"
bindPort = 7000

# 🔐 强烈建议加 token！防“搭便车”
auth.method = "token"
auth.token = "你生成的随机长字符串，比如 openssl rand -hex 16"

# 可选：开个 dashboard，方便看状态
webServer.addr = "0.0.0.0"
webServer.port = 7500
webServer.user = "admin"
webServer.password = "别用 123456…… 换个复杂点的"

# （进阶）想更安全？开 TLS（需要证书）
# transport.tls.force = true
# transport.tls.certFile = "/path/to/server.crt"
# transport.tls.keyFile = "/path/to/server.key"
```

启动frp 服务端
```bash
./frps -c frps.toml
# 建议用 systemd 或 supervisor 守护，别直接前台跑
```


## frp 客户端

可以有多个客户端

```toml
erverAddr = "你云服务器的公网 IP"
serverPort = 7000

# 必须和服务端一致！否则连不上
auth.method = "token"
auth.token = "和上面一样的 token"

# 示例1：穿透 SSH（方便远程连内网机器）
[[proxies]]
name = "ssh-to-dev"
type = "tcp"
localIP = "127.0.0.1"   # 或具体内网 IP，如 192.168.1.100
localPort = 22
remotePort = 1022       # 公网访问时用 your-ip:1022 连 SSH

# 示例2：穿透 MySQL（⚠️ 谨慎开放！）
[[proxies]]
name = "mysql-local"
type = "tcp"
localIP = "127.0.0.1"
localPort = 3308        # 你本机 MySQL 实际端口
remotePort = 13309      # 公网访问端口 —— 别用 3306！避开扫描器默认目标
```
启动客户端：

```bash
./frpc -c frpc.toml
```

接下来你可以通过公网ip 端口访问你内网的服务啦。