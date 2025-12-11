/// <reference types="chrome" />

import { useState, useEffect } from "react";
import Dashboard from "./Dashboard";
import { scrapeGmailEmails } from "../api/googleApi";
interface User {
  id: number;
  name: string;
  svv_email: string;
  profile_pic: string;
}

interface GmailData {
  messages: Array<{
    id: string;
    subject: string;
    from: string;
    date: string;
    body: string;
    snippet: string;
  }>;
  nextPageToken?: string;
  resultSizeEstimate: number;
}

type  OAuthMessage = {
  type: string;
  user?: User;
  token?: string;
  refreshToken?: string;
}

type  GmailScrapedMessage  = {
    type: string;
    data?: GmailData;
    error?: string;
}
function AuthPage() {
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false);
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [authLoading, setAuthLoading] = useState(false);
  const [gmailData, setGmailData] = useState<GmailData | null>(null);
  const [scrapingLoading, setScrapingLoading] = useState(false);

  useEffect(() => {
    // Check if we're in a Chrome extension environment
    if (typeof chrome === "undefined" || !chrome.storage) {
      console.error("Chrome extension API not available");
      setLoading(false);
      return;
    }

    // Check existing authentication
    chrome.storage.local.get(["isAuthenticated", "user", "token", "refreshToken"], (result) => {
      if (result.isAuthenticated && result.user && result.token) {
        setIsAuthenticated(true);
        setUser(result.user as User);
        // Start Gmail scraping only after confirming authentication
        handleGmailScrape();
      }
      setLoading(false);
    });

    // Listen for authentication success
    const messageListener = (message: OAuthMessage | GmailScrapedMessage) => {
      if (message.type === "USER_OAUTH_SUCCESSFUL") {
        const oauthMessage = message as OAuthMessage;
        setIsAuthenticated(true);
        setUser(oauthMessage.user as User);
        setAuthLoading(false);
        // Start Gmail scraping after successful OAuth
        handleGmailScrape();
      }

      if (message.type === "GMAIL_SCRAPE_SUCCESS") {
        const gmailMessage = message as GmailScrapedMessage;
        console.log("Gmail scrape successful:", gmailMessage.data);
        if (gmailMessage.data) {
          setGmailData(gmailMessage.data);
          setScrapingLoading(false);
        }
      }

      if (message.type === "GMAIL_SCRAPE_ERROR") {
        const gmailMessage = message as GmailScrapedMessage;
        console.error("Gmail scrape error:", gmailMessage.error);
        setScrapingLoading(false);
      }
    };

    chrome.runtime.onMessage.addListener(messageListener);

    return () => {
      chrome.runtime.onMessage.removeListener(messageListener);
    };
  }, []); // Remove isAuthenticated dependency to avoid infinite loops

  const handleGmailScrape = async () => {
    try {
      setScrapingLoading(true);
      console.log("Starting Gmail scraping...");
      const gmailResult = await scrapeGmailEmails();
      setGmailData(gmailResult);
      console.log("Gmail data received:", gmailResult);
      
      // Store in chrome storage for persistence
      if (typeof chrome !== "undefined" && chrome.storage) {
        chrome.storage.local.set({ gmailData: gmailResult });
      }
    } catch (error) {
      console.error("Failed to scrape Gmail:", error);
    } finally {
      setScrapingLoading(false);
    }
  };

  const handleGoogleLogin = () => {
    console.log("Starting Google OAuth...");

    // Check if we're in a Chrome extension hood
    if (typeof chrome === "undefined" || !chrome.runtime) {
      console.error("Chrome extension API not available");
      alert("This feature only works in the Chrome extension environment");
      return;
    }

    setAuthLoading(true);

    chrome.runtime.sendMessage({ type: "START_OAUTH" }, (response) => {
      console.log("OAuth response:", response);
      if (!response?.success) {
        console.error("OAuth failed:", response?.error);
        setAuthLoading(false);
        alert("Failed to start OAuth: " + (response?.error || "Unknown error"));
      }
      //  We don set loading to false here because we waitin for the callback
    });
  };

  const handleLogout = () => {
    if (typeof chrome !== "undefined" && chrome.storage) {
      chrome.storage.local.clear(() => {
        setIsAuthenticated(false);
        setUser(null);
      });
    }
  };

  if (loading) {
    return (
      <div className="extension-popup brutalism-container">
        <div className="brutalism-card">
          <h1 className="brutalism-title">Loading...</h1>
          {scrapingLoading && (
            <p className="brutalism-text">Fetching Gmail data...</p>
          )}
        </div>
      </div>
    );
  }

  if (isAuthenticated && user) {
    return (
      <Dashboard 
        user={user} 
        onLogout={handleLogout}
        gmailData={gmailData}
        scrapingLoading={scrapingLoading}
        onRefreshGmail={handleGmailScrape}
      />
    );
  }

  return (
    <div className="extension-popup brutalism-container">
      <div className="brutalism-card">
        <h1 className="brutalism-title">College Buddy</h1>
        <p className="brutalism-subtitle">Hitting deadlines made easier</p>

        <button
          className="brutalism-btn brutalism-btn-primary"
          onClick={handleGoogleLogin}
          disabled={authLoading}
        >
          {authLoading ? "Opening Google..." : "Get Started!"}
        </button>

        {authLoading && (
          <p className="brutalism-text mt-2">
            Please complete the authorization in the new tab
          </p>
        )}
      </div>
    </div>
  );
}

export default AuthPage;
