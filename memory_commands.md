# OpenClaw 记忆命令指南

## 🎯 命令列表

### 1. `!files` - 列出关联文件
**功能**: 显示所有关联的文件和目录状态
**使用**: 直接输入 `!files`
**输出示例**:
```
📁 关联文件系统:
✅ 核心安装: C:\Users\YOGA\AppData\Local\Temp\openclaw-usb\openclaw
✅ 配置目录: E:\openclaw-data\.openclaw  
✅ 记忆备份: E:\openclaw-memory-backup
⚠️ 资源包: D:\OpenClaw_Packages (待检查)
```

### 2. `!backup` - 执行备份
**功能**: 创建当前状态的完整备份
**使用**: `!backup [备注]`
**示例**: `!backup 版本更新前备份`
**输出**: 备份完成通知和备份位置

### 3. `!restore` - 恢复记忆
**功能**: 从备份恢复记忆
**使用**: `!restore [备份日期]`
**示例**: `!restore 2026-04-15`
**输出**: 恢复进度和结果

### 4. `!info` - 系统信息
**功能**: 显示系统版本和状态
**使用**: 直接输入 `!info`
**输出示例**:
```
🦞 OpenClaw 2026.4.14 (ad24fcc)
📁 工作区: E:\openclaw-data\.openclaw\workspace
💾 记忆: 69.6 KB (main.sqlite)
🔄 最后备份: 2026-04-15 16:50
```

### 5. `!check` - 完整性检查
**功能**: 检查所有关联文件的完整性
**使用**: 直接输入 `!check`
**输出**: 文件完整性报告

## 🔧 命令实现原理

### 文件关联检查
```bash
# 检查核心安装
Test-Path "C:\Users\YOGA\AppData\Local\Temp\openclaw-usb\openclaw\package.json"

# 检查配置目录  
Test-Path "E:\openclaw-data\.openclaw\openclaw.json"

# 检查记忆备份
Test-Path "E:\openclaw-memory-backup\memory-database\main.sqlite"
```

### 备份命令流程
1. 创建备份目录: `E:\openclaw-backup-YYYY-MM-DD-HHMM`
2. 复制配置文件
3. 复制记忆数据库
4. 复制工作区文件
5. 生成备份报告

### 恢复命令流程
1. 选择备份版本
2. 停止OpenClaw服务
3. 恢复文件
4. 启动OpenClaw
5. 验证恢复结果

## 📁 关联文件结构

### 核心文件
```
C:\Users\YOGA\AppData\Local\Temp\openclaw-usb\openclaw\
├── dist/          # 编译文件 (500+)
├── skills/        # 技能模块 (50+)
├── docs/          # 文档
├── package.json   # 版本信息
└── openclaw.mjs   # 主程序
```

### 配置和记忆
```
E:\openclaw-data\.openclaw\
├── openclaw.json          # 主配置
├── memory/
│   └── main.sqlite        # 记忆数据库
├── workspace/
│   ├── AGENTS.md          # 工作指南
│   ├── SOUL.md            # 核心身份
│   ├── USER.md            # 用户信息
│   ├── file_associations.json
│   └── memory_commands.md
└── extensions/            # 扩展
```

### 备份系统
```
E:\openclaw-memory-backup\
├── memory-database/       # 记忆备份
├── workspace/             # 工作区备份
├── config/                # 配置备份
├── restore_memory.bat     # 恢复脚本
└── README-如何恢复记忆.md
```

## 🚀 使用示例

### 示例1: 日常检查
```
用户: !files
助手: 📁 关联文件系统状态...
      ✅ 核心安装: 正常 (2026.4.14)
      ✅ 配置目录: 正常
      ✅ 记忆备份: 正常 (今天备份)
      ⚠️ 资源包: 存在 (待检查)
```

### 示例2: 执行备份
```
用户: !backup 日常备份
助手: 🔄 正在备份...
      📁 创建备份: E:\openclaw-backup-2026-04-15-1815
      ✅ 配置文件备份完成
      ✅ 记忆数据库备份完成  
      ✅ 工作区文件备份完成
      📋 备份总结: 3个文件，总计 85.7 KB
```

### 示例3: 系统信息
```
用户: !info
助手: 🦞 OpenClaw 2026.4.14 (ad24fcc)
      🕒 运行时间: 2小时15分钟
      💾 记忆大小: 69.6 KB
      📁 工作区: 15.4 KB (8个文件)
      🔄 最后活动: 记忆关联系统配置
```

## ⚙️ 配置自定义

### 添加新的关联文件
编辑 `file_associations.json`:
```json
{
  "新关联": {
    "路径": "C:\\新路径",
    "类型": "自定义类型",
    "重要性": "高"
  }
}
```

### 自定义命令
在AGENTS.md中添加:
```markdown
### 自定义命令
- `!mycommand` - 自定义功能描述
```

## 🔍 故障排除

### 问题: 命令不响应
1. 检查AGENTS.md是否包含命令定义
2. 验证文件关联配置
3. 查看启动日志

### 问题: 文件找不到
1. 运行 `!check` 检查完整性
2. 验证文件路径是否正确
3. 检查文件权限

### 问题: 备份失败
1. 确保有足够的磁盘空间
2. 检查目标目录权限
3. 验证源文件是否可读

## 📈 高级功能

### 自动备份计划
可以配置定期自动备份:
- 每日凌晨备份
- 每周完整备份
- 每月归档备份

### 版本管理
集成Git进行配置版本管理:
- 跟踪配置变更
- 回滚到特定版本
- 分支管理不同环境

### 云同步
支持云存储同步:
- 自动上传备份
- 多设备同步
- 版本历史

## 🎯 最佳实践

### 日常使用
1. 每天启动时运行 `!files` 检查状态
2. 重要变更前执行 `!backup`
3. 定期运行 `!check` 验证完整性

### 维护建议
1. 每月清理旧备份
2. 更新关联配置文件
3. 测试恢复流程

### 安全建议
1. 加密敏感备份
2. 定期更换访问令牌
3. 监控文件访问日志

---

## 💡 提示

- 使用 `!files` 快速了解系统状态
- 重要操作前总是先备份
- 定期测试恢复流程
- 自定义命令满足特定需求

**这些记忆命令让你能够轻松管理和维护OpenClaw的完整文件生态系统！**