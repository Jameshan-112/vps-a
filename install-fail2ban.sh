#!/bin/bash

# 更新软件包并安装 fail2ban
apt update
apt upgrade -y
apt install fail2ban -y

# 配置 fail2ban
cat <<EOT > /etc/fail2ban/jail.local
#DEFAULT-START
[DEFAULT]
bantime = 600
findtime = 300
maxretry = 5
banaction = iptables-allports
action = %(action_mwl)s
#DEFAULT-END

[sshd]
ignoreip = 127.0.0.1/8
enabled = true
filter = sshd
port = 22
maxretry = 2
findtime = 300
bantime = 600
banaction = iptables-allports
action = %(action_mwl)s
logpath = /var/log/auth.log
EOT

# 尝试启动 fail2ban 服务
systemctl start fail2ban 2>/dev/null

# 检查启动是否报错
if [[ $? -ne 0 ]]; then
    echo "Adding 'backend = systemd' to /etc/fail2ban/jail.local due to systemctl error."
    sed -i '/^\[DEFAULT\]/a backend = systemd' /etc/fail2ban/jail.local
    systemctl start fail2ban
fi

# 启动并启用 fail2ban
systemctl enable fail2ban
