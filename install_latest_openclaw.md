# OpenClaw 最新版本安装指南

## 当前状态
- 当前版本: 2026.3.14 (临时USB安装)
- 最新版本: 2026.4.14
- 配置文件位置: `E:\openclaw-data\.openclaw`

## 安装步骤

### 1. 下载最新版本
访问以下链接下载最新版本：
- **GitHub Releases**: https://github.com/openclaw/openclaw/releases/latest
- **直接下载链接**: https://github.com/openclaw/openclaw/archive/refs/tags/v2026.4.14.zip

### 2. 解压到新目录
建议解压到以下目录之一：
- `C:\openclaw-2026.4.14`
- `E:\openclaw-2026.4.14`
- 或任何你喜欢的目录

### 3. 安装依赖
进入解压后的目录，运行：
```bash
npm install
```
或（如果可用）：
```bash
pnpm install
```

### 4. 复制配置文件
将以下文件/目录从旧安装复制到新安装：
- `E:\openclaw-data\.openclaw\openclaw.json` → 新目录的配置
- `E:\openclaw-data\.openclaw\workspace\` → 新目录的工作区
- `E:\openclaw-data\.openclaw\memory\` → 新目录的记忆文件

### 5. 启动新版本
```bash
node openclaw.mjs
```

## 方案B：使用现有目录更新

如果你希望继续使用当前目录 (`C:\Users\YOGA\AppData\Local\Temp\openclaw-usb\openclaw`)，可以尝试：

1. 删除 `node_modules` 目录
2. 下载最新版本源码覆盖当前文件
3. 重新安装依赖：
   ```bash
   npm install
   ```

## 重要提醒

1. **备份配置**: 确保备份 `E:\openclaw-data\.openclaw\openclaw.json`
2. **工作区文件**: 备份 `E:\openclaw-data\.openclaw\workspace\` 目录
3. **记忆文件**: 备份 `E:\openclaw-data\.openclaw\memory\` 目录

## 验证安装
安装完成后，运行：
```bash
node openclaw.mjs --version
```
应该显示：`2026.4.14`

## 故障排除
如果遇到问题：
1. 检查Node.js版本：需要 Node.js >= 22.16.0
2. 检查网络连接
3. 查看错误日志