#!/bin/bash

# Function to send a request with headers to simulate a browser request
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

# Fetch the latest version of the APK from Uptodown
get_uptodown_version() {
    # URL of the YouTube version page on Uptodown
    url="https://youtube.en.uptodown.com/android/versions"

    # Extract the latest version number (adjust regex if necessary)
    version=$(req -q "$url" | grep -oP 'class="version">\K[^<]+' | head -n 1)
    echo "$version"
}

# Function to download APK from Uptodown based on version
download_apk_from_uptodown() {
    name="$1"  # Example: "youtube"
    package="$2"  # Example: "com.google.android.youtube"

    # Get the latest version
    version=$(get_uptodown_version)

    # Construct the URL for the download page based on version
    url="https://$name.en.uptodown.com/android/versions"
    
    # Find the correct download URL based on version
    download_url=$(req -q "$url" | grep -oP 'data-url="([^"]*)"' | grep "$version" | head -n 1)
    
    # If a download URL is found, extract the direct link
    if [[ -n "$download_url" ]]; then
        download_url="https://dw.uptodown.com/dwn/$(echo $download_url | sed -n 's/.*data-url="\([^"]*\)".*/\1/p')"
        
        # Download the APK
        req "$name-v$version.apk" "$download_url"
    else
        echo "Failed to find the download URL for version $version"
    fi
}

# Example usage
download_apk_from_uptodown "youtube" "com.google.android.youtube"
