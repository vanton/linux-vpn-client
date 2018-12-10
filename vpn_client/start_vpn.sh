#!/bin/bash

# NOTE 以下为控制字符数出，使用 echo -e 可以控制屏幕输出的格式
# NOTE 控制字符为不可见字符，可能会造成日志文件的过滤出现不可控结果
# bla="\033[30m" # 30 40 black   #000
red="\\033[31m"   # 31 41 red     #c33
gre="\\033[32m"   # 32 42 green   #3c3
yel="\\033[33m"   # 33 43 yellow  #cc3
# blu="\\033[34m" # 34 44 blue    #33c
mag="\\033[35m"   # 35 45 magenta #c3c
# cya="\\033[36m" # 36 46 cyan    #3cc
# whi="\\033[37m" # 37 47 white   #ccc
cle="\\033[0m"    # clear

reD="\\033[4;31m" # 31 41 red   #c33
# grE="\\033[4;32m"  # 32 42 green #3c3
# RED="\\033[41;37m" # 37 47 white on red  #ccc #c33
# BLU="\\033[44;37m" # 37 47 white on blue #ccc #33c
# bol="\\033[1m" # bold
# und="\\033[4m" # underline

export LC_CTYPE=en_US.UTF-8

h() {
	param=(
		"ppp.*"
		"inet [0-9]*\\.[0-9]*\\.[0-9]*\\.[0-9]*"
		"from [0-9]*\\.[0-9]*\\.[0-9]*\\.[0-9]*\\[[0-9]*\\]"
		"to [0-9]*\\.[0-9]*\\.[0-9]*\\.[0-9]*\\[[0-9]*\\]"
	)
	_OPTS=" -i "
	n_flag=

	# set zsh compatibility
	[[ -n $ZSH_VERSION ]] && setopt localoptions && setopt ksharrays && setopt ignorebraces

	local _i=0

	if [[ -n $H_COLORS_FG ]]; then
		local _CSV="$H_COLORS_FG"
		local OLD_IFS="$IFS"
		IFS=','
		local _COLORS_FG=()
		for entry in $_CSV; do
			_COLORS_FG=("${_COLORS_FG[@]}" "$entry")
		done
		IFS="$OLD_IFS"
	else
		_COLORS_FG=(
			"underline bold red"
			"underline bold green"
			"underline bold yellow"
			"underline bold blue"
			"underline bold magenta"
			"underline bold cyan"
		)
	fi

	if [[ -n $H_COLORS_BG ]]; then
		local _CSV="$H_COLORS_BG"
		local OLD_IFS="$IFS"
		IFS=','
		local _COLORS_BG=()
		for entry in $_CSV; do
			_COLORS_BG=("${_COLORS_BG[@]}" "$entry")
		done
		IFS="$OLD_IFS"
	else
		_COLORS_BG=(
			"bold on_red"
			"bold on_green"
			"bold black on_yellow"
			"bold on_blue"
			"bold on_magenta"
			"bold on_cyan"
			"bold black on_white"
		)
	fi

	if [[ -z $n_flag ]]; then
		# inverted-colors-last scheme
		_COLORS=("${_COLORS_FG[@]}" "${_COLORS_BG[@]}")
	else
		# inverted-colors-first scheme
		_COLORS=("${_COLORS_BG[@]}" "${_COLORS_FG[@]}")
	fi

	if [ -n "$ZSH_VERSION" ]; then
		local WHICH="whence"
	else
		[ -n "$BASH_VERSION" ]
		local WHICH="type -P"
	fi

	if ! ACKGREP_LOC="$($WHICH ack-grep)" || [ -z "$ACKGREP_LOC" ]; then
		if ! ACK_LOC="$($WHICH ack)" || [ -z "$ACK_LOC" ]; then
			echo "ERROR: Could not find the ack or ack-grep commands"
			return 1
		else
			local ACK=$($WHICH ack)
		fi
	else
		local ACK=$($WHICH ack-grep)
	fi

	for keyword in "${param[@]}"; do
		# echo "!! "${keyword}
		local _COMMAND=$_COMMAND"$ACK $_OPTS --noenv --flush --passthru --color --color-match=\"${_COLORS[$_i]}\" '$keyword' |"
		_i=$_i+1
	done
	# trim ending pipe
	_COMMAND=${_COMMAND%?}
	# echo "$_COMMAND"
	cat - | eval $_COMMAND
}

countdown() {
	seconds_left=5
	# echo "请等待 ${seconds_left} 秒……"
	while [ $seconds_left -gt 0 ]; do
		echo -n $seconds_left
		sleep 1
		seconds_left=$((seconds_left - 1))
		echo -ne "\\r     \\r" #清除本行文字
	done
}

# NOTE 判断系统版本
rr=""
release=$(cat /proc/version)
release=$(echo "$release" | tr '[:upper:]' '[:lower:]')
echo "$release"
if [[ $release =~ "ubuntu" ]] || [[ $release =~ "debian" ]]; then
	# ? Ubuntu & Debian
	rr="ubuntu"
fi

if [[ $release =~ "centos" ]] || [[ $release =~ "red hat" ]]; then
	# ? CentOS & RHEL
	rr="centos"
fi

# NOTE 创建 xl2tpd 控制文件：
echo -e "${yel}创建 xl2tpd 控制文件${cle}"
mkdir -p /var/run/xl2tpd
touch /var/run/xl2tpd/l2tp-control

# NOTE 重启服务：
echo -e "${yel}重启服务${cle}"
service strongswan restart
service xl2tpd restart

# NOTE 等待服务启动：
echo -e "${reD}等待服务启动${cle}"
countdown

# NOTE 开始 IPsec 连接：
echo -e "${yel}开始 IPsec 连接${cle}"
case $rr in
ubuntu)
	echo -e "${gre}Ubuntu & Debian${cle}"
	# ? Ubuntu & Debian
	ipsec up myvpn | h
	;;
centos)
	echo -e "${gre}CentOS & RHEL${cle}"
	# ? CentOS/RHEL & Fedora
	strongswan up myvpn | h
	;;
*)
	echo -e "${gre}unknown${cle}"
	# ? CentOS/RHEL & Fedora
	strongswan up myvpn | h
	;;
esac

# NOTE 等待配置完成：
echo -e "${reD}等待配置完成${cle}"
countdown

# NOTE 开始 L2TP 连接：
echo -e "${yel}开始 L2TP 连接${cle}"
echo "c myvpn" >/var/run/xl2tpd/l2tp-control

# NOTE 等待 ip 连接：
echo -e "${reD}等待 ip 连接${cle}"
countdown

# NOTE 运行 ifconfig 并且检查输出
echo -e "${yel}运行 ifconfig 并且检查输出${cle}"
ifconfig | h

# NOTE 检查你现有的默认路由：
echo -e "${yel}检查你现有的默认路由${cle}"
ip route | h
gw=$(ip route | grep "default via" | cut -d " " -f 3)

# NOTE 从新的默认路由中排除你的 VPN 服务器 IP （替换为你自己的值）：
echo -e "${yel}从新的默认路由中排除你的 VPN 服务器 IP${cle}"
VPN_SERVER_IP=$(head -n 1 "$HOME/.vpn_config")
echo -e "${gre}VPN_SERVER_IP: ${VPN_SERVER_IP}${cle}"
echo -e "${gre}gw: ${gw}${cle}"
route add "$VPN_SERVER_IP" gw "$gw"

# NOTE 如果你的 VPN 客户端是一个远程服务器，则必须从新的默认路由中排除你的本地电脑的公有 IP，以避免 SSH 会话被断开：
echo -e "${yel}如果你的 VPN 客户端是一个远程服务器，则必须从新的默认路由中排除你的本地电脑的公有 IP，以避免 SSH 会话被断开${cle}"
echo -e "如果上方 ifconfig 不存在设备 ${reD}ppp0: ${cle}, 请按 ctrl+c 退出后重新运行"
# ? 用户输入
MY_IP=$(wget -qO- http://ipv4.icanhazip.com)
echo -e -n "${mag}本地电脑的公有 IP (${cle}$MY_IP${mag}):${cle} "
read -r MY_IP_INPUT
if [[ -n $MY_IP_INPUT ]]; then
	echo "input: $MY_IP_INPUT"
	route add "$MY_IP_INPUT" gw "$gw"
else
	echo "$MY_IP"
	route add "$MY_IP" gw "$gw"
fi

# NOTE 添加一个新的默认路由，并且开始通过 VPN 服务器发送数据：
echo -e "${yel}添加一个新的默认路由，并且开始通过 VPN 服务器发送数据${cle}"
route add default dev ppp0

# NOTE VPN 连接已成功完成。检查 VPN 是否正常工作：
echo -e "${yel}VPN 连接已成功完成。检查 VPN 是否正常工作${cle}"
wget -qO- http://ipv4.icanhazip.com
echo -e "${red}^^^^^^^^^^^^^^^^${cle}"
echo -e "${red}以上命令应该返回 你的 VPN 服务器 IP${cle}"
