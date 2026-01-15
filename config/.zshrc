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
alias clash='nohup env WEBKIT_DISABLE_COMPOSITING_MODE=1 clash-verge > ~/clash_verge.log 2>&1 &'
alias jep='nohup env WEBKIT_DISABLE_COMPOSITING_MODE=1 /home/ice/file/zip/jetbrains-crack-toolbox_2.2.0_linux/jetbrains-crack-toolbox > ~/jetbrains-crack.log 2>&1 &'
alias cls='clear'
alias ll='ls -l'

# Docker 容器简化格式化输出
alias dpsf='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.Ports}}"'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dpsm='docker ps --format "table {{.ID}}\t{{.Image}}\t{{.Names}}"'

# claude code 
export PATH="$HOME/.local/bin:$PATH"

# --- JDK Switcher ---
function _switch_jdk() {
    export JAVA_HOME=$1
    export PATH=$JAVA_HOME/bin:$PATH
    echo "Switched to JDK from: $JAVA_HOME"
    java -version
}

# 这里的路径请确保与你的 ~/jdks 目录下的文件夹名一致
alias usejdk8='_switch_jdk ~/jdks/jdk1.8.0_461'
alias usejdk11='_switch_jdk ~/jdks/jdk-11.0.28'
alias usejdk17='_switch_jdk ~/jdks/jdk-17.0.16'
alias usejdk21='_switch_jdk ~/jdks/jdk-21.0.9'

# 设置一个默认 JDK (比如 21)
export JAVA_HOME=~/jdks/jdk-21.0.9
export PATH=$JAVA_HOME/bin:$PATH


