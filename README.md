# COSMOS

The COSMOS ground system is an open-source spacecraft ground system created by Ball Aerospace. This repo contains
the configuration for a ground station to send commands to and interpret telemetry from UMD BPP payloads.

## Installing COSMOS
1. Download and install [Ruby 2.2.5 32-bit](http://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-2.2.5.exe). Make sure "Add Ruby executables to your PATH" is checked.

2. Download and run [32-bit Devkit for Ruby 2.0 and Above](http://dl.bintray.com/oneclick/rubyinstaller/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe) and extract to its own folder. 

3. Open the command line and move to the folder you just extracted the Devkit to (in Windows, Shift + RightClick -> "Open command window here") and run the following commands:

        ruby dk.rb init
        
        ruby dk.rb install
        
4. Install COSMOS, as well as its dependencies:

        gem install cosmos
        
   If you get an error with the above command, try updating RubyGems (the Ruby package manager):
   
        gem update --system
        
   If updating RubyGems fails, follow the instructions on [this page](https://rubygems.org/pages/download/) to manually update RubyGems, then try installing again.

5. Clone this repository using Git to get the configuration for our payloads. For help using Git, read [this guide](http://zrb.io/git/).

6. Start COSMOS by opening your local clone of this repository and running "launcher.bat".
