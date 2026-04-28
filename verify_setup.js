// Node.js安装验证脚本
console.log("=== Node.js & OpenClaw 安装验证 ===\n");

// 检查Node.js
try {
    const nodeVersion = process.version;
    console.log(`✅ Node.js 版本: ${nodeVersion}`);
    
    // 检查npm
    try {
        const { execSync } = require('child_process');
        const npmVersion = execSync('npm --version', { encoding: 'utf8' }).trim();
        console.log(`✅ npm 版本: ${npmVersion}`);
    } catch (npmError) {
        console.log('❌ npm 不可用');
    }
    
    // 检查OpenClaw
    console.log("\n=== OpenClaw 检查 ===");
    const fs = require('fs');
    const path = require('path');
    
    const openclawPath = 'C:/Users/lenovo/AppData/Local/Temp/openclaw-usb/openclaw';
    
    if (fs.existsSync(openclawPath)) {
        console.log(`✅ OpenClaw 目录存在: ${openclawPath}`);
        
        // 检查package.json
        const packageJsonPath = path.join(openclawPath, 'package.json');
        if (fs.existsSync(packageJsonPath)) {
            const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
            console.log(`✅ OpenClaw 版本: ${packageJson.version}`);
            console.log(`📋 Node.js 要求: ${packageJson.engines.node}`);
            
            // 检查Node.js版本是否符合要求
            const requiredVersion = packageJson.engines.node.replace('>=', '');
            const currentVersion = process.version.replace('v', '');
            
            console.log(`🔍 版本兼容性: ${currentVersion} >= ${requiredVersion} ?`);
            
            // 简单的版本比较
            const [currentMajor, currentMinor] = currentVersion.split('.').map(Number);
            const [requiredMajor, requiredMinor] = requiredVersion.split('.').map(Number);
            
            if (currentMajor > requiredMajor || 
                (currentMajor === requiredMajor && currentMinor >= requiredMinor)) {
                console.log('✅ Node.js 版本符合要求');
            } else {
                console.log('❌ Node.js 版本过低，需要升级');
            }
        }
        
        // 尝试运行OpenClaw
        try {
            const openclawMain = path.join(openclawPath, 'openclaw.mjs');
            if (fs.existsSync(openclawMain)) {
                console.log('\n🔧 测试运行OpenClaw...');
                const { execSync } = require('child_process');
                const versionOutput = execSync(`node "${openclawMain}" --version`, { 
                    encoding: 'utf8',
                    cwd: openclawPath 
                }).trim();
                console.log(`✅ OpenClaw 运行测试成功: ${versionOutput}`);
            }
        } catch (runError) {
            console.log('❌ OpenClaw 运行测试失败:', runError.message);
        }
        
    } else {
        console.log(`❌ OpenClaw 目录不存在: ${openclawPath}`);
    }
    
    // 检查数据目录
    console.log("\n=== 数据目录检查 ===");
    const dataPath = 'E:/openclaw-data/.openclaw';
    if (fs.existsSync(dataPath)) {
        console.log(`✅ 数据目录存在: ${dataPath}`);
        
        // 列出重要文件
        const importantFiles = ['workspace/AGENTS.md', 'workspace/SOUL.md', 'workspace/TOOLS.md'];
        importantFiles.forEach(file => {
            const filePath = path.join(dataPath, file);
            if (fs.existsSync(filePath)) {
                console.log(`   ✅ ${file}`);
            } else {
                console.log(`   ❌ ${file} (缺失)`);
            }
        });
    } else {
        console.log(`❌ 数据目录不存在: ${dataPath}`);
    }
    
} catch (error) {
    console.log('❌ 验证过程中出错:', error.message);
}

console.log("\n=== 系统信息 ===");
console.log(`平台: ${process.platform}`);
console.log(`架构: ${process.arch}`);
console.log(`当前目录: ${process.cwd()}`);

console.log("\n=== 验证完成 ===");