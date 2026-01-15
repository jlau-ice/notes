
1. 准备一个纯净版本的PE就行了

删除EFI删除

```bash
# 进入diskpart
diskpart

list disk

sel disk 0

list partition

sel partition 1

delete partition override
```

2. 创建分区+格式化
```bash
# 创建EFI
diskpart

list disk

sel disk 0

list partition

# 创建
create partition efi

# 格式化
format quick fs=fat32 label=system

# 分配fan

assign letter=S

exit
```


3. 重建引导
```bash
bcdboot C:\windows /l zh-cn 

bcdboot C:\windows /s S: /f UEFI /l zh-cn
```