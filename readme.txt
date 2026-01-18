
# เข้าไปที่ Shell ของ ODL Controller
docker exec -it odl_controller /opt/opendaylight/bin/client

docker exec -it odl_controller /bin/bash
/home/user/karaf-0.18.1/bin/client
ssh -p 8101 karaf@localhost

ตรวจสอบ version ของ ODL
info
log:display | grep hawtio

# -------------- ติดตั้ง Feature พื้นฐานสำหรับ OpenFlow Controller ---------------

feature:install odl-restconf odl-openflowplugin-flow-services-rest odl-openflowplugin-app-table-miss-enforcer

# odl-restconf: เปิดประตูให้คนภายนอก (เช่น Postman, Python, Browser) เข้ามาสั่งงานได้ (ผ่าน Port 8181)
# odl-openflowplugin-flow-services-rest: เปิดระบบ OpenFlow ให้ ODL สามารถไปสั่ง Switch/Router ได้
# odl-openflowplugin-app-table-miss-enforcer: กฎพื้นฐานที่บอก Switch ว่า "ถ้ามีข้อมูลวิ่งมาแล้วไม่รู้จะไปไหน ให้ส่งมาถาม Controller นะ"

feature:list -i | grep openflow
feature:list -i | grep odl-restconf
feature:list -i | grep odl-openflowplugin-flow-services-rest
feature:list -i | grep odl-openflowplugin-app-table-miss-enforcer

# feature:list -i | grep restconf
# feature:install odl-restconf
# feature:list -i | grep openflow
# ------------------------------------------------------------------------------

# โหลด hawtio-osgi-2.17.0.war ที่ https://repo1.maven.org/maven2/io/hawt/hawtio-osgi/2.17.0/hawtio-osgi-2.17.0.war 
# เอาไฟล์ .war ไปไว้ที่ deploy โยใช้ cp หรือ volumes:
# docker cp C:\Users\T\Downloads\hawtio-osgi-2.17.0.war odl_controller:/home/user/karaf-0.18.1/deploy/

bundle:list -s | grep hawtio
feature:install hawtio

feature:install war
bundle:start 25
bundle:list -s | grep hawtio

# เข้าไปที่ URL นี้: http://localhost:8181/hawtio

# ------------------------------------------------------------------------------

# ดูรหัสผ่านในไฟล์ users.properties
cat etc/users.properties
# Username: karaf
# Password: karaf

# เพิ่ม user ใหม่ ชื่อ admin รหัสผ่าน admin
echo "admin = admin,_g_:admingroup" >> etc/users.properties
# Username: admin
# Password: admin

http://localhost:8181/rests/data/ietf-yang-library:modules-state
# ------------------------------------------------------------------------------

sudo docker logs odl_controller

# ip odl = 10.222.20.222 and 172.16.1.102
# ตั้งค่า IP Address ให้กับ Switch ใน GNS3
ifconfig eth0 10.222.20.103 netmask 255.255.255.0 up
ping 10.222.20.222

ovs-vsctl show
# สั่งให้ OVS วิ่งไปหา OpenDaylight
ovs-vsctl add-br br0
# เพิ่มพอร์ต eth0 เข้าไปใน Bridge
ovs-vsctl add-port br0 eth0


# ตั้งค่า Controller: เปลี่ยน 10.222.20.222 เป็น IP เครื่อง ODl
ovs-vsctl set-controller br0 tcp:10.222.20.222:6633
# ตั้งค่า OpenFlow Version (แนะนำ): OpenDaylight ทำงานได้ดีที่สุดกับ OpenFlow 1.3
# ovs-vsctl set protocols br0 OpenFlow13
ovs-vsctl show

# ดูตรงบรรทัด Controller "tcp:..." จะต้องมีคำว่า is_connected: true ครับ
# เช็คที่ฝั่ง OpenDaylight (Browser/Postman): เข้าลิงก์เดิมครับ: http://172.16.1.102:8181/rests/data/network-topology:network-topology
# คุณควรจะเห็น Node ใหม่โผล่ขึ้นมา (เช่น openflow:1234...) ครับ

# ดูว่า OpenDaylight "เสก" กฎอะไรลงไปใน Switch บ้าง
ovs-ofctl -O OpenFlow13 dump-flows br0

# dump-flows แล้วยังเห็นแค่บรรทัดเดียว (priority=0 actions=CONTROLLER) แสดงว่า:
# ODL ทำงานแบบ "Hub Mode" หรือ Packet-Out Only: คือรับเรื่องเองทุกเม็ด ไม่ฝังกฎลง Switch (กินแรง CPU Controller เยอะ)


# ลองเพิ่มกฎง่ายๆ ดูครับ (Block Ping จากภายนอก)
# Method: PUT
# เปลี่ยน openflow:174191499024971 เป็น ID ของ Switch ตัวที่ PC ต่ออยู่
# block-ping-1 คือชื่อ ID ของกฎที่เราตั้งเอง
http://172.16.1.102:8181:8181/rests/data/opendaylight-inventory:nodes/node/openflow:174191499024971/flow-node-inventory:table/0/flow/block-ping-1
# Auth: User: admin / Pass: admin
# Header: Content-Type: application/json


# docker image build -t odl-ubuntu-f:latest .
# docker images

# docker commit odl_controller odl-ubuntu-f:1.0
# docker tag odl-ubuntu-f:1.0 taothong/odl-ubuntu-f:1.0
# docker push taothong/odl-ubuntu-f:1.0


# ------------------------------------------------------------------------------
# ovs-vsctl show
# ovs-vsctl add-br br1
# ovs-vsctl add-br br0 -- set bridge br0 datapath_type=netdev
# ovs-vsctl del-br br0
# ovs-vsctl del-br br1

# ovs-vsctl show
# ip addr show br1

# ---------- ดู ip interface ----------
# ip -br a
# ip addr
# ovs-ofctl show br1