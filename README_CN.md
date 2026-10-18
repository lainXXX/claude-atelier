# Claude Code 终端配置工具

> Windows Terminal + Claude Code 一键配置：精选字体×配色主题，或 DIY 自定义组合。

[English Documentation](README.md)

![预览](preview-all.png)

## 特性

- **7 套精选主题**：字体和配色预先搭配好，一步到位
- **4 款编程字体**：中英文等宽对齐，全部开源免费
- **7 套护眼配色**：深色浅色兼顾，满足不同偏好
- **DIY 自定义**：字体和配色自由组合（28 种组合）
- **自动配置**：Windows Terminal + Claude Code 设置一次完成
- **离线部署**：字体包可复用，支持无网环境安装

## 快速开始

### 本机安装

1. 双击 `preview.html` 预览所有主题效果
2. 双击 `setup.bat`，按提示选择主题序号
3. 关闭所有终端窗口，重新打开

### 其他机器

1. 把整个 `claude-terminal-setup` 文件夹复制到目标机器
2. 双击 `setup.bat`，选择主题
3. 首次安装会下载字体（约 150MB），网络慢时需要耐心等待
4. 关闭所有终端窗口，重新打开

## 使用方法

### 交互式菜单（推荐）

```cmd
setup.bat
```

输入主题序号（1-7），或输入 `diy` 进入自定义模式。

### 命令行参数

**安装精选主题：**
```cmd
setup.bat -Preset forest
```

**DIY 自定义组合：**
```cmd
setup.bat -Font wenkai -Theme paper
```

**配置 Claude Code 代理：**
```cmd
setup.bat -BaseUrl https://your-proxy.com -AuthToken your-key
```

### 参数说明

| 参数 | 说明 | 可选值 |
|------|------|--------|
| `-Preset` | 精选主题 ID | `forest` `craft` `polar` `moon` `wave` `paper` `zen` |
| `-Font` | 字体 ID（DIY 模式） | `maple` `sarasa` `wenkai` `jbmaple` |
| `-Theme` | 配色 ID（DIY 模式） | `everforest` `gruvbox` `nord` `rosepine` `kanagawa` `dousha` `paper` |
| `-BaseUrl` | Claude API 代理地址 | 任意 URL |
| `-AuthToken` | 代理认证 Token | 字符串 |

## 精选主题

### 🌲 森林绿 Forest Green（默认）
**字体：** Maple Mono NF CN • **配色：** Everforest Dark  
灰绿色背景配暖米色文字，柔和圆润，长时间使用不累眼。

![森林绿](previews/forest.png)

### 🪵 工艺棕 Craft Brown
**字体：** 更纱黑体 Sarasa Term SC • **配色：** Gruvbox Material  
复古暖棕色调，方正字形，专业感强，适合传统审美。

![工艺棕](previews/craft.png)

### 🧊 极地蓝 Polar Blue
**字体：** Maple Mono NF CN • **配色：** Nord  
冷色蓝灰背景，简洁清爽。

![极地蓝](previews/polar.png)

### 🌙 玫瑰紫 Rosé Purple
**字体：** Maple Mono NF CN • **配色：** Rosé Pine Moon  
优雅紫灰色调，低调精致。

### 🌊 波浪青 Wave Cyan
**字体：** JetBrains Maple Mono • **配色：** Kanagawa Wave  
深青色背景，水墨画风，英文硬朗中文圆润。

![波浪青](previews/wave.png)

### 📄 纸张白 Paper White
**字体：** 霞鹜文楷等宽 LXGW WenKai Mono • **配色：** 豆沙绿 Light  
浅色主题配手写楷书字体，文艺温润，适合长时间阅读。

![纸张白](previews/paper.png)

### 🎨 禅意米 Zen Beige
**字体：** 更纱黑体 Sarasa Term SC • **配色：** Paper Light  
简洁浅米色背景，清爽明快。

---

**完整主题对比：** 见 [preview.html](preview.html)

## 字体选项

| ID | 字体名称 | 风格 | 适用场景 |
|----|----------|------|----------|
| `maple` | Maple Mono NF CN | 圆润柔和，中英 2:1 对齐，带 Nerd Font 图标 | 默认推荐，中文友好 |
| `sarasa` | 更纱黑体 Sarasa Term SC | 方正规整，传统专业，字形清晰 | 喜欢传统字形 |
| `wenkai` | 霞鹜文楷等宽 LXGW WenKai Mono | 手写楷书味，文艺温润 | 浅色主题，长文本阅读 |
| `jbmaple` | JetBrains Maple Mono | 英文 JetBrains Mono 硬朗 + 中文 Maple 圆润 | 英文代码为主 |

## 配色选项

| ID | 配色名称 | 类型 | 风格 |
|----|----------|------|------|
| `everforest` | Everforest Dark | 深色 | 灰绿底暖米色字 |
| `gruvbox` | Gruvbox Material | 深色 | 暖棕底米白字 |
| `nord` | Nord | 深色 | 冷蓝灰 |
| `rosepine` | Rosé Pine Moon | 深色 | 紫灰 |
| `kanagawa` | Kanagawa Wave | 深色 | 深青，水墨风 |
| `dousha` | 豆沙绿 | 浅色 | 浅绿底，护眼 |
| `paper` | Paper | 浅色 | 浅米底，简洁 |

## DIY 搭配建议

**护眼长时间使用：**
- 文楷 + 豆沙绿：`setup.bat -Font wenkai -Theme dousha`
- 更纱 + Paper：`setup.bat -Font sarasa -Theme paper`

**深色极简风：**
- Maple + Nord：`setup.bat -Font maple -Theme nord`
- JetBrains Maple + Kanagawa：`setup.bat -Font jbmaple -Theme kanagawa`

**复古暖色：**
- 更纱 + Gruvbox：`setup.bat -Font sarasa -Theme gruvbox`

## 配置内容

脚本会修改以下内容：

### Windows Terminal 设置
- 字体、字号、行高、边距
- 配色方案（明暗两套）
- 新建配置文件"Claude Code"，自动运行 `claude` 命令
- 光标样式、透明度

### Claude Code 设置（`~/.claude/settings.json`）
- 权限模式：`bypassPermissions`（跳过所有工具调用确认）
- 主题：根据配色自动设置为 `light` 或 `dark`
- 跳过启动风险提示
- API 代理地址（如果提供）

### 系统设置
- 为当前用户安装字体（无需管理员权限）
- 配置 cmd 在 Windows Terminal 中打开

## 卸载 / 恢复

原始配置已备份：
- `~/.claude/settings.json.bak`
- `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json.bak`

**恢复原始配置：**
```cmd
copy %USERPROFILE%\.claude\settings.json.bak %USERPROFILE%\.claude\settings.json
copy %LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json.bak %LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

**卸载字体：**
打开"设置 > 个性化 > 字体"，搜索字体名称卸载。

**恢复 cmd 默认行为：**
删除注册表 `HKCU\Console\%%Startup` 下的 `DelegationConsole` 和 `DelegationTerminal` 两个键值。

## 离线部署

适用于无网络或网络受限的环境：

1. 在联网机器上运行一次 `setup.bat`，字体会下载到当前目录
2. 把整个文件夹（含下载的字体包）复制到目标机器
3. 在目标机器运行 `setup.bat`，会自动使用本地字体包

字体包文件名：
- `MapleMono-NF-CN.zip`
- `SarasaTermSC-TTF-1.0.42.7z`
- `LXGWWenKaiMono-Regular.ttf`
- `LXGWWenKaiMono-Medium.ttf`
- `JetBrainsMapleMono-NF-XX-XX-XX.zip`

## 常见问题

**Q: 选了主题但没变化？**  
A: 关闭所有终端窗口重新打开。按 Ctrl+Shift+W 可一键关闭所有标签页。

**Q: 浅色主题看着难受？**  
A: 终端配色和 Claude Code 内部主题要匹配。脚本会自动设置，但如果你手动改了终端配色，需要在 Claude Code 里输入 `/theme` 选 `light`。

**Q: 想临时恢复权限确认提示？**  
A: 在 Claude Code 中按 `Shift + Tab` 可以切换权限模式。

**Q: 字体下载慢或失败？**  
A: 所有字体包都来自 GitHub 官方 release。可以先手动下载到本目录，脚本会检测到并使用本地文件。

**Q: 能否只换字体不换配色？**  
A: 可以。打开终端设置（Ctrl+,），点击"Claude Code"配置文件，在"外观"里改字体。或者用 DIY 模式重新选。

**Q: 支持其他终端吗？**  
A: 目前只支持 Windows Terminal。配色方案可以手动移植到其他终端，但字体安装和 Claude 配置是通用的。

## 环境要求

- Windows 10/11
- Windows Terminal（通过 Microsoft Store 安装，或 Windows 11 自带）
- Claude Code CLI
- Node.js（仅重新生成预览图时需要）

## 许可证

MIT

## 致谢

- 字体：[Maple Mono](https://github.com/subframe7536/maple-font)、[更纱黑体](https://github.com/be5invis/Sarasa-Gothic)、[霞鹜文楷](https://github.com/lxgw/LxgwWenKai)、[JetBrains Maple Fusion](https://github.com/SpaceTimee/Fusion-JetBrainsMapleMono)
- 配色：[Everforest](https://github.com/sainnhe/everforest)、[Gruvbox Material](https://github.com/sainnhe/gruvbox-material)、[Nord](https://www.nordtheme.com/)、[Rosé Pine](https://rosepinetheme.com/)、[Kanagawa](https://github.com/rebelot/kanagawa.nvim)
