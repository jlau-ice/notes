
首先需要 字体的 ttf 文件 
放到 

```bash
sudo mkdir -p /usr/share/fonts/PingFang

sudo cp PingFangSC-Regular.ttf PingFangSC-Medium.ttf PingFangSC-Semibold.ttf /usr/share/fonts/PingFang/

# 设置权限
sudo chmod 644 /usr/share/fonts/PingFang/*.ttf
```

创建 `/etc/fonts/local.conf` 文件

```xml
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <match target="pattern">
        <test qual="any" name="family"><string>sans-serif</string></test>
        <edit name="family" mode="prepend" binding="strong">
            <string>PingFang SC</string>
        </edit>
    </match>

    <match target="pattern">
        <test name="family"><string>PingFang SC</string></test>
        <test name="weight" compare="less"><int>100</int></test>
        <edit name="weight" mode="assign" binding="same"><int>100</int></edit>
    </match>

    <match target="font">
        <edit name="embeddedbitmap" mode="assign"><bool>false</bool></edit>
        <edit name="antialias" mode="assign"><bool>true</bool></edit>
        <edit name="hinting" mode="assign"><bool>true</bool></edit>
        <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
    </match>
</fontconfig>
```


重建缓存
```bash
# 1. 彻底清空缓存目录 
sudo rm -rf /var/cache/fontconfig/* rm -rf ~/.cache/fontconfig/* 
# 2. 强制重新扫描 
sudo fc-cache -rv
```


验证

```bash
# 默认无衬线是谁
fc-match sans-serif
# PingFangSC-Medium.ttf: "PingFang SC" "常规"

# 系统里还有没有残留的 Thin 苹方？ 列表里应该**只有** Regular, Medium, Semibold 这三行。
fc-list :family=PingFang\ SC
# /usr/share/fonts/PingFang/PingFangSC-Medium.ttf: PingFang SC,苹方_粗体,?®®??_??:style=常规,Bold,Regular
# /usr/share/fonts/PingFang/PingFangSC-Semibold.ttf: PingFang SC,苹方_特粗:style=常规,Heavy,Regular
# /usr/share/fonts/PingFang/PingFangSC-Regular.ttf: PingFang SC,苹方_中等,?®®??_??:style=常规,Medium,Regular
```
