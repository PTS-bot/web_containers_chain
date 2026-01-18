#!/bin/bash
set -e

# ==========================================
# 1. ส่วนกำหนดตัวแปร (Configuration Variables)
# ==========================================
JUP_TOKEN="${JUPYTER_TOKEN:-master}"       
WORK_DIR="${JUPYTER_WORKDIR:-/home/master}" 
REQ_FILE="requirements_python.txt"          

echo "========================================"
echo "Starting Installation with configs:"
echo " - Token/Password : $JUP_TOKEN"
echo " - Working Dir    : $WORK_DIR"
echo "========================================"

# ==========================================
# 2. ส่วนติดตั้ง (Installation)
# ==========================================
apt-get update

# 🔥 เพิ่ม iputils-ping (สำหรับ ping) และ net-tools (เผื่อใช้ ifconfig) ตรงนี้ครับ
apt-get install -y \
    python3 \
    python3-pip \
    python3-dev \
    build-essential \
    openjdk-11-jdk \
    git \
    curl \
    iputils-ping \
    net-tools

apt-get clean
rm -rf /var/lib/apt/lists/*

pip3 install --no-cache-dir --upgrade pip
pip3 install --no-cache-dir jupyterlab

if [ -f "$REQ_FILE" ]; then
    echo "Found $REQ_FILE, installing..."
    pip3 install --no-cache-dir -r "$REQ_FILE"
fi

# ==========================================
# 3. ส่วนตั้งค่า (Configuration)
# ==========================================
mkdir -p /root/.jupyter
CONFIG_FILE="/root/.jupyter/jupyter_lab_config.py"
mkdir -p "$WORK_DIR"

echo "c.ServerApp.base_url = '/jupyter'" >> "$CONFIG_FILE"
echo "Generating Jupyter Config at $CONFIG_FILE..."

cat <<EOT > "$CONFIG_FILE"
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.allow_root = True
c.ServerApp.allow_origin = '*'
c.ServerApp.allow_remote_access = True
c.ServerApp.disable_check_xsrf = True
c.ServerApp.tornado_settings = {'headers': {'Content-Security-Policy': "frame-ancestors 'self' *"}}
c.ServerApp.token = '$JUP_TOKEN'
c.ServerApp.root_dir = '$WORK_DIR'
EOT

echo "=== Installation Complete ==="