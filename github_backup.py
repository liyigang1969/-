#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""GitHub backup - non-interactive version using existing git config"""

import json
import os
import subprocess
import urllib.request
import urllib.error
import shutil

workspace = r"F:\openclaw-data\.openclaw\workspace"

# Step 1: Check git status
os.chdir(workspace)
r = subprocess.run(["git", "remote", "-v"], capture_output=True, text=True, timeout=10)
print("REMOTE:", repr(r.stdout))

# Step 2: Check if we already have git repo initialized
r2 = subprocess.run(["git", "rev-parse", "--git-dir"], capture_output=True, text=True, timeout=10)
print("GIT DIR:", repr(r2.stdout), repr(r2.stderr))

# Step 3: If no remote, we need token
# Check for token in environment variable
token = os.environ.get("GITHUB_TOKEN", "")

if not token:
    print("NO_TOKEN: Need a GitHub Personal Access Token")
    print()
    print("=== INSTRUCTIONS ===")
    print("1. Go to: https://github.com/settings/tokens")
    print("2. Log in with: liyigang1969@163.com")
    print("3. Click 'Generate new token' > 'Fine-grained token'")
    print("4. Set repo permissions to Read and Write")
    print("5. Copy the token")
    print()
    print('Then run:')
    print('  $env:GITHUB_TOKEN="your_token_here"; python github_backup.py')
    print()
    exit(1)

print(f"TOKEN_OK: {token[:10]}...")

# Verify token
req = urllib.request.Request(
    "https://api.github.com/user",
    headers={
        "Authorization": f"Bearer {token}",
        "User-Agent": "OpenClaw/1.0",
        "Accept": "application/vnd.github.v3+json"
    }
)
try:
    with urllib.request.urlopen(req, timeout=15) as resp:
        user = json.loads(resp.read().decode())
        print(f"USER: {user['login']}")
        
        # Create repo
        repo_name = "openclaw-workspace"
        create_req = urllib.request.Request(
            "https://api.github.com/user/repos",
            data=json.dumps({
                "name": repo_name,
                "description": "OpenClaw workspace backup",
                "private": False,
                "auto_init": True
            }).encode(),
            headers={
                "Authorization": f"Bearer {token}",
                "User-Agent": "OpenClaw/1.0",
                "Content-Type": "application/json",
                "Accept": "application/vnd.github.v3+json"
            },
            method="POST"
        )
        
        try:
            with urllib.request.urlopen(create_req, timeout=15) as resp:
                repo = json.loads(resp.read().decode())
                clone_url = repo['clone_url']
                print(f"REPO_CREATED: {clone_url}")
        except urllib.error.HTTPError as e:
            body = e.read().decode()
            if e.code == 422:
                print(f"REPO_EXISTS: may already exist")
                # Check repos
                list_req = urllib.request.Request(
                    "https://api.github.com/user/repos?per_page=100",
                    headers={
                        "Authorization": f"Bearer {token}",
                        "User-Agent": "OpenClaw/1.0",
                        "Accept": "application/vnd.github.v3+json"
                    }
                )
                with urllib.request.urlopen(list_req, timeout=15) as lr:
                    repos = json.loads(lr.read().decode())
                    for r in repos:
                        if r["name"] == repo_name:
                            clone_url = r["clone_url"]
                            print(f"FOUND: {clone_url}")
                            break
                    else:
                        print(f"REPO_NOT_FOUND: {body}")
                        exit(1)
            else:
                print(f"ERROR: {e.code} {body}")
                exit(1)
        
        # Push
        repo_dir = os.path.join(os.path.dirname(workspace), "workspace_repo")
        if os.path.exists(repo_dir):
            shutil.rmtree(repo_dir)
        
        auth_url = clone_url.replace("https://", f"https://x-access-token:{token}@")
        
        print("CLONING...")
        r = subprocess.run(["git", "clone", auth_url, repo_dir], capture_output=True, text=True, timeout=60)
        if r.returncode != 0:
            print(f"CLONE_FAILED: {r.stderr}")
            exit(1)
        
        print("COPYING...")
        exclude = {".git", "__pycache__", "node_modules"}
        for item in os.listdir(workspace):
            if item in exclude:
                continue
            src = os.path.join(workspace, item)
            dst = os.path.join(repo_dir, item)
            if os.path.isdir(src):
                if os.path.exists(dst):
                    shutil.rmtree(dst)
                shutil.copytree(src, dst)
            else:
                shutil.copy2(src, dst)
        
        os.chdir(repo_dir)
        subprocess.run(["git", "config", "user.name", "liyigang1969"], capture_output=True)
        subprocess.run(["git", "config", "user.email", "liyigang1969@163.com"], capture_output=True)
        
        subprocess.run(["git", "add", "-A"], timeout=30)
        subprocess.run(["git", "commit", "-m", "OpenClaw workspace backup"], 
                      capture_output=True, text=True, timeout=30)
        
        print("PUSHING...")
        r = subprocess.run(["git", "push", "origin", "main"], 
                          capture_output=True, text=True, timeout=120)
        if r.returncode != 0:
            r = subprocess.run(["git", "push", "origin", "master"], 
                              capture_output=True, text=True, timeout=120)
        
        if r.returncode == 0:
            print(f"SUCCESS! https://github.com/{user['login']}/{repo_name}")
        else:
            print(f"PUSH_FAILED: {r.stderr}")
            
except urllib.error.HTTPError as e:
    print(f"API_ERROR: {e.code} - {e.read().decode()}")
except Exception as e:
    print(f"ERROR: {e}")
