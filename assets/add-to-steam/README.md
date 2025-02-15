[![Donations](https://img.shields.io/badge/Support%20on-Ko--Fi-red)](https://ko-fi.com/suchmememanyskill)

# Add to steam

made by @suchmememanyskill(https://github.com/suchmememanyskill/steam-deck-addons)
all credits do him

This is a simple application that adds the path passed as a commandline argument to Steam. The .desktop file adds an entry to the right click menu in Dolphin of Windows or Linux executables to add them to Steam. This should also work in other kde enviroments. I've only tested it on the Steam Deck and on Manjaro

![Example](https://raw.githubusercontent.com/suchmememanyskill/steam-deckt-addons/main/Dolphin-rightclick-addtosteam/Example.png)

## Notes:
- Accesses the latest logged in user to add the new shortcut to. This hasn't been tested at all. Please open an issue if it's using the wrong userdata folder
- You need to reboot steam to see the changes made to the shortcuts

## Install (Steam deck):
1. Launch into the desktop mode
2. [Download the `add-to-steam.sh` script](https://github.com/llbranco/Pimp-my-Decky/main/assets/add-to-steam/add-to-steam.sh). Save the file when prompted
- em portugês [baixe o `add-to-steam_ptbr.sh` script](https://github.com/llbranco/Pimp-my-Decky/main/assets/add-to-steam/add-to-steam_ptbr.sh). Salve o arquivo
3. Right click `add-to-steam.sh` in Dolphin and select Properties
4. Navigate to the Permissions tab
5. Check 'Is executable', then click 'OK'
6. Right click `add-to-steam.sh` in Dolphin and select 'Run in Konsole'

## Uninstall
1. Navigate to `~/.local/share/kservices5/ServiceMenus` and delete `SimpleSteamShortcutAdder.desktop`
2. Navigate to `~/.bin` and delete `SimpleSteamShortcutAdder`

## Changelog
To download the newest version, re-install the program.

- 1.2.1 @ [steam-deck-addons](https://github.com/suchmememanyskill/steam-deck-addons/commit/3c2b8384d876b1fd45ccd132ac2e2c0205ce03a5): Add source code to this repository
- 1.2 @ [Duplicate](https://github.com/suchmememanyskill/Duplicate/commit/e79826f18177647827e300f57964f261e4c36c78): Hopefully add multiple user support
- 1.1 @ [Duplicate](https://github.com/suchmememanyskill/Duplicate/commit/479116262895a1f98b4af18036fce88c9daf8d68): Add more sanity checks to make debugging easier
- 1.0 @ [Duplicate](https://github.com/suchmememanyskill/Duplicate/commit/55fa634cca516209a1cbf6f11815401c99c6a44a): Initial release 
