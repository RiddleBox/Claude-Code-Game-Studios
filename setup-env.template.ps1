# =============================================================================
# Claude Code Game Studios — Environment Setup Template
# =============================================================================
# 使用方法：
#   1. 复制此文件为 setup-env.ps1（已在 .gitignore 中，不会上传）
#   2. 填入你的 API Key
#   3. 运行：.\setup-env.ps1
#   4. 重开终端，或在同一终端运行：. .\setup-env.ps1（点号加载到当前会话）
# =============================================================================

# --- 你的 API Key（填在这里）---
$API_KEY = "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# --- Base URL（中转服务地址，默认 api123.icu）---
$BASE_URL = "https://api123.icu"

# --- 写入用户级环境变量（永久生效，重开终端后自动加载）---
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", $API_KEY, "User")
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", $BASE_URL, "User")

# --- 同时写入当前会话（立即生效，不用重开终端）---
$env:ANTHROPIC_API_KEY = $API_KEY
$env:ANTHROPIC_BASE_URL = $BASE_URL

Write-Host ""
Write-Host "✅ 环境变量已配置：" -ForegroundColor Green
Write-Host "   ANTHROPIC_API_KEY  = $($API_KEY.Substring(0,8))..." -ForegroundColor Cyan
Write-Host "   ANTHROPIC_BASE_URL = $BASE_URL" -ForegroundColor Cyan
Write-Host ""
Write-Host "现在可以运行：claude" -ForegroundColor Yellow
