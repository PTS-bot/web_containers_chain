#!/bin/bash

# ตั้งค่า Path
KARAF_DIR="/home/user/karaf-0.18.1"
CLIENT_BIN="$KARAF_DIR/bin/client"
LOG_FILE="/var/log/odl_setup.log"

# รายชื่อ Feature
FEATURES="odl-restconf odl-openflowplugin-flow-services-rest odl-openflowplugin-app-table-miss-enforcer"

# ฟังก์ชันสำหรับ Print ลงทั้งหน้าจอและ Log file
log_msg() {
    echo "$1" | tee -a $LOG_FILE
}

log_msg "--- [Setup] Script Started ---"

# 1. รอ Karaf (วนลูปเช็ค)
log_msg " >> Waiting for Karaf SSH..."

RETRIES=0
MAX_RETRIES=60

while true; do
    # เช็คสถานะ (ซ่อน error ไว้ก่อนจะได้ไม่รก)
    $CLIENT_BIN "system:version" > /dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        log_msg " >> Karaf is UP! Ready to install."
        break
    fi

    if [ $RETRIES -ge $MAX_RETRIES ]; then
        log_msg " !! FAIL: Karaf took too long."
        exit 1
    fi

    echo -n "." # พิมพ์จุดรอไปเรื่อยๆ
    sleep 10
    RETRIES=$((RETRIES+1))
done

echo "" # ขึ้นบรรทัดใหม่หลังจุด

# 2. ติดตั้ง Feature
log_msg " >> Installing features: $FEATURES"
# สั่งติดตั้งและโชว์ผลลัพธ์ถ้ามี error
$CLIENT_BIN "feature:install $FEATURES" | tee -a $LOG_FILE

# 3. ตรวจสอบและโชว์ผลลัพธ์ (ส่วนที่คุณต้องการ!)
log_msg "========================================"
log_msg " >> VERIFICATION RESULT (feature:list):"
log_msg "========================================"

# --- ไฮไลท์: สั่ง print ออกมาตรงๆ เลย ---
$CLIENT_BIN "feature:list -i | grep openflow" | tee -a $LOG_FILE

log_msg "========================================"
log_msg "--- [Setup] Finished ---"