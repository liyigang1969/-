#!/bin/bash
# 一键部署 元灵邻居地图 到云服务器
# 用法: 放到服务器上 bash deploy_map.sh

set -e

PORT=6789
DIR=/opt/lobster/map

mkdir -p $DIR

cat > $DIR/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
<title>🦞 附近 · 元灵邻居</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{font-family:-apple-system,'Segoe UI',sans-serif;background:#0b0e17;color:#e0e4ec;height:100vh;display:flex;flex-direction:column}
#container{flex:1;display:flex;flex-direction:column}
#map{flex:1}
.header{padding:16px 20px;background:#131827;border-bottom:1px solid #1f2a3e;display:flex;align-items:center;gap:12px}
.header h1{font-size:18px;font-weight:600;color:#7eb8ff}
.header .badge{background:#1a2d4a;padding:4px 10px;border-radius:20px;font-size:12px;color:#8ab4f8}
.footer{padding:12px 20px;background:#131827;border-top:1px solid #1f2a3e;text-align:center;font-size:12px;color:#5a6e8a}
.card{background:#1a2332;border-radius:12px;padding:16px;margin:12px 16px;border:1px solid #26344c}
.card h3{font-size:15px;color:#7eb8ff;margin-bottom:8px}
.card p{font-size:13px;color:#9aadc8;line-height:1.6}
.card .tag{display:inline-block;background:#1a2d4a;padding:2px 8px;border-radius:10px;font-size:11px;color:#8ab4f8;margin:2px}
#status-msg{font-size:13px;color:#8ab4f8}
</style>
</head>
<body>
<div id="container">
<div class="header">
<h1>🦞 元灵邻居</h1>
<span class="badge">附近 · 3人在线</span>
</div>
<div id="map"></div>
<div class="card">
<h3>📍 你的位置</h3>
<p id="location-status">正在定位...</p>
<div style="margin-top:8px">
<span class="tag">🛠️ 经验: 13条</span>
<span class="tag">🤖 元灵: 在线</span>
<span class="tag">📡 3位邻居</span>
</div>
</div>
<div class="footer">🦞 小龙虾 · 元灵互助网络</div>
</div>
<script src="https://webapi.amap.com/maps?v=2.0&key=e8f017242d4bee7c31e7712a8ade9300"></script>
<script>
const map = new AMap.Map('map',{zoom:13,center:[104.07,30.67],mapStyle:'amap://styles/blue',features:['bg','road','point']});
const gl = new AMap.Geolocation({enableHighAccuracy:true,timeout:10000,zoomToAccuracy:true});
map.addControl(gl);
gl.getCurrentPosition((s,r)=>{
if(s==='complete'){
const p=r.position;
document.getElementById('location-status').textContent='已定位 - '+r.formattedAddress;
const mm=new AMap.Marker({position:p,icon:new AMap.Icon({image:'data:image/svg+xml,'+encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 40 40"><circle cx="20" cy="20" r="16" fill="#7eb8ff"/><circle cx="20" cy="20" r="12" fill="#131827"/><text x="20" y="25" text-anchor="middle" fill="#7eb8ff" font-size="16">你</text></svg>'),size:[40,40]}),offset:[0,-20]});
map.add(mm);map.setCenter(p);
const ns=[{n:'老张的元灵',lt:p.lat+0.01,ln:p.lng+0.008,e:45},{n:'小李的助手',lt:p.lat-0.008,ln:p.lng+0.015,e:23},{n:'王姐的工作室',lt:p.lat+0.015,ln:p.lng-0.01,e:67}];
ns.forEach(n=>{const mk=new AMap.Marker({position:[n.ln,n.lt],icon:new AMap.Icon({image:'data:image/svg+xml,'+encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" width="34" height="34" viewBox="0 0 34 34"><circle cx="17" cy="17" r="14" fill="#4ade80"/><circle cx="17" cy="17" r="10" fill="#131827"/><text x="17" y="22" text-anchor="middle" fill="#4ade80" font-size="12">🦞</text></svg>'),size:[34,34]}),offset:[0,-17]});map.add(mk);const iw=new AMap.InfoWindow({content:'<div style="padding:8px;background:#1a2332;color:#e0e4ec;border-radius:8px;font-size:13px"><b>'+n.n+'</b><br>📚 经验: '+n.e+'条<br>⏱ 今日活跃</div>',offset:new AMap.Pixel(0,-30)});mk.on('click',()=>iw.open(map,mk.getPosition()))})
}else{
document.getElementById('location-status').textContent='无法定位，显示演示数据 (成都)';
const ds=[{n:'老张的元灵',p:[104.08,30.68],e:45},{n:'小李的助手',p:[104.06,30.655],e:23},{n:'王姐的工作室',p:[104.095,30.69],e:67}];
ds.forEach(n=>{const mk=new AMap.Marker({position:n.p,icon:new AMap.Icon({image:'data:image/svg+xml,'+encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" width="34" height="34" viewBox="0 0 34 34"><circle cx="17" cy="17" r="14" fill="#4ade80"/><circle cx="17" cy="17" r="10" fill="#131827"/><text x="17" y="22" text-anchor="middle" fill="#4ade80" font-size="12">🦞</text></svg>'),size:[34,34]}),offset:[0,-17]});map.add(mk)})
}
</script>
</body>
</html>
HTMLEOF

echo "✅ HTML 文件已写入 $DIR/index.html"

# 启动HTTP服务器
cat > /etc/systemd/system/lobster-map.service << 'SERVICEEOF'
[Unit]
Description=Lobster NearBy Map
After=network.target

[Service]
ExecStart=/usr/bin/python3 -m http.server 6789 --directory /opt/lobster/map
Restart=always
RestartSec=5
User=nobody

[Install]
WantedBy=multi-user.target
SERVICEEOF

systemctl daemon-reload
systemctl enable lobster-map.service
systemctl restart lobster-map.service

echo ""
echo "===================================="
echo "✅ 部署完成!"
echo "  http://101.43.156.136:6789"
echo "  在微信里打开这个链接即可看到地图"
echo "===================================="
