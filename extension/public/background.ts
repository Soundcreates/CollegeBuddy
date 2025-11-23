//this is the service manager file for the extension
//what is service manager?
//well in webapps we use different frontend files to do api calling and all that
//but in extensions we have different architecture, we do it in background.ts file which gets moved to the dist folder which is infact being loaded on to the users screen
//soo all the backendd calling should be done in this file

type addListenerType = {
  message: any,
  sender : any,
  sendResponse : any
}

chrome.runtime.onMessage.addListener((message, sender, sendResponse) :addListenerType => {
  if(message.type === "START_OAUTH"){
    //handling start oauth flow
    handleOAuth(sendresponse);
    return true;
  }

  if(message.type == "OAUTH_COMPLETE"){
    //storing the local data
    chrome.storage.local.set({
      isAuthenticated: true,
      user: message.user,
      token: message.token,
    }, () => {
      //notify popup about successfull oauth
      chrome.runtime.sendMessage({
        type: "AUTH_SUCCESS",
        user: message.user
      });
      sendResponse({success: true});
    });
    return true;
  }
};

async function handleOAuth(sendResponse :any){
  try{
    const response = await fetch("http://localhost:8080/api/auth/OAuth", {
      method : "POST",
      headers: {
        'Content-Type': 'application/json',
      },
    });

    const data = await response.json();

    if(data.success && data.oauth_url){
      chrome.tabs.create({
        url: data.oauth_url,
        active: true
      }, (tab) => {
        //Listen for tab updates to catch the call back
        const listener = (tabId, changeInfo, updatedTab){
          if(tabId === tab.id && changeInfo.url){
            //checking if url contains callback
            if(changeInfo.url.includes('/api/auth/google/callback')) {
              //this signals that the outh hogaya, so close the tab
              chrome.tabs.remove(tabId);
              chrome.tabs.onUpdated.removeListener(listener);
              sendResponse({success: true});
            }
          }
        };
        chrome.tabs.onUpdated.addListener(listener);
      });
    }else{
      sendResponse({success: false, error: "Failed to get OAuth URL"});

    }
  }catch(err : string){
    console.error("OAuth error: ", err.message);
    sendResponse({success: false, error: err.message})
  }
}