#!/bin/bash

# 脚本保存路径
SCRIPT_PATH="$HOME/Fractal Bitcoin.sh"

# 主菜单函数
function main_menu() {
    while true; do
        clear
        echo "脚本由推特 @ferdie_jhovie，免费开源，请勿相信收费"
        echo "================================================================"
        echo "节点社区 Telegram 群组: https://t.me/niuwuriji"
        echo "节点社区 Telegram 频道: https://t.me/niuwuriji"
        echo "节点社区 Discord 社群: https://discord.gg/GbMV5EcNWF"
        echo "退出脚本，请按键盘ctrl c退出即可"
        echo "请选择要执行的操作:"
        echo "1) 安装节点（0.1.8版本）"
        echo "2) 查看服务日志"
        echo "3) 创建钱包"
        echo "4) 查看私钥"
        echo "5) 更新脚本（旧0.1.7更新）"
        echo "6) 备份私钥"
        echo "7) 退出"
        echo -n "请输入选项 [1-6]: "
        read choice
        case $choice in
            1) install_node ;;
            2) view_logs ;;
            3) create_wallet ;;
            4) view_private_key ;;
            5) update_script ;;
            6) backup_private_key ;;
            7) exit 0 ;;
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
    wget https://github.com/fractal-bitcoin/fractald-release/releases/download/v0.1.8/fractald-0.1.8-x86_64-linux-gnu.tar.gz

    # 提取 fractald 库
    echo "提取 fractald 库..."
    tar -zxvf fractald-0.1.8-x86_64-linux-gnu.tar.gz

    # 进入 fractald 目录
    echo "进入 fractald 目录..."
    cd fractald-0.1.8-x86_64-linux-gnu

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
WorkingDirectory=/root/fractald-0.1.8-x86_64-linux-gnu
ExecStart=/root/fractald-0.1.8-x86_64-linux-gnu/bin/bitcoind -datadir=/root/fractald-0.1.8-x86_64-linux-gnu/data/ -maxtipage=504576000
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
    cd /root/fractald-0.1.8-x86_64-linux-gnu/bin && ./bitcoin-wallet -wallet=wallet -legacy create
    
    # 提示用户按任意键返回主菜单
    read -p "按任意键返回主菜单..."
}

# 备份私钥函数
function backup_private_key() {
    echo "备份私钥..."

    # 确保备份目录存在
    mkdir -p "$BACKUP_DIR" || { echo "创建备份目录失败"; return 1; }

    # 备份整个 wallet 目录
    cp -r /root/.bitcoin/wallets/wallet "$BACKUP_DIR/wallet_backup" || { echo "备份私钥失败"; return 1; }

    echo "私钥备份完成，备份文件位置: $BACKUP_DIR/wallet_backup"

    # 提示用户按任意键返回主菜单
    read -p "按任意键返回主菜单..."
    sleep 30
}

# 查看私钥函数
function view_private_key() {
    echo "正在查看私钥..."
    
    # 进入 fractald 目录
    cd /root/fractald-0.1.8-x86_64-linux-gnu/bin
    
    # 使用 bitcoin-wallet 导出私钥
    ./bitcoin-wallet -wallet=/root/.bitcoin/wallets/wallet/wallet.dat -dumpfile=/root/.bitcoin/wallets/wallet/MyPK.dat dump
    
    # 解析并显示私钥
    awk -F 'checksum,' '/checksum/ {print "钱包的私钥是:" $2}' /root/.bitcoin/wallets/wallet/MyPK.dat
    
    # 提示用户按任意键返回主菜单
    read -p "按任意键返回主菜单..."
}

# 更新脚本函数
function update_script() {
    echo "开始更新脚本..."

    # 备份 data 目录
    echo "备份 data 目录..."
    sudo cp -r /root/fractald-0.1.7-x86_64-linux-gnu/data /root/fractal-data-backup

    # 下载新版本 fractald 库
    echo "下载新版本 fractald 库..."
    wget https://github.com/fractal-bitcoin/fractald-release/releases/download/v0.1.8/fractald-0.1.8-x86_64-linux-gnu.tar.gz

    # 提取新版本 fractald 库
    echo "提取新版本 fractald 库..."
    tar -zxvf fractald-0.1.8-x86_64-linux-gnu.tar.gz

    # 进入新版本 fractald 目录
    echo "进入新版本 fractald 目录..."
    cd fractald-0.1.8-x86_64-linux-gnu

    # 恢复备份的 data 文件
    echo "恢复备份的 data 文件..."
    cp -r /root/fractal-data-backup /root/fractald-0.1.8-x86_64-linux-gnu/

    # 更新 systemd 服务文件（如果有变化）
    echo "更新 systemd 服务文件..."
    sudo tee /etc/systemd/system/fractald.service > /dev/null <<EOF
[Unit]
Description=Fractal Node
After=network.target

[Service]
User=root
WorkingDirectory=/root/fractald-0.1.8-x86_64-linux-gnu
ExecStart=/root/fractald-0.1.8-x86_64-linux-gnu/bin/bitcoind -datadir=/root/fractald-0.1.8-x86_64-linux-gnu/data/ -maxtipage=504576000
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
    echo "启用并启动 fractald 服务..."
    sudo systemctl enable fractald
    sudo systemctl start fractald

    echo "脚本更新完成。"

    # 提示用户按任意键返回主菜单
    read -p "按任意键返回主菜单..."
}

# 启动主菜单
main_menu
