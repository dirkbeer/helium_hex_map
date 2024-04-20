# Developing iOS apps using Flutter

Based on [these](https://docs.flutter.dev/get-started/install/macos/mobile-ios) instructions.

1. You will need an iPhone and a computer with Mac OS. If developing on Windows or Linux, you can use a docker container instead of a real Mac OS machine [Docker-OSX](https://github.com/sickcodes/Docker-OS). Here is how I installed that on Ubuntu 22.04 [link](https://github.com/dirkbeer/helium_hex_map/blob/main/docker_osx_install.md)
 
2. Install Xcode 15. Download from [link], double-click to extract, drag into Applications and run the XCode application

3. Install cocoapods

3.1 Install command line tools
```
xcode-select -- install
```

3.2 Install cocoapods
```
sudo gem install drb -v 2.0.6
sudo gem install activesupport -v 6.1.7.7
sudo gem install cocoapods
```

4. Configure XCode
```
sudo sh -c 'xcode-select -s /Applications/Xcode.app/Contents/Developer && xcodebuild -runFirstLaunch'
sudo xcodebuild -license
```
