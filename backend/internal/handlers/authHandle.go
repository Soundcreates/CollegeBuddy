package handlers

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"somaiya-ext/internal/auth"
	"somaiya-ext/internal/models"
	"strings"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"gorm.io/gorm"
)

const oauthStateString = "kjssecodecell"

func (h *Handler) getGoogleOauthConfig() *oauth2.Config {
	return &oauth2.Config{
		ClientID:     h.Config.OAUTH_CLIENT_ID,
		ClientSecret: h.Config.OAUTH_CLIENT_SECRET,
		RedirectURL:  "http://localhost:8080/api/auth/google/callback",
		Scopes:       []string{"https://www.googleapis.com/auth/userinfo.email", "https://www.googleapis.com/auth/userinfo.profile"},
		Endpoint:     google.Endpoint,
	}
}
func (h *Handler) HandleGoogleLogin(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	googleOauthConfig := h.getGoogleOauthConfig()
	url := googleOauthConfig.AuthCodeURL(oauthStateString, oauth2.AccessTypeOffline)
	fmt.Println("Generated OAuth URL: ", url)
	response := map[string]interface{}{
		"success":   true,
		"oauth_url": url,
		"message":   "OAuth URL generated successfully",
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

// here in this googlecallback functionm, my main motto will be to get the user code and store teh access and refresh token in db
func (h *Handler) GoogleCallBack(w http.ResponseWriter, r *http.Request) {
	state := r.FormValue("state")
	if state != oauthStateString { //here i get the state from the url
		http.Error(w, "Invalid OAuth state", http.StatusBadRequest)
		return
	}
	//this is the code
	code := r.FormValue("code")
	if code == "" {
		http.Error(w, "Code not found", http.StatusBadRequest)
		return
	}
	//thiis is the token im exchanging
	googleOauthConfig := h.getGoogleOauthConfig()
	token, err := googleOauthConfig.Exchange(context.Background(), code)
	if err != nil {
		http.Error(w, "Token exchange failed: "+err.Error(), http.StatusInternalServerError)
		return
	}

	refreshToken := token.RefreshToken

	fmt.Println("Refresh Token: ", refreshToken)
	client := googleOauthConfig.Client(context.Background(), token)
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
	token , success, err := h.login(w, r, userInfo)

	if err != nil || success == false {
		fmt.Println("Logging in failed,aborting...")
		return
	}

	cfg := h.Config

	if err == nil {
		// Instead of redirecting to a web page, redirect to extension (extension routing thoda confusing hai ig)
		extensionURL := fmt.Sprintf("chrome-extension://%s/callback/callback.html?token=%s",
			cfg.EXTENSION_ID, token.AccessToken)

		http.Redirect(w, r, extensionURL, http.StatusTemporaryRedirect)
		return
	}
	// Handle error case
	errorURL := fmt.Sprintf("chrome-extension://%s/oauth-error.html?error=%s",
		cfg.EXTENSION_ID, "auth_failed")
	http.Redirect(w, r, errorURL, http.StatusTemporaryRedirect)
}

func (h *Handler) login(w http.ResponseWriter, r *http.Request, userInfo models.Student) (string,  bool, error) {
	w.Header().Set("Content-Type", "application/json")

	var foundStudent models.Student

	err := h.DB.Where("svv_email = ?", userInfo.SVVEmail).First(&foundStudent).Error

	if err != nil {
		http.Error(w, "This User doesn't exist in database: "+err.Error(), http.StatusUnauthorized)
		return " ", false, err
	}

	token, err := auth.SignJWt(userInfo, h.Config.JWT_SECRET)
	if err != nil {
		http.Error(w, "Error in jwt process "+err.Error(), http.StatusBadGateway)
		return " ", false, err
	}

	// response := map[string]interface{}{
	// 	"success": true,
	// 	"message": "Login Successful",
	// 	"user":    foundStudent,
	// 	"token":   token,
	// }

	// w.WriteHeader(http.StatusOK)
	// json.NewEncoder(w).Encode(response)
	return token, true, nil

}

func (h *Handler) register(w http.ResponseWriter, r *http.Request, userInfo models.Student) (string,bool, error){
	// Create the user in database
	var student models.Student
	result := h.DB.Create(&userInfo)
	if result.Error != nil {
		http.Error(w, "Failed to register user: "+result.Error.Error(), http.StatusInternalServerError)
		return " ", false, result.Error
	}

	token, err := auth.SignJWt(userInfo, h.Config.JWT_SECRET)
	if err != nil {
		http.Error(w, "Error in jwt process "+err.Error(), http.StatusBadGateway)
		return " ", false, err
	}

	// response := map[string]interface{}{
	// 	"success": true,
	// 	"message": "Register Successful",
	// 	"user":    student,
	// 	"token":   token,
	// }

	// w.WriteHeader(http.StatusOK)
	// json.NewEncoder(w).Encode(response)

	return token, true, nil
}

func (h *Handler) Profile(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"message": "Profile endpoint", "status": "OK"}`))
}
