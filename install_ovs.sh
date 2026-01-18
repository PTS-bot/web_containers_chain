#!/bin/bash
set -e  # ถ้ามี error ให้หยุดทันที

echo "=== [Install] Open vSwitch & Network Tools ==="

# 1. อัปเดตและติดตั้ง Package
apt-get update
apt-get install -y \
    openvswitch-switch \
    net-tools \
    iproute2 \
    procps \
    uuid-runtime \
    curl \
    git

# 2. สร้าง Directory ที่จำเป็นสำหรับ OVS runtime
mkdir -p /var/run/openvswitch
mkdir -p /var/log/openvswitch

# 3. ลบ cache เพื่อลดขนาด Image
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "=== [Install] OVS Complete ==="