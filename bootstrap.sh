#!/bin/sh
# set -euo pipefail

# Install "Command line tools" xcode-select --install
# Install Homebrew -> https://brew.sh

# Parse options

usage() {
	echo "Usage: $0 [additional options]"
	echo
	echo "  Options:"
	echo
	echo "    --pod                   -  Run pod install"
	echo "    --update-submodule      -  Git submodule update with --remote option"
	exit 1;
}

OPT_POD=false
OPT_SUBMODULE=false

while test $# -gt 0
do
    case "$1" in
        --pod)
			OPT_POD=true
            ;;
        --update-submodule)
			OPT_SUBMODULE=true
            ;;
        *)
		usage 1>&2
        ;;
    esac
    shift
done

echo "🔜 Check & Install dependencies..."

if which -a brew > /dev/null; then
    echo "🟢 Homebrew installed. Skipping install"
else
    echo "🔴 Homebrew not installed. Start install"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if which -a mint > /dev/null; then
    echo "🟢 Mint installed. Skipping install"
else
    echo "🔴 Mint not installed. Start install"
    brew install mint
fi

echo "🔄 Mint bootstrap dependencies"
mint bootstrap --mintfile ./Utilites/Mintfile 
echo "✅ Dependencies succesfully installed"

echo "🚀 Running SwiftFormat"
mint run swiftformat@0.51.11 . --config .swiftformat

echo "🚀 Running SwiftGen"
mint run swiftgen@6.5.1 config run --config swiftgen.yml 

if [ "$OPT_POD" = true ] ; then
    echo "🚀 Running pod install"
	pod install
fi

if [ "$OPT_SUBMODULE" = true ] ; then
    echo "🚀 Running submodule remote update"
    git submodule update --remote
fi

echo "Bootstrap competed 🎉"
