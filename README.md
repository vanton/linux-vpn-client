# linux vpn client

## 项目介绍

linux 下连接 l2tp/ipsec vpn。
本地建立 vpn 隧道转发服务。

## 结构说明

```sh
vpn_client
    |-  install_vpn.sh  安装脚本。仅做了 centOS 和 ubuntu 配置。
    |-  start_vpn.sh    启动脚本
    |-  stop_vpn.sh     停止脚本
```

## 使用说明

注意：普通用户需要 `sudo` 运行。

### 安装时需要输入的参数说明：

* 你的VPN服务器IP:
* 你的IPsec预共享密钥: 在 vpn 服务器查看 `/etc/ipsec.secrets`
* 你的VPN用户名: 设置服务器时输入，在 vpn 服务器查看 `/etc/ppp/chap-secrets`
* 你的VPN密码: 同上。

### 修改服务端账号密码

单个用户修改

```sh
echo "用户名:$(openssl passwd -1 密码):xauth-psk\n" > /etc/ipsec.d/passwd
```

新增用户

```sh
echo "用户名:$(openssl passwd -1 密码):xauth-psk\n" >> /etc/ipsec.d/passwd
```

多个用户
```sh
echo "用户名1:$(openssl passwd -1 密码1):xauth-psk\n用户名2:$(openssl passwd -1 密码2):xauth-psk\n" > /etc/ipsec.d/passwd
```

## 参考文献

[setup-ipsec-vpn ## Linux VPN Clients](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients.md#linux-vpn-clients)
