# COSMOS

The COSMOS ground system is an open-source spacecraft ground system created by Ball Aerospace. This repo contains
the configuration for a ground station to send commands to and interpret telemetry from UMD BPP payloads.

COSMOS is configured mainly through config files. Here are the ones you'll commonly need:

* [config/targets/](config/targets/) - Definitions of each payload's 
* [config/system/system.txt](config/system/system.txt) - Top-level COSMOS configuration (add payload here)
* [config/tools/cmd_tlm_server/cmd_tlm_server.txt](config/tools/cmd_tlm_server/cmd_tlm_server.txt) - Interface/communication configurations

COSMOS's interfaces and protocols are also extensible through the implementation of ruby classes. Those are stored in [lib/](lib/).

## Installation

### Installing COSMOS on Windows

1. Download and install [Ruby+Devkit 2.4.4-1 (x64)](https://github.com/oneclick/rubyinstaller2/releases/download/rubyinstaller-2.4.4-1/rubyinstaller-devkit-2.4.4-1-x64.exe). Press ```ENTER``` when prompted.

2. Open the Windows Command Prompt as an Administrator (on Windows 10, ```Windows key + X -> A```).

3. Install COSMOS, as well as its dependencies, by running the following command:

        gem install cosmos

Respond to the following prompt with ```y```.

        Overwrite the executable? [yN]  y

4. Clone this repository using Git to get the configuration for our payloads.

5. Start COSMOS by opening your local clone of this repository and running ```launcher.bat```.


### Installing COSMOS on Ubuntu

Warning: Untested

1. `sudo apt-get install ruby-full`

2. Clone this repo using git

3. Run `ruby Launcher` from the repo to start cosmos



