#!/bin/bash
set -e

# Configuration
NAMESPACE="ufbrowsers"
ALPINE_IMAGE_NAME="ultra-fast-alpine-chrome"
UBUNTU_IMAGE_NAME="ultra-fast-ubuntu-chrome"

echo "=================================================="
echo "  Browser Images Publisher (Auto-Versioning)"
echo "  Namespace: $NAMESPACE"
echo "=================================================="

# helper to extract version
get_version() {
    local image=$1
    local cmd=$2
    # Run container to get version string. 
    # Grep/Awk usage depends on specific output of browser --version
    docker run --rm "$image" sh -c "$cmd" | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|[0-9]+\.[0-9]+\.[0-9]+' | head -n 1
}

# --- 1. Alpine Image (Skipped) ---
# echo ""
# echo "[1/2] Processing Alpine Image..."
# Alpine support removed as per request.


# --- 2. Ubuntu Image ---
echo ""
echo "[2/2] Processing Ubuntu Image..."
TEMP_TAG="$NAMESPACE/$UBUNTU_IMAGE_NAME:temp"

# Build
docker build -t "$TEMP_TAG" -f ubuntu-full/Dockerfile .

# Extract Version (Chrome)
# Output format usually: "Google Chrome 120.0.6099.109"
echo "Extracting Chrome version..."
VERSION=$(get_version "$TEMP_TAG" "google-chrome --version")

if [ -z "$VERSION" ]; then
    echo "Error: Could not detect Chrome version for Ubuntu."
    exit 1
fi
echo "Detected Ubuntu Chrome Version: $VERSION"

# Tag & Push (Semantic Versioning)
MAJOR=$(echo "$VERSION" | cut -d. -f1)
MINOR=$(echo "$VERSION" | cut -d. -f1,2)

TAG_FULL="$NAMESPACE/$UBUNTU_IMAGE_NAME:$VERSION"
TAG_MAJOR="$NAMESPACE/$UBUNTU_IMAGE_NAME:$MAJOR"
TAG_MINOR="$NAMESPACE/$UBUNTU_IMAGE_NAME:$MINOR"
TAG_LATEST="$NAMESPACE/$UBUNTU_IMAGE_NAME:latest"

echo "Checking if version $VERSION already exists on Registry..."
if docker manifest inspect "$TAG_FULL" > /dev/null 2>&1; then
    echo "⚠️  Image $TAG_FULL already exists. Skipping publish."
    echo "   (To force publish, delete the tag from Docker Hub or increment version)"
    
    # Optional: We could still update 'latest' if we wanted, but user request implies "only to publish" if modified.
    # We will exit cleanly.
    exit 0
else
    echo "🚀 New version detected ($VERSION). Proceeding to publish."
fi

echo "Tagging:"
echo "  - $TAG_FULL"
echo "  - $TAG_MINOR"
echo "  - $TAG_MAJOR"
echo "  - $TAG_LATEST"

docker tag "$TEMP_TAG" "$TAG_FULL"
docker tag "$TEMP_TAG" "$TAG_MINOR"
docker tag "$TEMP_TAG" "$TAG_MAJOR"
docker tag "$TEMP_TAG" "$TAG_LATEST"

echo "Pushing Tags..."
docker push "$TAG_FULL"
docker push "$TAG_MINOR"
docker push "$TAG_MAJOR"
docker push "$TAG_LATEST"

echo ""
echo "✅ Success! Images published."
echo "Ubuntu:"
echo "  - $TAG_FULL"
echo "  - $TAG_MINOR"
echo "  - $TAG_MAJOR"
echo "  - $TAG_LATEST"
