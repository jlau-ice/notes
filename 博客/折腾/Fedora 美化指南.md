
魔法安装，这里就不多介绍了

## 输入法

原生代理 ibus 联想不是一般的垃圾，安装 Fcitx5 输入法

安装Fcitx5 安装核心包、中文输入法和配置工具 这提供了框架、拼音/五笔等输入法和图形配置界面。
```bash
sudo dnf install fcitx5 fcitx5-chinese-addons fcitx5-configtool
```

添加自启动 安装自启动脚本，让Fcitx5开机运行

```bash
sudo dnf install fcitx5-autostart
```
配置环境变量 `/etc/environment`

## 字体补充

`leetcode` 需要字体 `Droid Sans Mono`

```bash
sudo dnf install google-droid-sans-mono-fonts
```

idea GUI 界面中文字体不现实，现实为方块

```bash
# 安装 思源黑体 (Adobe Source Han Sans) 和 文泉驿微米黑
sudo dnf install adobe-source-han-sans-cn-fonts wqy-microhei-fonts wqy-zenhei-fonts

# 安装中文语言包支持（这会补齐大部分缺失的依赖）
sudo dnf install langpacks-zh_CN
```

解决“可变字体”兼容问题（Fedora 用户常遇坑） (可选)

Fedora 默认安装的是 `google-noto-sans-cjk-vf-fonts`（VF 代表 Variable Font）。某些版本的 IntelliJ IDEA (Java) 无法正确解析这种字体，导致显示方块。

**解决方法是替换为静态版本：**
```bash
# 移除可变字体版本
sudo dnf remove google-noto-sans-cjk-vf-fonts

# 安装静态版本
sudo dnf install google-noto-sans-cjk-fonts google-noto-serif-cjk-fonts

手动刷新字体缓存
sudo fc-cache -fv
```

jetbrains 系列字体

```bash
sudo dnf install jetbrains-mono-fonts-all
```

[官网下载地址](https://download.jetbrains.com/fonts/JetBrainsMono-2.304.zip?_cl=MTsxOzE7RGpqTGhJZzhqTENXWm9namliZlh4dUV5cVM5dlRoaldJMVBMOUFXZWRZcFNBVFFVamFCamdjckdGcW9oSzNZNzs=&_gl=1*k8r7iq*_gcl_au*ODk4MTMzNjI0LjE3Njc5NTIzNDU.*FPAU*ODk4MTMzNjI0LjE3Njc5NTIzNDU.*_ga*MTM2NDE3MzE2Mi4xNzY3OTUyMzQ1*_ga_9J976DJZ68*czE3NjgxMDY5NzAkbzMkZzAkdDE3NjgxMDY5NzQkajU2JGwwJGgw)

[第三方地址](https://release-assets.githubusercontent.com/github-production-release-asset/27574418/c2cb9596-7c30-4241-8421-a0e6d8ab1112?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-01-11T04%3A40%3A46Z&rscd=attachment%3B+filename%3DJetBrainsMono.zip&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-01-11T03%3A40%3A18Z&ske=2026-01-11T04%3A40%3A46Z&sks=b&skv=2018-11-09&sig=cFw%2B6IKeDkWPDB0MXHqiWQjq9tiXAFAvBxti1ELb6Iw%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc2ODEwNzMzNSwibmJmIjoxNzY4MTAzNzM1LCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.NmA6TIvvqdvjHTNSJh1-e7041KtKC2sfZCbdVLW96AA&response-content-disposition=attachment%3B%20filename%3DJetBrainsMono.zip&response-content-type=application%2Foctet-stream)

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

## 终端美化

这里终端模拟器选用的是`ghostty`，`sh`工具用的是`zsh`
为啥用 `ghostty`，请看 其他的像 `gnome-terminal`  `Ptyxis` 都对 `starship` 不是很好 只有`ghostty`左右的圆角处理的比较好，这里没有去试`oh-my-zsh` 听说也很不错。
![](https://cdn.nlark.com/yuque/0/2026/png/34904774/1768014475413-9d66460b-4445-4801-a5fe-d0f80dc83dab.png)

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

[主题下载gruvbox-rainbow](https://starship.rs/presets/toml/gruvbox-rainbow.toml)

下载好的`toml`文件重命名为`starship.toml` 复制到 `~/.config/` 目录下

编辑zshrc
```
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

3. 终端模拟器美化
下载 `ghostty` 主题 [下载地址](https://github.com/catppuccin/ghostty/blob/main/themes/catppuccin-frappe.conf)

将下载好的文件放到一个位置 ，为这里放到了 `/home/ice/.config/ghostty/`
编辑 `ghostty` 的配置文件 位置在 `/home/ice/.config/ghostty/config`
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

一些必要依赖下载

```bash
# obsidian 运行所需
sudo dnf install fuse fuse-libs

# clash-verge 运行所需
sudo dnf install libappindicator-gtk3
sudo dnf install ayatana-indicator-application

# 独显模式 运行可能出问题加上参数 
nohup env WEBKIT_DISABLE_COMPOSITING_MODE=1 clash-verge > ~/clash_verge.log 2>&1 &
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


拓展推荐
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


开启可变刷新率

```bash
flatpak install page.tesk.Refine
```

## GRUB启动美化

你可以去 [Gnome-look.org](https://www.gnome-look.org/browse?cat=109) 寻找喜欢的 GRUB 主题。这里我推荐一个非常流行且自动化的工具：**Vinceliuice 的 GRUB 主题库**。

```bash
git clone https://github.com/vinceliuice/grub2-themes.git
cd grub2-themes
sudo ./install.sh -t tela -s 1080p
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```



## 开发环境

nvm
```bash
sudo pacman -S nvm

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
```


pnpm 单node 管理
pnpm 不跟着 Node 自动装，nvm 每切一个 Node，都要单独处理。
```bash

corepack enable

corepack prepare pnpm@latest --activate
```

zshrc 内容补充

```bash
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
```