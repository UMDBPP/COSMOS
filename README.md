# COSMOS

The COSMOS ground system is an open-source spacecraft ground system created by Ball Aerospace. This repo contains
the configuration for a ground station to send commands to and interpret telemetry from UMD BPP payloads.

## Installing COSMOS on Windows
1. Download and install [Ruby 2.2.5 32-bit](http://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-2.2.5.exe). Make sure "Add Ruby executables to your PATH" is checked.

2. Download and run [32-bit Devkit for Ruby 2.0 and Above](http://dl.bintray.com/oneclick/rubyinstaller/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe) and extract to its own folder. 

3. Open the command line and move to the folder you just extracted the Devkit to (in Windows, Shift + RightClick -> "Open command window here") and run the following commands:

        ruby dk.rb init
        
        ruby dk.rb install
        
4. Download [RubyGems, the Ruby package manager](https://rubygems.org/rubygems/rubygems-2.6.8.zip) and extract the ZIP archive to its own folder. After extracting, open a command line windows in the extracted folder and run:

        ruby setup.rb

5. Install COSMOS, as well as its dependencies:

        gem install cosmos

6. Clone this repository using Git to get the configuration for our payloads. For help using Git, read [this guide](http://zrb.io/git/).

7. Start COSMOS by opening your local clone of this repository and running "launcher.bat".


## Installing COSMOS on Ubuntu

Warning: Untested

1. `sudo apt-get install ruby-full`

2. Clone this repo using git

3. Run `ruby Launcher` from the repo to start cosmos

