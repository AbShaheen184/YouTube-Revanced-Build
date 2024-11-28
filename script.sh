#!/bin/bash

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

get_latest_version() {
    grep -Evi 'alpha|beta' | grep -oPi '\b\d+(\.\d+)+(?:\-\w+)?(?:\.\d+)?(?:\.\w+)?\b' | sort -ur | awk 'NR==1'
}

get_apkmirror_version() {
    grep 'fontBlack' | sed -n 's/.*>\(.*\)<\/a> <\/h5>.*/\1/p' | sed 20q
}

apkmirror() {
    org="$1" name="$2" package="$3" arch="$4"

    # Fetch the latest version
    url="https://www.apkmirror.com/uploads/?appcategory=$name"
    version="$(req - $url | get_apkmirror_version | get_latest_version)"
    echo "Latest version found: $version"

    # Construct version-specific page URL
    url="https://www.apkmirror.com/apk/$org/$name/$name-${version//./-}-release"
    echo "Fetching variant details from: $url"

    # Extract architecture-specific APK link
    variant_url="https://www.apkmirror.com$(req - $url | grep '>nodpi<' -B15 | grep '>'$arch'<' -B13 | grep '>APK<' -B5 \
        | perl -ne 'print "$1\n" if /.*href="([^"]*download\/)".*/ && ++$i == 1;')"
    echo "Variant page URL: $variant_url"

    # Extract the actual download URL
    download_url="https://www.apkmirror.com$(req - $variant_url | perl -ne 'print "$1\n" if /.*href="([^"]*key=[^"]*)".*/')"
    download_url="https://www.apkmirror.com$(req - $download_url | perl -ne 's/amp;//g; print "$1\n" if /.*href="([^"]*key=[^"]*)".*/')"
    echo "Download URL: $download_url"

    # Download the APK
    req "$name-v$version.apk" "$download_url"
    echo "APK downloaded: $name-v$version.apk"
}

# Usage: Download YouTube APK for ARM64-v8a
apkmirror "google-inc" \
          "youtube" \
          "com.google.android.youtube" \
          "arm64-v8a"
