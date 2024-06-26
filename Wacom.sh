#!/bin/sh


WacomPersistentPlist="/Library/Containers/com.wacom.DataStoreMgr/Data/Library/Preferences/.wacom/persistent.plist"
WacomTabletPrefs="/Library/Group Containers/EG27766DY7.com.wacom.WacomTabletDriver/Library/Preferences/com.wacom.wacomtablet.prefs"
userName=USER1

echo "/Users/$userName"$(/usr/bin/dirname "${WacomTabletPrefs}")``