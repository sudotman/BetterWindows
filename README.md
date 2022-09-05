# Better Windows
A nifty tool made for additions to a usual Windows installation. 

## Purpose
Windows is the most popular OS but setting up a fresh install takes a lot of manual installation/configuration usually and hence this tool was made.
<br>

!["How the application looks"](https://github.com/sudotman/sudotman/blob/main/demos/BetterWindows/overall.png)

## Installation
You can download the latest ```.ps1``` through [Releases](https://github.com/sudotman/BetterWindows/releases/) and right-click and select *'Run with Powershell'*.

or

You can clone/download zip of the repository. 

## Usage
Most things are self-explanatory but just make sure to:
- Install the Prereqs before using most of the things. 
- Right-click and select *'Run with Powershell'*.

# Contents

## 1. Tools / FFMpeg
Fetches FFMpeg's latest release from the release repo, extracts the binary, adds it to PATH too.

!["ffmpeg"](https://github.com/sudotman/sudotman/blob/main/demos/BetterWindows/ffmpeg.png)

## 2. Tools / Remove Bloat
Removes all pre-installed bloatware.

## 2. Tools / Youtube-Dl + Context
Gets the latest Youtube-Dl release and adds it to PATH and adds a context menu entry to download a video anywhere in the directory.

## 3. Prereqs / Git+Chocolatey
Installs Git and Chocolatey silently. The entries below require Git and Chocolatey to be installed.

## 4. Chocolatey / Development Essentials
Fetches and installs:
- Visual Studio Code
- NodeJS
- Notepad++
- 7Zip


## 5. Chocolatey / Gaming Essentials
Fetches and installs:
- Epic Games Launcher
- RetroArch
- Steam
- Discord

## 6. Chocolatey / Entertainment Essentials
Fetches and installs:
- VLC
- Spotify

## 7 Chocolatey / Satyam Essentials
Fetches and installs:
Development and entertainment plus:
- Android Debug Bridge

## 8. Why / Rebloat
If for some reason, you would want to rebloat your device in a proper way.



## To-Do:
- ~~Add a Debloater type script too to make it a one-stop solution. (Maybe fork the famous windows10debloater)~~
- Reorganize the script a little bit (maybe a more procedural main-function based script)
- Maybe rework the UI (not really needed as the basic selection menu gets the work done but would be more pleasing)
- Remove redundant code, maybe have string selections/array selections to fetch chocolatey for example. And, also divide them into functions.
