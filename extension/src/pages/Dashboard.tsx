
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
                <h1 className="brutalism-title">Welcome!</h1>
                
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