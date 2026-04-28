// OpenClaw Launcher - JavaScript version
// Run with: node launch_openclaw.js

const { execSync, spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('============================================');
console.log('     OpenClaw JavaScript Launcher');
console.log('============================================\n');

function runCommand(cmd) {
    try {
        console.log(`Running: ${cmd}`);
        const result = execSync(cmd, { encoding: 'utf8' });
        console.log(result);
        return true;
    } catch (error) {
        console.log(`Error: ${error.message}`);
        return false;
    }
}

function testNodeJS() {
    console.log('1. Testing Node.js...');
    return runCommand('C:\\nodejs\\node.exe --version');
}

function testFDrive() {
    console.log('\n2. Testing F drive...');
    const dataDir = 'F:\\openclaw-data\\.openclaw';
    if (fs.existsSync(dataDir)) {
        console.log(`✅ F drive data directory exists: ${dataDir}`);
        return true;
    } else {
        console.log(`❌ F drive data directory not found: ${dataDir}`);
        return false;
    }
}

function copyOpenClawToF() {
    console.log('\n3. Copying OpenClaw to F drive...');
    const source = 'C:\\Users\\lenovo\\AppData\\Local\\Temp\\openclaw-usb\\openclaw';
    const target = 'F:\\OpenClaw_Fresh';
    
    if (!fs.existsSync(target)) {
        fs.mkdirSync(target, { recursive: true });
    }
    
    try {
        // Simple copy for demonstration
        // In real implementation, would use proper file copying
        console.log(`Copying from ${source} to ${target}`);
        runCommand(`xcopy "${source}\\*" "${target}" /E /I /H /Y /Q`);
        return true;
    } catch (error) {
        console.log(`Copy failed: ${error.message}`);
        return false;
    }
}

function startOpenClaw(port = 3000) {
    console.log(`\n4. Starting OpenClaw on port ${port}...`);
    
    // Set environment variables
    process.env.OPENCLAW_DATA = 'F:\\openclaw-data\\.openclaw';
    process.env.OPENCLAW_STATE_DIR = 'F:\\openclaw-data\\.openclaw';
    
    const openclawDir = 'F:\\OpenClaw_Fresh';
    const openclawPath = path.join(openclawDir, 'openclaw.mjs');
    
    if (!fs.existsSync(openclawPath)) {
        console.log(`❌ OpenClaw not found at: ${openclawPath}`);
        console.log('Please run copy function first.');
        return false;
    }
    
    console.log(`Starting OpenClaw from: ${openclawDir}`);
    console.log(`Using data directory: ${process.env.OPENCLAW_DATA}`);
    console.log(`Port: ${port}`);
    console.log('\n=== OpenClaw Output ===\n');
    
    try {
        const openclaw = spawn('C:\\nodejs\\node.exe', [
            openclawPath,
            'gateway',
            '--port', port.toString(),
            '--log-level', 'info'
        ], {
            cwd: openclawDir,
            stdio: 'inherit'
        });
        
        openclaw.on('close', (code) => {
            console.log(`\nOpenClaw exited with code: ${code}`);
            process.exit(code);
        });
        
    } catch (error) {
        console.log(`Failed to start OpenClaw: ${error.message}`);
        return false;
    }
    
    return true;
}

// Main execution
async function main() {
    console.log('Starting tests...\n');
    
    // Run tests
    const nodeOk = testNodeJS();
    if (!nodeOk) {
        console.log('\n❌ Node.js test failed. Cannot continue.');
        return;
    }
    
    const fDriveOk = testFDrive();
    if (!fDriveOk) {
        console.log('\n⚠️  F drive test failed, but continuing...');
    }
    
    // Copy OpenClaw if needed
    const openclawDir = 'F:\\OpenClaw_Fresh';
    const openclawPath = path.join(openclawDir, 'openclaw.mjs');
    
    if (!fs.existsSync(openclawPath)) {
        console.log('\nOpenClaw not found on F drive, copying...');
        copyOpenClawToF();
    }
    
    // Start OpenClaw
    console.log('\n============================================');
    console.log('     Starting OpenClaw Gateway');
    console.log('============================================');
    console.log('\nPress Ctrl+C to stop\n');
    
    startOpenClaw(3003);
}

// Run main function
if (require.main === module) {
    main().catch(console.error);
}

module.exports = { testNodeJS, testFDrive, startOpenClaw };