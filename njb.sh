#!/bin/bash

# 日志文件路径
log_file="./log.txt"

# 错误处理函数，将错误信息写入日志文件
handle_error() {
    local error_message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "错误 [$timestamp]: $error_message" >> "$log_file"
    exit 1
}

# 将成功信息写入日志文件
log_success() {
    local message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "成功 [$timestamp]: $message" >> "$log_file"
}

# 文件替换函数
replace_file() {
    local source_file="$1"
    local target_file="$2"
    
    # 检查源文件是否存在
    if [ ! -f "$source_file" ]; then
        handle_error "源文件不存在: $source_file"
    fi

    # 检查目标文件是否存在
    if [ ! -f "$target_file" ]; then
        handle_error "目标文件不存在: $target_file"
    fi
    
    # 执行替换操作
    if cp -f "$source_file" "$target_file"; then
        log_success "文件替换成功: $target_file"
        
        # 修改文件权限为770
        chmod 770 "$target_file"
        log_success "文件权限修改成功: $target_file"
    else
        handle_error "文件替换失败: $target_file"
    fi
}

# 替换文件的列表
files_to_replace=(
    "Plex Media Server/plex.mo:/Applications/Plex Media Server.app/Contents/Resources/locale/zh_CN/LC_MESSAGES/plex.mo"
    "Plex Media Server/plex.po:/Applications/Plex Media Server.app/Contents/Resources/locale/zh_CN/LC_MESSAGES/plex.po"
    "Web Clients/zh.json:/Applications/Plex Media Server.app/Contents/Resources/Plug-ins-c0dd5a73e/WebClient.bundle/Contents/Resources/translations/zh.json"
    # 添加更多的文件替换路径
)

# 获取当前工作目录
current_directory=$(pwd)

# 遍历文件列表并逐一执行替换操作
for file in "${files_to_replace[@]}"; do
    source_file="$current_directory/${file%%:*}"
    target_file="${file#*:}"
    replace_file "$source_file" "$target_file"
done

# 关闭 Plex Media Server
echo "→ 正在关闭 Plex Media Server..."
osascript -e 'quit app "Plex Media Server"'

# 等待 Plex Media Server 完全关闭
while pgrep -x "Plex Media Server" > /dev/null; do
    sleep 1
done

# 启动 Plex Media Server
echo "→ 正在启动 Plex Media Server..."
open -a "Plex Media Server"

echo "→ Plex Media Server 已经完成重启！！！
→ 请输入localhost:32400登录进行检查~"
