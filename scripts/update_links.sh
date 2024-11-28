#!/bin/bash

# Fetch latest ReVanced CLI URL
CLI_URL=$(curl -s https://api.github.com/repos/ReVanced/revanced-cli/releases/latest \
    | jq -r '.assets[] | select(.name | contains("revanced-cli")) | .browser_download_url')

# Fetch latest patches URL
PATCHES_URL=$(curl -s https://api.github.com/repos/ReVanced/revanced-patches/releases/latest \
    | jq -r '.assets[] | select(.name | contains("patches")) | .browser_download_url')

# Fetch latest integrations URL
INTEGRATION_URL=$(curl -s https://api.github.com/repos/ReVanced/revanced-integrations/releases/latest \
    | jq -r '.assets[] | select(.name | contains("integrations")) | .browser_download_url')

# Fetch latest YouTube APK link (via scraping or API)
YOUTUBE_URL=$(curl -s "https://apkmirror.com" | grep "latest_youtube_apk_regex_here")

# Update environment file for GitHub Actions
echo "CLI_URL=$CLI_URL" > .env
echo "PATCHES_URL=$PATCHES_URL" >> .env
echo "INTEGRATION_URL=$INTEGRATION_URL" >> .env
echo "YOUTUBE_URL=$YOUTUBE_URL" >> .env
