#!/bin/zsh
##########################################################################
# File Name: ./goinstall.sh
# Author: amoscykl
# mail: amoscykl980629@163.com
# Created Time: 六  8/17 20:50:14 2024

# 设置 GOPATH 目录听见到 PATH 中
# export GOPATH=$HOME/go_dev
# export PATH=$PATH:$GOPATH/bin
#########################################################################


to_lower() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

to_upper() {
  echo "$1" | tr '[:lower:]' '[:upper:]'
}

# 设置go 安装包路径
GOTAR="/tmp/"

# 版本好正则
version_regex='^[0-9]+\.[0-9]+\.[0-9]+$'

# 判断操作系统类型
OS_TYPE=$(to_lower "$(uname)")
echo "检测系统类型为: $OS_TYPE"

# 设置go 下载路径前缀
GOINSTALL_URL="https://golang.google.cn/dl/"

# 判断macos 架构
GO_INSTALL_DIR="$HOME"

# 获取go 版本参#!/bin/zsh

to_lower() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

to_upper() {
  echo "$1" | tr '[:lower:]' '[:upper:]'
}

GOTAR="/tmp/"
version_regex='^[0-9]+\.[0-9]+\.[0-9]+$'
OS_TYPE=$(to_lower "$(uname)")
echo "检测系统类型为: $OS_TYPE"
GOINSTALL_URL="https://golang.google.cn/dl/"
GO_INSTALL_DIR="$HOME"
version=$1
echo "指定的版本为:$version"

if [ "$#" -eq 0 ]; then
  echo "未指定版本"
  exit 1
fi

if ! [[ $version =~ $version_regex ]]; then
  echo "错误: 提供的版本号 '$version' 格式不正确"
  echo "必须符合 '主版本号.次版本号.修订号'的形式, 如1.23.0"
  exit 1
fi

ARCH=$(to_lower $(uname -m))

if [ "$OS_TYPE" = "darwin" ]; then
  if [ "$ARCH" = "arm64" ]; then
    echo "macos on ARM64 arch"
  elif [ "$ARCH" = "x86_64" ]; then
    echo "MAC_OS on x86_64"
  else
    echo "unknown macos arch: $ARCH"
    exit 1
  fi
elif [ "$OS_TYPE" = "linux" ]; then
  if [ "$ARCH" = "x86_64" ]; then
    ARCH="amd64"
    echo "Linux arch amd64 detected."
  else
    echo "Linux arch $ARCH detected."
  fi
else
  echo "Unsupported operating system: $OS_TYPE $ARCH"
  exit 1
fi

GO_NAME="go$version.$OS_TYPE-$ARCH.tar.gz"
GOINSTALL_URL="$GOINSTALL_URL$GO_NAME"
echo "下载链接:$GOINSTALL_URL"

if [ -f "$GOTAR$GO_NAME" ]; then
  echo "文件存在"
else
  wget -O "$GOTAR$GO_NAME" "$GOINSTALL_URL"
  echo "文件不存在"
fi

echo "下载文件到指定目录$GOTAR$GO_NAME"
echo "解压压缩包到指定文件夹：$GO_INSTALL_DIR"
rm -rf "$HOME/go"
if ! tar -xvf "$GOTAR$GO_NAME" -C "$GO_INSTALL_DIR"; then
  echo "解压失败，删除下载的压缩包 $GOTAR$GO_NAME"
  rm -f "$GOTAR$GO_NAME"
  exit 2
fi
