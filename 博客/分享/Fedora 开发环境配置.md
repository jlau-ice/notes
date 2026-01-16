## jdk

官网下载 tar.gz 解压即可
[官网地址](https://www.oracle.com/java/technologies/downloads)

设置快捷切换命令
```bash 
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
```

## nvm
脚本安装
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash


# pnpm 安装
# 启用 corepack
corepack enable

# 激活特定版本的 pnpm (可选)
corepack prepare pnpm@latest --activate
```

## claude code脚本安装

```bash
curl -fsSL https://claude.ai/install.sh | bash
brew install --cask claude-code
winget install Anthropic.ClaudeCode
```

## uv 安装

```bash
sudo dnf install uv
# 或者脚本安装
curl -LsSf https://astral.sh/uv/install.sh | sh
wget -qO- https://astral.sh/uv/install.sh | sh
curl -LsSf https://astral.sh/uv/0.9.25/install.sh | sh
```

### 常用的uv命令（这个老忘记）

#### 1. 项目初始化与环境管理

```bash
# 创建新项目
uv init my-project

uv venv          # 默认使用系统 Python
uv venv --python 3.12  # 创建指定版本的虚拟环境

# 激活环境
source .venv/bin/activate
```


#### 2. 软件包管理 (类似 pip)

这是最常用的部分，速度比 `pip` 快 10-100 倍。

```
# 安装包
uv pip install requests

# 从 requirements.txt 安装：
uv pip install -r requirements.txt

# 卸载包
uv pip uninstall requests

# 查看已安装包
uv pip list
```


uv add
**添加普通依赖**：
```bash
uv add requests
```

添加开发环境依赖（类似 npm install -D，用于存放 ruff, pytest 等测试/格式化工具）：

```
uv add --dev pytest
```

**安装特定版本的包**：

```bash
uv add "requests>=2.31.0"
```

**从 Git 或本地路径添加**：
```bash
uv add git+https://github.com/encode/httpx
uv add ./local_package_dir
```

当你使用 `uv add` 时，它不仅仅是“安装一个包”，而是**接管了整个项目的生命周期**。它与 `package.json` 的逻辑几乎一模一样：

| **动作**     | **npm (Node.js)**   | **uv (Python)**       |
| ---------- | ------------------- | --------------------- |
| **配置文件**   | `package.json`      | `pyproject.toml`      |
| **锁文件**    | `package-lock.json` | `uv.lock`             |
| **添加依赖**   | `npm install <pkg>` | **`uv add <pkg>`**    |
| **安装所有依赖** | `npm install`       | **`uv sync`**         |
| **运行脚本**   | `npm run <script>`  | **`uv run <script>`** |

#### 3. 直接运行脚本 (无须预装环境)

```
# 直接运行脚本 (无须预装环境)
uv run script.py

# 直接在临时环境执行命令
uv run --with requests python -c "import requests; print(requests.get('https://google.com'))"
```
#### 4. 工具管理 (类似 pipx)

如果你想全局安装一些 Python 工具（如 `black`, `ruff`, `httpie`），但又不想污染全局环境：


```bash
uv tool install ruff
uvx ruff --version  # uvx 是 uv tool run 的简写
```


#### 5. Python 版本管理

`uv` 可以像管理包一样管理 Python 解释器：

**列出可安装的 Python 版本**：

```bash
uv python list
```

**安装特定版本**：

```bash
uv python install 3.11
```


**在当前目录查找 Python**：

```bash
uv python find
```


#### 6. 锁定依赖 (类似 pip-compile)

**编译 requirements.in 到 .txt**：

```bash
uv pip compile requirements.in -o requirements.txt
```

**同步环境（删除多余包，确保与锁定文件一致）**：

```bash
uv pip sync requirements.txt
```



