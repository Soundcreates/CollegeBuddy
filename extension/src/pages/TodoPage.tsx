
import { useEffect, useState } from "react";
import type { GmailMessage } from "../types/types";
import { getGmailMessage } from "../api/backendApi";

interface TodoPageProps {
    mailId: string;
    onBack: () => void;
}

function TodoPage({ mailId, onBack }: TodoPageProps) {
    const [message, setMessage] = useState<GmailMessage | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchMessage = async () => {
            try {
                setLoading(true);
                setError(null);
                
                // Get token from chrome storage
                const result = await new Promise<{ token?: string }>((resolve) => {
                    if (typeof chrome !== "undefined" && chrome.storage) {
                        chrome.storage.local.get(["token"], (items) => {
                            resolve(items);
                        });
                    } else {
                        resolve({});
                    }
                });

                if (!result.token) {
                    setError("Authentication token not found");
                    return;
                }

                const response = await getGmailMessage(mailId, result.token);
                
                if (response.success && response.message) {
                    setMessage(response.message);
                } else {
                    setError("Failed to fetch message details");
                }
            } catch (err) {
                console.error("Error fetching message:", err);
                setError("Failed to load message. Please try again.");
            } finally {
                setLoading(false);
            }
        };

        fetchMessage();
    }, [mailId]);

    const decodeBase64 = (data: string): string => {
        try {
            // Gmail API returns base64url encoded data, need to convert to regular base64
            const base64 = data.replace(/-/g, '+').replace(/_/g, '/');
            return atob(base64);
        } catch (e) {
            console.error("Error decoding base64:", e);
            return data;
        }
    };

    if (loading) {
        return (
            <div className="extension-popup brutalism-container">
                <div className="brutalism-card">
                    <button 
                        className="brutalism-btn brutalism-btn-secondary mb-2"
                        onClick={onBack}
                    >
                        ← Back
                    </button>
                    <p className="brutalism-text">Loading message...</p>
                </div>
            </div>
        );
    }

    if (error || !message) {
        return (
            <div className="extension-popup brutalism-container">
                <div className="brutalism-card">
                    <button 
                        className="brutalism-btn brutalism-btn-secondary mb-2"
                        onClick={onBack}
                    >
                        ← Back
                    </button>
                    <p className="brutalism-text text-red-600">{error || "Message not found"}</p>
                </div>
            </div>
        );
    }

    return (
        <div className="extension-popup brutalism-container">
            <div className="brutalism-card">
                <button 
                    className="brutalism-btn brutalism-btn-secondary mb-2 text-xs"
                    onClick={onBack}
                >
                    ← Back
                </button>

                <h1 className="brutalism-title text-sm mb-2">Mail Details</h1>

                <div className="space-y-2 overflow-y-auto max-h-[350px] hide-scrollbar">
                    {/* Date */}
                    <div className="border-2 border-black p-2">
                        <p className="brutalism-text font-bold text-[10px] mb-1">Date:</p>
                        <p className="brutalism-text text-xs">{message.date}</p>
                    </div>

                    {/* Subject */}
                    <div className="border-2 border-black p-2">
                        <p className="brutalism-text font-bold text-[10px] mb-1">Subject:</p>
                        <p className="brutalism-text text-xs break-words">{message.subject}</p>
                    </div>

                    {/* From */}
                    <div className="border-2 border-black p-2">
                        <p className="brutalism-text font-bold text-[10px] mb-1">From:</p>
                        <p className="brutalism-text text-xs break-words">{message.from}</p>
                    </div>

                    {/* To */}
                    {message.to && (
                        <div className="border-2 border-black p-2">
                            <p className="brutalism-text font-bold text-[10px] mb-1">To:</p>
                            <p className="brutalism-text text-xs break-words">{message.to}</p>
                        </div>
                    )}

                    {/* Snippet */}
                    {message.snippet && (
                        <div className="border-2 border-black p-2">
                            <p className="brutalism-text font-bold text-[10px] mb-1">Preview:</p>
                            <p className="brutalism-text text-xs break-words">{message.snippet}</p>
                        </div>
                    )}

                    {/* Body */}
                    {message.body && (
                        <div className="border-2 border-black p-2">
                            <p className="brutalism-text font-bold text-[10px] mb-1">Message:</p>
                            <div 
                                className="brutalism-text text-xs break-words"
                                dangerouslySetInnerHTML={{ __html: decodeBase64(message.body) }}
                            />
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}

export default TodoPage;