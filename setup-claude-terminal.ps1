<#
  Claude Code 终端一键配置 (Windows 10/11)
  - 安装 Claude Code（若未安装）
  - 默认免审批 (bypassPermissions)
  - 安装字体 + 配色（7 套精选主题一步到位，见 presets.json，也可 DIY 自由组合）
  - Windows Terminal: 护眼配色 + "Claude Code" 默认配置
  - cmd 窗口默认在 Windows Terminal 中打开

  用法:
    双击 setup.bat
    或: powershell -ExecutionPolicy Bypass -File setup-claude-terminal.ps1 [-Preset <id>] [-BaseUrl <url>] [-AuthToken <token>]
    或 DIY: ... [-Theme <id>] [-Font <id>]  (跳过 Preset 选择，直接指定字体和配色)
#>
param(
    [string]$Preset,
    [string]$BaseUrl,
    [string]$AuthToken,
    [string]$Theme,
    [string]$Font
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'

function Step($msg) { Write-Host "==> $msg" -ForegroundColor Green }

# 给 PSCustomObject 设置属性（不存在则新增）
function Set-Prop($obj, $name, $value) {
    $obj | Add-Member -NotePropertyName $name -NotePropertyValue $value -Force
}

function Read-Json($path) {
    $text = [IO.File]::ReadAllText($path)
    # 去掉整行 // 注释（Windows Terminal 允许 JSONC）
    $text = ($text -split "`n" | Where-Object { $_ -notmatch '^\s*//' }) -join "`n"
    return $text | ConvertFrom-Json
}

function Write-Json($path, $obj) {
    $json = $obj | ConvertTo-Json -Depth 32
    [IO.File]::WriteAllText($path, $json, (New-Object Text.UTF8Encoding $false))
}

function Backup($path) {
    if (Test-Path $path) { Copy-Item $path "$path.$stamp.bak" }
}

# ---------------------------------------------------------------- 1. Claude Code
Step '检查 Claude Code'
if (Get-Command claude -ErrorAction SilentlyContinue) {
    Write-Host "    已安装: $(claude --version)"
} elseif (Get-Command npm -ErrorAction SilentlyContinue) {
    Write-Host '    通过 npm 安装...'
    npm install -g @anthropic-ai/claude-code
} else {
    Write-Host '    通过官方安装脚本安装...'
    Invoke-RestMethod https://claude.ai/install.ps1 | Invoke-Expression
}

# ---------------------------------------------------------------- 2. 免审批
Step '配置 Claude Code 默认免审批'
$claudeDir = Join-Path $env:USERPROFILE '.claude'
$ccPath = Join-Path $claudeDir 'settings.json'
New-Item -ItemType Directory -Force $claudeDir | Out-Null
Backup $ccPath
$cc = if (Test-Path $ccPath) { Read-Json $ccPath } else { [pscustomobject]@{} }

if (-not $cc.permissions) { Set-Prop $cc 'permissions' ([pscustomobject]@{}) }
Set-Prop $cc.permissions 'defaultMode' 'bypassPermissions'
Set-Prop $cc 'skipDangerousModePermissionPrompt' $true

if ($BaseUrl -or $AuthToken) {
    if (-not $cc.env) { Set-Prop $cc 'env' ([pscustomobject]@{}) }
    if ($BaseUrl)   { Set-Prop $cc.env 'ANTHROPIC_BASE_URL' $BaseUrl }
    if ($AuthToken) { Set-Prop $cc.env 'ANTHROPIC_AUTH_TOKEN' $AuthToken }
}
Write-Json $ccPath $cc

# ---------------------------------------------------------------- 3. 主题预设 or DIY
$presets = Get-Content (Join-Path $PSScriptRoot 'presets.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$fonts = Get-Content (Join-Path $PSScriptRoot 'fonts.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$themes = Get-Content (Join-Path $PSScriptRoot 'themes.json') -Raw -Encoding UTF8 | ConvertFrom-Json

# 若同时给了 -Theme 和 -Font，视为 DIY，跳过 Preset 选择
$isDIY = $Theme -and $Font
if (-not $isDIY -and -not $Preset) {
    Write-Host '==> 选择主题（预览见 preview.html）' -ForegroundColor Green
    for ($i = 0; $i -lt $presets.Count; $i++) {
        Write-Host ("      {0}. {1}  - {2}" -f ($i + 1), $presets[$i].title, $presets[$i].desc)
    }
    Write-Host ("      {0}. 🎨 DIY 自定义  - 自由搭配字体和配色" -f ($presets.Count + 1)) -ForegroundColor Cyan
    $n = Read-Host '    输入序号 [默认 1]'
    $idx = if ($n -match '^\d+$' -and [int]$n -ge 1 -and [int]$n -le ($presets.Count + 1)) { [int]$n - 1 } else { 0 }
    if ($idx -eq $presets.Count) {
        $isDIY = $true
    } else {
        $Preset = $presets[$idx].id
    }
}

if (-not $isDIY) {
    $chosen = $presets | Where-Object { $_.id -eq $Preset } | Select-Object -First 1
    if (-not $chosen) { $chosen = $presets[0] }
    Write-Host "==> 使用主题: $($chosen.title)" -ForegroundColor Green
    $Font = $chosen.font
    $Theme = $chosen.theme
}

# ---------------------------------------------------------------- 4. 字体（DIY 模式下才会问）
Step '安装字体'
$fontDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows\Fonts'
$fontReg = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
$fnt = $fonts | Where-Object { $_.id -eq $Font } | Select-Object -First 1
if (-not $fnt) {
    Write-Host '    选择字体（预览见 preview.html）:'
    for ($i = 0; $i -lt $fonts.Count; $i++) {
        Write-Host ("      {0}. {1}  - {2}" -f ($i + 1), $fonts[$i].title, $fonts[$i].desc)
    }
    $n = Read-Host '    输入序号 [默认 1]'
    $idx = if ($n -match '^\d+$' -and [int]$n -ge 1 -and [int]$n -le $fonts.Count) { [int]$n - 1 } else { 0 }
    $fnt = $fonts[$idx]
}
Write-Host "    使用字体: $($fnt.title)"
$fontFace = $fnt.face

if (Test-Path (Join-Path $fontDir $fnt.files[0])) {
    Write-Host '    已安装，跳过'
} else {
    $tmp = Join-Path $env:TEMP "claude-font-$stamp"
    New-Item -ItemType Directory -Force $tmp | Out-Null
    foreach ($d in $fnt.downloads) {
        $name = Split-Path $d.url -Leaf
        $file = Join-Path $tmp $name
        # 若脚本同目录有同名离线包则直接用（GitHub 访问慢的机器）
        $local = Join-Path $PSScriptRoot $name
        if (Test-Path $local) {
            Write-Host "    使用本地离线包 $name"
            Copy-Item $local $file
        } else {
            Write-Host "    下载 $name ..."
            Invoke-WebRequest $d.url -OutFile $file -UseBasicParsing
        }
        $actual = (Get-FileHash $file -Algorithm SHA256).Hash
        if ($actual -ne $d.sha256.ToUpper()) { throw "字体校验失败: $name" }
        # zip / 7z 统一用系统自带的 tar (bsdtar) 解压
        if ($name -match '\.(zip|7z)$') { & "$env:SystemRoot\System32\tar.exe" -xf $file -C $tmp }
    }
    New-Item -ItemType Directory -Force $fontDir | Out-Null
    foreach ($f in $fnt.files) {
        $src = Get-ChildItem $tmp -Recurse -Filter $f | Select-Object -First 1
        if (-not $src) { throw "压缩包中未找到 $f" }
        Copy-Item $src.FullName (Join-Path $fontDir $f) -Force
        $style = ($f -replace '\.ttf$', '') -replace '^.*-', ''
        New-ItemProperty $fontReg -Name "$fontFace $style (TrueType)" -Value (Join-Path $fontDir $f) -PropertyType String -Force | Out-Null
    }
    Remove-Item $tmp -Recurse -Force
}

# ---------------------------------------------------------------- 5. Windows Terminal
Step '配置 Windows Terminal'
$wtPkg = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe'
if (-not (Test-Path $wtPkg) -and -not (Get-Command wt -ErrorAction SilentlyContinue)) {
    Write-Host '    未检测到 Windows Terminal，通过 winget 安装...'
    winget install --id Microsoft.WindowsTerminal -e --accept-source-agreements --accept-package-agreements
}
$wtDir = Join-Path $wtPkg 'LocalState'
New-Item -ItemType Directory -Force $wtDir | Out-Null
$wtPath = Join-Path $wtDir 'settings.json'
Backup $wtPath
$wt = if (Test-Path $wtPath) { Read-Json $wtPath } else { [pscustomobject]@{} }

# 所有模板的配色都注册进 Windows Terminal，所选模板设为默认
$sel = $themes | Where-Object { $_.id -eq $Theme } | Select-Object -First 1
if (-not $sel) {
    Write-Host '    选择配色模板（预览见 preview.html）:'
    for ($i = 0; $i -lt $themes.Count; $i++) {
        Write-Host ("      {0}. {1}  - {2}" -f ($i + 1), $themes[$i].title, $themes[$i].desc)
    }
    $n = Read-Host '    输入序号 [默认 1]'
    $idx = if ($n -match '^\d+$' -and [int]$n -ge 1 -and [int]$n -le $themes.Count) { [int]$n - 1 } else { 0 }
    $sel = $themes[$idx]
}
Write-Host "    使用模板: $($sel.title)"
$schemeName = $sel.scheme.name
$names = $themes | ForEach-Object { $_.scheme.name }
$schemes = @(@($wt.schemes) | Where-Object { $_ -and $names -notcontains $_.name }) + @($themes | ForEach-Object { $_.scheme })
Set-Prop $wt 'schemes' $schemes

if (-not $wt.profiles) { Set-Prop $wt 'profiles' ([pscustomobject]@{}) }
Set-Prop $wt.profiles 'defaults' ([pscustomobject]@{
    colorScheme = $schemeName
    font = [pscustomobject]@{ face = $fontFace; size = $fnt.size; cellHeight = '1.2' }
    padding = '16, 12'; cursorShape = 'bar'; opacity = 97
    useAcrylic = $false; antialiasingMode = 'cleartype'
})

$guid = '{c1a0de00-c0de-4c1a-9dee-5c0dec0de001}'
$ccProfile = [pscustomobject]@{
    guid = $guid; name = 'Claude Code'; commandline = 'cmd.exe /k claude'
    startingDirectory = '%USERPROFILE%'; tabTitle = 'Claude Code'
    suppressApplicationTitle = $true; icon = [string][char]0x2733; tabColor = $sel.scheme.cursorColor
}
$list = @($ccProfile) + @(@($wt.profiles.list) | Where-Object { $_ -and $_.guid -ne $guid })
Set-Prop $wt.profiles 'list' $list

Set-Prop $wt 'defaultProfile' $guid
Set-Prop $wt 'theme' $sel.claudeTheme
Set-Prop $wt 'initialCols' 130
Set-Prop $wt 'initialRows' 36
Set-Prop $wt 'centerOnLaunch' $true
Write-Json $wtPath $wt

# Claude Code 界面明暗跟随模板（浅色背景需 light 主题才看得清）
# ~/.claude.json 是 Claude Code 的状态文件，用 node 原样修改，避免 PowerShell 重新序列化
$cjPath = Join-Path $env:USERPROFILE '.claude.json'
if (Get-Command node -ErrorAction SilentlyContinue) {
    Backup $cjPath
    # PowerShell 5.1 传参会吞掉双引号，所以写到临时文件再执行
    $jsFile = Join-Path $env:TEMP "set-claude-theme-$stamp.js"
    'const fs=require("fs"),p=process.argv[2];let c={};try{c=JSON.parse(fs.readFileSync(p,"utf8"))}catch(e){}c.theme=process.argv[3];fs.writeFileSync(p,JSON.stringify(c,null,2))' |
        Set-Content $jsFile -Encoding ASCII
    node $jsFile $cjPath $sel.claudeTheme
    Remove-Item $jsFile
} else {
    Write-Host "    提示: 进入 Claude Code 后输入 /theme 选择 $($sel.claudeTheme)" -ForegroundColor Yellow
}

# ---------------------------------------------------------------- 5. cmd 默认用 Windows Terminal 打开
Step '设置 Windows Terminal 为默认终端'
$startup = 'HKCU:\Console\%%Startup'
New-Item $startup -Force | Out-Null
New-ItemProperty $startup -Name DelegationConsole  -Value '{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}' -PropertyType String -Force | Out-Null
New-ItemProperty $startup -Name DelegationTerminal -Value '{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}' -PropertyType String -Force | Out-Null

Write-Host ''
Write-Host '完成。关闭所有终端窗口后重新打开 "终端" 或在 cmd 中输入 claude。' -ForegroundColor Cyan
Write-Host "原配置已备份为 *.$stamp.bak" -ForegroundColor DarkGray
