# Somaiya Vidyavihar LMS Extension

A browser extension that scrapes LMS and Gmail data and pushes events to Google Keep.

## Development

1. Install dependencies:

```bash
npm install
```

2. Build the extension:

```bash
npm run build
```

## Installing the Extension

### For Chrome/Edge:

1. Build the extension using `npm run build`
2. Open Chrome/Edge and go to `chrome://extensions/` (or `edge://extensions/`)
3. Enable "Developer mode" (toggle in top right)
4. Click "Load unpacked"
5. Select the `dist` folder from your project
6. The extension should now appear in your extensions list

### For Firefox:

1. Build the extension using `npm run build`
2. Open Firefox and go to `about:debugging`
3. Click "This Firefox"
4. Click "Load Temporary Add-on"
5. Navigate to the `dist` folder and select `manifest.json`

## Features

- Scrapes LMS data from kjsse.edu.in
- Monitors Gmail for relevant emails
- Integrates with Google Keep for event management
- Popup interface for easy access

## Permissions

- `storage`: For storing extension data
- `identity`: For Google authentication
- `activeTab`: For accessing current tab content
- Host permissions for kjsse.edu.in and mail.google.com

## Development Notes

This extension is built with:

- React + TypeScript
- Vite for building
- Chrome Extension Manifest V3

## File Structure

```
dist/                 # Built extension (load this folder in browser)
├── manifest.json    # Extension manifest
├── index.html       # Popup HTML
├── popup.js         # Popup React app
├── popup.css        # Popup styles
├── background.js    # Background service worker
└── assets/          # Static assets
```
