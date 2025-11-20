
## 背景

最近用的这款笔记，方便倒是很方便，通过git插件能实现笔记的同步，但是图片都是在本地，也同步到github上去了，这本身没啥问题，但是如果我将md文件倒入到到我的博客，这就会有问题了。图片就会无法加载。这里我们就需要用到图床了。

## 前提

前提你需要一个域名和服务器。前段时间刷到个可以用`cloudflare`图床搭建的项目好像什么都不需要，感兴趣可以去看看。

https://linux.do/t/topic/251653

[MarSeventh/CloudFlare-ImgBed: CloudFlare 图床，基于 CloudFlare Pages 和 Telegram Bot 的免费图片托管解决方案！ (github.com)](https://github.com/MarSeventh/CloudFlare-ImgBed)  
从[【白嫖大善人】基于Telegraph的CF免费图床有全新前端啦！！！（开源、清晰、美观、动画丝滑、玩法多样）](https://linux.do/t/topic/154391)  
[收集大家关于CF和TG BOT图床的意见，为下一步开发做准备](https://linux.do/t/topic/215977/27)

## MinIO部署及解析

### docker部署MinIO


最简单的方式就是通过docker部署啦。

```yml
services:
  minio:
    image: minio:latest
    container_name: local_minio
    restart: always
    environment:
      MINIO_ROOT_USER: minio_h2tzp6
      MINIO_ROOT_PASSWORD: minio_Sfh2Zr
      TZ: Asia/Shanghai
    volumes:
      - ./data:/data
      - ./config:/root/.minio
    ports:
      - "9000:9000"
      - "9001:9001"
    command: server /data --console-address ":9001" --address ":9000"
```

创建一个文件夹下面放上面内容的 `docker-compose.yml`文件，并创建`data`和`config`目录用来外挂数据和配置。执行下面命令启动容器。MinIO就部署好啦。

```shell
# 启动容器
docker compose up -d 
```

接下来配置反向代理

### 域名解析

你可以将域名托管在 Cloudflare 上，或者通过阿里云等国内服务进行域名解析。我选择 Cloudflare 的原因是，它会在你服务器和外部访问之间加一层代理，隐藏真实 IP。如果服务器在境外，还能避免被墙的风险。

在我的配置中，我创建了两个解析记录：一个用于 MinIO 控制台访问（看板），另一个用于对外的 MinIO 文件访问，这样管理和使用更清晰。

![域名解析](https://img.dryice.icu/images/2025/11/20/20251120131640298_repeat_1763615802085__906829.png)

### 反向代理

我使用的是 **1Panel** 面板，配置反向代理比较简单。大致步骤如下：

**操作路径：**

`网站 → 网站 → 创建网站 → 反向代理`

然后依次填写：

- **域名**：刚刚在 DNS 中解析好的二级域名
    
- **代理地址**：MinIO 服务的访问地址
    
- **SSL**：如需 HTTPS，需要提前申请好证书
    

提交后即可完成反向代理配置。

需要注意两点：

1. **域名端口**：通常使用 `80`（HTTP）和 `443`（HTTPS）
    
2. **SSL 配置**：开启 HTTPS 时必须先在 1Panel 里导入或申请证书
    

---

### 示例

以我的配置为例：

- **MinIO 控制台域名**：`minio.xxx.com`
    
    - 代理地址：`http://127.0.0.1:9001`
        
- **文件访问域名**：`img.xxx.com`
    
    - 代理地址：`http://127.0.0.1:9000`
        

这样就实现了 MinIO 控制台和文件访问分别通过不同二级域名来访问，既清晰又方便管理。

---


## PicGo 配置

### 下载PicGo

[下载地址](https://github.com/Molunerfinn/picgo/releases),从这个页面选择稳定的版本下载。
安装好之后，下载插件,选择 minio-custom 2.5.3

![image.png](https://img.dryice.icu/images/2025/11/20/20251120134232921_repeat_1763617354471__829803.png)


### 配置图床

在这个里面配置 endPoint，其余的正常填写即可，需要注意一下这里的，自定义域名也最好写一下，不然返回的地址会带一个443端口很不好看。
启用自动归档，这里会自动创建年月日的文件夹，方便查找。

对了，还需要在MinIO创建对于的Bucket,和accessKey,将Bucket设置为public
![image.png](https://img.dryice.icu/images/2025/11/20/20251120143514766_repeat_1763620516368__069447.png)


这里的到的AccessKey 和 SecreKey 填写到下面的配置里面

![image.png](https://img.dryice.icu/images/2025/11/20/20251120143553098_repeat_1763620554790__417443.png)

![image.png](https://img.dryice.icu/images/2025/11/20/20251120143611736_repeat_1763620573044__793594.png)


>注意这个endPoint 不需要前面的https

![image.png](https://img.dryice.icu/images/2025/11/20/20251120142227714_repeat_1763619749176__200654.png)

![image.png](https://img.dryice.icu/images/2025/11/20/20251120142414295_repeat_1763619855710__663809.png)


## Obsidian配置

下载插件

![image.png](https://img.dryice.icu/images/2025/11/20/20251120142832809_repeat_1763620114339__078528.png)

配置上传地址接口，这里的地址和PicGo里的核对一下是不是这个端口，正常来说不用改，直接就能使用，如果用不了报错，看看是不是缺了依赖，我用的是linux，缺少一个`wl-clipboard`的依赖。安装一下即可。

```
Error: Can't find no wl-clipboard at Socket.<anonymous> (/tmp/.mount_PicGo-VGUMov/resources/app.asar/node_modules/picgo/dist/index.cjs.js:1:50431) at Socket.emit (node:events:394:28) at addChunk (node:internal/streams/readable:315:12) at readableAddChunk (node:internal/streams/readable:289:9) at Socket.Readable.push (node:internal/streams/readable:228:10) at Pipe.onStreamRead (node:internal/stream_base_commons:199:23)
```

| 发行版                            | 安装命令                            |
| ------------------------------ | ------------------------------- |
| **Fedora / Red Hat / CentOS**​ | `sudo dnf install wl-clipboard` |
| **Debian / Ubuntu**​           | `sudo apt install wl-clipboard` |
| **Arch Linux / Manjaro**​      | `sudo pacman -S wl-clipboard`   |


![image.png](https://img.dryice.icu/images/2025/11/20/20251120142855938_repeat_1763620137475__135577.png)


好啦，现在在Obsidian里面粘贴图片直接会到图床上了。