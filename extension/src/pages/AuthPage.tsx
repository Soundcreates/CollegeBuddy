import { useEffect, useState } from 'react';
import { handleGoogleAuth } from '../api/googleApi'

function AuthPage() {
    const[isLoggedIn, setIsLoggedIn]  = useState<boolean>(false);
    const [user, setUser] = useState<any | null>(null);
    const [authLoading  , setAuthLoading] = useState<boolean>(false);


    useEffect(()=>{
        chrome.storage.local.get(['access_token', 'user'], (result) => {
            if(result.access_token){
                setIsLoggedIn(true);
                setUser(result.user);
            }
        });

        const messageListener = (message : any) => {
            if(message.type === 'USER_LOGGED_IN'){
                setIsLoggedIn(true);
                setUser(message.user);
            }
        };


        chrome.runtime.onMessage.addListener(messageListener);

        return () => {
            chrome.runtime.onMessage.removeListener(messageListener);
        }
    },[])
        const handleGoogleClick = () => {
            setAuthLoading(true);
            console.log("Approaching Google..");
            chrome.tabs.create({
                url: "http://localhost:8080/api/auth/OAuth",
            });
           
        }
 return (
    <div className="extension-popup">
        <div className="brutalism-flex-center">
            <div className="brutalism-container">
                <h1 className="brutalism-title">College Buddy</h1> 
                <p className="brutalism-text">Hitting deadlines made easier</p>
                <button 
                </button>
            </div>
        </div>
    </div>
  )
}

export default AuthPage