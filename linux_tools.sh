#!/bin/bash

# 检查是否为root用户
if [ "$(id -u)" != "0" ]; then
    echo -e "\033[31m错误：此脚本需要root权限运行！\033[0m"
    exit 1
fi

# 检测系统类型
detect_os() {
    if [ -f /etc/redhat-release ]; then
        OS="centos"
    elif [ -f /etc/debian_version ]; then
        OS="debian"
    else
        OS=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
    fi
    echo "检测到系统类型: $OS"
}

# 主菜单函数
show_menu() {
    clear
    echo -e "\n\033[34m======== Linux应急排查工具 ========\033[0m"
    echo "1. 文件系统检查"
    echo "2. 开机启动项分析"
    echo "3. 敏感文件扫描"
    echo "4. 网络连接分析"
    echo "5. 进程检查"
    echo "6. 登录审计"
    echo "7. 用户账户检查"
    echo "8. 历史命令分析"
    echo "9. 计划任务检查"
    echo "10. 环境变量检查"
    echo "11. 系统日志检查"
    echo "12. 资源监控"
    echo "0. 退出"
    echo -e "\033[34m=================================\033[0m"
    echo -n "请输入选项编号: "
}

# 文件系统检查
file_check() {
    clear
    echo -e "\n\033[34m===== 文件系统检查 =====\033[0m"
    echo "1. 显示根目录所有文件"
    echo "2. 显示当前目录详细信息"
    echo "3. 检查/tmp敏感目录"
    echo "0. 返回主菜单"
    read -p "请选择: " sub
    
    case $sub in
        1) ls -alt / ;;
        2) ls -alh ;;
        3) ls -alh /tmp ;;
        0) return ;;
        *) echo "无效选择";;
    esac
    read -p "按回车键继续..."
}

# 开机启动项分析
boot_analysis() {
    clear
    echo -e "\n\033[34m===== 开机启动项分析 =====\033[0m"
    detect_os
    
    echo "1. 显示所有自启动项"
    echo "2. 显示时间排序前十的自启动项"
    echo "3. 查看启动项详细信息"
    echo "4. 检查启动项状态"
    echo "5. 禁用自启动"
    echo "6. 启用自启动"
    echo "0. 返回主菜单"
    read -p "请选择: " sub
    
    case $sub in
        1)
            if [ "$OS" = "centos" ]; then
                ls -alh /etc/rc.d/init.d/
            else
                ls -alh /etc/init.d/
            fi
            ;;
        2)
            if [ "$OS" = "centos" ]; then
                cd /etc/rc.d/init.d/ && ls -alh | head -n 10
            else
                cd /etc/init.d/ && ls -alh | head -n 10
            fi
            ;;
        3)
            read -p "请输入启动项名称: " item
            if [ "$OS" = "centos" ]; then
                stat /etc/rc.d/init.d/$item
            else
                stat /etc/init.d/$item
            fi
            ;;
        4)
            read -p "请输入启动项名称: " item
            if [ "$OS" = "centos" ]; then
                service $item status
            else
                /etc/init.d/$item status
            fi
            ;;
        5)
            read -p "请输入要禁用的启动项: " item
            if [ "$OS" = "centos" ]; then
                chkconfig $item off
            else
                update-rc.d $item disable
            fi
            ;;
        6)
            read -p "请输入要启用的启动项: " item
            if [ "$OS" = "centos" ]; then
                chkconfig $item on
            else
                update-rc.d $item enable
            fi
            ;;
        0) return ;;
        *) echo "无效选择";;
    esac
    read -p "按回车键继续..."
}

# 敏感文件扫描
file_scan() {
    clear
    echo -e "\n\033[34m===== 敏感文件扫描 =====\033[0m"
    echo "1. 查找24小时内修改的PHP文件"
    echo "2. 查找72小时内新增的PHP文件"
    echo "3. 查找权限777的PHP文件"
    echo "0. 返回主菜单"
    read -p "请选择: " sub
    
    case $sub in
        1) find ./ -mtime 0 -name "*.php" 2>/dev/null ;;
        2) find ./ -ctime -2 -name "*.php" 2>/dev/null ;;
        3) find ./ -iname "*.php" -perm 777 2>/dev/null ;;
        0) return ;;
        *) echo "无效选择";;
    esac
    read -p "按回车键继续..."
}

# 网络连接分析
network_analysis() {
    clear
    echo -e "\n\033[34m===== 网络连接分析 =====\033[0m"
    echo "1. 查看所有网络连接"
    echo "2. 终止可疑连接"
    echo "0. 返回主菜单"
    read -p "请选择: " sub
    
    case $sub in
        1) 
            # 尝试使用netstat，如果不存在则使用ss
            if command -v netstat &> /dev/null; then
                netstat -pantl
            else
                ss -tulnp
            fi
            ;;
        2)
            read -p "请输入要终止的PID: " pid
            kill -9 $pid
            ;;
        0) return ;;
        *) echo "无效选择";;
    esac
    read -p "按回车键继续..."
}

# 进程检查
process_check() {
    clear
    echo -e "\n\033[34m===== 进程检查 =====\033[0m"
    echo "1. 查看所有进程"
    echo "2. 查看指定PID进程"
    echo "3. 按端口查进程"
    echo "0. 返回主菜单"
    read -p "请选择: " sub
    
    case $sub in
        1) ps aux ;;
        2)
            read -p "请输入PID: " pid
            ps aux | grep $pid
            ;;
        3)
            read -p "请输入端口号: " port
            if command -v lsof &> /dev/null; then
                lsof -i:$port
            else
                netstat -tulnp | grep :$port
            fi
            ;;
        0) return ;;
        *) echo "无效选择";;
    esac
    read -p "按回车键继续..."
}

# 登录审计
login_audit() {
    clear
    echo -e "\n\033[34m===== 登录审计 =====\033[0m"
    echo "1. 查看登录日志（排除本地登录）"
    echo "2. 查看实时登录"
    echo "0. 返回主菜单"
    read -p "请选择: " sub
    
    case $sub in
        1) last -i | grep -v '0.0.0.0\|127.0.0.1' ;;
        2) w ;;
        0) return ;;
        *) echo "无效选择";;
    esac
    read -p "按回车键继续..."
}

# 用户账户检查
user_check() {
    clear
    echo -e "\n\033[34m===== 用户账户检查 =====\033[0m"
    echo "1. 查看用户记录文件"
    echo "2. 筛选具有root权限的用户"
    echo "3. 查看用户密码信息"
    echo "0. 返回主菜单"
    read -p "请选择: " sub
    
    case $sub in
        1) cat /etc/passwd ;;
        2) grep "0:0" /etc/passwd ;;
        3) cat /etc/shadow ;;
        0) return ;;
        *) echo "无效选择";;
    esac
    read -p "按回车键继续..."
}

# 历史命令分析
history_analysis() {
    clear
    echo -e "\n\033[34m===== 历史命令分析 =====\033[0m"
    echo "1. 查看root用户历史命令"
    echo "2. 查看当前用户历史命令"
    echo "3. 检查可疑命令"
    echo "0. 返回主菜单"
    read -p "请选择: " sub
    
    case $sub in
        1) 
            if [ -f /root/.bash_history ]; then
                cat /root/.bash_history
            else
                echo "未找到root用户的历史命令文件"
            fi
            ;;
        2) history ;;
        3)
            echo "检查可疑命令..."
            echo "1. wget/curl下载命令:"
            history | grep -E 'wget|curl'
            echo -e "\n2. SSH连接命令:"
            history | grep 'ssh'
            echo -e "\n3. 压缩/解压命令:"
            history | grep -E 'tar|zip|gzip|unzip'
            ;;
        0) return ;;
        *) echo "无效选择";;
    esac
    read -p "按回车键继续..."
}

# 计划任务检查
cron_check() {
    clear
    echo -e "\n\033[34m===== 计划任务检查 =====\033[0m"
    echo "1. 查看当前用户计划任务"
    echo "2. 查看系统计划任务"
    echo "3. 删除计划任务"
    echo "4. 编辑计划任务"
    echo "0. 返回主菜单"
    read -p "请选择: " sub
    
    case $sub in
        1) crontab -l ;;
        2) 
            echo "/etc/crontab:"
            cat /etc/crontab
            echo -e "\n/etc/cron.d/:"
            ls -alh /etc/cron.d/
            ;;
        3) crontab -r ;;
        4) crontab -e ;;
        0) return ;;
        *) echo "无效选择";;
    esac
    read -p "按回车键继续..."
}

# 环境变量检查
env_check() {
    clear
    echo -e "\n\033[34m===== 环境变量检查 =====\033[0m"
    echo "当前PATH环境变量:"
    echo $PATH | tr ':' '\n'
    echo -e "\n检查PATH中可疑目录:"
    echo $PATH | tr ':' '\n' | grep -E '/tmp|/dev|/var/tmp'
    read -p "按回车键继续..."
}

# 系统日志检查
log_check() {
    clear
    echo -e "\n\033[34m===== 系统日志检查 =====\033[0m"
    detect_os
    
    echo "1. 查看认证日志"
    echo "2. 查看系统日志"
    echo "3. 查看安全日志"
    echo "0. 返回主菜单"
    read -p "请选择: " sub
    
    case $sub in
        1)
            if [ "$OS" = "centos" ]; then
                cat /var/log/secure
            else
                cat /var/log/auth.log
            fi
            ;;
        2)
            if [ "$OS" = "centos" ]; then
                cat /var/log/messages
            else
                cat /var/log/syslog
            fi
            ;;
        3)
            if [ "$OS" = "centos" ]; then
                cat /var/log/audit/audit.log
            else
                cat /var/log/kern.log
            fi
            ;;
        0) return ;;
        *) echo "无效选择";;
    esac
    read -p "按回车键继续..."
}

# 主程序循环
while true; do
    show_menu
    read choice
    case $choice in
        1) file_check ;;
        2) boot_analysis ;;
        3) file_scan ;;
        4) network_analysis ;;
        5) process_check ;;
        6) login_audit ;;
        7) user_check ;;
        8) history_analysis ;;
        9) cron_check ;;
        10) env_check ;;
        11) log_check ;;
        12) top ;;
        0) echo "退出系统"; exit 0 ;;
        *) echo "无效选择，请重新输入";;
    esac
done
