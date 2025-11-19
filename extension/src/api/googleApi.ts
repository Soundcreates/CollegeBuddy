import server from "./backendApi";

async function handleGoogleAuth() {
    try {
        const response = await server.post("/api/auth/OAuth");
        console.log("OAuth response:", response.data);
        
        if (response.data.success && response.data.oauth_url) {
            // Check if we're in a Chrome extension environment
            if (typeof chrome !== 'undefined' && chrome.tabs) {
                // Open the OAuth URL in a new tab
                chrome.tabs.create({ url: response.data.oauth_url });
                
            } else {
                // Fallback for development - open in new window
                window.open(response.data.oauth_url, '_blank');
            }
        }
    } catch (err) {
        console.error("Error during Google OAuth:", err);
    }
}

export { handleGoogleAuth };