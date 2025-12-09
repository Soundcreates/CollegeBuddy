/// <reference types="chrome" />

// The token comes from the chrome.runtime.sendMessage in the HTML, not URL params
// We just need to wait for the message from background script
console.log('Callback page loaded, token will come via chrome.runtime.sendMessage from background');