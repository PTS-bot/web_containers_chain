const express = require('express');
const bodyParser = require('body-parser');
const session = require('express-session');
const cors = require('cors');
const mongoose = require('mongoose'); // เรียกใช้ Mongoose

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());
app.use(express.static('public'));
app.use(session({
    secret: 'secret-key-mongo-change-this',
    resave: false,
    saveUninitialized: true
}));

// ==========================================
// 🍃 MONGODB CONNECTION & SCHEMAS
// ==========================================
// เชื่อมต่อ MongoDB (ชื่อ host คือ 'mongo' ตามชื่อ service ใน docker-compose)
mongoose.connect('mongodb://mongo:27017/auth_system')
    .then(() => console.log('✅ Connected to MongoDB'))
    .catch(err => console.error('❌ MongoDB Connection Error:', err));

// 1. สร้าง Schema สำหรับ User
const userSchema = new mongoose.Schema({
    username: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    role: { type: String, default: 'user' },
    status: { type: String, default: 'pending' },
    groups: { type: [String], default: [] }, // Array ของชื่อกลุ่ม
    permissions: { type: [String], default: [] }
});

// 2. สร้าง Schema สำหรับ Group
const groupSchema = new mongoose.Schema({
    name: { type: String, required: true, unique: true },
    permissions: { type: [String], default: [] }
});

const User = mongoose.model('User', userSchema);
const Group = mongoose.model('Group', groupSchema);

// ==========================================
// 🔥 SYSTEM INITIALIZATION (สร้าง Admin/Group แรก)
// ==========================================
async function initSystem() {
    try {
        // สร้าง Group 'General' ถ้ายังไม่มี
        const groupCount = await Group.countDocuments();
        if (groupCount === 0) {
            await Group.create({ name: 'General', permissions: [] });
            console.log("System: Default Group 'General' Created");
        }

        // สร้าง Superadmin ถ้ายังไม่มี
        const admin = await User.findOne({ username: 'admin' });
        if (!admin) {
            await User.create({
                username: 'admin',
                password: 'admin',
                role: 'superadmin',
                status: 'approved',
                groups: ['General'],
                permissions: ['all']
            });
            console.log("System: Default Superadmin Created");
        } else {
            // Force Update Admin (กันพลาด)
            if (admin.role !== 'superadmin') {
                admin.role = 'superadmin';
                admin.status = 'approved';
                await admin.save();
                console.log("System: Admin fixed to Superadmin");
            }
        }
    } catch (e) {
        console.error("Init Error:", e);
    }
}
// รอให้ต่อ DB ติดก่อนค่อย Init
mongoose.connection.once('open', initSystem);

// ==========================================
// 🛠️ HELPER FUNCTIONS
// ==========================================
async function getCombinedPermissions(user) {
    let perms = new Set(user.permissions || []);
    
    // ดึง Permission จาก Group ที่ User อยู่
    if (user.groups && user.groups.length > 0) {
        const groups = await Group.find({ name: { $in: user.groups } });
        groups.forEach(g => {
            g.permissions.forEach(p => perms.add(p));
        });
    }
    return Array.from(perms);
}

// ==========================================
// 🚀 API ROUTES
// ==========================================

// 1. Login
app.post('/api/login', async (req, res) => {
    const { username, password } = req.body;
    try {
        const user = await User.findOne({ username, password });
        if (user) {
            if (!user.status) user.status = 'pending';
            
            const finalPermissions = await getCombinedPermissions(user);
            
            req.session.user = { 
                username: user.username, 
                role: user.role, 
                status: user.status, 
                groups: user.groups,
                permissions: finalPermissions
            };
            res.json({ success: true, user: req.session.user });
        } else {
            res.json({ success: false, message: 'Invalid credentials' });
        }
    } catch (e) { res.status(500).json({ success: false, message: e.message }); }
});
// ... (ต่อจาก app.post('/api/login' ...)

// ✅ API สำหรับการสมัครสมาชิกด้วยตัวเอง (Self-Register)
app.post('/api/register', async (req, res) => {
    const { username, password } = req.body;
    try {
        const existing = await User.findOne({ username });
        if (existing) return res.json({ success: false, message: 'Username already exists' });

        await User.create({
            username, 
            password, 
            role: 'user', 
            status: 'pending', // ⏳ สมัครเองต้องรออนุมัติ
            groups: [],
            permissions: []
        });
        res.json({ success: true });
    } catch (e) { res.json({ success: false, message: e.message }); }
});

// ... (ส่วนอื่นๆ เหมือนเดิม)
app.post('/api/logout', (req, res) => {
    req.session.destroy();
    res.json({ success: true });
});

// 2. User CRUD
app.get('/api/users', async (req, res) => {
    try {
        const users = await User.find({}, '-password'); // ไม่ส่ง password กลับไป
        res.json(users);
    } catch (e) { res.status(500).json([]); }
});

app.post('/api/create-user', async (req, res) => {
    const { username, password, group } = req.body;
    try {
        const existing = await User.findOne({ username });
        if (existing) return res.json({ success: false, message: 'User exists' });

        await User.create({
            username, 
            password, 
            role: 'user', 
            status: 'approved',
            groups: group ? [group] : []
        });
        res.json({ success: true });
    } catch (e) { res.json({ success: false, message: e.message }); }
});

app.post('/api/update-user', async (req, res) => {
    const { username, role, status, groups } = req.body;
    try {
        const updateData = {};
        if (role) updateData.role = role;
        if (status) updateData.status = status;
        if (groups) updateData.groups = groups;

        await User.findOneAndUpdate({ username }, updateData);
        res.json({ success: true });
    } catch (e) { res.json({ success: false, message: 'Update failed' }); }
});

app.post('/api/delete-user', async (req, res) => {
    const { username } = req.body;
    try {
        const user = await User.findOne({ username });
        if (user && user.role === 'superadmin') return res.json({ success: false, message: "Cannot delete Superadmin" });
        
        await User.deleteOne({ username });
        res.json({ success: true });
    } catch (e) { res.json({ success: false }); }
});

// 3. Group CRUD
app.get('/api/groups', async (req, res) => {
    try {
        const groups = await Group.find({});
        res.json(groups);
    } catch (e) { res.status(500).json([]); }
});

app.post('/api/create-group', async (req, res) => {
    const { name } = req.body;
    try {
        const existing = await Group.findOne({ name });
        if (existing) return res.json({ success: false, message: 'Group exists' });
        
        await Group.create({ name, permissions: [] });
        res.json({ success: true });
    } catch (e) { res.json({ success: false, message: e.message }); }
});

app.post('/api/update-group', async (req, res) => {
    const { name, permissions } = req.body;
    try {
        await Group.findOneAndUpdate({ name }, { permissions });
        res.json({ success: true });
    } catch (e) { res.json({ success: false }); }
});

app.post('/api/delete-group', async (req, res) => {
    const { name } = req.body;
    try {
        await Group.deleteOne({ name });
        // ลบชื่อ Group ออกจาก User ทุกคน (Pull from array)
        await User.updateMany(
            { groups: name },
            { $pull: { groups: name } }
        );
        res.json({ success: true });
    } catch (e) { res.json({ success: false }); }
});

// 4. Password Ops
app.post('/api/change-password', async (req, res) => {
    const { username, oldPassword, newPassword } = req.body;
    try {
        const user = await User.findOne({ username, password: oldPassword });
        if (user) {
            user.password = newPassword;
            await user.save();
            res.json({ success: true });
        } else {
            res.json({ success: false, message: 'Incorrect password' });
        }
    } catch (e) { res.json({ success: false, message: e.message }); }
});

app.post('/api/admin-reset-password', async (req, res) => {
    const { targetUsername, newPassword } = req.body;
    try {
        const user = await User.findOne({ username: targetUsername });
        if (user) {
            user.password = newPassword;
            await user.save();
            res.json({ success: true });
        } else {
            res.json({ success: false, message: 'User not found' });
        }
    } catch (e) { res.json({ success: false, message: e.message }); }
});

app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});