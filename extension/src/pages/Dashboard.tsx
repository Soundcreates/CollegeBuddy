import type { GmailMessage } from "../types/types";
import { useState } from "react";
import TodoPage from "./TodoPage";

interface User {
    id: string;
    name: string;
    svv_email: string;
    profile_pic: string;
}

interface DashboardProps {
    user: User;
    onLogout: () => void;
    gmailData: GmailMessage[] | null;
    scrapingLoading: boolean;
    onRefreshGmail: () => Promise<void>;
}

function Dashboard({ user, onLogout, gmailData, scrapingLoading, onRefreshGmail }: DashboardProps) {

    const [selectedMailId, setSelectedMailId] = useState<string | null>(null);

    if (selectedMailId) {
        return <TodoPage mailId={selectedMailId} onBack={() => setSelectedMailId(null)} />;
    }
    
    return (
        
        <div className="extension-popup brutalism-container">
            <div className="brutalism-card">
                <h1 className="brutalism-title my-1">Welcome!</h1>
                
                <div className="flex items-center mb-1">
                    {user.profile_pic && (
                        <img 
                            src={user.profile_pic} 
                            alt="Profile" 
                            className="w-10 h-10 rounded-full mr-3"
                        />
                    )}
                    <div>
                        <p className="brutalism-text font-bold text-sm m-0">{user.name}</p>
                        <p className="brutalism-text text-xs m-0">{user.svv_email}</p>
                    </div>
                </div>

                {/* Gmail Section */}
                <div className="mt-1">
                    <div className="flex justify-between items-center mb-1">
                        <h2 className="brutalism-subtitle text-sm m-0">Gmail Inbox</h2>
                        <button 
                            className="brutalism-btn brutalism-btn-secondary text-[10px] px-2 py-0.5 m-0 w-auto"
                            onClick={onRefreshGmail}
                            disabled={scrapingLoading}
                        >
                            {scrapingLoading ? "..." : "↻"}
                        </button>
                    </div>
                </div>

                {/* Todo List Box */}
                <div className="todo-box flex flex-col flex-1 min-h-0 overflow-hidden">
                    <h2 className="todo-title text-xs mb-2">This Week's tasks</h2>
                    <div className="todo-list overflow-y-auto hide-scrollbar flex-1 max-h-[200px]">
                        {scrapingLoading ? (
                            <p className="brutalism-text text-xs">Loading tasks...</p>
                        ) : gmailData?.length === 0 ? (
                            <p className="brutalism-text text-xs">No tasks for this week!</p>
                        ) : (
                            gmailData?.map((email) => (
                                <div key={email.id} className="todo-item cursor-pointer" onClick={() => setSelectedMailId(email.id)}>
                                    <input type="checkbox" className="todo-checkbox w-3 h-3" />
                                    <span className="todo-text text-xs truncate">{email.subject}</span>
                                </div>
                            ))
                        )}
                   </div>
                </div>
                
                <button 
                    className="brutalism-btn brutalism-btn-secondary"
                    onClick={onLogout}
                >
                    Logout
                </button>
            </div>
        </div>
    );
}

export default Dashboard;