import server from "./backendApi";
import type { GmailMessage } from "../types/types";

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


interface GmailScrapeResponse {
  success: boolean;
  messages: GmailMessage[];
  count: number;
}

async function scrapeGmailEmails(): Promise<GmailScrapeResponse> {
    return new Promise((resolve, reject) => {
        if (typeof chrome !== "undefined" && chrome.runtime) {
            chrome.runtime.sendMessage(
                { type: "START_GMAIL_SCRAPE" },
                (response) => {
                    if (chrome.runtime.lastError) {
                        reject(new Error(chrome.runtime.lastError.message));
                        return;
                    }

                    if (response.success) {
                        resolve(response.data);
                    } else {
                        reject(new Error(response.error));
                    }
                }
            );
        } else {
            reject(new Error("Chrome runtime not available"));
        }
    });
}

export { handleGoogleAuth, scrapeGmailEmails };