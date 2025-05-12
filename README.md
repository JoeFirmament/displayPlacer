# DisplayPlacer - 解决相同型号显示器混淆问题的脚本

![版本](https://img.shields.io/badge/版本-1.0.0-blue)
![平台](https://img.shields.io/badge/平台-macOS-lightgrey)
![语言](https://img.shields.io/badge/语言-Bash-green)

DisplayPlacer 是一个简单实用的显示器布局管理脚本，macOS，为我自己使用设计。它主要解决了使用雷电集线器连接多个相同型号显示器时，系统无法正确识别和保持显示器配置的问题。

这个脚本源于个人需求：每次插入雷电4集线器后，两个相同型号的显示器会混淆，导致旋转状态和位置设置错误，需要手动重新调整。

## 屏幕截图

### 终端界面

![DisplayPlacer 终端界面](screenCapture.jpg)

### HTML可视化界面

![DisplayPlacer HTML可视化界面](visualization_screenshot.png)

HTML可视化工具提供了更直观的显示器布局展示，帮助您快速理解和验证显示器配置。

## 使用场景

DisplayPlacer 特别适用于以下场景：

- **相同型号显示器**：当您连接两个相同型号的外部显示器，系统无法正确区分它们时
- **使用集线器或扩展坞**：当您通过 USB-C/雷电集线器连接显示器，导致显示器识别不稳定时
- **旋转显示器**：当您需要将其中一个显示器旋转 90 度使用，而另一个保持水平放置时
- **频繁连接/断开显示器**：当您经常需要连接或断开显示器，每次都需要重新排列布局时

## 功能特点

- **基于序列号识别显示器**：通过显示器的序列号（而非不稳定的 Persistent ID）准确识别相同型号的显示器
  - 使用 `ioreg` 命令从 EDID 信息中提取显示器序列号
  - 即使是相同型号的显示器，也能通过唯一的序列号区分
- **自动检测显示器混淆**：自动检测显示器序列号与系统分配的 Contextual ID 是否匹配，如果不匹配则提示交换
- **HTML可视化布局**：提供直观的HTML可视化界面，精确展示显示器的位置、大小和旋转状态
- **ASCII布局图**：提供简单的ASCII布局图，帮助用户在终端中快速理解当前显示器排列
- **坐标系统说明**：详细解释 macOS 显示器坐标系统，帮助用户理解显示器位置
- **交互式验证**：引导用户验证布局是否正确，并提供相应的操作建议
- **配置保存/加载**：可以保存正确的配置，以便下次快速应用

## 前提条件

在使用 DisplayPlacer 之前，您需要先安装 displayplacer 工具：

### 安装 displayplacer

#### 方法 1：使用 Homebrew 安装（推荐）

如果您已经安装了 [Homebrew](https://brew.sh/)，可以使用以下命令安装 displayplacer：

```bash
brew tap jakehilborn/jakehilborn
brew install displayplacer
```

#### 方法 2：手动安装

1. 访问 [displayplacer GitHub 仓库](https://github.com/jakehilborn/displayplacer)
2. 下载最新版本的源代码
3. 按照仓库中的说明进行编译和安装

### 验证安装

安装完成后，运行以下命令验证 displayplacer 是否正确安装：

```bash
displayplacer list
```

如果显示了当前显示器的配置信息，则表示安装成功。

## 安装 DisplayPlacer

1. 下载 DisplayPlacer 脚本：

   ```bash
   curl -o displayPlacer.sh https://raw.githubusercontent.com/JoeFirmament/displayPlacer/main/displayPlacer.sh
   ```

1. 赋予脚本执行权限：

   ```bash
   chmod +x displayPlacer.sh
   ```

## 使用方法

### 基本使用

1. 打开终端
1. 导航到脚本所在目录
1. 运行脚本：

   ```bash
   ./displayPlacer.sh
   ```

1. 按照屏幕上的提示操作

### 使用流程

1. 脚本会检测当前显示器状态并显示详细信息
2. 获取显示器的序列号信息，检查是否需要交换显示器
3. 显示当前布局的ASCII可视化图表
4. 生成HTML可视化界面，并提示是否在浏览器中打开
5. 提示您检查当前布局是否正确
6. 如果布局正确，您可以选择退出脚本
7. 如果布局不正确，脚本会交换两个外部显示器的配置
8. 应用配置后，再次检查布局是否正确
9. 如果配置正确，您可以选择保存此配置以便将来使用

### HTML可视化工具

脚本包含一个HTML可视化工具，可以直观地展示当前显示器布局：

1. 运行脚本时，会自动生成HTML可视化文件
2. 您可以选择在浏览器中打开此文件查看布局
3. 可视化界面包含以下功能：
   - 按照实际比例显示显示器的大小和位置
   - 使用不同颜色区分不同的显示器
   - 显示每个显示器的名称、分辨率和坐标
   - 提供坐标系统说明，帮助理解显示器位置
   - 提供按钮控制显示/隐藏标签、重置视图等

您也可以单独运行可视化工具：

```bash
./generate_display_visualization.sh
```

这将生成最新的HTML可视化文件，并提示是否在浏览器中打开。

### 自定义配置

您可以编辑脚本开头的配置部分，根据自己的需求自定义显示器布局：

```bash
# 您外部显示器的原生分辨率
NATIVE_RESOLUTION="2560x1440"

# 显示器序列号 - 用于识别相同型号的显示器
DISPLAY_SERIAL_1="33231Z0130531"  # 第一个外部显示器的序列号
DISPLAY_SERIAL_2="33231Z0130537"  # 第二个外部显示器的序列号

# Contextual ID 1: 内置屏幕配置
CONFIG_CONTEXTUAL_1="res:1710x1112 hz:60 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0"

# Contextual ID 2: 外部屏幕1配置 (不旋转的那个)
CONFIG_CONTEXTUAL_2="res:${NATIVE_RESOLUTION} hz:60 color_depth:8 enabled:true scaling:off origin:(-2560,-328) degree:0"

# Contextual ID 3: 外部屏幕2配置 (旋转90度的那个)
CONFIG_CONTEXTUAL_3="res:${ROTATED_RESOLUTION} hz:60 color_depth:8 enabled:true scaling:off origin:(1710,-900) degree:90"
```

## 坐标系统说明

在 macOS 的显示器坐标系统中：

- **原点(0,0)**：位于主显示器的左上角
- **X轴**：从左到右为正方向，向右增加
- **Y轴**：从上到下为正方向，向下增加
- **多显示器布局**：
  - 显示器在主显示器右侧：X坐标为正值
  - 显示器在主显示器左侧：X坐标为负值
  - 显示器在主显示器上方：Y坐标为负值
  - 显示器在主显示器下方：Y坐标为正值

## 故障排除

如果遇到问题，请尝试以下解决方案：

1. **显示器序列号无法识别**：
   - 确保所有显示器都已正确连接
   - 检查脚本中的序列号是否与您的显示器序列号匹配
   - 可以使用 `ioreg -l | grep "AlphanumericSerialNumber"` 命令查看当前连接的显示器序列号

2. **应用配置时出错**：
   - 检查显示器分辨率设置是否支持
   - 对于旋转90度的显示器，确保使用正确的旋转分辨率（宽高交换）
   - 查看脚本输出的错误信息，了解具体问题

3. **鼠标移动方向不正确**：
   - 检查显示器的物理排列是否与系统中的排列一致
   - 调整脚本中的坐标配置
   - 尝试交换两个外部显示器的配置

4. **脚本无法正确交换显示器**：
   - 确保两个外部显示器都被系统识别（Contextual ID 2 和 3）
   - 检查 displayplacer list 的输出，确认显示器信息
   - 手动编辑脚本中的配置参数

## 工作原理

脚本通过以下步骤解决显示器混淆问题：

1. 使用 displayplacer 获取当前显示器信息
2. 使用 ioreg 命令获取显示器的序列号信息
3. 检查序列号与 Contextual ID 的对应关系
4. 如果发现不匹配，提示交换两个外部显示器
5. 应用正确的配置，确保每个显示器都有正确的旋转状态和位置

### 显示器序列号识别

脚本使用以下方法获取和使用显示器序列号：

```bash
# 获取所有显示器的 EDID 信息，包含序列号
ioreg -l | grep -A 20 "DisplayAttributes" | grep "AlphanumericSerialNumber"
```

这个命令会返回类似以下的输出：

```bash
"AlphanumericSerialNumber" = "33231Z0130531"
"AlphanumericSerialNumber" = "33231Z0130537"
```

脚本中的实现：

```bash
# 获取显示器序列号的函数
get_display_serial_numbers() {
    echo "正在获取显示器序列号信息..."

    # 使用 ioreg 命令获取显示器的 EDID 信息
    EDID_INFO=$(ioreg -l | grep -A 20 "DisplayAttributes" | grep "AlphanumericSerialNumber")

    # 提取序列号
    SERIAL_1_FOUND=$(echo "$EDID_INFO" | grep -c "$DISPLAY_SERIAL_1")
    SERIAL_2_FOUND=$(echo "$EDID_INFO" | grep -c "$DISPLAY_SERIAL_2")

    # 检查序列号与 Contextual ID 的对应关系
    EDID_INFO_WITH_CONTEXT=$(ioreg -l | grep -A 50 -B 10 "DisplayAttributes")

    # 根据序列号和 Contextual ID 的对应关系决定是否需要交换显示器
    # ...
}
```

要使用此功能，您需要：

1. 找到您的显示器序列号：

   ```bash
   ioreg -l | grep "AlphanumericSerialNumber"
   ```

2. 将找到的序列号添加到脚本的配置部分：

   ```bash
   # 显示器序列号 - 用于识别相同型号的显示器
   DISPLAY_SERIAL_1="您的第一个显示器序列号"
   DISPLAY_SERIAL_2="您的第二个显示器序列号"
   ```

3. 脚本会自动检测序列号与 Contextual ID 的对应关系，如果不匹配，会提示交换显示器

## 许可证

本项目采用 MIT 许可证。

## 致谢

- [jakehilborn/displayplacer](https://github.com/jakehilborn/displayplacer) - 提供了底层的显示器配置工具
- 感谢所有测试和提供反馈的用户
