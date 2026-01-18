#!/bin/bash
set -e

echo "=== [Install] Python & Jupyter Lab ==="

# 1. ติดตั้ง Python และ Pip (ถ้ายังไม่มี หรือต้องการ version ล่าสุด)
# หมายเหตุ: ODL image บางตัวมี python มาแล้ว แต่ลงซ้ำเพื่อ update ได้
apt-get update
apt-get install -y python3 python3-pip python3-dev build-essential
apt-get clean
rm -rf /var/lib/apt/lists/*

# 2. ติดตั้ง Jupyter Lab และ Library พื้นฐาน
pip3 install --no-cache-dir --upgrade pip
pip3 install --no-cache-dir jupyterlab

# 3. ติดตั้งจาก requirements_python.txt (ถ้ามี)
if [ -f "/home/master/requirements_python.txt" ]; then
    echo "Found requirements_python.txt, installing..."
    pip3 install --no-cache-dir -r /home/master/requirements_python.txt
fi

# 4. สร้าง Config Jupyter (ให้รองรับ root และเข้าผ่าน web ได้)
mkdir -p /root/.jupyter
CONFIG_FILE="/root/.jupyter/jupyter_lab_config.py"

echo "c.ServerApp.base_url = '/proxy/jupyter'" >> $CONFIG_FILE # <-- เพิ่มบรรทัดนี้

echo "c.ServerApp.ip = '0.0.0.0'" > $CONFIG_FILE
echo "c.ServerApp.port = 8888" >> $CONFIG_FILE
echo "c.ServerApp.open_browser = False" >> $CONFIG_FILE
echo "c.ServerApp.allow_root = True" >> $CONFIG_FILE
echo "c.ServerApp.token = 'master'" >> $CONFIG_FILE


echo "c.ServerApp.root_dir = '/'" >> $CONFIG_FILE # ให้มองเห็นทั้งเครื่อง

echo "=== [Install] Jupyter Complete ==="