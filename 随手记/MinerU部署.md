
  
### 4. 扫描件 PDF 无法识别？  
  
扫描件 PDF 本质上是图片组成的 PDF，没有文字层。DocReader 的默认解析器（MarkItDown）无法提取其中的文字。  
  
**解决方案**：部署 MinerU 服务。MinerU 具备 OCR 能力，能够高精度地将扫描件 PDF 转化为可编辑的 Markdown 格式。  
  
#### MinerU 部署方式  
  
**方式一：Conda 安装（推荐）**  
  
```bash  
# 创建并激活环境  
conda create -n mineru python=3.12 -y  
conda activate mineru  
  
# 安装 MinerUpip install --upgrade pip && pip install uv  
uv pip install -U "mineru[all]"  
  
# 下载模型（选择 modelscope 源，国内更快）  
export MINERU_MODEL_SOURCE=modelscope  
mineru-models-download  
  
# 启动服务  
mineru-api --host 0.0.0.0 --port 8080 --device gpu  
```  
  
**方式二：UV Tool 安装**  
  
```bash  
uv tool install "mineru[all]" --python 3.12  
# 下载模型  
export MINERU_MODEL_SOURCE=modelscopemineru-models-download  
  
# 启动服务  
mineru-api --host 0.0.0.0 --port 8080 --device gpu```  
  
#### 配置 DocReader 连接 MinerU  
  
在 `.env` 文件或 `docker-compose.yml` 中添加：  
  
```yaml  
environment:  
  - MINERU_ENDPOINT=http://your-mineru-host:8080  
```  
  
#### 注意事项  
  
- **GPU 要求**：MinerU 需要 NVIDIA GPU 支持，建议显存 >= 8GB  
- **CPU 模式**：如无 GPU，可使用 `--device cpu`，但速度较慢  
- **模型大小**：首次下载模型约需 2-3GB 空间