# CollegeBuddy Extension Setup Guide

This guide will help you set up and use the CollegeBuddy Extension locally, as the extension is not hosted.

## Prerequisites
- Google Chrome browser
- Node.js and npm installed
- Docker and Docker Compose installed
- Git (optional, for cloning)

## 1. Fork the Repository
```
git clone <repo-url>
cd Somaiya_ext
```

## 3. Build the Extension Frontend
```
cd extension
npm install
npm run build
```
- The build output will be in the `extension/dist` folder.

## 4. Load the Extension in Chrome
1. Open Chrome and go to `chrome://extensions`
2. Enable "Developer mode" (top right)
3. Click "Load unpacked"
4. Select the `extension/dist` folder

For questions or issues, open an issue in this repository or contact the maintainer.
