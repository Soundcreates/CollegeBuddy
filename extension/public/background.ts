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
  refreshToken?: string;
}

const API_BASE_URL =
  import.meta.env.VITE_MODE === "development"
    ? import.meta.env.VITE_API_BASE_URL
    : import.meta.env.VITE_API_PROD_URL;

// Listen for messages from popup
chrome.runtime.onMessage.addListener(
  (message: OAuthMessage, sender, sendResponse) => {
    console.log("Message received in background:", message);

    if (message.type === "START_OAUTH") {
      handleOAuth(sendResponse);
      return true;
    }

    if (message.type === "OAUTH_SUCCESS") {
      console.log(
        "OAuth is successful, this log is coming from background:",
        message,
      );

      chrome.storage.local.set(
        {
          user: message.user,
          token: message.token,
          refreshToken: message.refreshToken,
          isAuthenticated: true,
        },
        () => {
          chrome.runtime.sendMessage({
            type: "USER_OAUTH_SUCCESSFUL",
            user: message.user,
            token: message.token,
            refreshToken: message.refreshToken,
          });
          sendResponse({ success: true });
        },
      );
      return true;
    }

    if (message.type === "START_GMAIL_SCRAPE") {
      // Get token from storage and start scraping
      chrome.storage.local.get(["token"], (result) => {
        if (result.token && typeof result.token === "string") {
          scrapeGmail(result.token as string)
            .then((data) => {
              sendResponse({ success: true, data: data });
            })
            .catch((error) => {
              sendResponse({ success: false, error: error.message });
            });
        } else {
          sendResponse({
            success: false,
            error: "No OAuth token found. Please authenticate first.",
          });
        }
      });
      return true; // Keep message channel open for async response
    }
  },
);

// Listen for messages from external pages (the callback page)
chrome.runtime.onMessageExternal.addListener(
  (message: OAuthMessage, sender, sendResponse) => {
    console.log("External message received:", message, "from:", sender);

    if (
      message.type === "OAUTH_SUCCESS" &&
      sender.url &&
      sender.url.includes("localhost:8080")
    ) {
      console.log("OAuth success from callback page:", message);

      chrome.storage.local.set(
        {
          user: message.user,
          token: message.token,
          refreshToken: message.refreshToken,
          isAuthenticated: true,
        },
        () => {
          chrome.runtime.sendMessage({
            type: "USER_OAUTH_SUCCESSFUL",
            user: message.user,
            token: message.token,
            refreshToken: message.refreshToken,
          });
          sendResponse({ success: true });
        },
      );
      return true;
    }
  },
);

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
        },
      );
    } else {
      console.error("Failed to get OAuth URL:", data);
      sendResponse({ success: false, error: "Failed to get OAuth URL" });
    }
  } catch (error: unknown) {
    console.error("OAuth error:", error);
    const errorMessage =
      error instanceof Error ? error.message : "Unknown error";
    sendResponse({
      success: false,
      error: `Backend connection failed: ${errorMessage}. Make sure your Go server is running on port 8080.`,
    });
  }
}

async function scrapeGmail(token: string) {
  try {
    console.log("Starting gmail scraping...");

    const response = await fetch("http://localhost:8080/api/scrape/gmail", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const data = await response.json();
    console.log("Gmail scraping successful:", data);

    // Store the scraped emails in chrome storage for  extension to access
    chrome.storage.local.set({
      gmailData: data,
      lastScrapeTime: new Date().toISOString(),
    });

    // Notify popup that scraping is complete
    chrome.runtime.sendMessage({
      type: "GMAIL_SCRAPE_SUCCESS",
      data: data,
    });

    return data;
  } catch (error) {
    console.error("Gmail scraping error:", error);
    const errorMessage =
      error instanceof Error ? error.message : "Unknown error";

    // Notify popup about the error
    chrome.runtime.sendMessage({
      type: "GMAIL_SCRAPE_ERROR",
      error: errorMessage,
    });

    throw error;
  }
}
