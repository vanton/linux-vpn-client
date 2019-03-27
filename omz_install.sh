#!/bin/bash

# sh -c "$(curl -fsSL https://raw.githubusercontent.com/vanton/linux-vpn-client/master/omz_install.sh)"

yum -y install zsh zsh-lovers
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# 替换
sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="tjkirch"/' .zshrc
sed -i 's/^plugins=(.*)/plugins=(git colored-man-pages colorize command-not-found man cp sudo yum python pip nvm npm node z zsh_reload zsh-syntax-highlighting)/' .zshrc

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
