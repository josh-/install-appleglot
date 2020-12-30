#!/bin/bash

PROGRAM_NAME=$0
DMG_PATH=$1

if ! [ -x "$(command -v install_name_tool)" ]; then
    echo "install_name_tool is required, please install it with `xcode-select --install`" >&2
    exit 1
fi

function usage {
    echo "usage: $PROGRAM_NAME [path to AppleGlot dmg]"
    exit 1
}

if [ $# -eq 0 ]
then
    usage
    exit 1
fi

# Mount DMG
echo "Mounting disk image..."
hdiutil attach -nobrowse -readonly -quiet "$DMG_PATH"

# Create temporary directory
TEMP_DIR=$(mktemp -d)

# Expand pkg
echo "Expanding package..."
pkgutil --expand /Volumes/AppleGlot/AppleGlot.pkg "$TEMP_DIR/expanded" &>/dev/null
cd "$TEMP_DIR/expanded/AppleGlot.pkg"

# Unount DMG
hdiutil detach -quiet "$DMG_PATH"

# Unpack payload
tar xvf Payload &>/dev/null

# Change library load paths for main binary
echo "Updating dylib paths..."
install_name_tool \
    ./usr/local/bin/appleglot \
    -change \
    "/System/Library/PrivateFrameworks/AppleGlot.framework/Versions/A/AppleGlot" \
    "/Library/Frameworks/AppleGlot.framework/Versions/A/AppleGlot" \

# Change library load paths for each active plugin
for filename in ./System/Library/PrivateFrameworks/AppleGlot.framework/PlugIns/*; do
    BUNDLE_NAME="$(basename $filename)"
    BINARY_NAME="${BUNDLE_NAME%.*}"

    install_name_tool \
        "$filename/Contents/MacOS/$BINARY_NAME" \
        -change \
        "/System/Library/PrivateFrameworks/AppleGlot.framework/Versions/A/AppleGlot" \
        "/Library/Frameworks/AppleGlot.framework/Versions/A/AppleGlot"

    install_name_tool \
        "$filename/Contents/MacOS/$BINARY_NAME" \
        -change \
        "/System/Library/PrivateFrameworks/MonteLib.framework/Versions/A/MonteLib" \
        "/Library/Frameworks/MonteLib.framework/Versions/A/MonteLib"
done

# Copy files into place
echo "Copying files..."
echo "You may be prompted for your system password"
sudo ditto ./usr/local/share/man/man1/appleglot.1 /usr/local/share/man/man1/appleglot.1
sudo ditto ./usr/local/bin/appleglot /usr/local/bin/appleglot

sudo ditto \
    ./Library/Application\ Support/AppleGlot/PlugIns/AppleGlotIBPlugin.bundle \
    /Library/Application\ Support/AppleGlot/PlugIns/AppleGlotIBPlugin.bundle

sudo ditto \
    ./System/Library/PrivateFrameworks/MonteLib.framework \
    /Library/Frameworks/MonteLib.framework

sudo ditto \
    ./System/Library/PrivateFrameworks/AppleGlot.framework \
    /Library/Frameworks/AppleGlot.framework

echo "Done!"
exit 0
