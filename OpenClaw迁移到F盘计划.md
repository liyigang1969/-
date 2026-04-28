# OpenClaw 迁移到F盘计划

## 🎯 迁移目标
将E盘所有OpenClaw相关内容复制到F盘，配置OpenClaw从F盘启动。

## 📊 磁盘状态分析

### 当前磁盘 (E盘)
- **总容量**: 31.4 GB
- **可用空间**: 30.3 GB
- **OpenClaw使用**: ~1.1 GB
- **包含内容**:
  1. `E:\openclaw-data\.openclaw\` - 配置和记忆
  2. `E:\openclaw-memory-backup\` - 记忆备份
  3. 其他相关文件

### 目标磁盘 (F盘)
- **总容量**: 4.19 TB (≈4194 GB)
- **可用空间**: 4.19 TB (≈4194 GB)
- **状态**: 几乎为空，理想的目标盘

## 📋 迁移内容清单

### 1. 核心配置和记忆
```
E:\openclaw-data\.openclaw\
├── openclaw.json          # 主配置文件
├── memory\                # 记忆数据库
│   └── main.sqlite        # 所有历史记忆
├── workspace\             # 工作区文件
│   ├── AGENTS.md          # 工作指南
│   ├── SOUL.md            # 核心身份
│   ├── USER.md            # 用户信息
│   ├── file_associations.json
│   └── 记忆关联系统.md
├── extensions\            # 扩展目录
└── 其他配置文件
```

### 2. 记忆备份
```
E:\openclaw-memory-backup\
├── memory-database\       # 记忆备份
├── workspace\             # 工作区备份
├── config\                # 配置备份
├── restore_memory.bat     # 恢复脚本
└── README-如何恢复记忆.md
```

### 3. 其他可能的相关文件
需要检查E盘是否有其他OpenClaw相关文件。

## 🚀 迁移方案选择

### 方案A：完整复制 + 配置更新（推荐）
1. 复制所有OpenClaw文件到F盘
2. 更新OpenClaw配置指向F盘
3. 测试从F盘启动
4. 验证功能完整性

### 方案B：符号链接方案
1. 在F盘创建主要文件
2. 在E盘创建符号链接到F盘
3. 保持现有路径不变
4. 实际文件存储在F盘

### 方案C：混合方案
1. 配置和记忆在F盘
2. 运行文件在E盘（或C盘）
3. 通过配置关联

**推荐方案A**：最干净，性能最好，易于管理。

## 🔧 实施步骤

### 阶段1：准备工作
1. **备份当前状态**
   - 运行完整备份
   - 验证备份完整性
   - 准备回滚计划

2. **检查F盘状态**
   - 确认F盘可用性
   - 检查文件系统
   - 确保有足够权限

3. **停止OpenClaw服务**
   - 优雅停止当前运行实例
   - 确认进程已停止
   - 释放文件锁

### 阶段2：文件复制
1. **创建目标目录结构**
   ```
   F:\openclaw-data\.openclaw\
   F:\openclaw-memory-backup\
   ```

2. **复制配置文件**
   - 使用robocopy保持权限和时间戳
   - 验证复制完整性
   - 记录复制过程

3. **复制记忆数据库**
   - 确保SQLite数据库完整复制
   - 验证数据库可读性
   - 测试记忆访问

### 阶段3：配置更新
1. **更新OpenClaw配置**
   - 修改路径指向F盘
   - 更新网关配置
   - 调整扩展路径

2. **更新记忆关联配置**
   - 修改file_associations.json
   - 更新启动脚本路径
   - 调整备份配置

3. **更新系统环境**
   - 检查环境变量
   - 更新快捷方式
   - 调整服务配置

### 阶段4：测试验证
1. **启动测试**
   - 从F盘启动OpenClaw
   - 验证网关连接
   - 测试基本功能

2. **功能验证**
   - 测试记忆访问
   - 验证工具使用
   - 检查扩展加载

3. **性能测试**
   - 比较启动速度
   - 测试文件访问性能
   - 验证稳定性

### 阶段5：切换和清理
1. **正式切换**
   - 确认测试通过
   - 更新启动配置
   - 设置自动启动

2. **清理旧文件**
   - 备份旧文件（保留一段时间）
   - 清理E盘空间
   - 更新文档

3. **监控和维护**
   - 监控运行状态
   - 定期备份
   - 性能优化

## ⚠️ 风险和控制

### 风险1：数据丢失
- **控制措施**：完整备份，验证复制完整性
- **回滚方案**：保留E盘原文件1周

### 风险2：配置错误
- **控制措施**：逐步测试，配置验证
- **回滚方案**：快速恢复原配置

### 风险3：性能问题
- **控制措施**：性能测试，监控调整
- **回滚方案**：回退到原位置

### 风险4：兼容性问题
- **控制措施**：全面功能测试
- **回滚方案**：恢复原环境

## 📝 详细操作脚本

### 1. 备份脚本
```powershell
# 创建迁移前备份
$backupDir = "E:\openclaw-migration-backup-$(Get-Date -Format 'yyyy-MM-dd-HHmm')"
New-Item -ItemType Directory -Path $backupDir
Copy-Item -Path "E:\openclaw-data" -Destination $backupDir -Recurse
Copy-Item -Path "E:\openclaw-memory-backup" -Destination $backupDir -Recurse
```

### 2. 复制脚本
```powershell
# 复制到F盘
robocopy "E:\openclaw-data" "F:\openclaw-data" /MIR /R:3 /W:10 /LOG:copy_log.txt
robocopy "E:\openclaw-memory-backup" "F:\openclaw-memory-backup" /MIR /R:3 /W:10
```

### 3. 配置更新脚本
```powershell
# 更新配置文件路径
$configFile = "F:\openclaw-data\.openclaw\openclaw.json"
$config = Get-Content $configFile | ConvertFrom-Json
# 更新路径配置...
$config | ConvertTo-Json -Depth 10 | Set-Content $configFile
```

### 4. 验证脚本
```powershell
# 验证复制完整性
Compare-Object (Get-ChildItem "E:\openclaw-data" -Recurse) (Get-ChildItem "F:\openclaw-data" -Recurse)
# 测试数据库可读性
Test-Path "F:\openclaw-data\.openclaw\memory\main.sqlite"
```

## 🕐 时间估算

### 阶段时间
1. **准备**: 15分钟
2. **复制**: 30-60分钟（取决于文件大小）
3. **配置**: 30分钟
4. **测试**: 60分钟
5. **切换**: 15分钟

### 总时间
- **预计**: 2.5-3.5小时
- **最坏情况**: 4小时（含回滚）

## 📞 支持计划

### 迁移期间支持
1. 实时监控迁移过程
2. 及时处理问题
3. 定期进度报告

### 迁移后支持
1. 7×24小时监控
2. 性能优化建议
3. 问题排查支持

### 紧急回滚
1. 5分钟内回滚能力
2. 数据完整性保证
3. 服务快速恢复

## ✅ 成功标准

### 技术标准
1. ✅ 所有文件完整复制
2. ✅ OpenClaw从F盘正常启动
3. ✅ 所有功能正常工作
4. ✅ 性能不低于原水平

### 业务标准
1. ✅ 用户无感知切换
2. ✅ 数据完整性100%
3. ✅ 服务可用性99.9%
4. ✅ 迁移时间在计划内

### 运维标准
1. ✅ 监控系统正常
2. ✅ 备份系统就绪
3. ✅ 文档更新完成
4. ✅ 团队培训完成

## 🔮 迁移后优化

### 短期优化（1周内）
1. 性能基准测试
2. 监控告警配置
3. 备份策略优化

### 中期优化（1月内）
1. 存储性能优化
2. 内存使用优化
3. 启动速度优化

### 长期优化（3月内）
1. 高可用配置
2. 灾难恢复演练
3. 容量规划

---

## 🚀 开始迁移

**建议执行顺序：**
1. 审核本计划
2. 创建备份
3. 执行复制
4. 配置更新
5. 测试验证
6. 正式切换
7. 监控优化

**需要确认：**
- [ ] F盘可用性和权限
- [ ] 迁移时间窗口
- [ ] 回滚方案接受
- [ ] 支持团队就绪

**迁移指挥官**：小星子（OpenClaw助手）
**迁移时间**：建议在业务低峰期进行
**预计影响**：服务中断1-2小时