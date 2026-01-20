const appConfig = {
    title: "",
    menus: [
        // {
        //     name: "Desktop",
        //     url: "http://localhost:3100",
        //     active: false
        // },
        {
            id: "white_board",
            name: "White board",
            icon: "fas fa-pen-nib",
            // url: "/White_board/",
            url: "http://localhost:5001",
            active: false
        },        
        {
            id: "obsidian",  
            name: "obsidian",
            icon: "fas fa-sticky-note",
            url: "/obsidian/",
            // url: "http://localhost:3000",
            active: false
        },

        // {
        //     name: "Home",
        //     url: "home.html", 
        //     active: true
        // },

        {
            id: "jupyter",
            name: "Jupyter I",
            icon: "fas fa-code",
            url: "/jupyter/",
            // url: "http://jupyter:8888/jupyter/lab",
            // url: "http://localhost:8888/jupyter/lab",
            active: false
        },
        {
            id: "jupyter2",
            name: "Jupyter II",
            icon: "fas fa-code",
            url: "/jupyter2/",
            // url: "http://jupyter2:8888/jupyter/lab",
            active: false
        },
        {
            id: "ai_llm",
            name: "AI(LLM)",
            icon: "fas fa-robot",
            // url: "/open-webui/",
            url: "http://localhost:8877",
            active: false
        },
        { 
            id: 'manage_users',       // ID สำหรับเช็ค Permission ใน DB
            name: 'Admin Panel', 
            icon: 'fas fa-users-cog', 
            url: 'admin-view.html',   // ไฟล์ HTML ที่จะโหลดใส่ Iframe
            adminOnly: true           // (Custom Flag) ระบุว่าเฉพาะ Admin
        },       
    ]
};