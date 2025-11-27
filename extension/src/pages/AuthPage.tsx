/// <reference types="chrome" />

import { useState, useEffect } from 'react';
import Dashboard from './Dashboard';

interface User {
    id: number;
    name: string;
    svv_email: string;
    profile_pic: string;
}

interface OAuthMessage {
    type: string;
    user?: User;
    token?: string;
}

function AuthPage() {
    const [isAuthenticated, setIsAuthenticated] = useState<boolean>(false);
    const [user, setUser] = useState<User | null>(null);
    const [loading, setLoading] = useState(true);
    const [authLoading, setAuthLoading] = useState(false);

    useEffect(() => {
        // Check if we're in a Chrome extension environment
        if (typeof chrome === 'undefined' || !chrome.storage) {
            console.error('Chrome extension API not available');
            setLoading(false);
            return;
        }

        // Check existing authentication
        chrome.storage.local.get(['isAuthenticated', 'user', 'token'], (result) => {
            if (result.isAuthenticated && result.user && result.token) {
                setIsAuthenticated(true);
                setUser(result.user as User); // same reason down there
            }
            setLoading(false);
        });

        // Listen for authentication success
        const messageListener = (message: OAuthMessage) => {
            if (message.type === 'USER_OAUTH_SUCCESSFUL') {
                setIsAuthenticated(true);
                setUser(message.user as User); // we doin the 'as User' thingy just to be double sure or for nerds this called type assertion type shi
                setAuthLoading(false);
            }
        };

        chrome.runtime.onMessage.addListener(messageListener);

        return () => {
            chrome.runtime.onMessage.removeListener(messageListener);
        };
    }, []);

    const handleGoogleLogin = () => {
        console.log("Starting Google OAuth...");
        
        // Check if we're in a Chrome extension hood
        if (typeof chrome === 'undefined' || !chrome.runtime) {
            console.error('Chrome extension API not available');
            alert('This feature only works in the Chrome extension environment');
            return;
        }

        setAuthLoading(true);
        
        chrome.runtime.sendMessage({ type: 'START_OAUTH' }, (response) => {
            console.log('OAuth response:', response);
            if (!response?.success) {
                console.error('OAuth failed:', response?.error);
                setAuthLoading(false);
                alert('Failed to start OAuth: ' + (response?.error || 'Unknown error'));
            }
            //  We don set loading to false here because we waitin for the callback
        });
    };

    const handleLogout = () => {
        if (typeof chrome !== 'undefined' && chrome.storage) {
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
                </div>
            </div>
        );
    }

    if (isAuthenticated && user) {
        return <Dashboard user={user} onLogout={handleLogout} />;
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