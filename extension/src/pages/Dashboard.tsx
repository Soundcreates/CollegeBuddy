interface User {
    id: number;
    name: string;
    svv_email: string;
    profile_pic: string;
}

interface DashboardProps {
    user: User;
    onLogout: () => void;
}

function Dashboard({ user, onLogout }: DashboardProps) {
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