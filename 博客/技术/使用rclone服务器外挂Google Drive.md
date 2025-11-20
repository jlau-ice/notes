## 引子

前不久入手了一台 **16H16G 的服务器**，111 三年的价格确实香。因为是小厂商的机器，多少还是有点“跑路风险”的担忧，所以我给一些关键数据做了额外备份。

这里我使用 **rclone** 将 **Google Drive 挂载成服务器的一个磁盘目录**，把需要长期保存的文件定时同步到这个“外挂硬盘”里，算是给数据多上一道保险。

至于为什么不直接把数据实时同步到 Google Drive？主要是：

- **实时交互过于频繁**，会不断与 Google Drive API 通信；
    
- **对服务器性能有影响**，尤其是网站流量高峰时；
    
- **挂载到本地再同步** 性能更可控，也不影响线上服务。
    

这样一来，日常使用完全像操作本地文件夹一样，稳定又高效。

下面是具体操作步骤。

## 安装 rclone。

```bash
# Arch Linux / Manjaro
sudo pacman -S rclone

# Debian/Ubuntu
sudo apt update 
sudo apt install rclone
```

验证安装是否成功

```bash
rclone version
```

应该显示类似信息：

```bash
rclone version
rclone v1.71.2
- os/version: arch (64 bit)
- os/kernel: 6.17.7-arch1-1 (x86_64)
- os/type: linux
- os/arch: amd64
- go/version: go1.25.3 X:nodwarf5
- go/linking: dynamic
- go/tags: none
```

## 配置服务

```bash
root@ser657914752113:/# rclone config
No remotes found, make a new one?
n) New remote
s) Set configuration password
q) Quit config
n/s/q> n
```

输入n 创建新的远程
```bash
Enter name for new remote.
name> gdrive
```
输入名称如我的叫 `gdrive` 回车
```bash
Option Storage.
Type of storage to configure.
Choose a number from below, or type in your own value.
 1 / 1Fichier
   \ (fichier)
 2 / Akamai NetStorage
   \ (netstorage)
 3 / Alias for an existing remote
   \ (alias)
 4 / Amazon S3 Compliant Storage Providers including AWS, Alibaba, ArvanCloud, Ceph, ChinaMobile, Cloudflare, DigitalOcean, Dreamhost, Exaba, FlashBlade, GCS, HuaweiOBS, IBMCOS, IDrive, IONOS, LyveCloud, Leviia, Liara, Linode, Magalu, Mega, Minio, Netease, Outscale, OVHcloud, Petabox, RackCorp, Rclone, Scaleway, SeaweedFS, Selectel, StackPath, Storj, Synology, TencentCOS, Wasabi, Qiniu, Zata and others
   \ (s3)
 5 / Backblaze B2
   \ (b2)
 6 / Better checksums for other remotes
   \ (hasher)
 7 / Box
   \ (box)
 8 / Cache a remote
   \ (cache)
 9 / Citrix Sharefile
   \ (sharefile)
10 / Cloudinary
   \ (cloudinary)
11 / Combine several remotes into one
   \ (combine)
12 / Compress a remote
   \ (compress)
13 / DOI datasets
   \ (doi)
14 / Dropbox
   \ (dropbox)
15 / Encrypt/Decrypt a remote
   \ (crypt)
16 / Enterprise File Fabric
   \ (filefabric)
17 / FTP
   \ (ftp)
18 / FileLu Cloud Storage
   \ (filelu)
19 / Files.com
   \ (filescom)
20 / Gofile
   \ (gofile)
21 / Google Cloud Storage (this is not Google Drive)
   \ (google cloud storage)
22 / Google Drive
   \ (drive)
23 / Google Photos
   \ (google photos)
24 / HTTP
   \ (http)
25 / Hadoop distributed file system
   \ (hdfs)
26 / HiDrive
   \ (hidrive)
27 / ImageKit.io
   \ (imagekit)
28 / In memory object storage system.
   \ (memory)
29 / Internet Archive
   \ (internetarchive)
30 / Jottacloud
   \ (jottacloud)
31 / Koofr, Digi Storage and other Koofr-compatible storage providers
   \ (koofr)
32 / Linkbox
   \ (linkbox)
33 / Local Disk
   \ (local)
34 / Mail.ru Cloud
   \ (mailru)
35 / Mega
   \ (mega)
36 / Microsoft Azure Blob Storage
   \ (azureblob)
37 / Microsoft Azure Files
   \ (azurefiles)
38 / Microsoft OneDrive
   \ (onedrive)
39 / OpenDrive
   \ (opendrive)
40 / OpenStack Swift (Rackspace Cloud Files, Blomp Cloud Storage, Memset Memstore, OVH)
   \ (swift)
41 / Oracle Cloud Infrastructure Object Storage
   \ (oracleobjectstorage)
42 / Pcloud
   \ (pcloud)
43 / PikPak
   \ (pikpak)
44 / Pixeldrain Filesystem
   \ (pixeldrain)
45 / Proton Drive
   \ (protondrive)
46 / Put.io
   \ (putio)
47 / QingCloud Object Storage
   \ (qingstor)
48 / Quatrix by Maytech
   \ (quatrix)
49 / SMB / CIFS
   \ (smb)
50 / SSH/SFTP
   \ (sftp)
51 / Sia Decentralized Cloud
   \ (sia)
52 / Storj Decentralized Cloud Storage
   \ (storj)
53 / Sugarsync
   \ (sugarsync)
54 / Transparently chunk/split large files
   \ (chunker)
55 / Uloz.to
   \ (ulozto)
56 / Union merges the contents of several upstream fs
   \ (union)
57 / Uptobox
   \ (uptobox)
58 / WebDAV
   \ (webdav)
59 / Yandex Disk
   \ (yandex)
60 / Zoho
   \ (zoho)
61 / iCloud Drive
   \ (iclouddrive)
62 / premiumize.me
   \ (premiumizeme)
63 / seafile
   \ (seafile)
Storage> 22
```
输入22 选择 Google Drive
```bash
Option client_id.
Google Application Client Id
Setting your own is recommended.
See https://rclone.org/drive/#making-your-own-client-id for how to create your own.
If you leave this blank, it will use an internal key which is low performance.
Enter a value. Press Enter to leave empty.
client_id> 
```
这里直接回车即可：
空着就行,你不追求高并发访问的话，用 rclone 内置的 client_id 完全够用。继续下一步。
```bash
Option client_secret.
OAuth Client Secret.
Leave blank normally.
Enter a value. Press Enter to leave empty.
client_secret> 
```
同样直接回车,留空即可。继续下一步。
```bash
Option scope.
Comma separated list of scopes that rclone should use when requesting access from drive.
Choose a number from below, or type in your own value.
Press Enter to leave empty.
 1 / Full access all files, excluding Application Data Folder.
   \ (drive)
 2 / Read-only access to file metadata and file contents.
   \ (drive.readonly)
   / Access to files created by rclone only.
 3 | These are visible in the drive website.
   | File authorization is revoked when the user deauthorizes the app.
   \ (drive.file)
   / Allows read and write access to the Application Data folder.
 4 | This is not visible in the drive website.
   \ (drive.appfolder)
   / Allows read-only access to file metadata but
 5 | does not allow any access to read or download file content.
   \ (drive.metadata.readonly)
scope> 1
```
这里选 1，你要把 Google Drive 挂载到服务器当硬盘用，需要完整读写权限。
```bash
Option service_account_file.
Service Account Credentials JSON file path.
Leave blank normally.
Needed only if you want use SA instead of interactive login.
Leading `~` will be expanded in the file name as will environment variables such as `${RCLONE_CONFIG_DIR}`.
Enter a value. Press Enter to leave empty.
service_account_file> 
```
这里继续回车，留空即可：
你不需要 Service Account，这一步直接跳过。继续下一步。
```bash
Edit advanced config?
y) Yes
n) No (default)
y/n> n
```
这里选 n，不需要改高级配置。
```bash
Use web browser to automatically authenticate rclone with remote?
 * Say Y if the machine running rclone has a web browser you can use
 * Say N if running rclone on a (remote) machine without web browser access
If not sure try Y. If Y failed, try N.

y) Yes (default)
n) No
y/n> n
```
你这是在服务器里跑的，应该是没有浏览器的，选 n。
```bash
Option config_token.
For this to work, you will need rclone available on a machine that has
a web browser available.
For more help and alternate methods see: https://rclone.org/remote_setup/
Execute the following on the machine with the web browser (same rclone
version recommended):
        rclone authorize "drive" "eyJzY29wZSI6ImRyaXZlIn0"
Then paste the result.
Enter a value.
config_token> 
```
需要切换到本地电脑终端，在本地终端运行下面命令。浏览器会弹出来让你授权。
正常授权即可

```bash
rclone authorize "drive" "eyJzY29wZSI6ImRyaXZlIn0"
```
完成授权得到tocken 粘贴到服务器里面
![image.png](https://img.dryice.icu/images/2025/11/20/20251120155813856_repeat_1763625496676__432829.png)

![image.png](https://img.dryice.icu/images/2025/11/20/20251120160105704_repeat_1763625667279__355609.png)

```bash
Configure this as a Shared Drive (Team Drive)?

y) Yes
n) No (default)
y/n> n
```
这里选 n，因为你用的是个人 Google Drive，不是企业 Workspace 的 Team Drive（共享盘）。
```bash
Configuration complete.
Options:
- type: drive
- scope: drive
- token: {"access_token":"xxx","token_type":"Bearer","refresh_token":"xxxx","expiry":"2025-11-20T16:58:27.382702815+08:00","expires_in":3599}
- team_drive: 
Keep this "gdrive" remote?
y) Yes this is OK (default)
e) Edit this remote
d) Delete this remote
y/e/d> 
```

这里直接选 **y** 保存即可；到这你的 `gdrive` 已经配置完成了。

## 验证

接下来你可以直接测试一下：

```bash
rclone ls gdrive:
```

可以看见谷歌硬盘里的东西啦。

![image.png](https://img.dryice.icu/images/2025/11/20/20251120160611663_repeat_1763625973188__766154.png)


挂载硬盘

我这里是将谷歌云盘的debain文件夹挂在到 `/mnt/gdrive`，你可以自行调整

```bash
mkdir -p /mnt/gdrive
```

```bash
sudo tee /etc/systemd/system/rclone-gdrive.service <<'EOF'
[Unit]
Description=Rclone Google Drive Mount
After=network-online.target

[Service]
Type=notify
User=root
ExecStart=/usr/bin/rclone mount gdrive:debain /mnt/gdrive \
  --vfs-cache-mode writes \
  --vfs-cache-max-age 24h \
  --vfs-cache-max-size 10G \
  --buffer-size 64M \
  --dir-cache-time 72h \
  --poll-interval 1m \
  --log-file /var/log/rclone-gdrive.log \
  --log-level INFO
ExecStop=/bin/fusermount3 -uz /mnt/gdrive
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
```


```bash
# 重载 systemd 配置
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

# 启动服务 & 开机自启
sudo systemctl enable --now rclone-gdrive.service

# 查看状态
sudo systemctl status rclone-gdrive
sudo journalctl -u rclone-gdrive -f   # 实时日志
```

可以看见挂载成功了。

![image.png](https://img.dryice.icu/images/2025/11/20/20251120161510015_repeat_1763626511536__622555.png)

可以用 `df -h | grep gdrive` 看看挂载情况，嗯，可以看见使用情况。

![image.png](https://img.dryice.icu/images/2025/11/20/20251120161931482_repeat_1763626773048__561602.png)

接下来试试在 这个文件夹下面创建文件看看是否同步。
```bash
cd /mnt/gdrive
touch test.txt
```

可以看见，能正常同步啦。
![image.png](https://img.dryice.icu/images/2025/11/20/20251120162202612_repeat_1763626924255__225517.png)

现在只需要，写定时任务把一些总要的数据做同步就行啦。