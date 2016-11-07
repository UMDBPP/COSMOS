# COSMOS

The COSMOS ground system is an open-source spacecraft ground system created by Ball Aerospace. This repo contains
the configuration for a ground station to send commands to and interpret telemetry from UMD BPP payloads.

## Installing COSMOS
1. Download and install [Ruby 2.2.5 32-bit](http://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-2.2.5.exe). Make sure "Add Ruby executables to your PATH" is checked.

2. Download the [32-bit Devkit for Ruby 2.0 and Above](http://dl.bintray.com/oneclick/rubyinstaller/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe) and extract to its own folder. 

3. Open a command line and move to the folder you just extracted the Devkit to (in Windows, Shift + RightClick -> "Open command window here") and run the following commands:

        ruby dk.rb init
        
        ruby dk.rb install
        
4. Try running `gem install cosmos` It will likely give you an error about not being able to find COSMOS (which is caused by the ruby package manager being out of date). If so, try updating ruby gems (the ruby package manager) by running `gem update --system`. If that fails as well, follow the instructions on [this page](https://rubygems.org/pages/download/) to update your package manager manually.

5. Download all the dependencies and install COSMOS by running `gem install cosmos`. If this also fails, reboot your computer and try again.

6. Clone this repository, which contains the configuration for our payloads. For help using Git, read [this guide](http://zrb.io/git/).

7. Start COSMOS by running launcher.bat, included in this repository.
