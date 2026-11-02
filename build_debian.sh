zapfast_VERSION=$1
BUILD_VERSION=$2
ARCH=${3:-amd64}  # Default to amd64 if no architecture specified

if [ -z "$zapfast_VERSION" ] || [ -z "$BUILD_VERSION" ]; then
    echo "Usage: $0 <zapfast_version> <build_version> [architecture]"
    echo "Example: $0 0.21.0 1 arm64"
    echo "Example: $0 0.21.0 1 all    # Build for all architectures"
    echo "Supported architectures: amd64, arm64, all"
    exit 1
fi

# Function to map Debian architecture to the upstream .deb asset name
get_zapfast_release() {
    local arch=$1
    case "$arch" in
        "amd64"|"arm64")
            echo "zapfast_${zapfast_VERSION}_${arch}"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to build for a specific architecture
build_architecture() {
    local build_arch=$1
    local zapfast_release

    zapfast_release=$(get_zapfast_release "$build_arch")
    if [ -z "$zapfast_release" ]; then
        echo "❌ Unsupported architecture: $build_arch"
        echo "Supported architectures: amd64, arm64"
        return 1
    fi

    echo "Building for architecture: $build_arch using $zapfast_release"

    # Clean up any previous builds for this architecture
    rm -rf "$zapfast_release" || true
    rm -f "${zapfast_release}.deb" || true

    # Download upstream's .deb for this architecture
    if ! wget "https://github.com/crmne/zapfast/releases/download/v${zapfast_VERSION}/${zapfast_release}.deb"; then
        echo "❌ Failed to download ZapFast .deb for $build_arch"
        return 1
    fi

    # Unpack only the payload; the control data (and its Depends) is replaced by ours
    if ! dpkg-deb -x "${zapfast_release}.deb" "$zapfast_release"; then
        echo "❌ Failed to extract ZapFast .deb for $build_arch"
        return 1
    fi

    rm -f "${zapfast_release}.deb"

    if [ ! -f "$zapfast_release/usr/bin/zapfast" ] || [ ! -f "$zapfast_release/usr/share/applications/zapfast.desktop" ]; then
        echo "❌ Unexpected package layout: $zapfast_release/usr/bin/zapfast or zapfast.desktop not found"
        return 1
    fi

    # One package for every suite: upstream ships one binary per architecture,
    # so only the old ~<suite> version suffix ever differed. The fixed ~griffo
    # keeps it below the distro's own build of the same version.
    FULL_VERSION="$zapfast_VERSION-${BUILD_VERSION}~griffo_${build_arch}"
    echo "  Building $FULL_VERSION"

    if ! docker build . -t "zapfast-$build_arch" \
        --build-arg zapfast_VERSION="$zapfast_VERSION" \
        --build-arg BUILD_VERSION="$BUILD_VERSION" \
        --build-arg FULL_VERSION="$FULL_VERSION" \
        --build-arg ARCH="$build_arch" \
        --build-arg ZAPFAST_RELEASE="$zapfast_release"; then
        echo "❌ Failed to build Docker image for $build_arch"
        return 1
    fi

    id="$(docker create "zapfast-$build_arch")"
    if ! docker cp "$id:/zapfast_$FULL_VERSION.deb" - > "./zapfast_$FULL_VERSION.deb"; then
        echo "❌ Failed to extract .deb package for $build_arch"
        return 1
    fi

    if ! tar -xf "./zapfast_$FULL_VERSION.deb"; then
        echo "❌ Failed to extract .deb contents for $build_arch"
        return 1
    fi

    # Clean up extracted directory
    rm -rf "$zapfast_release" || true

    echo "✅ Successfully built for $build_arch"
    return 0
}

# Main build logic
if [ "$ARCH" = "all" ]; then
    echo "🚀 Building zapfast $zapfast_VERSION-$BUILD_VERSION for all supported architectures..."
    echo ""

    # All supported architectures (upstream publishes amd64 and arm64 only)
    ARCHITECTURES=("amd64" "arm64")

    for build_arch in "${ARCHITECTURES[@]}"; do
        echo "==========================================="
        echo "Building for architecture: $build_arch"
        echo "==========================================="

        if ! build_architecture "$build_arch"; then
            echo "❌ Failed to build for $build_arch"
            exit 1
        fi

        echo ""
    done

    echo "🎉 All architectures built successfully!"
    echo "Generated packages:"
    ls -la zapfast_*.deb
else
    # Build for single architecture
    if ! build_architecture "$ARCH"; then
        exit 1
    fi
fi
