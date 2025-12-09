package handlers

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"somaiya-ext/internal/auth"
	"somaiya-ext/internal/models"
	"strings"
	"time"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"gorm.io/gorm"
)

const OauthStateString = "kjssecodecell"

type userGmailKey string

const user_gmail userGmailKey = "user_gmail"

func (h *Handler) getGoogleOauthConfig() *oauth2.Config {
	return &oauth2.Config{
		ClientID:     h.Config.OAUTH_CLIENT_ID,
		ClientSecret: h.Config.OAUTH_CLIENT_SECRET,
		RedirectURL:  "http://localhost:8080/api/auth/google/callback",
		Scopes: []string{
			"https://www.googleapis.com/auth/userinfo.email",
			"https://www.googleapis.com/auth/userinfo.profile",
			"https://www.googleapis.com/auth/gmail.readonly",
		},
		Endpoint: google.Endpoint,
	}
}
func (h *Handler) HandleGoogleLogin(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	googleOauthConfig := h.getGoogleOauthConfig()
	url := googleOauthConfig.AuthCodeURL(OauthStateString, oauth2.AccessTypeOffline)
	fmt.Println("Generated OAuth URL: ", url)
	response := map[string]interface{}{
		"success":   true,
		"oauth_url": url,
		"message":   "OAuth URL generated successfully",
	}

	json.NewEncoder(w).Encode(response)
}

// here in this googlecallback functionm, my main motto will be to get the user code and store teh access and refresh token in db
func (h *Handler) GoogleCallBack(w http.ResponseWriter, r *http.Request) {
	state := r.FormValue("state")
	if state != OauthStateString { //here i get the state from the url
		http.Error(w, "Invalid OAuth state", http.StatusBadRequest)
		return
	}
	//this is the code
	code := r.FormValue("code")
	if code == "" {
		http.Error(w, "Code not found", http.StatusBadRequest)
		return
	}
	//this is the token im exchanging
	// Create a context with a 10-second timeout for OAuth operations
	ctx, cancel := context.WithTimeout(r.Context(), 10*time.Second)
	defer cancel()

	googleOauthConfig := h.getGoogleOauthConfig()
	token, err := googleOauthConfig.Exchange(ctx, code)
	if err != nil {
		http.Error(w, "Token exchange failed: "+err.Error(), http.StatusInternalServerError)
		return
	}

	refreshToken := token.RefreshToken

	fmt.Println("Refresh Token: ", refreshToken)
	client := googleOauthConfig.Client(ctx, token)
	resp, err := client.Get("https://www.googleapis.com/oauth2/v2/userinfo")
	if err != nil {
		http.Error(w, "Failed to get user info: "+err.Error(), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	body, _ := io.ReadAll(resp.Body)

	var googleUser models.GoogleUser

	if err := json.Unmarshal(body, &googleUser); err != nil {
		http.Error(w, "Failed to parse user info: "+err.Error(), http.StatusInternalServerError)
		return
	}

	if !googleUser.VerifiedEmail {
		http.Error(w, "Unauthorized: Email domain not allowed", http.StatusUnauthorized)
		return
	}

	//handling only somaiya.edu to be allowed
	suffix := "somaiya.edu"

	if !strings.HasSuffix(googleUser.Email, suffix) {
		http.Error(w, "UnAuthorized: Only somaiya students are allowed", http.StatusUnauthorized)
		return
	}

	userInfo := models.Student{
		Name:          googleUser.Name,
		SVVEmail:      googleUser.Email,
		ProfilePic:    googleUser.Picture,
		VerifiedEmail: googleUser.VerifiedEmail,
		ORefreshToken: refreshToken,
		OAccessToken:  token.AccessToken,
	}

	var existingUser models.Student
	err = h.DB.Where("svv_email = ?", userInfo.SVVEmail).First(&existingUser).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			fmt.Println("Registering New User")
			h.register(w, r, userInfo)
			return
		}
		http.Error(w, "Database error: "+err.Error(), http.StatusInternalServerError)
		return
	}

	fmt.Println("Logging in Existing User")
	_, success, err := h.login(w, r, userInfo)

	if err != nil || !success {
		fmt.Println("Logging in failed,aborting...")
		return
	}

	cfg := h.Config

	if success {
		// Create a simple HTML callback page that communicates with the extension
		log.Println("Preparing OAuth success callback page")
		log.Println("Generating JWT token for user:", userInfo.SVVEmail)
		jwtToken, jwtErr := auth.SignJWt(userInfo, h.Config.JWT_SECRET)
		if jwtErr != nil {
			log.Println("Error creating jwt token")
			http.Error(w, "Failed to generate JWT token: "+jwtErr.Error(), http.StatusInternalServerError)
			return
		}
		callbackHTML := fmt.Sprintf(`
<!DOCTYPE html>
<html>
<head>
    <title>OAuth Callback</title>
</head>
<body>
    <div id="status">Authentication successful! You can close this tab.</div>
    <script>
        // Send message to extension
        if (window.chrome && chrome.runtime && chrome.runtime.sendMessage) {
            const extensionId = '%s';
            chrome.runtime.sendMessage(extensionId, {
                type: 'OAUTH_SUCCESS',
                user: %s,
                token: '%s'
            }, function(response) {
                if (chrome.runtime.lastError) {
                    console.log('Error:', chrome.runtime.lastError.message);
                } else {
                    console.log('Message sent to extension:', response);
                    // Close the tab after successful communication
                    window.close();
                }
            });
        }
        
        // Fallback: redirect to extension popup
        setTimeout(function() {
            window.close();
        }, 2000);
    </script>
</body>
</html>`, cfg.EXTENSION_ID, `{"email":"`+userInfo.SVVEmail+`", "name":"`+userInfo.Name+`"}`, jwtToken)

		w.Header().Set("Content-Type", "text/html")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(callbackHTML))
		return
	}
	// Handle error case
	errorHTML := fmt.Sprintf(`
<!DOCTYPE html>
<html>
<head>
    <title>OAuth Error</title>
</head>
<body>
    <div id="status">Authentication failed. Please try again.</div>
    <script>
        // Send error message to extension
        if (window.chrome && chrome.runtime && chrome.runtime.sendMessage) {
            const extensionId = '%s';
            chrome.runtime.sendMessage(extensionId, {
                type: 'OAUTH_ERROR',
                error: 'Authentication failed'
            }, function(response) {
                console.log('Error message sent to extension');
                window.close();
            });
        }
        
        setTimeout(function() {
            window.close();
        }, 3000);
    </script>
</body>
</html>`, cfg.EXTENSION_ID)

	w.Header().Set("Content-Type", "text/html")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(errorHTML))
}

func (h *Handler) login(w http.ResponseWriter, r *http.Request, userInfo models.Student) (string, bool, error) {
	w.Header().Set("Content-Type", "application/json")

	var foundStudent models.Student

	err := h.DB.Where("svv_email = ?", userInfo.SVVEmail).First(&foundStudent).Error

	if err != nil {
		http.Error(w, "This User doesn't exist in database: "+err.Error(), http.StatusUnauthorized)
		return "", false, err
	}

	token, err := auth.SignJWt(userInfo, h.Config.JWT_SECRET)
	if err != nil {
		http.Error(w, "Error in jwt process "+err.Error(), http.StatusBadGateway)
		return "", false, err
	}

	return token, true, nil
	// json.NewEncoder(w).Encode(response)
	return token, true, nil

}

func (h *Handler) register(w http.ResponseWriter, r *http.Request, userInfo models.Student) (string, bool, error) {
	// Create the user in database
	result := h.DB.Create(&userInfo)
	if result.Error != nil {
		http.Error(w, "Failed to register user: "+result.Error.Error(), http.StatusInternalServerError)
		return "", false, result.Error
	}

	token, err := auth.SignJWt(userInfo, h.Config.JWT_SECRET)
	if err != nil {
		http.Error(w, "Error in jwt process "+err.Error(), http.StatusBadGateway)
		return "", false, err
	}

	return token, true, nil
}

// helper function to get student profile from JWT token
func (h *Handler) Profile(w http.ResponseWriter, token string) (map[string]interface{}, error) {
	// Parse JWT token to extract email
	log.Println("Reached profile provider!")

	log.Println("Parsing JWT token for profile retrieval")

	claims, err := auth.ParseJwt(token, h.Config.JWT_SECRET)
	if err != nil {
		log.Println("Error parsing JWT token:", err.Error())
		return nil, fmt.Errorf("invalid token: %v", err)
	}
	log.Println("JWT token parsed successfully")
	log.Println("(Profile provider)=>Extracting email from token claims")
	gmail, ok := claims["email"].(string)
	if !ok {
		return nil, fmt.Errorf("email not found in token claims")
	}
	log.Println("(Profile provider)=> Email extracted from token claims:", gmail)

	var student models.Student
	log.Println("(Profile provider)=> Querying database for student profile with email:", gmail)
	err = h.DB.Where("svv_email = ?", gmail).First(&student).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			log.Println("(Profile provider)=> Student not found in database")
			return nil, fmt.Errorf("student not found")
		}
		log.Println("(Profile provider)=> Database query error:", err.Error())
		return nil, fmt.Errorf("error querying user profile: %v", err)
	}

	log.Println("(Profile provider)=> Student profile retrieved successfully for email:", student.SVVEmail)
	log.Printf("(Profile provider)=> OAuth Access Token (first 20 chars): %.20s...", student.OAccessToken)
	log.Printf("(Profile provider)=> OAuth Refresh Token (first 20 chars): %.20s...", student.ORefreshToken)

	response := map[string]interface{}{
		"success": true,
		"message": "Profile fetched successfully",
		"user": map[string]interface{}{
			"id":              student.ID,
			"name":            student.Name,
			"svv_net_id":      student.SVVNetId,
			"email":           student.SVVEmail,
			"picture":         student.ProfilePic,
			"verified_email":  student.VerifiedEmail,
			"o_refresh_token": student.ORefreshToken,
			"o_access_token":  student.OAccessToken,
		},
	}
	log.Println("(Profile provider)=> Profile response prepared successfully")

	return response, nil
}

// Helper function to parse JWT token using handler's config (for scraper handler)
func (h *Handler) ParseJWTForScraping(tokenString string) (map[string]interface{}, error) {
	return auth.ParseJwt(tokenString, h.Config.JWT_SECRET)
}
