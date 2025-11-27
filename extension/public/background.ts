/// <reference types = "chrome" />

console.log("Background script loaded!");

interface OAuthResponse {
  success: boolean;
  error?: string;
  tabId?: number;
}

interface OAuthMessage {
  type: string;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  user?: any;
  token?: string;
}

// Listen for messages from popup
chrome.runtime.onMessage.addListener((message: OAuthMessage, sender, sendResponse) => {
  console.log("Message received in background:", message);

  if (message.type === "START_OAUTH") {
    handleOAuth(sendResponse);
    return true;
  }

  if (message.type === "OAUTH_SUCCESS") {
    console.log("OAuth is successful, this log is coming from background:", message);
    
    chrome.storage.local.set(
      {
        user: message.user,
        token: message.token,
        isAuthenticated: true,
      },
      () => {
        chrome.runtime.sendMessage({
          type: "USER_OAUTH_SUCCESSFUL",
          user: message.user,
          token: message.token
        });
        sendResponse({ success: true });
      }
    );
    return true;
  }
});

// Listen for messages from external pages (the callback page)
chrome.runtime.onMessageExternal.addListener((message: OAuthMessage, sender, sendResponse) => {
  console.log("External message received:", message, "from:", sender);
  
  if (message.type === "OAUTH_SUCCESS" && sender.url && sender.url.includes("localhost:8080")) {
    console.log("OAuth success from callback page:", message);
    
    chrome.storage.local.set(
      {
        user: message.user,
        token: message.token,
        isAuthenticated: true,
      },
      () => {
        chrome.runtime.sendMessage({
          type: "USER_OAUTH_SUCCESSFUL",
          user: message.user,
          token: message.token
        });
        sendResponse({ success: true });
      }
    );
    return true;
  }
});

async function handleOAuth(sendResponse: (response: OAuthResponse) => void) {
  try {
    console.log("Starting OAuth flow....");
    
    const response = await fetch("http://localhost:8080/api/auth/OAuth", {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
      },
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const data = await response.json();
    console.log("OAuth URL response:", data);

    if (data.success && data.oauth_url) {
      chrome.tabs.create(
        {
          url: data.oauth_url,
          active: true,
        },
        (tab) => {
          console.log("OAuth tab created:", tab?.id);
          sendResponse({ success: true, tabId: tab?.id });
        }
      );
    } else {
      console.error("Failed to get OAuth URL:", data);
      sendResponse({ success: false, error: "Failed to get OAuth URL" });
    }
  } catch (error: unknown) {
    console.error("OAuth error:", error);
    const errorMessage = error instanceof Error ? error.message : "Unknown error";
    sendResponse({ 
      success: false, 
      error: `Backend connection failed: ${errorMessage}. Make sure your Go server is running on port 8080.`
    });
  }
}