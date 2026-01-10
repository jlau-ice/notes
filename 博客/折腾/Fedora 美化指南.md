一些必要工具

```plain
# obsidian 运行所需
sudo dnf install fuse fuse-libs
```

输入法

安装Fcitx5 安装核心包、中文输入法和配置工具 这提供了框架、拼音/五笔等输入法和图形配置界面。
```bash
sudo dnf install fcitx5 fcitx5-chinese-addons fcitx5-configtool
```
添加自启动 安装自启动脚本，让Fcitx5开机运行
```bash
sudo dnf install fcitx5-autostart
```

配置环境变量 /etc/envi...
```
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
```


显卡驱动安装

```bash
sudo dnf install \
https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf makecache

sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda
```


拓展下载 ： 

```bash
sudo dnf install flatpak

# 解决源不生效的问题
flatpak remote-delete fedora
flatpak remote-delete flathub
# 重新添加
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
# 安装拓展管理器
flatpak search ExtensionManager
flatpak install flathub com.mattjakeman.ExtensionManager
```



```bash
Blur my Shell  # 他会让你桌面上面以及周围 是亚克力效果。很不错

Burn my Shell  # 窗口打开、关闭 特效

Caffeine  # 他会让你的屏幕保持常亮

Input Method Panel # 输入法美化

Logo Menu # 左上角的图标 支持自定义

Vitals # 他会显示网速等信息

Lock screen background #锁屏壁纸

AppIndicator and KStatusNotifierItem Support  # 他会在状态栏显示应用

Clipboard Indicator # 剪切板历史

Lock Keys  # 大写锁字母等开启情况

```


**GRUB美化**

你可以去 [Gnome-look.org](https://www.gnome-look.org/browse?cat=109) 寻找喜欢的 GRUB 主题。这里我推荐一个非常流行且自动化的工具：**Vinceliuice 的 GRUB 主题库**。

```plain
git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes
sudo ./install.sh -t tela -s 1080p
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```



魔法工具

```plain

```





zsh 安装主题配置

``` bash
sudo dnf install zsh
# 修改shell
chsh -s /usr/bin/zsh
# 重启
```

终端美化

```plain
# 添加源
dnf copr enable atim/starship
dnf install starship

# 或者脚本安装
curl -sS https://starship.rs/install.sh | sh

# 编辑zshrc 

```



安装ghostty 其他的像 gnome-terminal  Ptyxis 都对starship 不是很好

可以看见吧，左右的圆角处理的不好。 0

<!-- 这是一张图片，ocr 内容为： -->
![](https://cdn.nlark.com/yuque/0/2026/png/34904774/1768014475413-9d66460b-4445-4801-a5fe-d0f80dc83dab.png)

```bash
sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
sudo dnf install ghostty


# 语法高亮和自动补全
sudo dnf install zsh-syntax-highlighting zsh-autosuggestions

# fedora 43 不支持
# 1. 启用第三方仓库
sudo dnf copr enable @zsh-users/zsh-completions
# 2. 安装插件
sudo dnf install zsh-completions
```





```bash
# .zshrc 配置
# 这个是starshship 主题配置
eval "$(starship init zsh)"

# arch linux 
#语法检查和高亮
#source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
#source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# fedora
# 语法检查和高亮
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

#开启tab上下左右选择补全
zstyle ':completion:*' menu select
autoload -Uz compinit
compinit

# 设置历史记录文件的路径
HISTFILE=~/.zsh_history

# 设置在会话（内存）中和历史文件中保存的条数，建议设置得大一些
HISTSIZE=1000
SAVEHIST=1000

# 忽略重复的命令，连续输入多次的相同命令只记一次
setopt HIST_IGNORE_DUPS

# 忽略以空格开头的命令（用于临时执行一些你不想保存的敏感命令）
#setopt HIST_IGNORE_SPACE

# 在多个终端之间实时共享历史记录
# 这是实现多终端同步最关键的选项
setopt SHARE_HISTORY

# 让新的历史记录追加到文件，而不是覆盖
setopt APPEND_HISTORY
# 在历史记录中记录命令的执行开始时间和持续时间
setopt EXTENDED_HISTORY
```





开启可变刷新率

```bash
flatpak install page.tesk.Refine
```



ghotty 美化

配色下载地址 [https://github.com/catppuccin/ghostty/blob/main/themes/catppuccin-frappe.conf](https://github.com/catppuccin/ghostty/blob/main/themes/catppuccin-frappe.conf)

```bash
theme = /home/ice/.config/ghostty/catppuccin-frappe.conf
background-opacity = 0.85

font-family = "Adwaita Mono"
font-size = 15
#隐藏标题栏
window-decoration = none

#设置左右边距
window-padding-x=10
#设置上下边距
window-padding-y=10
```



字体

```bash
sudo dnf install google-droid-sans-mono-fonts
```

**下载字体包：** 访问 [JetBrains Mono 官网](https://www.jetbrains.com/lp/mono/) 点击下载，或者在终端直接用 `wget`：

1. Bash

```bash
wget https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip
```

**解压：**

2. Bash

```bash
unzip JetBrainsMono-2.304.zip -d jetbrains-font
```

3. **创建字体目录：** 你可以选择安装给“当前用户”或“全系统”：
    - **仅当前用户：**`mkdir -p ~/.local/share/fonts`
    - **全系统（推荐）：**`sudo mkdir -p /usr/share/fonts/jetbrains`

**移动字体文件：**

4. Bash

```bash
# 假设你安装给全系统
sudo cp -r jetbrains-font/fonts/ttf/*.ttf /usr/share/fonts/jetbrains/
```

**刷新字体缓存（必须执行）：**

5. Bash

```bash
fc-cache -fv
```

---



处理idea 字体不显示问题



在 Fedora 系统中出现 IDE 界面（GUI）中文显示为方块的情况，通常是因为 **Java 运行时（JRE）无法正确调用系统的中文字体**，或者系统默认安装的是 **“可变字体”（Variable Fonts）**，而 Java 对这类新格式字体的支持在某些环境下不够稳定。

你可以按照以下步骤彻底解决：

---

### 第一步：安装中文字体包
Fedora 默认可能只安装了基础字体。通过 `dnf` 安装最通用的开源中文字体：

Bash

```bash
# 安装 思源黑体 (Adobe Source Han Sans) 和 文泉驿微米黑
sudo dnf install adobe-source-han-sans-cn-fonts wqy-microhei-fonts wqy-zenhei-fonts

# 安装中文语言包支持（这会补齐大部分缺失的依赖）
sudo dnf install langpacks-zh_CN
```

---

### 第二步：解决“可变字体”兼容问题（Fedora 用户常遇坑）
Fedora 默认安装的是 `google-noto-sans-cjk-vf-fonts`（VF 代表 Variable Font）。某些版本的 IntelliJ IDEA (Java) 无法正确解析这种字体，导致显示方块。

**解决方法是替换为静态版本：**

Bash

```bash
# 移除可变字体版本
sudo dnf remove google-noto-sans-cjk-vf-fonts

# 安装静态版本
sudo dnf install google-noto-sans-cjk-fonts google-noto-serif-cjk-fonts
```

---

### 第三步：在 IDEA 中手动指定 GUI 字体
安装完字体后，需要告诉 IDEA 使用哪一个：

1. 打开 IDEA 的 **Settings** (`Ctrl + Alt + S`)。
2. 进入 **Appearance & Behavior > Appearance**。
3. 勾选 **Use custom font**。
4. 在下拉列表中选择：
    - **Source Han Sans CN** (思源黑体)
    - 或者 **WenQuanYi Micro Hei** (文泉驿微米黑)
5. 点击 **OK**。

**提示：** 如果你在列表中找不到新安装的字体，请尝试重启 IDEA 甚至重启系统以刷新字体缓存。

---

### 第四步：手动刷新字体缓存（可选）
如果执行完上述步骤仍不生效，可以在终端执行：

Bash

```plain
sudo fc-cache -fv
```

然后完全退出 IDEA 再重新启动。

---

### 总结
对于 Fedora 用户，**最核心的操作通常是第二步**：将 `vf` (Variable Fonts) 版本的 Noto CJK 字体替换为普通版本，并确保安装了 `wqy-zenhei-fonts` 作为保底备份。

**这些操作之后，界面的方块应该就会恢复成正常的中文了。还需要我帮你检查编辑器（写代码的地方）的字体渲染设置吗？**

