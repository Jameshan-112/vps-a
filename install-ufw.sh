#!/bin/bash
apt update
apt upgrade -y
# 更新包列表
apt update

# 安装 UFW 防火墙
apt install -y ufw

# 默认拒绝所有传入连接
ufw default deny

# 允许 SSH 端口 (22)
ufw allow 22

# 启用 UFW 防火墙
ufw enable -y

echo "UFW 配置完成，默认拒绝所有入站连接，允许端口 22（SSH）。"
