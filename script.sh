#!/bin/bash

# Function to send requests with custom headers to simulate a browser request
req() {
    wget --header="User-Agent: Mozilla/5.0 (Android 13; Mobile; rv:125.0) Gecko/125.0 Firefox/125.0" \
         --header="Content-Type: application/octet-stream" \
         --header="Accept-Language: en-US,en;q=0.9" \
         --header="Connection: keep-alive" \
         --header="Upgrade-Insecure-Requests: 1" \
         --header="Cache-Control: max-age=0" \
         --header="Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8" \
         --keep-session-cookies --timeout=30 -nv -O "$@"
}

# Get the latest APK version of a specific app from Uptodown
get_uptodown_version() {
    name="$1"
    url="https://$name.en.uptodown.com/android/versions"
    
    # Extract the latest version number by matching the version tag
    version=$(req -q "$url" | grep -oP 'class="version">\K[^<]+' | head -n 1)
    echo "$version"
}

# Function to download APK from Uptodown using the extracted version
download_apk_from_uptodown() {
    name="$1"  # Example: "youtube"
    package="$2"  # Example: "com.google.android.youtube"

    # Get the latest version of the app
    version=$(get_uptodown_version "$name")

    # Construct the version URL
    version_url="https://$name.en.uptodown.com/android/versions"

    # Fetch the page and extract the correct download URL for the found version
    download_url=$(req -q "$version_url" | grep -oP 'data-url="([^"]*)"' | grep "$version" | head -n 1)

    # If a download URL is found, extract the real download link
    if [[ -n "$download_url" ]]; then
        download_url="https://dw.uptodown.com/dwn/$(echo $download_url | sed -n 's/.*data-url="\([^"]*\)".*/\1/p')"

        # Download the APK
        echo "Downloading APK from: $download_url"
        req "$name-v$version.apk" "$download_url"
    else
        echo "Failed to find the download URL for version $version"
    fi
}

# Example usage to download the latest version of YouTube
download_apk_from_uptodown "youtube" "com.google.android.youtube"
