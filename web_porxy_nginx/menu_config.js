const appConfig = {
    title: "",
    menus: [
        {
            name: "Home",
            url: "home.html", 
            active: true
        },
        {
            name: "Jupyter",
            url: "/jupyter/",
            // url: "http://jupyter:8888/jupyter/lab",
            // url: "http://localhost:8888/jupyter/lab",
            active: false
        },
        {
            name: "AI(LLM)",
            url: "http://localhost:8877",
            active: false
        },
        {
            name: "White_board",
            // url: "/wbo",
            url: "http://localhost:5001",
            active: false
        },
        {
            name: "obsidian",
            url: "http://localhost:3000",
            active: false
        },
        {
            name: "Desktop",
            url: "http://localhost:3100",
            active: false
        }        
    ]
};