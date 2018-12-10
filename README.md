# linux vpn client

## 项目介绍

linux 下连接 l2tp/ipsec vpn。
本地建立 vpn 隧道转发服务。

> **Ubuntu 17.10 及 以后版本，可以使用 network-manager-l2tp 管理。**
1. Install network-manager-l2tp:

    ```sh
    sudo apt install network-manager-l2tp network-manager-l2tp-gnome
    ```

2. Settings > Network > Click the + button > Select “Layer 2 Tunneling Protocol (L2TP)”

3. 填写服务器，用户名，密码。（注意，密码框后的 ? 点击选择存储密码）

4. Click IPSec Settings…

    > 选择 “Enable IPsec tunnel to L2TP host”
    > 填写 ”Pre-shared key“
    > Advanced 下：
    > Phase 1 Algorithms 填写 “3des-sha1-modp1024”
    > Phase 2 Algorithms 填写 “3des-sha1”
    > 选择 “Enforce UDP encapsulation”
    > 保存

5. disable xl2tpd

    ```sh
    sudo service xl2tpd stop
    sudo systemctl disable xl2tpd
    ```

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
{
    echo "用户名1:$(openssl passwd -1 密码1):xauth-psk"
    echo "用户名2:$(openssl passwd -1 密码2):xauth-psk"
} > /etc/ipsec.d/passwd
```

## 参考文献

[setup-ipsec-vpn ## Linux VPN Clients](https://github.com/hwdsl2/setup-ipsec-vpn/blob/master/docs/clients.md#linux-vpn-clients)
