#!/bin/bash
set -e

# Configuration
# Configuration
NAMESPACE="ufbrowsers"

echo "=================================================="
echo "  Browser Images Publisher (Auto-Versioning)"
echo "  Namespace: $NAMESPACE"
echo "=================================================="

# helper to extract version
get_version() {
    local image=$1
    local cmd=$2
    # Run container to get version string. 
    # Capture output first to avoid broken pipes from grep closing early
    local full_output
    full_output=$(docker run --rm "$image" sh -c "$cmd" 2>&1)
    
    # Extract version using grep
    echo "$full_output" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+|[0-9]+\.[0-9]+\.[0-9]+' | head -n 1
}

# --- Build & Publish Logic ---

publish_image() {
    local NAME=$1
    local DOCKERFILE=$2
    local VERSION_CMD=$3
    
    echo ""
    echo "--------------------------------------------------"
    echo "Processing $NAME ..."
    echo "--------------------------------------------------"
    
    local TEMP_TAG="$NAMESPACE/$NAME:temp"
    
    # Build
    # Note: Build context is still root (.) to access common/ scripts
    docker build -t "$TEMP_TAG" -f "$DOCKERFILE" .
    
    # Extract Version
    echo "Extracting version..."
    local VERSION
    VERSION=$(get_version "$TEMP_TAG" "$VERSION_CMD")
    
    if [ -z "$VERSION" ]; then
        echo "Error: Could not detect version for $NAME"
        exit 1
    fi
    echo "Detected Version: $VERSION"
    
    # Semantic Versioning
    local MAJOR=$(echo "$VERSION" | cut -d. -f1)
    local MINOR=$(echo "$VERSION" | cut -d. -f1,2)
    
    local TAG_FULL="$NAMESPACE/$NAME:$VERSION"
    local TAG_MAJOR="$NAMESPACE/$NAME:$MAJOR"
    local TAG_MINOR="$NAMESPACE/$NAME:$MINOR"
    local TAG_LATEST="$NAMESPACE/$NAME:latest"
    
    # Check Registry (Idempotency)
    echo "Checking registry..."
    # If FORCE_PUBLISH is not true AND the manifest exists, we skip.
    if [ "$FORCE_PUBLISH" != "true" ] && docker manifest inspect "$TAG_FULL" > /dev/null 2>&1; then
        echo "⚠️  $TAG_FULL already exists. Skipping."
        echo "   (Set FORCE_PUBLISH=true to override)"
        return 0
    fi
    
    echo "Tagging & Pushing:"
    echo "  - $TAG_FULL"
    echo "  - $TAG_MAJOR"
    echo "  - $TAG_LATEST"
    
    docker tag "$TEMP_TAG" "$TAG_FULL"
    docker tag "$TEMP_TAG" "$TAG_MAJOR"
    docker tag "$TEMP_TAG" "$TAG_MINOR"
    docker tag "$TEMP_TAG" "$TAG_LATEST"
    
    docker push "$TAG_FULL"
    docker push "$TAG_MAJOR"
    docker push "$TAG_MINOR"
    docker push "$TAG_LATEST"
    echo "✅ Published $NAME"
}

# --- 1. Chrome ---
publish_image "ultra-fast-chrome" "images/chrome/Dockerfile" "google-chrome --version"

# --- 2. Firefox ---
publish_image "ultra-fast-firefox" "images/firefox/Dockerfile" "firefox --version"

# --- 3. Edge ---
# Edge version output might need cleanup (e.g. "Microsoft Edge 120.0...")
publish_image "ultra-fast-edge" "images/edge/Dockerfile" "microsoft-edge-stable --version"

echo ""
echo "🎉 All builds processed."
