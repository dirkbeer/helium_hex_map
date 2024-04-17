# helium_hex_map

Shows Helium Mobile Discovery Mapping hexes that you have visited. A draft / alpha / debug version, a coding excercise for me, currently for Android only.

<img src="https://github.com/dirkbeer/flutter_h3_map/assets/6425332/59bc602f-60fc-4e7f-9f63-2b801255f45e" height="300">

## Overview

Displays a map at your location and updates it as you move. If the location has the required accuracy, displays the H3 hex and increases the hex count.

_Blue_ hexes are hexes you've visited in the last 15 minutes.

_Green_ hexes are at least 15 minutes old and should have increased the count in your Mapping Feed (if no one else has mapped them).

_Green transparent_ hexes are hexes that are out of the 60 minute cooldown period.

## Limitations

Helium does not provide information on which hexes have been Discovery Mapped by other subscribers. You may not get credit for all the hexes counted by this app.

As far as I know, Helium doesn't disclose the exact criteria for counting a hex. This app assumes that they only count hexes if the phone had an accurate position.

## Installation

1. Download the [app-debug.apk](https://github.com/dirkbeer/helium_hex_map/releases/tag/v0.1.0-alpha) to your phone
2. Find it using Files
3. Tap to install
