#!/bin/bash

# ตั้งค่า Path (เช็คให้ตรงกับเครื่องคุณ)
KARAF_DIR="/home/user/karaf-0.18.1"
SYS_PROP="$KARAF_DIR/etc/system.properties"

echo "==========================================="
echo "   Hawtio Security Unlocker & Verifier"
echo "==========================================="

# 1. เช็คว่าเจอไฟล์ config ไหม
if [ ! -f "$SYS_PROP" ]; then
    echo " !! ERROR: File not found at $SYS_PROP"
    exit 1
fi

# 2. เริ่มการแก้ไข (ถ้ายังไม่เคยแก้)
if grep -q "hawtio.xframeOptionsEnabled" "$SYS_PROP"; then
    echo " >> Config found. Skipping append step."
else
    echo " >> Appending security bypass configs..."
    
    # Backup
    cp "$SYS_PROP" "$SYS_PROP.bak"

    cat <<EOT >> "$SYS_PROP"

# ----------------------------------------------------------------
# UNLOCK HAWTIO (Added by script)
# ----------------------------------------------------------------
hawtio.xframeOptionsEnabled = false
hawtio.contentSecurityPolicyEnabled = false
hawtio.http.strictTransportSecurity = false
jolokia.allowErrorDetails = true
hawtio.keycloakEnabled = false
hawtio.authenticationEnabled = true
# ----------------------------------------------------------------
EOT
    echo " >> Write Complete."
fi

echo "==========================================="
echo "   VERIFICATION: Reading $SYS_PROP"
echo "==========================================="

# 3. ส่วนตรวจสอบ (Print ค่าออกมาดูเลย)
# เราจะค้นหาคำว่า hawtio หรือ jolokia ในไฟล์ แล้วโชว์บรรทัดนั้น
echo "Current Settings in File:"
echo "-------------------------"
grep -E "hawtio\.|jolokia\." "$SYS_PROP" | grep -v "#"
echo "-------------------------"

# 4. ตรวจสอบความถูกต้อง
if grep -q "hawtio.xframeOptionsEnabled = false" "$SYS_PROP"; then
    echo "✅ CHECK PASS: xFrameOptions is DISABLED"
else
    echo "❌ CHECK FAIL: xFrameOptions setting NOT FOUND!"
fi

echo "==========================================="
echo " IMPORTANT: You MUST RESTART the container now!"
echo " docker restart <container_name>"
echo "==========================================="