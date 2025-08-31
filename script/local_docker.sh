#!/bin/bash

# Docker用户组配置脚本
# 功能：将当前用户添加到docker组并验证配置
# 适用于Deepin系统
# 需要以普通用户身份运行（会通过sudo获取必要权限）

# 检查是否以root身份运行
if [ "$(id -u)" -eq 0 ]; then
    echo "错误：请不要以root身份运行此脚本，请以普通用户身份运行。"
    exit 1
fi

# 显示当前用户信息
echo "当前用户: $USER"
echo "正在配置Docker用户组权限..."

# 1. 检查docker组是否存在，不存在则创建
echo "检查docker用户组..."
if ! getent group docker >/dev/null; then
    echo "docker组不存在，正在创建..."
    sudo groupadd docker
    if [ $? -ne 0 ]; then
        echo "错误：创建docker组失败"
        exit 1
    fi
    echo "docker组创建成功"
else
    echo "docker组已存在"
fi

# 2. 将当前用户添加到docker组
echo "将用户 $USER 添加到docker组..."
sudo usermod -aG docker $USER
if [ $? -ne 0 ]; then
    echo "错误：添加用户到docker组失败"
    exit 1
fi
echo "用户已成功添加到docker组"

# 3. 刷新用户组权限
echo "刷新用户组权限..."
newgrp docker <<EONG
echo "当前有效组ID: $(id -g)"
EONG

# 4. 修改docker.sock权限（可选，根据需求）
echo "调整Docker套接字权限..."
sudo chmod 666 /var/run/docker.sock
if [ $? -ne 0 ]; then
    echo "警告：无法修改/var/run/docker.sock权限，可能不影响基本使用"
fi

# 5. 重启Docker服务
echo "重启Docker服务..."
sudo systemctl restart docker
if [ $? -ne 0 ]; then
    echo "错误：重启Docker服务失败"
    exit 1
fi

# 6. 验证配置是否生效
echo "验证Docker配置..."
docker ps -a >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Docker配置验证成功！"
    echo "您现在已经可以无需sudo直接运行Docker命令"
else
    echo "警告：Docker配置验证失败"
    echo "可能需要注销并重新登录系统才能使更改生效"
fi

echo "脚本执行完成"
