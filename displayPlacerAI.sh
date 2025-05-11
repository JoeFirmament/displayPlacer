#!/bin/bash

# =====================================================================
# DisplayPlacerAI - 智能显示器布局管理脚本
# =====================================================================
#
# 脚本功能：检测当前外部显示器状态，显示给用户确认，然后根据 Contextual ID 应用预设配置。
# 适用于使用集线器连接多台相同型号显示器，导致 Persistent ID 不稳定的情况。
# 假定内置屏幕的 Contextual ID 为 1，两个外部屏幕的 Contextual ID 分别为 2 和 3。
# 注意：displayplacer 帮助信息提到 Contextual ID 不可靠，此脚本是基于尝试。
#
# 坐标系统说明：
# - macOS 显示器坐标以主显示器左上角为原点(0,0)
# - X轴：从左到右为正方向
# - Y轴：从上到下为正方向
# - 显示器位置由其左上角坐标决定
#
# 使用方法：
# 1. 运行脚本 ./displayPlacerAI.sh
# 2. 查看当前显示器状态和布局可视化
# 3. 确认是否应用预设配置
# =====================================================================

# --- 配置部分 ---
# 您外部显示器的原生分辨率
NATIVE_RESOLUTION="2560x1440"

# 配置文件路径
CONFIG_FILE="$HOME/.display_config.sh"

# 根据您之前提供的正确状态下的 displayplacer list 输出，配置每个屏幕的期望设置
# 这些配置会应用到通过 Contextual ID 识别到的当前 Persistent ID 上

# Contextual ID 1: 内置屏幕配置 (通常不旋转，作为主显示器)
# 从您的 list 输出获取详细参数：res, hz, color_depth, scaling, origin, degree
CONFIG_CONTEXTUAL_1="res:1710x1112 hz:60 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0"

# Contextual ID 2: 对应其中一个外部屏幕的配置 (假设是您想旋转 0 度的那个)
# 使用原生分辨率
CONFIG_CONTEXTUAL_2="res:${NATIVE_RESOLUTION} hz:60 color_depth:8 enabled:true scaling:off origin:(-2560,-328) degree:0"

# Contextual ID 3: 对应另一个外部屏幕的配置 (假设是您想旋转 90 度的那个)
# 对于旋转90度的显示器，需要交换分辨率的宽高
ROTATED_RESOLUTION="1440x2560"  # 旋转90度后的分辨率
CONFIG_CONTEXTUAL_3="res:${ROTATED_RESOLUTION} hz:60 color_depth:8 enabled:true scaling:off origin:(1710,-900) degree:90"

# --- 结束配置部分 ---

# 保存当前配置的函数
save_current_config() {
    echo "#!/bin/bash" > "$CONFIG_FILE"
    echo "# 自动保存的显示器配置 - $(date)" >> "$CONFIG_FILE"
    echo "CONFIG_CONTEXTUAL_1=\"$CONFIG_CONTEXTUAL_1\"" >> "$CONFIG_FILE"
    echo "CONFIG_CONTEXTUAL_2=\"$CONFIG_CONTEXTUAL_2\"" >> "$CONFIG_FILE"
    echo "CONFIG_CONTEXTUAL_3=\"$CONFIG_CONTEXTUAL_3\"" >> "$CONFIG_FILE"
    chmod +x "$CONFIG_FILE"
    echo "当前配置已保存到 $CONFIG_FILE"
}

# 加载保存的配置（如果存在）
load_saved_config() {
    if [ -f "$CONFIG_FILE" ]; then
        source "$CONFIG_FILE"
        echo "已加载保存的配置"
        return 0
    else
        echo "未找到保存的配置文件"
        return 1
    fi
}

# 显示布局可视化
visualize_layout() {
    # 提取位置信息
    local internal_origin=$(echo "$CONFIG_CONTEXTUAL_1" | grep -o "origin:[^)]*)" | sed 's/origin://')
    local external1_origin=$(echo "$CONFIG_CONTEXTUAL_2" | grep -o "origin:[^)]*)" | sed 's/origin://')
    local external2_origin=$(echo "$CONFIG_CONTEXTUAL_3" | grep -o "origin:[^)]*)" | sed 's/origin://')

    local internal_degree=$(echo "$CONFIG_CONTEXTUAL_1" | grep -o "degree:[0-9]*" | sed 's/degree://')
    local external1_degree=$(echo "$CONFIG_CONTEXTUAL_2" | grep -o "degree:[0-9]*" | sed 's/degree://')
    local external2_degree=$(echo "$CONFIG_CONTEXTUAL_3" | grep -o "degree:[0-9]*" | sed 's/degree://')

    echo ""
    echo "显示器布局可视化："
    echo "----------------------------------------"
    echo "内置屏幕 (ID 1):"
    echo "  位置: $internal_origin"
    echo "  旋转: $internal_degree 度"
    echo ""
    echo "外部屏幕 1 (ID 2):"
    echo "  位置: $external1_origin"
    echo "  旋转: $external1_degree 度"
    echo ""
    echo "外部屏幕 2 (ID 3):"
    echo "  位置: $external2_origin"
    echo "  旋转: $external2_degree 度"
    echo ""
    echo "布局示意图："
    echo "----------------------------------------"
    echo "注意：此示意图基于坐标系统，其中主显示器左上角为原点(0,0)"
    echo "      X轴从左到右为正，Y轴从上到下为正"
    echo "----------------------------------------"

    # 简单的ASCII布局图
    if [ "$external1_degree" -eq 0 ] && [ "$external2_degree" -eq 90 ]; then
        echo "    +-------------+  +-----+"
        echo "    |             |  |     |"
        echo "    | 外部屏幕 1  |  |     |"
        echo "    | (水平放置)  |  |  外 |"
        echo "    |             |  |  部 |"
        echo "    +-------------+  |  屏 |"
        echo "                     |  幕 |"
        echo "      +----------+   |  2  |"
        echo "      |  内置屏  |   |     |"
        echo "      +----------+   +-----+"
    elif [ "$external1_degree" -eq 90 ] && [ "$external2_degree" -eq 0 ]; then
        echo "+-----+  +-------------+"
        echo "|     |  |             |"
        echo "|     |  | 外部屏幕 2  |"
        echo "|  外 |  | (水平放置)  |"
        echo "|  部 |  |             |"
        echo "|  屏 |  +-------------+"
        echo "|  幕 |"
        echo "|  1  |   +----------+"
        echo "|     |   |  内置屏  |"
        echo "+-----+   +----------+"
    else
        echo "自定义布局 (请根据位置坐标判断实际排列)"
    fi
    echo "----------------------------------------"
}

echo "正在获取当前显示器信息..."
# 获取当前显示器配置列表
DISPLAY_INFO=$(displayplacer list)

# 初始化变量，用于存储根据 Contextual ID 找到的当前 Persistent ID 和详细信息
# 不使用关联数组，改用普通变量存储显示器信息

echo "正在解析显示器信息..."

current_persistent_id=""
current_contextual_id=""
current_type=""
current_resolution=""
current_rotation=""
current_origin=""

# 逐行解析 displayplacer list 的输出
# 使用进程替换方式读取 DISPLAY_INFO 变量，避免在 while 循环中创建子 shell 导致变量值丢失
while read line; do
    # 提取 Persistent screen id
    if [[ "$line" =~ ^Persistent\ screen\ id:\ ([0-9A-F-]+) ]]; then
        # 如果已经处理完上一个显示器块，保存信息
        if [[ -n "$current_persistent_id" && -n "$current_contextual_id" ]]; then
            # 使用普通变量存储，变量名格式为 display_id_X，display_type_X 等
            eval "display_id_${current_contextual_id}=\"$current_persistent_id\""
            eval "display_type_${current_contextual_id}=\"$current_type\""
            eval "display_resolution_${current_contextual_id}=\"$current_resolution\""
            eval "display_rotation_${current_contextual_id}=\"$current_rotation\""
            eval "display_origin_${current_contextual_id}=\"$current_origin\""
        fi
        # 开始处理新的显示器块
        current_persistent_id="${BASH_REMATCH[1]}"
        current_contextual_id=""
        current_type=""
        current_resolution=""
        current_rotation=""
        current_origin=""

    # 提取 Contextual screen id
    elif [[ "$line" =~ ^Contextual\ screen\ id:\ ([0-9]+) ]]; then
        current_contextual_id="${BASH_REMATCH[1]}"

    # 提取 Type
    elif [[ "$line" =~ ^Type:\ (.+) ]]; then
        current_type="${BASH_REMATCH[1]}"

    # 提取 Resolution
    elif [[ "$line" =~ ^Resolution:\ ([0-9]+x[0-9]+) ]]; then
        current_resolution="${BASH_REMATCH[1]}"

    # 提取 Rotation
    elif [[ "$line" =~ ^Rotation:\ ([0-9]+) ]]; then
        current_rotation="${BASH_REMATCH[1]}"

     # 提取 Origin
    elif [[ "$line" =~ ^Origin:\ \((.+)\) ]]; then
        current_origin="(${BASH_REMATCH[1]})"
    fi
done < <(echo "$DISPLAY_INFO")

# 处理最后一个显示器块的信息
if [[ -n "$current_persistent_id" && -n "$current_contextual_id" ]]; then
    # 使用普通变量存储
    eval "display_id_${current_contextual_id}=\"$current_persistent_id\""
    eval "display_type_${current_contextual_id}=\"$current_type\""
    eval "display_resolution_${current_contextual_id}=\"$current_resolution\""
    eval "display_rotation_${current_contextual_id}=\"$current_rotation\""
    eval "display_origin_${current_contextual_id}=\"$current_origin\""
fi


# 检查是否找到了 Contextual ID 2 和 3 的信息
if [[ -z "$display_id_2" || -z "$display_id_3" ]]; then
    echo "错误：未能找到 Contextual ID 2 或 3 的显示器信息。"
    echo "请检查显示器连接状态，确保两个外部显示器都被识别并分配了 Contextual ID 2 和 3。"
    # 可以选择输出 displayplacer list 的全部内容用于调试
    # echo "displayplacer list 输出内容："
    # echo "$DISPLAY_INFO"
    exit 1
fi

echo ""
echo "检测到当前外部显示器状态 (基于 Contextual ID):"
echo "--------------------------------------------------"
echo "外部屏幕 1 (Contextual ID 2):"
echo "  类型: $display_type_2"
echo "  Persistent ID: $display_id_2"
echo "  当前分辨率: $display_resolution_2"
echo "  当前旋转角度: $display_rotation_2 度"
echo "  当前位置 (Origin): $display_origin_2"
echo "--------------------------------------------------"
echo "外部屏幕 2 (Contextual ID 3):"
echo "  类型: $display_type_3"
echo "  Persistent ID: $display_id_3"
echo "  当前分辨率: $display_resolution_3"
echo "  当前旋转角度: $display_rotation_3 度"
echo "  当前位置 (Origin): $display_origin_3"
echo "--------------------------------------------------"
echo ""

# 显示布局可视化
visualize_layout

# 根据当前显示器状态调整配置
adjust_config_for_current_state() {
    # 检查外部屏幕2的当前旋转状态
    if [[ "$display_rotation_3" == "90" ]]; then
        # 如果当前已经是90度旋转，使用旋转后的分辨率
        CONFIG_CONTEXTUAL_3_ADJUSTED="${CONFIG_CONTEXTUAL_3}"
    else
        # 如果当前不是90度旋转，但我们想要设置为90度，使用旋转后的分辨率
        CONFIG_CONTEXTUAL_3_ADJUSTED="${CONFIG_CONTEXTUAL_3}"
    fi

    # 检查外部屏幕1的当前旋转状态
    if [[ "$display_rotation_2" == "90" ]]; then
        # 如果当前是90度旋转，但我们想要设置为0度，使用原始分辨率
        CONFIG_CONTEXTUAL_2_ADJUSTED="${CONFIG_CONTEXTUAL_2}"
    else
        # 如果当前不是90度旋转，使用原始分辨率
        CONFIG_CONTEXTUAL_2_ADJUSTED="${CONFIG_CONTEXTUAL_2}"
    fi
}

# 调整配置
adjust_config_for_current_state

# 构建即将执行的 displayplacer 命令
COMMAND="displayplacer"
# 添加内置屏幕的配置 (使用 Contextual ID 1 的 Persistent ID)
if [[ -n "$display_id_1" ]]; then
    COMMAND+=" \"id:$display_id_1 ${CONFIG_CONTEXTUAL_1}\""
else
     echo "警告：未能找到 Contextual ID 1 (内置屏幕) 的信息，将只配置外部显示器。"
fi

# 添加外部屏幕的配置 (使用 Contextual ID 2 和 3 的 Persistent ID)
COMMAND+=" \"id:$display_id_2 ${CONFIG_CONTEXTUAL_2_ADJUSTED}\""
COMMAND+=" \"id:$display_id_3 ${CONFIG_CONTEXTUAL_3_ADJUSTED}\""


echo "坐标系统说明："
echo "----------------------------------------"
echo "在 macOS 的显示器坐标系统中，坐标位置是以主显示器的左上角为原点(0,0)的。"
echo "• X轴：从左到右为正方向，向右增加"
echo "• Y轴：从上到下为正方向，向下增加"
echo "• 多显示器布局："
echo "  - 显示器在主显示器右侧：X坐标为正值"
echo "  - 显示器在主显示器左侧：X坐标为负值"
echo "  - 显示器在主显示器上方：Y坐标为负值"
echo "  - 显示器在主显示器下方：Y坐标为正值"
echo ""
echo "当前布局解释："
echo "• 内置屏幕(ID 1)：位于坐标(0,0)，作为主显示器"
echo "• 外部屏幕1(ID 2)：位于坐标($display_origin_2)，在主显示器的左侧且稍微上方"
echo "• 外部屏幕2(ID 3)：位于坐标($display_origin_3)，在主显示器的右侧且上方"
echo "----------------------------------------"
echo ""
echo "请检查当前显示器布局是否正确："
echo "----------------------------------------"
echo "1. 请移动鼠标到各个显示器上，确认鼠标移动方向与显示器物理位置一致"
echo "2. 尝试将窗口拖动到不同显示器，检查窗口是否按预期移动"
echo "3. 检查显示器的旋转状态是否符合实际情况"
echo "----------------------------------------"

read -p "当前布局是否正常？(y/n): " layout_ok

if [[ "$layout_ok" =~ ^[Yy]$ ]]; then
    echo "很好！当前布局正常。您可以退出脚本或继续查看配置信息。"
    read -p "是否退出脚本？(y/n): " exit_script
    if [[ "$exit_script" =~ ^[Yy]$ ]]; then
        echo "感谢使用 DisplayPlacerAI！"
        exit 0
    fi
else
    echo "布局不正常，我们可以尝试应用预设配置来修复问题。"
fi

echo ""
echo "即将应用以下配置命令，旨在将外部屏幕 1 (Contextual ID 2) 设置为不旋转，外部屏幕 2 (Contextual ID 3) 设置为旋转 90 度："

# 询问是否显示完整命令
read -p "是否显示完整配置命令？ (y/n): " show_command
if [[ "$show_command" =~ ^[Yy]$ ]]; then
    echo "$COMMAND" # 打印完整命令
fi

# 询问用户是否确认执行
read -p "是否应用此配置？ (y/n): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "正在应用配置..."
    # 使用 eval 来正确处理构建的命令字符串中的引号和空格
    eval "$COMMAND"

    # 检查命令执行结果
    if [ $? -eq 0 ]; then
        echo "显示器配置已成功应用。"
        echo ""
        echo "请再次检查显示器布局："
        echo "----------------------------------------"
        echo "1. 请移动鼠标到各个显示器上，确认鼠标移动方向是否正确"
        echo "2. 检查窗口是否可以正常拖动到所有显示器"
        echo "3. 检查显示器的旋转状态是否符合您的需求"
        echo "----------------------------------------"

        # 询问是否保存当前配置
        read -p "新的布局是否正确？是否保存此配置？ (y/n): " save_confirm
        if [[ "$save_confirm" =~ ^[Yy]$ ]]; then
            save_current_config
            echo "配置已保存！下次您可以直接加载此配置。"
            echo "如果您的显示器连接方式发生变化，可能需要重新配置。"
        else
            echo "配置未保存。如需恢复之前的配置，请重新运行脚本。"
            echo "提示：您可以尝试调整系统偏好设置中的显示器排列来修复问题。"
        fi
    else
        echo "执行 displayplacer 命令时发生错误。"
        echo "请检查终端输出的错误信息。"
        echo ""
        echo "可能的解决方案："
        echo "1. 确认显示器连接正常"
        echo "2. 检查显示器分辨率设置是否支持"
        echo "3. 尝试在系统偏好设置中重新排列显示器后再运行脚本"
    fi
else
    # 询问是否要加载保存的配置
    read -p "是否加载之前保存的配置？ (y/n): " load_confirm
    if [[ "$load_confirm" =~ ^[Yy]$ ]]; then
        if load_saved_config; then
            # 调整配置
            adjust_config_for_current_state

            # 重新构建命令
            COMMAND="displayplacer"
            if [[ -n "$display_id_1" ]]; then
                COMMAND+=" \"id:$display_id_1 ${CONFIG_CONTEXTUAL_1}\""
            fi
            COMMAND+=" \"id:$display_id_2 ${CONFIG_CONTEXTUAL_2_ADJUSTED}\""
            COMMAND+=" \"id:$display_id_3 ${CONFIG_CONTEXTUAL_3_ADJUSTED}\""

            echo "正在应用保存的配置..."
            eval "$COMMAND"

            if [ $? -eq 0 ]; then
                echo "保存的显示器配置已成功应用。"
                echo ""
                echo "请检查显示器布局是否恢复正常："
                echo "----------------------------------------"
                echo "1. 请移动鼠标到各个显示器上，确认鼠标移动方向是否正确"
                echo "2. 检查窗口是否可以正常拖动到所有显示器"
                echo "3. 检查显示器的旋转状态是否符合您的需求"
                echo "----------------------------------------"

                read -p "布局是否已恢复正常？ (y/n): " layout_restored
                if [[ "$layout_restored" =~ ^[Yy]$ ]]; then
                    echo "太好了！您的显示器布局已恢复正常。"
                    echo "感谢使用 DisplayPlacerAI！"
                else
                    echo "如果布局仍有问题，您可以："
                    echo "1. 尝试在系统偏好设置中手动调整显示器排列"
                    echo "2. 重新运行脚本并应用新的配置"
                    echo "3. 检查显示器连接和系统设置"
                fi
            else
                echo "应用保存的配置时发生错误。"
                echo "可能的原因："
                echo "1. 显示器配置已更改，保存的配置不再适用"
                echo "2. 显示器连接方式发生变化"
                echo "3. 系统设置发生变化"
                echo ""
                echo "建议重新运行脚本并创建新的配置。"
            fi
        fi
    else
        echo "已取消应用配置。"
        echo ""
        echo "您可以："
        echo "1. 尝试在系统偏好设置中手动调整显示器排列"
        echo "2. 稍后再次运行脚本尝试其他配置"
        echo "3. 如果当前布局已经满足需求，无需进一步操作"
        echo ""
        echo "感谢使用 DisplayPlacerAI！"
    fi
fi
