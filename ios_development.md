# Developing iOS apps using Flutter

Based on [these](https://docs.flutter.dev/get-started/install/macos/mobile-ios) instructions.

1. You will need an iPhone and a computer with Mac OS. If developing on Windows or Linux, you can use a docker container instead of a real Mac OS machine [Docker-OSX](https://github.com/sickcodes/Docker-OS). Here is how I installed that on Ubuntu 22.04 [link](https://github.com/dirkbeer/helium_hex_map/blob/main/docker_osx_install.md)
 
2. Install Xcode 15. Download from [link], double-click to extract, drag into Applications and run the XCode application. Install the iOS simulator when prompted.

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

5. Set up iPhone passthrough to the docker-osx supplement to instructions [here](https://github.com/sickcodes/Docker-OSX?tab=readme-ov-file#connect-to-a-host-running-usbfluxd)
   
5.1 Install prerequisites on host machine
```
sudo apt install usbmuxd socat
wget https://github.com/corellium/usbfluxd/releases/download/v1.0/usbfluxd-x86_64-libc6-libdbus13.tar.gz
cd usbfluxd-aarch64-libc6-libdbus13/
sudo cp usbflux* /usr/local/sbin/
nano ~/.bashrc
export PATH="/usr/local/sbin:$PATH"
```
5.2 Set up usb passthrough on docker-osx. [Install homebrew](https://osxdaily.com/2022/12/28/how-to-install-homebrew-on-macos-ventura/)

6. Trust yourself as developer
   Settings -> General -> VPN & Device Management

