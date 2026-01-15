
魔法工具安装，懂的都懂

## 输入法

首先当然要安装一下输入法啦
原生代理ibus联想不是很好，这里我们选择安装Fcitx5输入法
```bash
sudo dnf install fcitx5 fcitx5-chinese-addons fcitx5-configtool
```
添加自启动 安装自启动脚本，让Fcitx5开机运行
```bash
sudo dnf install fcitx5-autostart
```
配置环境变量 `/etc/environment`

```
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
```

## 字体补充

网页 `leetcode` 需要字体 `Droid Sans Mono` (刷题党必备需要哈哈哈)


```bash
sudo dnf install google-droid-sans-mono-fonts
```

idea GUI 界面中文字体显示错误，显示为方块

```bash
# 安装 思源黑体 (Adobe Source Han Sans) 和 文泉驿微米黑
sudo dnf install adobe-source-han-sans-cn-fonts wqy-microhei-fonts wqy-zenhei-fonts

# 安装中文语言包支持（这会补齐大部分缺失的依赖）
sudo dnf install langpacks-zh_CN
```

解决“可变字体”兼容问题 (可选)

Fedora 默认安装的是 `google-noto-sans-cjk-vf-fonts`（VF 代表 Variable Font）。某些版本的 IntelliJ IDEA (Java) 无法正确解析这种字体，导致显示方块。

替换为静态版本：
```bash
# 移除可变字体版本
sudo dnf remove google-noto-sans-cjk-vf-fonts

# 安装静态版本
sudo dnf install google-noto-sans-cjk-fonts google-noto-serif-cjk-fonts

# 手动刷新字体缓存
sudo fc-cache -fv
```

jetbrains 系列字体

```bash
sudo dnf install jetbrains-mono-fonts-all
```
jetbrains 字体的一些补充（有的需要重启才生效）
[官网下载地址](https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip?_cl=MTsxOzE7RGpqTGhJZzhqTENXWm9namliZlh4dUV5cVM5dlRoaldJMVBMOUFXZWRZcFNBVFFVamFCamdjckdGcW9oSzNZNzs=&_gl=1*k8r7iq*_gcl_au*ODk4MTMzNjI0LjE3Njc5NTIzNDU.*FPAU*ODk4MTMzNjI0LjE3Njc5NTIzNDU.*_ga*MTM2NDE3MzE2Mi4xNzY3OTUyMzQ1*_ga_9J976DJZ68*czE3NjgxMDY5NzAkbzMkZzAkdDE3NjgxMDY5NzQkajU2JGwwJGgw)  --- [其他地址](https://release-assets.githubusercontent.com/github-production-release-asset/27574418/c2cb9596-7c30-4241-8421-a0e6d8ab1112?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-01-11T04%3A40%3A46Z&rscd=attachment%3B+filename%3DJetBrainsMono.zip&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-01-11T03%3A40%3A18Z&ske=2026-01-11T04%3A40%3A46Z&sks=b&skv=2018-11-09&sig=cFw%2B6IKeDkWPDB0MXHqiWQjq9tiXAFAvBxti1ELb6Iw%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2ODEwNzMzNSwibmJmIjoxNzY4MTAzNzM1LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.NmA6TIvvqdvjHTNSJh1-e7041KtKC2sfZCbdVLW96AA&response-content-disposition=attachment%3B%20filename%3DJetBrainsMono.zip&response-content-type=application%2Foctet-stream)

下载解压把 `.ttf` 文件放入到 `/usr/share/fonts` 目录下面

```bash
unzip JetBrainsMono-2.304.zip -d jetbrains-font
```

**创建字体目录：** 你可以选择安装给“当前用户”或“全系统”：
仅当前用户：`mkdir -p ~/.local/share/fonts`
全系统（推荐）：`sudo mkdir -p /usr/share/fonts/jetbrains`
移动字体文件：

```bash
# 假设你安装给全系统
sudo cp -r jetbrains-font/fonts/ttf/*.ttf /usr/share/fonts/jetbrains/
```

这里的字体可能还不是很全如wps中的一些字体，但是应该够了


## 终端美化

这里终端模拟器选用的是`ghostty`，`sh`工具用的是`zsh`
为啥用 `ghostty`，请看 其他的像 `gnome-terminal`  `Ptyxis` 都对 `starship` 不是很好 只有`ghostty`左右的圆角处理的比较好，这里没有去试`oh-my-zsh` 听说也很不错，下次出一个 `oh-my-zsh`配置。

![img](https://img.dryice.icu/images/2026/01/13/20260113153412364_repeat_1768289653462__066703.png)

1. 安装`zsh` 和 `ghostty`
```bash
# 安装 `ghostty
sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
sudo dnf install ghostty

# 安装 zsh
sudo dnf install zsh

# 语法高亮和自动补全
sudo dnf install zsh-syntax-highlighting zsh-autosuggestions

# fedora 43 不支持
# 1. 启用第三方仓库
# sudo dnf copr enable @zsh-users/zsh-completions
# 2. 安装插件
# sudo dnf install zsh-completions
```

2. 下载starship

```
# 添加源
sudo dnf copr enable atim/starship
sudo dnf install starship

# 或者脚本安装
curl -sS https://starship.rs/install.sh | sh
```

[主题挑选](https://starship.rs/presets/gruvbox-rainbow)
我选的是`gruvbox-rainbow `主题
[主题下载gruvbox-rainbow](https://starship.rs/presets/toml/gruvbox-rainbow.toml)

下载好的`toml`文件重命名为`starship.toml` 放到 `~/.config/` 目录下

编辑zshrc，加入如下内容
```
eval "$(starship init zsh)"
```

附上我完整的zsh配置，里面包括了语法高亮和补全。类似下面的效果，只要按以下方向键`->`，就能补全。还是很方便的

![img](https://img.dryice.icu/images/2026/01/13/20260113153459732_repeat_1768289700852__089276.png)

```
# Created by newuser for 5.9
#

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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm              
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
alias clash='nohup env WEBKIT_DISABLE_COMPOSITING_MODE=1 clash-verge > ~/clash_verge.log 2>&1 &'
alias jep='nohup env WEBKIT_DISABLE_COMPOSITING_MODE=1 /home/ice/file/zip/jetbrains-crack-toolbox_2.2.0_linux/jetbrains-crack-toolbox > ~/jetbrains-crack.log 2>&1 &'

# 开启代理
proxy() {
  export http_proxy="http://127.0.0.1:7897"
  export https_proxy="http://127.0.0.1:7897"
  export HTTP_PROXY="$http_proxy"
  export HTTPS_PROXY="$https_proxy"
  export NO_PROXY="localhost,127.0.0.1,::1"
  export no_proxy="$NO_PROXY"
}

# 取消代理
unproxy() {
  unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY
}

alias switch-ohmyzsh='source ~/.zshrc.zsh-init'

alias cls='clear'
alias ll='ls -l'

# claude code
export PATH="$HOME/.local/bin:$PATH"

# Docker 容器简化格式化输出
alias dpsf='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.Ports}}"'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dpsm='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Names}}"'

# 这里的路径请确保与你的 ~/jdks 目录下的文件夹名一致
alias usejdk8='_switch_jdk ~/jdks/jdk1.8.0_461'
alias usejdk11='_switch_jdk ~/jdks/jdk-11.0.28'
alias usejdk17='_switch_jdk ~/jdks/jdk-17.0.16'
alias usejdk21='_switch_jdk ~/jdks/jdk-21.0.9'

# 设置一个默认 JDK (比如 21)
export JAVA_HOME=~/jdks/jdk-21.0.9
export PATH=$JAVA_HOME/bin:$PATH
```

重启终端就能看见配置好了，效果如下

![img](https://img.dryice.icu/images/2026/01/13/20260113153613073_repeat_1768289774470__954215.png)

3. 终端模拟器美化
下载 `ghostty` 主题 [下载地址](https://github.com/catppuccin/ghostty/blob/main/themes/catppuccin-frappe.conf)

将下载好的文件放到一个位置 ，为这里放到了 `/home/ice/.config/ghostty/`
编辑 `ghostty` 的配置文件。位置在 `/home/ice/.config/ghostty/config`
加入如下内容

```text
theme = /home/ice/.config/ghostty/catppuccin-frappe.conf

# 透明程度
background-opacity = 0.85

# 字体
font-family = "Adwaita Mono"

# 字体大小
font-size = 15

#隐藏标题栏
window-decoration = none

#设置左右边距
window-padding-x=10
#设置上下边距
window-padding-y=10

# 初始化高度和宽度
window-height = 28
window-width = 95
```
## 桌面美化

显卡驱动安装


```bash
sudo dnf install \
https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf makecache
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda
```


ExtensionManager拓展下载(这里用的是flatpak 下载会沙箱化，不推荐用这个安装微信，好像一些位置复制的文件不能粘贴到对话框，粘过去的只有路径)，这里重新添加源之后应该就能处理fedora的gnome-software 一直刷新的问题。

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

拓展推荐
![img](https://img.dryice.icu/images/2026/01/13/20260113153641035_repeat_1768289803030__114164.png)

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
Lock Keys  # 大写锁数字键开启情况
```

对应拓展的效果
Blur my Shell 开启和没有开启
![img](https://img.dryice.icu/images/2026/01/13/20260113153701043_repeat_1768289822163__687775.png)

Input Method Panel 开启和为开启效果
![img](https://img.dryice.icu/images/2026/01/13/20260113153724536_repeat_1768289845628__055279.png)

Logo Menu 苹果标就是他啦

![img](https://img.dryice.icu/images/2026/01/13/20260113153739363_repeat_1768289860657__734032.png)

Vitals 他会显示网速等信息


AppIndicator and KStatusNotifierItem Support 他会在状态栏显示应用
![img](https://img.dryice.icu/images/2026/01/13/20260113153754683_repeat_1768289875733__690477.png)

Clipboard Indicator  剪切板历史，可自定义快捷键
![img](https://img.dryice.icu/images/2026/01/13/20260113153816433_repeat_1768289898493__843021.png)


Lock Keys 大写锁数字键开启情况
![img](https://img.dryice.icu/images/2026/01/13/20260113153828899_repeat_1768289909994__096517.png)


下载Pins 
```bash
# Pins 可以隐藏快捷方式以及更换快捷方式图标,以及添加启动参数，比如我的clash-verge 启动闪退在独显模式，需要加 `WEBKIT_DISABLE_COMPOSITING_MODE=1` 这个参数才行
flatpak install io.github.fabrialberio.pinapp
```

![img](https://img.dryice.icu/images/2026/01/13/20260113153845509_repeat_1768289927577__654849.png)


![img](https://img.dryice.icu/images/2026/01/13/20260113153910451_repeat_1768289951567__838959.png)

## GRUB启动美化

你可以去 [Gnome-look.org](https://www.gnome-look.org/browse?cat=109) 寻找喜欢的 GRUB 主题。这里我用的是：Vinceliuice 的 GRUB 主题库，有四款主题可选 `tela|vimix|stylish|whitesur`。

```bash
git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes
# sudo ./install.sh -t whitesur -s 2k
# sudo ./install.sh -t whitesur -c 2560x1600
sudo ./install.sh -t whitesur -c 1920x1080
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

```text
  -t, --theme                 theme variant(s)          [tela|vimix|stylish|whitesur]       (default is tela)
  -i, --icon                  icon variant(s)           [color|white|whitesur]              (default is color)
  -s, --screen                screen display variant(s) [1080p|2k|4k|ultrawide|ultrawide2k] (default is 1080p)
  -c, --custom-resolution     set custom resolution     (e.g., 1600x900)                    (disabled in default)
  -r, --remove                remove theme              [tela|vimix|stylish|whitesur]       (must add theme name option, default is tela)

  -b, --boot                  install theme into '/boot/grub' or '/boot/grub2'
  -g, --generate              do not install but generate theme into chosen directory       (must add your directory)

  -h, --help                  show this help
```

暂时就这么多了，后续有的话再补充，这个应该适用于所有gnome桌面。