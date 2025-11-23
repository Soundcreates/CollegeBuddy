import server from "../api/backendApi";


async function main() {
    const res = await server.get("/api/auth/google/callback");


    const user = res.data;
    
    chrome.storage.local.set({
        isAuthenticated: true,
        user,
        token: user.token
    })


}