from pathlib import Path

root = Path(__file__).parent / "app/src/main/assets/www"
html_path = root / "index.html"
css_path = root / "styles.css"

html = html_path.read_text(encoding="utf-8")
html = html.replace("<title>Mirror Twins Solo</title>", "<title>Mirror Twins</title>")
html = html.replace("<small>OFFLINE SOLO</small>", "<small>SOLO + ONLINE</small>")
html = html.replace(
    '<div class="primary-row">\n        <button id="continueBtn" class="play-btn">▶ Play Level 1</button>\n        <button id="levelsBtn" class="icon-action">▦</button>\n      </div>',
    '<div class="primary-row">\n        <button id="continueBtn" class="play-btn">▶ Play Level 1</button>\n        <button id="levelsBtn" class="icon-action">▦</button>\n      </div>\n      <button id="onlineBtn" class="online-btn"><span>🌐</span><b>Online Arena</b><small>Live players · challenges · worldwide races</small></button>\n      <p id="onlineStatus" class="online-status">Online uses mt.grafixers.co.uk · Solo remains fully offline.</p>'
)
html = html.replace(
    '<div class="home-footer"><span>✓ Works without internet</span><span>Progress saved on device</span></div>',
    '<div class="home-footer"><span>✓ Solo works without internet</span><span>Online connects securely when selected</span></div>'
)
html = html.replace(
    'This Android test build is fully local. No account, VPS or internet connection is required.',
    'Solo mode is stored on this device and works offline. Online Arena connects securely to mt.grafixers.co.uk.'
)
html = html.replace('<script src="game.js"></script>', '<script src="game.js"></script>\n<script src="online.js"></script>')
html_path.write_text(html, encoding="utf-8")

css = css_path.read_text(encoding="utf-8")
css += r'''
.online-btn{width:100%;margin-top:12px;min-height:62px;border-radius:18px;border:1px solid rgba(87,196,255,.38);background:linear-gradient(135deg,rgba(32,112,211,.28),rgba(167,62,164,.18));display:grid;grid-template-columns:38px 1fr;grid-template-rows:auto auto;column-gap:10px;align-items:center;text-align:left;padding:10px 14px;box-shadow:0 12px 30px rgba(20,81,180,.18)}
.online-btn>span{grid-row:1/3;font-size:24px;text-align:center}
.online-btn>b{font-size:14px;color:#f4f8ff}
.online-btn>small{font-size:9px;letter-spacing:.035em;color:#9eb4d8;margin-top:2px}
.online-btn.connecting{opacity:.72}
.online-status{margin:7px 3px 0!important;font-size:9px!important;color:#7f93b5!important}
.online-status.warn{color:#ffb5a9!important}
'''
css_path.write_text(css, encoding="utf-8")

online_src = Path(__file__).parent / "online.js"
(root / "online.js").write_text(online_src.read_text(encoding="utf-8"), encoding="utf-8")
