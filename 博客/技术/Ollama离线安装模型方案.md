
1. **生成Modelfile**
```bash
# 后面模型名称是你要导出的模型名称，这里以qwen3:0.6b为例
ollama show --modelfile qwen3:0.6b >> Modelfile
```
运行后，一个名为 **Modelfile** 的文本文件将在当前目录下生成。

2. 确认模型 GGUF 文件路径
```bash
ollama show --modelfile qwen3:0.6b
#or
cat Modelfile
```
此命令的输出会显示 **Modelfile** 的内容，其中包含模型的 **GGUF** 文件路径，如下图所示
![image.png](https://img.dryice.icu/images/2025/12/09/20251209114612902_repeat_1765251974693__396336.png)


3. 拷贝模型 GGUF 文件
将上一步确认的 GGUF 文件拷贝到当前工作目录，并给它一个易于识别的名称（例如 `qwen3-0.6b.gguf`）。
```bash
# # 请将 '/var/lib/ollama/blobs/...' 替换为你实际查看到的路径
cp  /var/lib/ollama/blobs/sha256-7f4030143c1c477224c5434f8272c662a8b042079a0a584f0a27a1684fe2e1fa ./qwen3-0.6b.gguf
```

4. 编辑`Modelfile`文件
打开并编辑 **Modelfile** 文件，将 `FROM` 行的模型路径修改为我们刚刚拷贝到当前目录的相对路径。
```bash
vim Modelfile
```

将 **Modelfile** 中的内容（例如：`FROM /var/lib/ollama/blobs/...`）修改为：

```
FROM ./qwen3-0.6b.gguf # ... 其他配置项保持不变
```
![image.png](https://img.dryice.icu/images/2025/12/09/20251209115244084_repeat_1765252365712__354341.png)

5. 迁移和部署
将包含**修改后的 Modelfile** 和 **qwen3-0.6b.gguf** 的**整个目录**拷贝到目标（需要安装的）电脑上。
在目标电脑上，进入该目录并运行以下命令创建模型：
```bash
# 'qwen3:0.6b' 是你给新模型自定义的名称和标签
ollama create qwen3:0.6b -f Modelfile
```
模型创建成功后，即可使用 `ollama list ` 查看是否导入成功。

6. 自动化脚本（可选）
- Linux/macOS 脚本 (`create.sh`)
```bash
# 设置模型名称和标签
MODEL_NAME="qwen3:0.6b"
echo "开始创建 Ollama 模型: $MODEL_NAME"
ollama create $MODEL_NAME -f Modelfile
if [ $? -eq 0 ]; then
    echo "模型 $MODEL_NAME 创建成功！"
else
    echo "模型 $MODEL_NAME 创建失败。"
fi
```

- Windows 脚本 (`create.bat`)
```bash
@echo off
set MODEL_NAME=qwen3:0.6b
echo 正在创建 Ollama 模型: %MODEL_NAME%
ollama create %MODEL_NAME% -f Modelfile
if %errorlevel% equ 0 (
    echo.
    echo 模型 %MODEL_NAME% 创建成功！
) else (
    echo.
    echo 模型 %MODEL_NAME% 创建失败。
)
pause
```
