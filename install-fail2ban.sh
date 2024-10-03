#!/bin/bash

# 更新软件包并安装 fail2ban
apt update
apt upgrade -y
apt install fail2ban -y

# 配置 fail2ban
cat <<EOT > /etc/fail2ban/jail.local
#DEFAULT-START
[DEFAULT]
bantime = 600y
findtime = 300y
maxretry = 2
banaction = iptables-allports
action = %(action_mwl)s
#DEFAULT-END

[sshd]
ignoreip = 127.0.0.1/8
enabled = true
filter = sshd
port = 22
maxretry = 2
findtime = 300y
bantime = 600y
banaction = iptables-allports
action = %(action_mwl)s
logpath = /var/log/auth.log
EOT

# 尝试启动 fail2ban 服务
systemctl start fail2ban 2>/dev/null

# 检查 fail2ban 服务是否正在运行
# 检查 Fail2ban 是否在运行
if ! systemctl is-active --quiet fail2ban; then
    echo "Fail2ban 出错了，正在执行出错后的步骤"
    
    # 添加 'backend = systemd' 到 /etc/fail2ban/jail.local
    echo "Adding 'backend = systemd' to /etc/fail2ban/jail.local."
    sed -i '/^\[DEFAULT\]/a backend = systemd' /etc/fail2ban/jail.local
    
    # 重新加载 fail2ban 配置并重启服务
    echo "Restarting Fail2ban service."
    systemctl restart fail2ban
    
    # 检查重新启动的结果
    if ! systemctl is-active --quiet fail2ban; then
        echo "在添加 'backend = systemd' 后fail2ban还是启动失败。"
        exit 1
    else
        echo "Fail2ban successfully restarted."
    fi
else
    echo "Fail2ban is already running."
fi

# 启用 fail2ban 开机启动
systemctl enable fail2ban

echo "fail2ban 安装配置完成，配置文件在 /etc/fail2ban/jail.local 处修改。默认在300年内输入错误2次封禁该IP 600年。"

fail2ban-client status sshd
