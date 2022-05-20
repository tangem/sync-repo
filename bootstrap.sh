#!/bin/sh
# set -euo pipefail

# Install "Command line tools" xcode-select --install
# Install Homebrew -> https://brew.sh

echo "==== Installing dependencies... 🔜 ===="
brew install mint
mint install SwiftGen/SwiftGen
echo "==== Dependencies succesfully installed ✅ ===="

# echo "==== Running SwiftGen ===="
# mint run swiftgen
# echo "==== Bootstrap competed 🎉 ===="