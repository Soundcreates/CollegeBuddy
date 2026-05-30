/// <reference types="chrome" />

function getQueryParams() {
  const params = new URLSearchParams(window.location.search);
  return {
    token: params.get("token"),
    refreshToken: params.get("refresh_token"),
    user: params.get("user")
      ? JSON.parse(decodeURIComponent(params.get("user")!))
      : null,
  };
}

document.addEventListener("DOMContentLoaded", () => {
  const { token, refreshToken, user } = getQueryParams();
  const statusElement = document.getElementById("status");

  if (token && user) {
    console.log("Token found, sending to background...");
    if (statusElement)
      statusElement.innerText = "Authentication successful! Redirecting...";
    if (statusElement) statusElement.className = "success";

    chrome.runtime.sendMessage(
      {
        type: "OAUTH_SUCCESS",
        token,
        refreshToken,
        user,
      },
      (response) => {
        if (chrome.runtime.lastError) {
          console.error("Error sending message:", chrome.runtime.lastError);
          if (statusElement) {
            statusElement.innerHTML =
              "Error communicating with extension: " +
              chrome.runtime.lastError.message;
            statusElement.className = "error";
            statusElement.innerHTML +=
              "<br>Please check if the extension is installed and enabled.";
          }
        } else {
          console.log("Background response:", response);
          if (statusElement)
            statusElement.innerHTML +=
              "<br><span class='success'>Message sent! Background response: " +
              JSON.stringify(response) +
              "</span>";
          if (statusElement)
            statusElement.innerHTML +=
              "<br><strong>Please close this tab manually and check the extension.</strong>";

          // setTimeout(() => {
          //   window.close();
          // }, 1000);
        }
      },
    );
  } else {
    console.error("No token found in URL");
    if (statusElement) {
      statusElement.innerText = "Authentication failed. No token found.";
      statusElement.className = "error";
    }
  }
});
