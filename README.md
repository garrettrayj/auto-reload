<img src="https://github.com/garrettrayj/auto-reload/raw/master/AutoReload/Assets.xcassets/AppIcon.appiconset/icon_128x128@2x.png" height="128" width="128" alt="Auto Reload Icon" />

Auto Reload
===========

<img src="https://github.com/garrettrayj/auto-reload/raw/master/AutoReload/Assets.xcassets/AppPanel3.imageset/get.started.3@2x.png" height="300" width="300" alt="Auto Reload Thumbnail" />

Auto Reload is a Safari extension for automatically refreshing browser windows with recurring timers. The goal is to provide functionality with as few browser "add-on" side effects as possible. There's no javascript, the interface is all native controls, and no extra security permissions are required. The extension ships in a basic Mac app with instructions for enabling in Safari. The app is purely a wrapper and does not communicate with the extension.


Installation
------------

1. Download the [latest release](https://github.com/garrettrayj/auto-reload/releases/latest) from GitHub or purchase [Auto Reload on the Mac App Store](https://apps.apple.com/us/app/auto-reload/id1437349439) to support development and receive automatic updates
2. Open the Auto Reload application
3. Open Safari then go to `Preferences` > `Extensions`
4. Enable Auto Reload
5. Use the toolbar item to start/stop reloading windows


Support
-------

[Send an email](mailto:garrett@devsci.net) or create a GitHub issue for help. Suggestions and feedback are always welcome, no matter whether it's a message, review, or issue here.


Build from Source
-----------------

Requires Xcode with command line tools. Prepare by uninstalling existing versions of Auto Reload.

1. Clone the code
2. Drag the project directory to Xcode
3. Open Safari
    * Development is smoothest when attached to an existing Safari instance
    * Recommended that Xcode and Safari share the same desktop, neither in full-screen mode
4. Build and run the _application_ scheme then the _extension_ scheme to debug

---------------------------
&copy; 2021 Garrett Johnson
