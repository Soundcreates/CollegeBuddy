import axios from "axios";

const server = axios.create({
    baseURL: "http://localhost:8080",
    withCredentials: true,
});

// Token refresh function
export async function refreshAccessToken(refreshToken: string): Promise<{ access_token: string; refresh_token: string }> {
    try {
        const response = await server.post("/api/auth/refresh", {
            refresh_token: refreshToken
        });
        
        if (response.data.success) {
            return {
                access_token: response.data.access_token,
                refresh_token: response.data.refresh_token
            };
        } else {
            throw new Error(response.data.message || "Failed to refresh token");
        }
    } catch (error) {
        console.error("Token refresh failed:", error);
        throw error;
    }
}

// Add axios interceptor to automatically handle token refresh
server.interceptors.response.use(
    (response) => response,
    async (error) => {
        const originalRequest = error.config;
        
        if (error.response?.status === 401 && !originalRequest._retry) {
            originalRequest._retry = true;
            
            try {
                // Get tokens from chrome storage
                const result = await new Promise<{ token?: string; refreshToken?: string }>((resolve) => {
                    if (typeof chrome !== "undefined" && chrome.storage) {
                        chrome.storage.local.get(["token", "refreshToken"], (items: { [key: string]: any }) => {
                            resolve(items as { token?: string; refreshToken?: string });
                        });
                    } else {
                        resolve({});
                    }
                });
                
                if (result.refreshToken) {
                    const tokens = await refreshAccessToken(result.refreshToken);
                    
                    // Update stored tokens
                    if (typeof chrome !== "undefined" && chrome.storage) {
                        chrome.storage.local.set({
                            token: tokens.access_token,
                            refreshToken: tokens.refresh_token
                        });
                    }
                    
                    // Retry the original request with new token
                    originalRequest.headers['Authorization'] = `Bearer ${tokens.access_token}`;
                    return server(originalRequest);
                }
            } catch (refreshError) {
                console.error("Token refresh failed:", refreshError);
                // Clear authentication and redirect to login
                if (typeof chrome !== "undefined" && chrome.storage) {
                    chrome.storage.local.clear();
                }
                // Let the application handle the authentication failure
            }
        }
        
        return Promise.reject(error);
    }
);

export default server;