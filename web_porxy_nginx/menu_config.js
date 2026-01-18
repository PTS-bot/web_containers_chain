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
            name: "Pad.ws",
            url: "/jupyter/lab",
            active: false
        }
    ]
};