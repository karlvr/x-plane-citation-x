# Patches for X-Plane's default Cessna Citation X

These patches improve the behaviour of the default Cessna Citation X from Laminar Research in X-Plane 12 when used
with the Honeycomb Alpha and Honeycomb Bravo, and with the [Xsaitekpanels](https://github.com/sparker256/xsaitekpanels) plugin.

## Installation

Open a command prompt at the root of this project. Update the `TARGET` variable below to the path where your Citation X aircraft is found.

```shell
TARGET=~/X-Plane\ 12/Aircraft/Laminar\ Research/Cessna\ Citation\ X
patch -d "$TARGET" -p 0 < electrical.diff
patch -d "$TARGET" -p 0 < lights.diff
patch -d "$TARGET" -p 0 < throttle.diff
patch -d "$TARGET" -p 0 < sounds.diff
cp xsaitekpanels.ini "$TARGET/"
```

## Patches

### Electrical

* Avionics on/off commands (previously only a toggle command)
* EICAS on/off commands (previously only a toggle command)
* Battery left and right on/off commands (previously non-standard commands)

### Lights

Support for controlling lights using standard X-Plane on/off commands to suit the switches on the Honeycomb Alpha.

* Beacon and strobe lights on/off commands (aircraft only has one switch for both of these, so they map to that switch appropriately)
* Navigation lights on/off commands (previously only a toggle command)
* Taxi lights on/off commands (previously only a toggle command)
* Landing lights on/off commands (toggles left and right together; previously only a toggle command)

### Throttle

#### Engine cut-off switches

The Honeycomb Bravo has cut-off switches as an extra detent at the bottom of the throttle range. We add support for these
switches by configuring the Bravo throttle cut-off switches to use the new commands listed below:

* Engine cut-off left (`laminar/CitX/engine/cmd_mixture_left_min`)
* Engine cut-off right (`laminar/CitX/engine/cmd_mixture_right_min`)

### Sounds

* Taxi lights
* Landing lights
