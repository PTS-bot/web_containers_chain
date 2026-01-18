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
# ... (ส่วนบนเหมือนเดิม)

CONFIG_FILE="/root/.jupyter/jupyter_lab_config.py"

echo "=== [Config] Generating Jupyter Config ==="

# บรรทัดแรกใช้ > เพื่อสร้างไฟล์ใหม่    
echo "c.ServerApp.ip = '0.0.0.0'" > $CONFIG_FILE

# บรรทัดต่อไปใช้ >> เพื่อต่อท้าย
echo "c.ServerApp.port = 8888" >> $CONFIG_FILE
echo "c.ServerApp.open_browser = False" >> $CONFIG_FILE
echo "c.ServerApp.allow_root = True" >> $CONFIG_FILE
echo "c.ServerApp.token = 'master'" >> $CONFIG_FILE
echo "c.ServerApp.root_dir = '/'" >> $CONFIG_FILE


# --- 🔥 จุดเปลี่ยนสำคัญ: บอก Jupyter ว่าตัวเองอยู่ที่ /jupyter 🔥 ---
echo "c.ServerApp.base_url = '/jupyter'" >> $CONFIG_FILE

# ปิดระบบความปลอดภัยเรื่อง Origin และ iFrame
echo "c.ServerApp.allow_origin = '*'" >> $CONFIG_FILE
echo "c.ServerApp.allow_remote_access = True" >> $CONFIG_FILE
echo "c.ServerApp.tornado_settings = {'headers': {'Content-Security-Policy': \"frame-ancestors 'self' *\"}}" >> $CONFIG_FILE
# ปิด XSRF check เพื่อให้ iframe ทำงานได้ลื่นขึ้น
echo "c.ServerApp.disable_check_xsrf = True" >> $CONFIG_FILE

echo "=== [Install] Jupyter Complete ==="