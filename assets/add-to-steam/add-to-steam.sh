#!/bin/bash

echo Hello! This script will add an 'add to steam' button to the right click menu of applications
echo Making directories..
mkdir -p ~/.local/share/kservices5/ServiceMenus
mkdir -p ~/.bin

echo Downloading files..
curl https://github.com/llbranco/Pimp-my-Decky/main/assets/add-to-steam/SimpleSteamShortcutAdder -L -o ~/.bin/SimpleSteamShortcutAdder

curl https://raw.githubusercontent.com/llbranco/Pimp-my-Decky/main/assets/add-to-steam/SimpleSteamShortcutAdder.desktop -o ~/.local/share/kservices5/ServiceMenus/SimpleSteamShortcutAdder.desktop

echo Setting permissions..
chmod a+x ~/.bin/SimpleSteamShortcutAdder

read -p "Done! Press enter to exit"
