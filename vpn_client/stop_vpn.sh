#!/bin/bash

# NOTE 以下为控制字符数出，使用 echo -e 可以控制屏幕输出的格式
# NOTE 控制字符为不可见字符，可能会造成日志文件的过滤出现不可控结果
# bla="\033[30m" # 30 40 black   #000
red="\\033[31m" # 31 41 red     #c33
gre="\\033[32m" # 32 42 green   #3c3
yel="\\033[33m" # 33 43 yellow  #cc3
# blu="\\033[34m" # 34 44 blue    #33c
# mag="\\033[35m" # 35 45 magenta #c3c
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

# NOTE 停止通过 VPN 服务器发送数据：
echo -e "${yel}停止通过 VPN 服务器发送数据${cle}"
route del default dev ppp0

# NOTE 断开连接：
echo -e "${yel}断开连接${cle}"
case $rr in
    ubuntu)
        echo -e "${gre}Ubuntu & Debian${cle}"
        # ? Ubuntu & Debian
        echo "d myvpn" >/var/run/xl2tpd/l2tp-control
        ipsec down myvpn
    ;;
    centos)
        echo -e "${gre}CentOS & RHEL${cle}"
        # ? CentOS/RHEL & Fedora
        echo "d myvpn" >/var/run/xl2tpd/l2tp-control
        strongswan down myvpn
    ;;
    *)
        echo -e "${gre}unknown${cle}"
        # ? CentOS/RHEL & Fedora
        echo "d myvpn" >/var/run/xl2tpd/l2tp-control
        strongswan down myvpn
    ;;
esac

# NOTE VPN 断开，检查 IP 时候正常：
echo -e "${yel}VPN 断开，检查 IP 时候正常${cle}"
wget -qO- http://ipv4.icanhazip.com
echo -e "${red}^^^^^^^^^^^^^^^^${cle}"
echo -e "${red}以上命令应该返回 你的外部 IP${cle}"
