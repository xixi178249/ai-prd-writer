<#
ai-prd-writer 安装脚本（幂等，可重复运行）

用法：
  .\install.ps1                       自动探测并装到所有已存在的技能目录
  .\install.ps1 -Target "D:\my\skills" 只装到指定目录
#>
[CmdletBinding()]
param(
    [string]$Target = ""
)

$ErrorActionPreference = 'Stop'

$SkillName = 'ai-prd-writer'
$SrcDir    = $PSScriptRoot
$Payload   = @('SKILL.md', 'references', 'examples', 'evals')

# 源目录自检：缺文件就直接失败，不要装一个残废技能
foreach ($item in $Payload) {
    if (-not (Test-Path (Join-Path $SrcDir $item))) {
        Write-Host "X 源目录缺少 $item，请确认在仓库根目录执行" -ForegroundColor Red
        exit 1
    }
}
$skillMd = Join-Path $SrcDir 'SKILL.md'
if (-not (Select-String -Path $skillMd -Pattern '^name:' -Quiet)) {
    Write-Host "X SKILL.md 缺少 name 字段" -ForegroundColor Red
    exit 1
}
if (-not (Select-String -Path $skillMd -Pattern '^description:' -Quiet)) {
    Write-Host "X SKILL.md 缺少 description 字段" -ForegroundColor Red
    exit 1
}

function Install-Into {
    param([string]$DestRoot)

    $dest = Join-Path $DestRoot $SkillName
    New-Item -ItemType Directory -Path $dest -Force | Out-Null
    foreach ($item in $Payload) {
        Copy-Item -Path (Join-Path $SrcDir $item) -Destination $dest -Recurse -Force
    }
    Write-Host "OK 已安装 -> $dest" -ForegroundColor Green
    return $dest
}

$installed = @()

if ($Target) {
    $installed += Install-Into -DestRoot $Target
}
else {
    $home_dir = [Environment]::GetFolderPath('UserProfile')
    $candidates = @(
        (Join-Path $home_dir '.dsh\skills'),
        (Join-Path $home_dir '.claude\skills')
    )
    $found = $false
    foreach ($root in $candidates) {
        if (Test-Path $root) {
            $installed += Install-Into -DestRoot $root
            $found = $true
        }
    }
    if (-not $found) {
        Write-Host "· 未找到现有技能目录，默认创建 ~\.dsh\skills"
        $installed += Install-Into -DestRoot (Join-Path $home_dir '.dsh\skills')
    }
}

Write-Host ""
Write-Host "装好了，共 $($installed.Count) 处。"
Write-Host "下一步：重启你的编码助手会话（技能目录在会话启动时扫描，改完必须重启才生效）。"
Write-Host "验证：跟它说「写 PRD：给客服做个工单分类助手」，看它是否开始一次只问一个问题。"
Write-Host ""
Write-Host "想卸载：删掉上面列出的目录即可，无其他残留。"
