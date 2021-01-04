# install-appleglot

The latest version of [AppleGlot](https://developer.apple.com/download/more/?=AppleGlot) at time of writing is 4.0 (v161.6), and its installer has the following issues on macOS Catalina and Big Sur:

- the signing certificate is invalid (FB8770951)
- it hasn’t been updated to work on macOS Catalina’s Read-Only System Volume (FB8773764)

This repo contains a bash script to successfully install AppleGlot on macOS Catalina and Big Sur by placing its libraries in a writeable location and patching the `appleglot` binary to use these libraries – more information is available in [this blog post here](https://joshparnham.com/2020/12/installing-appleglot-on-macos-catalina-and-big-sur/).

## Usage

    ./install-appleglot.sh [path to AppleGlot dmg]