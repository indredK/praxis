#!/bin/bash

# 获取本机IP地址
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}' | head -1)

echo "🚀 启动Flutter应用，支持局域网访问..."
echo "📱 本机IP地址: $LOCAL_IP"
echo "🌐 局域网访问地址: http://$LOCAL_IP:58108"
echo "💻 本机访问地址: http://localhost:58108"
echo ""

# 停止可能运行的应用
pkill -f "dart.*58108" 2>/dev/null || true
sleep 2

# 启动Flutter应用，绑定到所有网络接口
echo "正在启动Flutter应用..."
flutter run --web-hostname 0.0.0.0 --web-port 58108 --device-id web-server
