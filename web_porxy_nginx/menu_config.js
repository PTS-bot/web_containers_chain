const appConfig = {
    title: "My Network Controller",
    menus: [
        {
            name: "Home (Login)",
            url: "home.html", 
            active: true
        },
        {
            name: "Hawtio (ODL)",
            url: "/hawtio/",
            // url: "/proxy/8181/hawtio/",
            active: false
        },
        {
            name: "API (ODL)",
            url: "http://localhost:8181/rests/data/ietf-yang-library:modules-state",
            active: false
        },
        {
            name: "Jupyter Lab",
            // url: "/proxy/8888/lab",
            // url: "http://localhost:8888",
            url: "/jupyter/lab",

            active: false
        },
        {
            // (อนาคต) Web App ใหม่ อยู่ Port 9000
            name: "Simulated Web",
            // url: "http://localhost:8080",    
            url: "https://reg.rbru.ac.th/registrar2/login.asp", 

            // url: "https://www.google.com",
            // url: "http://localhost:8181/hawtio/",
            // url: "http://localhost:8181/hawtio/auth/login.html",
            // url: "http://localhost:8181/rests/data/ietf-yang-library:modules-state",
            // url: "http://host.docker.internal:8181/hawtio", 
            active: false
        }
    ]
};