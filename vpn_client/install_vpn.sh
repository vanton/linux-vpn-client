#!/bin/bash

# NOTE 以下为控制字符数出，使用 echo -e 可以控制屏幕输出的格式
# NOTE 控制字符为不可见字符，可能会造成日志文件的过滤出现不可控结果
# bla="\033[30m" # 30 40 black   #000
red="\\033[31m" # 31 41 red     #c33
gre="\\033[32m" # 32 42 green   #3c3
yel="\\033[33m" # 33 43 yellow  #cc3
# blu="\\033[34m" # 34 44 blue    #33c
mag="\\033[35m" # 35 45 magenta #c3c
# cya="\\033[36m" # 36 46 cyan    #3cc
# whi="\\033[37m" # 37 47 white   #ccc
cle="\\033[0m" # clear

# reD="\\033[4;31m"  # 31 41 red   #c33
# grE="\\033[4;32m"  # 32 42 green #3c3
# RED="\\033[41;37m" # 37 47 white on red  #ccc #c33
# BLU="\\033[44;37m" # 37 47 white on blue #ccc #33c
# bol="\\033[1m" # bold
# und="\\033[4m" # underline

# NOTE 判断系统版本
rr=""
release=$(cat /proc/version)
release=$(echo "$release" | tr '[:upper:]' '[:lower:]')
echo "$release"
if [[ $release =~ "ubuntu" ]] || [[ $release =~ "debian" ]]; then
	# ? Ubuntu & Debian
	echo -e "${yel}Ubuntu & Debian${cle}"
	rr="ubuntu"
fi

if [[ $release =~ "centos" ]] || [[ $release =~ "red hat" ]]; then
	# ? CentOS & RHEL
	echo -e "${yel}CentOS & RHEL${cle}"
	rr="centos"
fi

# NOTE 安装依赖
echo -e "${yel}安装依赖${cle}"
case $rr in
ubuntu)
	echo -e "${gre}Ubuntu & Debian${cle}"
	# ? Ubuntu & Debian
	apt-get update
	apt-get -y install strongswan xl2tpd
	apt-get -y install ack-grep
	;;
centos)
	echo -e "${gre}CentOS & RHEL${cle}"
	# ? CentOS/RHEL & Fedora
	yum -y install epel-release
	yum --enablerepo=epel -y install strongswan xl2tpd
	yum --enablerepo=epel -y install ack
	;;
*)
	echo -e "${gre}unknown${cle}"
	# ? CentOS/RHEL & Fedora
	yum -y install epel-release
	yum --enablerepo=epel -y install strongswan xl2tpd
	yum --enablerepo=epel -y install ack
	;;
esac

# NOTE 创建 VPN 变量
# ? 用户输入
echo -e -n "${mag}你的VPN服务器IP:${cle} "
read -r VPN_SERVER_IP
echo "$VPN_SERVER_IP" >"$HOME/.vpn_config"

echo -e -n "${mag}你的IPsec预共享密钥:${cle} "
read -r VPN_IPSEC_PSK

echo -e -n "${mag}你的VPN用户名:${cle} "
read -r VPN_USER

echo -e -n "${mag}你的VPN密码:${cle} "
read -r VPN_PASSWORD

# NOTE 配置 strongSwan
echo -e "${yel}配置 strongSwan${cle}"
cat >/etc/ipsec.conf <<EOF
# ipsec.conf - strongSwan IPsec configuration file

# basic configuration

config setup
  # strictcrlpolicy=yes
  # uniqueids = no

# Add connections here.

# Sample VPN connections

conn %default
  ikelifetime=60m
  keylife=20m
  rekeymargin=3m
  keyingtries=1
  keyexchange=ikev1
  authby=secret
  ike=aes256-sha1-modp2048,aes128-sha1-modp2048!
  esp=aes256-sha1-modp2048,aes128-sha1-modp2048!

conn myvpn
  keyexchange=ikev1
  left=%defaultroute
  auto=add
  authby=secret
  type=transport
  leftprotoport=17/1701
  rightprotoport=17/1701
  right=$VPN_SERVER_IP
EOF

cat >/etc/ipsec.secrets <<EOF
: PSK "$VPN_IPSEC_PSK"
EOF

chmod 600 /etc/ipsec.secrets

# NOTE 修改系统配置
echo -e "${yel}修改系统配置${cle}"
case $rr in
ubuntu)
	echo -e "${gre}Ubuntu 不需要修改${cle}"
	;;
centos)
	echo -e "${gre}CentOS & RHEL${cle}"
	# ! For CentOS/RHEL & Fedora ONLY
	mv /etc/strongswan/ipsec.conf /etc/strongswan/ipsec.conf.old 2>/dev/null
	mv /etc/strongswan/ipsec.secrets /etc/strongswan/ipsec.secrets.old 2>/dev/null
	ln -s /etc/ipsec.conf /etc/strongswan/ipsec.conf
	ln -s /etc/ipsec.secrets /etc/strongswan/ipsec.secrets
	;;
*)
	echo -e "${gre}unknown 不需要修改${cle}"
	;;
esac

# NOTE 配置 xl2tpd
echo -e "${yel}配置 xl2tpd${cle}"
cat >/etc/xl2tpd/xl2tpd.conf <<EOF
[lac myvpn]
lns = $VPN_SERVER_IP
ppp debug = yes
pppoptfile = /etc/ppp/options.l2tpd.client
length bit = yes
EOF

cat >/etc/ppp/options.l2tpd.client <<EOF
ipcp-accept-local
ipcp-accept-remote
refuse-eap
require-chap
noccp
noauth
mtu 1280
mru 1280
noipdefault
defaultroute
usepeerdns
connect-delay 5000
name $VPN_USER
password $VPN_PASSWORD
EOF

chmod 600 /etc/ppp/options.l2tpd.client

echo -e "${red}配置完成，请运行 ./start_vpn.sh 启动${cle}"
