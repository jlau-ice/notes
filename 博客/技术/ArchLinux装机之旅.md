
## 装机前的准备

安装镜像 iso 在开源镜像站（推荐）或者 [archlinux 官方下载页面](https://archlinux.org/download/) 下载。

下面是国内常用的提供 archlinux 安装镜像的开源镜像站（选一个即可）：

- [中国科学技术大学开源镜像站](http://mirrors.ustc.edu.cn/)
- [清华大学开源软件镜像站](https://mirrors.tuna.tsinghua.edu.cn/)
- [华为开源镜像站](https://repo.huaweicloud.com/archlinux/)
- [兰州大学开源镜像站](https://mirror.lzu.edu.cn/archlinux/)

`iso` > `20XX.XX.XX` > `archlinux-20XX.XX.XX-x86_64.iso`

还需要一部分未分配空间，再此电脑中右击管理 打开磁盘管理，压缩卷。酌情分配。

## 基础安装

### 开始安装
插入U盘，进入bios, 将U盘移动到最前面，从U盘引导启动。
进入安装界面 选择第一个。
等待系统文件从U盘加载到内存中，加载完成就可以拔掉U盘了。
然后就是跟着上面进行基本的 检查 联网。

### 禁用reflector 服务

```shell
systemctl stop reflector.service
systemctl status reflector.service
```
>tips: 禁用补全不到的蜂鸣 `rmmod pcspkr`

>永久禁用：`vim /etc/modprobe.d/blacklist.conf`   添加 `blacklist pcspkr`

### 确认是否为 UEFI 模式

```shell
ls /sys/firmware/efi/efivars
```
若输出了一堆东西（`efi` 变量），则说明已在 `UEFI` 模式。否则请确认你的启动方式是否为 `UEFI`。

链接网络，这里可以通过有线或者无线连接，无线连接可能出现网卡问题，无法链接的情况。这里最好还是用有线链接，可以通过手机USB的方式给笔记比连接网络。

如果是无线连接。
```shell
iwctl # 进入交互式命令行
device list # 列出无线网卡设备名，比如无线网卡看到叫 wlan0
station wlan0 scan # 扫描网络
station wlan0 get-networks # 列出所有 wifi 网络
station wlan0 connect wifi-name # 进行连接，注意这里无法输入中文。回车后输入密码即可
exit # 连接成功后退出
```
最后测试一下是否连上了网络 `ping baidu.com`

### 更新系统时钟(可选)

```shell
timedatectl set-ntp true # 将系统时间与网络时间进行同步
timedatectl status # 检查服务状态
```
### 换源

```shell
vim /etc/pacman.d/mirrorlist
```

>`vim`技巧 将China 的剪切放最上面。按`v`进行选择。选择所有的`China`源。按`d`剪切。光标移动到最上。`p`进行粘贴。

### 分区和格式化
- `/` 根目录：`>= 128GB`（和用户主目录在同一个 `Btrfs` 文件系统上）
- `/home` 用户主目录：`>= 128GB`（和根目录在同一个 `Btrfs` 文件系统上）
- `/boot/efi` EFI 分区：`256MB`（由电脑厂商或 Windows 决定，无需再次创建）
- Swap 分区：`>= 电脑实际运行内存的 60%`（设置这个大小是为了配置休眠准备）

```shell
lsblk # 显示当前分区情况
cfdisk /dev/nvmexn1 # 对安装 archlinux 的磁盘分区
```
什么的x 和 1 具体要看你的磁盘。
如果你只有一块块银盘。在查看分区的时候应该会有一个 应该是`nvme0n1`

更具提示进行分区即可。这里讲一下 swap有两种方式，一个是交换文件的方式，一个是交换分区的方式。
如果使用交换分区的方式，在分区的时候要创建swap分区。交换文件的方式则不用，后期创建子卷挂载就行了。
还有一个就是关于启动分区 是 挂在到 `/boot` 还是 `/boot/efi`，还是挂载到`/efi`。都可以，建议后面两种。具体可以看:

[Arch Wiki](wiki.archlinux.org/title/EFI_system_partition#Typical_mount_points) 

[对于 EFI 系统挂载，哪个更好：/mnt/efi 还是 /boot/efi](https://www.reddit.com/r/archlinux/comments/o7ozp1/for_efi_system_mounting_what_would_be_better/?tl=zh-hans)

[EFI 分区：/boot, /boot/efi, 还是 /efi](https://www.reddit.com/r/archlinux/comments/1f9d40g/efi_partition_boot_bootefi_or_efi/?tl=zh-hans)

还有一个就启动分区要不要和window公用。我的建议是，如果你只有一块硬盘，那还是放一起。如果有两块，还是分开好，当然也可以放一起。一块的话最好还是不要单建EFI引导，可能会出现问题。没有尝试过。

### 格式化并创建 Btrfs子卷

```shell
# 格式化 EFI 分区 ，前面的过程中如果创建了 启动分区 这里需要格式化
# 如果共用一个启动分区，则不需要格式化！！则不需要格式化！！！则不需要格式化！！
# mkfs.fat -F32 /dev/nvmexn1pn
mkswap /dev/nvmexn1pn					# 格式化 Swap 分区
mkfs.btrfs -L myArch /dev/nvmexn1pn 	# 格式化 Btrfs 分区

# 为了创建子卷，我们需要先将 Btrfs 分区挂载到 /mnt 下：
mount -t btrfs -o compress=zstd /dev/nvmexn1pn /mnt

# 创建 Btrfs 子卷
btrfs subvolume create /mnt/@ # 创建 / 目录子卷
btrfs subvolume create /mnt/@home # 创建 /home 目录子卷
# 如果用的是交换文件的方式需要创建swap子卷
# btrfs subvolume create /mnt/@swap # 创建 /home 目录子卷
btrfs subvolume list -p /mnt

# 子卷创建好后，我们需要将 /mnt 卸载掉，以挂载子卷：
umount /mnt

mount -t btrfs -o subvol=/@,compress=zstd /dev/nvmexn1pn /mnt # 挂载 / 目录
mkdir /mnt/home # 创建 /home 目录
mount -t btrfs -o subvol=/@home,compress=zstd /dev/nvmexn1pn /mnt/home # 挂载 /home 目录
# 交换文件的方式
# mkdir /mnt/swap # 创建 /swap 目录
mount -t btrfs -o subvol=/@swap,compress=zstd /dev/nvmexn1pn /mnt/swap 

# 创建 /boot 目录  挂载 /boot 目录
mkdir -p /mnt/boot 
# 二选一 建议挂到 /boot/efi 
mount /dev/nvmexn1pn /mnt/boot 
mount /dev/nvmexn1pn /mnt/boot/efi  


# 挂在windows的启动分区，如果是两块银盘的话。
# mount /dev/nvmexn1pn /mnt/winboot  
# 如果是交换文件的方式，前面需要创建swap子卷。
swapon /dev/nvmexn1pn # 挂载交换分区
```


### 系统和必要软件安装

```shell
# 更新密钥
pacman -Sy archlinux-keyring
pacstrap -K /mnt base base-devel linux linux-firmware btrfs-progs
pacstrap /mnt networkmanager vim sudo zsh zsh-completions
```

### 创建swap 文件(只有使用交换文件才操作)
```shell
btrfs filesystem mkswapfile --size 64G --uuid clear /mnt/swap/swapfile
# 启动swap
swapon /mnt/swap/swapfile
```


### 生成fstab(开机自动挂载)
1. fstab 用来定义磁盘分区。它是 Linux 系统中重要的文件之一。使用 genfstab 自动根据当前挂载情况生成并写入 fstab 文件：
```shell
genfstab -U /mnt > /mnt/etc/fstab
cat /mnt/etc/fstab
```
2. 复查一下/mnt/etc/fstab确保没有错误：
```shell
cat /mnt/etc/fstab
```

若为 NVME 协议的硬盘，输出结果应该与此类似：
```fstab
# /dev/nvme0n1p6  /  btrfs  rw,relatime,compress=zstd:3,ssd,space_cache,subvolid=256,subvol=/@,subvol=@ 0 0
UUID=d01a3ca5-0798-462e-9a30-97065e7e36e1 /  btrfs  rw,relatime,compress=zstd:3,ssd,space_cache,subvolid=256,subvol=/@,subvol=@  0 0

# /dev/nvme0n1p1  /boot vfat  rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro      0 2
UUID=522C-80C6  /boot vfat  rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro 0 2

# /dev/nvme0n1p6  /home btrfs rw,relatime,compress=zstd:3,ssd,space_cache,subvolid=257,subvol=/@home,subvol=@home 0 0
UUID=d01a3ca5-0798-462e-9a30-97065e7e36e1 /home btrfs rw,relatime,compress=zstd:3,ssd,space_cache,subvolid=257,subvol=/@home,subvol=@home 0 0

# /dev/nvme0n1p5  none  swap  defaults  0 0
UUID=8e40dbed-590f-4cb8-80de-5cef8343a9fc none  swap  defaults  0 0
```
### change root
使用以下命令把系统环境切换到新系统下：
```shell
arch-chroot /mnt
```
此时，原来安装盘下的 /mnt 目录就变成了新系统的 / 目录。同时，可以发现命令行的提示符颜色和样式也发生了改变。


### 设置主机名与时区

```shell

vim /etc/hostname
```
```shell
vim /etc/hosts
```
ArchLinux 是前面设置的主机名
```txt
127.0.0.1   localhost
::1         localhost
127.0.1.1   ArchLinux.localdomain ArchLinux
```
```shell
# 设置时区
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

### 硬件时间设置
```shell
hwclock --systohc
```

### 设置 Locale

Locale 决定了软件使用的语言、书写习惯和字符集。
编辑 /etc/locale.gen，去掉 en_US.UTF-8 UTF-8 以及 zh_CN.UTF-8 UTF-8 行前的注释符号（#）：

然后使用如下命令生成 locale：
```shell
locale-gen
```

向 /etc/locale.conf 输入内容：
```shell
echo 'LANG=en_US.UTF-8'  > /etc/locale.conf
```

### 为 root 用户设置密码
```
passwd root
```
### 安装微码
```
pacman -S intel-ucode # Intel
pacman -S amd-ucode # AMD
```

### 安装引导程序

```shell
pacman -S grub efibootmgr os-prober
```
安装 GRUB 到 EFI 分区：
```shell
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ARCH
```

```
vim /etc/default/grub
```

进行如下修改：

- 去掉 `GRUB_CMDLINE_LINUX_DEFAULT` 一行中最后的 `quiet` 参数
- 把 `loglevel` 的数值从 `3` 改成 `5`。这样是为了后续如果出现系统错误，方便排错
- 加入 `nowatchdog` 参数，这可以显著提高开关机速度
- 为了引导 win10，则还需要添加新的一行 `GRUB_DISABLE_OS_PROBER=false`

>`nowatchdog` 参数无法禁用英特尔的看门狗硬件，改为 `modprobe.blacklist=iTCO_wdt` 即可。如有需要可以参考 [ArchWiki 对应内容](https://wiki.archlinuxcn.org/wiki/%E6%80%A7%E8%83%BD%E4%BC%98%E5%8C%96#%E7%9C%8B%E9%97%A8%E7%8B%97)

### 最后生成 `GRUB` 所需的配置文件：
```shell
grub-mkconfig -o /boot/grub/grub.cfg
```

### 完成安装

```shell
exit # 退回安装环境
umount -R /mnt # 卸载新分区
reboot # 重启
```



### 🎉 祝贺！🎉

到此为止，一个基础的、无图形界面的 archlinux 已经安装完成了！这时你应该可以感到满满的满足感（即使你还没有见到图形化的界面）。好好享受一下成功安装 archlinux 的喜悦吧！

## 桌面环境及美化


## 开发环境安装

## 桌面美化


## 终端美化


## 常见问题处理












