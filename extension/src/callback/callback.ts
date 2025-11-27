/// <reference types="chrome" />

// Get URL parameters
const urlParams = new URLSearchParams(window.location.search);
const success = urlParams.get('success');
const error = urlParams.get('error');
const token = urlParams.get('token');
const userParam = urlParams.get('user');

const statusDiv = document.getElementById('status')!;

if (success === 'true' && token && userParam) {
    try {
        // Parse user data
        const user = JSON.parse(decodeURIComponent(userParam));
        
        // Store authentication data
        chrome.storage.local.set({
            isAuthenticated: true,
            user: user,
            token: token
        }, () => {
            statusDiv.innerHTML = '<div class="success">✅ Authentication successful! You can close this tab.</div>';
            
            // Notify the extension popup
            chrome.runtime.sendMessage({
                type: 'OAUTH_SUCCESS',
                user: user,
                token: token
            }, (response) => {
                console.log('Response from background:', response);
                // Close the tab after a delay
                setTimeout(() => {
                    window.close();
                }, 2000);
            });
        });
    } catch (err) {
        console.error('Error parsing user data:', err);
        statusDiv.innerHTML = '<div class="error"> Error processing user data</div>';
    }
} else {
    // Handle error cases
    let errorMessage = 'Unknown error occurred';
    
    switch (error) {
        case 'no_code':
            errorMessage = 'Authorization code not received';
            break;
        case 'token_exchange':
            errorMessage = 'Failed to exchange code for token';
            break;
        case 'user_info':
            errorMessage = 'Failed to get user information';
            break;
        case 'invalid_domain':
            errorMessage = 'Please use your @somaiya.edu email address';
            break;
        case 'create_user':
            errorMessage = 'Failed to create user account';
            break;
        case 'jwt_generation':
            errorMessage = 'Failed to generate authentication token';
            break;
        default:
            errorMessage = 'Authentication failed';
    }
    
    statusDiv.innerHTML = `<div class="error"> ${errorMessage}</div>`;
    
    // Close tab after showing error
    setTimeout(() => {
        window.close();
    }, 3000);
}