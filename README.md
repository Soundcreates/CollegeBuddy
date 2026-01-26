[![wakatime](https://wakatime.com/badge/user/8e9eed09-5e3e-487a-80d6-aa372159ea08/project/895e0750-f0d9-48f5-b38c-c17e31659278.svg)](https://wakatime.com/badge/user/8e9eed09-5e3e-487a-80d6-aa372159ea08/project/895e0750-f0d9-48f5-b38c-c17e31659278)

# CollegeBuddy Extension Setup Guide

This guide will help you set up and use the CollegeBuddy Extension locally, as the extension is not hosted.

## Prerequisites
- Google Chrome browser
- Node.js and npm installed
- Git 

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
