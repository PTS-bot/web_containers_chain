#!/bin/bash

# 1. Start Open vSwitch (รองรับ WSL2)
echo "=== [Boot] Starting Open vSwitch ==="
/usr/share/openvswitch/scripts/ovs-ctl start --system-id=random || true

# เช็คว่า process ขึ้นไหม ถ้าไม่ขึ้นให้ force start
if ! pgrep -x "ovs-vswitchd" > /dev/null; then
    echo "Warning: ovs-vswitchd not running. Force starting..."
    ovs-vswitchd --pidfile --detach --log-file
fi
# --------------------------- Nginx -----------------------------------
echo "=== [Boot 2] Starting Nginx (Gateway) ==="
# สั่ง Start Nginx (แบบ service ปกติ ไม่ต้อง daemon off)
service nginx start
# หรือถ้า service ไม่เวิร์คใน image บางตัว ให้ใช้คำสั่งตรงๆ:
# /usr/sbin/nginx


# 2. Start Jupyter Lab (Background)
echo "=== [Boot] Starting Jupyter Lab ==="
nohup jupyter lab --allow-root > /var/log/jupyter.log 2>&1 &

# 3. Start OpenDaylight (Main Process)
# echo "=== [Boot] Starting OpenDaylight ==="

# ไฟล์นี้จะแก้ Config และรอ Install feature แบบ Background
# if [ -f "/usr/local/bin/setup_odl.sh" ]; then
#     /usr/local/bin/setup_odl.sh
# fi

# 5. Start OpenDaylight (พระเอกตัวจริง)
echo "=== [Boot] Starting OpenDaylight Main Process ==="
exec "$@"