GNOME桌面使用appimagelauncherd 安装Appimage 程序底部栏有的图标会显示为默认图标，这对于有强迫症的人来说这是大问题。

![image.png](https://img.dryice.icu/images/2026/01/15/20260115163357891_repeat_1768466039207__085692.png)


我遇到的两个软件就有这个问题。一个是 PicGo,一个是 Navicat。如上图所示。运行navicat底下显示的是GNOME默认给的一个默认图标。我很奇怪我的Obsidian也是Appimage运行的为啥就这两货运行起来图标就不能正常显示呢？

查询了一写资料，也有人遇到类似情况，好像换一个Appimage管理工具就好了不用appimagelauncherd。没有别的办法吗？问了一些啊伟大的 gemini。试了一下真解决了。

使用下面这个命令，然后点击 Navicat 窗口。（或者直接鼠标悬浮在运行程序上面就会显示 AppRun,从上图可以看到。）

```bash
xprop WM_CLASS
```

会返回下面内容，这样对对应为上面图中鼠标悬浮在上面显示 AppRun。

```bash
WM_CLASS(STRING) = "AppRun", "AppRun"
```

然后去`/home/ice/.local/share/applications/` 下面找到启动程序快捷方式。往里面添加一个下面参数。AppRun 也对应我们上面抓取到的。
```
StartupWMClass=AppRun
```

![image.png](https://img.dryice.icu/images/2026/01/15/20260115164449613_repeat_1768466691924__031496.png)

![image.png](https://img.dryice.icu/images/2026/01/15/20260115164411094_repeat_1768466652455__330716.png)

也可以使用Pins去修改。(可以通过 `flatp install io.github.fabrialberio.pinapp` 安装Pins)
![image.png](https://img.dryice.icu/images/2026/01/15/20260115164217172_repeat_1768466544495__326041.png)


修改好之后就正常了

![image.png](https://img.dryice.icu/images/2026/01/15/20260115165438368_repeat_1768467279758__809843.png)


然后我就去看了一下PicGo 里的参数。发现是 PicGo。鼠标悬浮在运行的程序上面发现名称是 picgo。改成picgo。果然就好了。


![image.png](https://img.dryice.icu/images/2026/01/15/20260115165840593_repeat_1768467521770__296207.png)

![image.png](https://img.dryice.icu/images/2026/01/15/20260115165535778_repeat_1768467336897__491568.png)

![image.png](https://img.dryice.icu/images/2026/01/15/20260115165923589_repeat_1768467564682__188981.png)