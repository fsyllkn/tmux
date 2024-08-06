#!/bin/bash

# 确保脚本以 root 用户身份运行
if [ "$EUID" -ne 0 ]; then
  echo "请以 root 身份运行此脚本"
  exit
fi

# 检测操作系统并安装 tmux
if [ -f /etc/redhat-release ]; then
    # CentOS 系统
    echo "检测到 CentOS 系统，正在安装 tmux..."
    yum update -y
    yum install -y tmux
elif [ -f /etc/lsb-release ] || [ -f /etc/debian_version ]; then
    # Ubuntu/Debian 系统
    echo "检测到 Ubuntu/Debian 系统，正在安装 tmux..."
    apt-get update -y
    apt-get install -y tmux
else
    echo "不支持的操作系统。请手动安装 tmux。"
    exit 1
fi

# 添加自动连接 tmux 的脚本到 .bashrc
echo "正在配置 .bashrc..."
BASHRC_FILE="$HOME/.bashrc"
TMUX_CONFIG='if [[ -n "$PS1" ]] && [[ -z "$TMUX" ]] && [[ -n "$SSH_CONNECTION" ]]; then
  tmux new -As0
fi'

# 检查 .bashrc 中是否已经包含 tmux 配置
if ! grep -q "tmux new -As0" "$BASHRC_FILE"; then
    echo "$TMUX_CONFIG" >> "$BASHRC_FILE"
    echo "已将 tmux 配置添加到 .bashrc"
else
    echo ".bashrc 中已存在 tmux 配置"
fi

# 重新加载 .bashrc
echo "正在重新加载 .bashrc..."
source "$BASHRC_FILE"

echo "设置完成。请重新连接 SSH 会话以查看效果。"
