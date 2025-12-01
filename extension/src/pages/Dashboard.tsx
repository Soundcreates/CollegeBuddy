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

interface DashboardProps {
    user: User;
    onLogout: () => void;
    gmailData: GmailData | null;
    scrapingLoading: boolean;
    onRefreshGmail: () => Promise<void>;
}

function Dashboard({ user, onLogout, gmailData, scrapingLoading, onRefreshGmail }: DashboardProps) {
    return (
        <div className="extension-popup brutalism-container">
            <div className="brutalism-card">
                <h1 className="brutalism-title my-10">Welcome!</h1>
                
                <div className="flex items-center mb-4">
                    {user.profile_pic && (
                        <img 
                            src={user.profile_pic} 
                            alt="Profile" 
                            className="w-12 h-12 rounded-full mr-3"
                        />
                    )}
                    <div>
                        <p className="brutalism-text font-bold">{user.name}</p>
                        <p className="brutalism-text text-sm">{user.svv_email}</p>
                    </div>
                </div>

                {/* Gmail Section */}
                <div className="mt-6">
                    <div className="flex justify-between items-center mb-4">
                        <h2 className="brutalism-subtitle">Gmail Inbox</h2>
                        <button 
                            className="brutalism-btn brutalism-btn-secondary"
                            onClick={onRefreshGmail}
                            disabled={scrapingLoading}
                        >
                            {scrapingLoading ? "Loading..." : "Refresh"}
                        </button>
                    </div>

                    {scrapingLoading && (
                        <p className="brutalism-text">Fetching your emails...</p>
                    )}

                    {gmailData && !scrapingLoading && (
                        <div className="gmail-list">
                            <p className="brutalism-text mb-3">
                                Found {gmailData.messages.length} emails
                            </p>
                            <div className="max-h-60 overflow-y-auto">
                                {gmailData.messages.map((email) => (
                                    <div key={email.id} className="border-b border-gray-300 pb-2 mb-2">
                                        <p className="font-bold text-sm">{email.subject || "No Subject"}</p>
                                        <p className="text-xs text-gray-600">{email.from}</p>
                                        <p className="text-xs text-gray-500">{new Date(email.date).toLocaleDateString()}</p>
                                        <p className="text-xs mt-1">{email.snippet}</p>
                                    </div>
                                ))}
                            </div>
                        </div>
                    )}

                    {!gmailData && !scrapingLoading && (
                        <p className="brutalism-text text-gray-500">
                            No Gmail data available. Click refresh to load emails.
                        </p>
                    )}
                </div>

                {/* Todo List Box */}
                <div className="todo-box">
                    <h2 className="todo-title">TODAY'S TASKS</h2>
                    <div className="todo-list">
                        <div className="todo-item">
                            <input type="checkbox" className="todo-checkbox" />
                            <span className="todo-text">Complete Data Structures Assignment</span>
                        </div>
                        <div className="todo-item">
                            <input type="checkbox" className="todo-checkbox" />
                            <span className="todo-text">Submit Project Report</span>
                        </div>
                        <div className="todo-item">
                            <input type="checkbox" className="todo-checkbox" />
                            <span className="todo-text">Prepare for Database Exam</span>
                        </div>
                        <div className="todo-item">
                            <input type="checkbox" className="todo-checkbox" />
                            <span className="todo-text">Attend Team Meeting at 3 PM</span>
                        </div>
                        <div className="todo-item">
                            <input type="checkbox" className="todo-checkbox" />
                            <span className="todo-text">Review Operating Systems Notes</span>
                        </div>
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