// 由 presets.json / themes.json / fonts.json 生成 preview.html 和 previews/*.png
// 用法: node tools/build-preview.js
// 字体样张优先加载 tools/.font-cache/ 下的 ttf（fonts.json 中 files[0]），没有则用本机已装字体
const fs = require('fs');
const path = require('path');

const root = path.join(__dirname, '..');
const presets = JSON.parse(fs.readFileSync(path.join(root, 'presets.json'), 'utf8'));
const themes = JSON.parse(fs.readFileSync(path.join(root, 'themes.json'), 'utf8'));
const fonts = JSON.parse(fs.readFileSync(path.join(root, 'fonts.json'), 'utf8'));
const FONT = `'Maple Mono NF CN', 'Cascadia Code', Consolas, monospace`;
const cache = path.join(__dirname, '.font-cache');

const esc = s => s.replace(/&/g, '&amp;').replace(/</g, '&lt;');

const fontFace = f => {
  const file = path.join(cache, f.files[0]);
  const src = fs.existsSync(file) ? `url("file:///${file.replace(/\\/g, '/')}")` : `local("${f.face}")`;
  return `@font-face { font-family: "Preview ${f.id}"; src: ${src} }`;
};

// 模拟一个 Claude Code 会话，使用给定预设的字体和配色
function terminalPreset(p) {
  const t = themes.find(x => x.id === p.theme);
  const f = fonts.find(x => x.id === p.font);
  const c = t.scheme;
  const span = (color, text, extra = '') => `<span style="color:${c[color] || color};${extra}">${esc(text)}</span>`;
  const lines = [ // 每行一个元素，按换行拼接
    span('cursorColor', '✳ ', 'font-weight:bold') + span('foreground', 'Claude Code', 'font-weight:bold') + span('brightBlack', '  v2.1 · ~/projects/demo'),
    '',
    span('brightBlack', '> ') + span('foreground', '帮我给 login 接口加上参数校验'),
    '',
    span('green', '● ') + span('foreground', 'Read') + span('brightBlack', '(src/api/login.ts)'),
    span('brightBlack', '  ⎿ 读取 48 行'),
    span('green', '● ') + span('foreground', 'Update') + span('brightBlack', '(src/api/login.ts)'),
    span('brightBlack', '  ⎿ ') + span('green', '+3 ') + span('red', '-1'),
    `<span style="background:${c.green}22;display:inline-block;width:100%">` + span('green', '  12 + if (!isEmail(body.email)) {') + '</span>',
    `<span style="background:${c.green}22;display:inline-block;width:100%">` + span('green', '  13 +   return res.status(400).json({ error: "邮箱格式错误" })') + '</span>',
    `<span style="background:${c.red}22;display:inline-block;width:100%">` + span('red', '  12 - const user = await db.find(body.email)') + '</span>',
    span('green', '● ') + span('foreground', 'Bash') + span('brightBlack', '(npm test)'),
    span('brightBlack', '  ⎿ ') + span('green', '✓ 12 passed') + span('yellow', '  ⚠ 1 warning'),
    '',
    span('foreground', '已为 login 接口添加邮箱格式校验，测试全部通过。'),
    '',
    span('purple', '⏵⏵ bypass permissions on') + span('brightBlack', ' (shift+tab to cycle)'),
  ];
  const tab = `<div class="tabbar" style="background:${shade(c.background, t.claudeTheme)}">
    <div class="tab" style="background:${c.background};color:${c.foreground};border-top:2px solid ${c.cursorColor}">✳ Claude Code</div></div>`;
  const palette = ['black', 'red', 'green', 'yellow', 'blue', 'purple', 'cyan', 'white']
    .map(k => `<i style="background:${c[k]}"></i>`).join('');
  return `<div class="win">${tab}
  <pre style="background:${c.background};color:${c.foreground};font-family:'Preview ${f.id}',monospace;font-size:${f.size}px">${lines.join('\n')}<span class="cur" style="background:${c.cursorColor}"></span></pre>
  <div class="pal" style="background:${c.background}">${palette}</div></div>`;
}

// 标签栏颜色：深色主题再暗一点，浅色主题再深一点
function shade(hex, mode) {
  const n = parseInt(hex.slice(1), 16), f = mode === 'light' ? 0.92 : 0.8;
  const r = Math.round(((n >> 16) & 255) * f), g = Math.round(((n >> 8) & 255) * f), b = Math.round((n & 255) * f);
  return `rgb(${r},${g},${b})`;
}

const css = `
* { box-sizing: border-box; margin: 0 }
body { font-family: system-ui, 'Microsoft YaHei', sans-serif; background: #0f1012; color: #d8dde5; padding: 36px }
h1 { font-weight: 600; font-size: 26px; margin-bottom: 8px; color: #e5eaf0 }
.sub { color: #7b8a9a; margin-bottom: 32px; font-size: 14px; line-height: 1.6 }
.grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(600px, 1fr)); gap: 32px }
.card { background: #16181b; border-radius: 12px; padding: 20px; border: 1px solid #272b30; transition: border 0.2s }
.card:hover { border-color: #3d4450 }
.card h2 { font-size: 17px; font-weight: 600; margin-bottom: 6px; color: #e0e5eb }
.card p { color: #869098; font-size: 13px; margin-bottom: 14px; line-height: 1.5 }
.win { border-radius: 8px; overflow: hidden; box-shadow: 0 4px 12px rgba(0,0,0,0.4); font-size: 13px }
.tabbar { padding: 8px 12px; display: flex; gap: 6px; border-bottom: 1px solid #0003 }
.tab { padding: 6px 14px; border-radius: 6px 6px 0 0; font-weight: 500; font-size: 12px }
pre { padding: 18px 22px; line-height: 1.65; overflow-x: auto; position: relative }
.cur { display: inline-block; width: 2px; height: 16px; margin-left: 2px; animation: blink 1.2s steps(2, start) infinite }
@keyframes blink { to { visibility: hidden } }
.pal { padding: 8px 22px; display: flex; gap: 6px; border-top: 1px solid #0003 }
.pal i { width: 20px; height: 20px; border-radius: 4px }
`;

const faceCSS = fonts.map(fontFace).join('\n');
const cards = presets.map(p => `<div class="card">
  <h2>${esc(p.title)}</h2>
  <p>${esc(p.desc)}</p>
  ${terminalPreset(p)}
</div>`).join('\n');

const html = `<!DOCTYPE html>
<html><head><meta charset="utf-8"><title>Claude Code 终端配置模板</title>
<style>${css}\n${faceCSS}</style></head>
<body>
<h1>Claude Code 终端配置模板</h1>
<p class="sub">字体 × 配色精选搭配，一步到位。双击 setup.bat 按序号选择，或加参数 -Preset &lt;id&gt; 跳过菜单。<br>想自己搭配字体和配色？选菜单最后一项「🎨 DIY 自定义」，或加参数 -Font &lt;id&gt; -Theme &lt;id&gt;。</p>
<div class="grid">
${cards}
</div>
</body></html>
`;

fs.writeFileSync(path.join(root, 'preview.html'), html, 'utf8');
console.log('✓ preview.html');

// 截图：若有 edge / msedge，给每个预设截一张 PNG
const edge = process.platform === 'win32' ? 'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe'
  : process.platform === 'darwin' ? '/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge'
  : 'microsoft-edge';

if (!fs.existsSync(edge) && process.platform === 'win32') {
  const alt = 'C:\\Program Files\\Microsoft\\Edge\\Application\\msedge.exe';
  if (fs.existsSync(alt)) edge = alt;
}

if (fs.existsSync(edge)) {
  const outDir = path.join(root, 'previews');
  fs.mkdirSync(outDir, { recursive: true });
  const { execFileSync } = require('child_process');
  presets.forEach(p => {
    const single = `<!DOCTYPE html><html><head><meta charset="utf-8"><style>${css}\n${faceCSS}</style></head>
<body style="padding:20px;width:680px">${terminalPreset(p)}</body></html>`;
    const tmp = path.join(outDir, `_tmp_${p.id}.html`);
    fs.writeFileSync(tmp, single, 'utf8');
    const png = path.join(outDir, `${p.id}.png`);
    execFileSync(edge, ['--headless', `--screenshot=${png}`, `--window-size=680,500`, tmp], { stdio: 'ignore' });
    fs.unlinkSync(tmp);
    console.log(`✓ previews/${p.id}.png`);
  });

  // 合并成一张大图
  const oneRow = 680, oneH = 500, gap = 20, cols = 2;
  const rows = Math.ceil(presets.length / cols), W = oneRow * cols + gap * (cols - 1), H = oneH * rows + gap * (rows - 1);
  const canvas = `<canvas id="c" width="${W}" height="${H}"></canvas>
<script>
const c = document.getElementById('c').getContext('2d'), presets = ${JSON.stringify(presets.map(p => p.id))};
let loaded = 0;
presets.forEach((id, i) => {
  const img = new Image();
  img.onload = () => {
    const x = (i % ${cols}) * (${oneRow} + ${gap}), y = Math.floor(i / ${cols}) * (${oneH} + ${gap});
    c.drawImage(img, x, y);
    if (++loaded === presets.length) setTimeout(() => location.href = 'done', 100);
  };
  img.src = 'file:///${outDir.replace(/\\/g, '/')}/' + id + '.png';
});
</script>`;
  const tmpAll = path.join(outDir, '_tmp_all.html');
  fs.writeFileSync(tmpAll, `<!DOCTYPE html><html><head><meta charset="utf-8"></head><body>${canvas}</body></html>`, 'utf8');
  const pngAll = path.join(root, 'preview-all.png');
  execFileSync(edge, ['--headless', `--screenshot=${pngAll}`, `--window-size=${W + 40},${H + 40}`, tmpAll], { stdio: 'ignore' });
  fs.unlinkSync(tmpAll);
  console.log('✓ preview-all.png');
} else {
  console.log('⚠ Edge not found, skip screenshot');
}
