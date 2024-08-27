#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/Fractal Bitcoin.sh"

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "特别鸣谢 @keyinotc提供的代码"
        echo "================================================================"
        echo "退出脚本，请按键盘ctrl c退出即可"
        echo "请选择要执行的操作:"
        echo "1) 安装节点"
        echo "2) 查看服务日志"
        echo "3) 创建钱包"
        echo "4) 查看私钥"
        echo "5) 退出"
        echo -n "请输入选项 [1-5]: "
        read choice
        case $choice in
            1) install_node ;;
            2) view_logs ;;
            3) create_wallet ;;
            4) view_private_key ;;
            5) exit 0 ;;
            *) echo "无效选项，请重新选择。" ;;
        esac
    done
}

# 安装节点函数
function install_node() {
    echo "开始更新系统，升级软件包，并安装必要的软件包..."

    # 更新软件包列表
    sudo apt update

    # 升级已安装的软件包
    sudo apt upgrade -y

    # 安装所需的软件包
    sudo apt install make gcc chrony curl build-essential pkg-config libssl-dev git wget jq -y

    echo "系统更新、软件包升级和安装完成。"

    # 下载 fractald 库
    echo "下载 fractald 库..."
    wget https://github.com/fractal-bitcoin/fractald-release/releases/download/v0.1.7/fractald-0.1.7-x86_64-linux-gnu.tar.gz

    # 提取 fractald 库
    echo "提取 fractald 库..."
    tar -zxvf fractald-0.1.7-x86_64-linux-gnu.tar.gz

    # 进入 fractald 目录
    echo "进入 fractald 目录..."
    cd fractald-0.1.7-x86_64-linux-gnu

    # 创建 data 目录
    echo "创建 data 目录..."
    mkdir data

    # 复制配置文件到 data 目录
    echo "复制配置文件到 data 目录..."
    cp ./bitcoin.conf ./data

    # 创建 systemd 服务文件
    echo "创建 systemd 服务文件..."
    sudo tee /etc/systemd/system/fractald.service > /dev/null <<EOF
[Unit]
Description=Fractal Node
After=network.target

[Service]
User=root
WorkingDirectory=/root/fractald-0.1.7-x86_64-linux-gnu
ExecStart=/root/fractald-0.1.7-x86_64-linux-gnu/bin/bitcoind -datadir=/root/fractald-0.1.7-x86_64-linux-gnu/data/ -maxtipage=504576000
Restart=always
RestartSec=3
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target
EOF

    # 重新加载 systemd 管理器配置
    echo "重新加载 systemd 管理器配置..."
    sudo systemctl daemon-reload

    # 启动并使服务在启动时自动启动
    echo "启动 fractald 服务并设置为开机自启..."
    sudo systemctl start fractald
    sudo systemctl enable fractald

    echo "安装节点完成。"
    
    # 提示用户按任意键返回主菜单
    read -p "按任意键返回主菜单..."
}

# 查看服务日志函数
function view_logs() {
    echo "查看 fractald 服务日志..."
    sudo journalctl -u fractald -fo cat
    
    # 提示用户按任意键返回主菜单
    read -p "按任意键返回主菜单..."
}

# 创建钱包函数
function create_wallet() {
    echo "创建钱包..."
    cd /root/fractald-0.1.7-x86_64-linux-gnu/bin && ./bitcoin-wallet -wallet=wallet -legacy create
    
    # 提示用户按任意键返回主菜单
    read -p "按任意键返回主菜单..."
}

# 查看私钥函数
function view_private_key() {
    echo "正在查看私钥..."
    
    # 进入 fractald 目录
    cd /root/fractald-0.1.7-x86_64-linux-gnu/bin
    
    # 使用 bitcoin-wallet 导出私钥
    ./bitcoin-wallet -wallet=/root/.bitcoin/wallets/wallet/wallet.dat -dumpfile=/root/.bitcoin/wallets/wallet/MyPK.dat dump
    
    # 解析并显示私钥
    awk -F 'checksum,' '/checksum/ {print "钱包的私钥是:" $2}' /root/.bitcoin/wallets/wallet/MyPK.dat
    
    # 提示用户按任意键返回主菜单
    read -p "按任意键返回主菜单..."
}

# 启动主菜单
main_menu
