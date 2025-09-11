#!/bin/bash

if [ -f /Library/LaunchDaemons/labstatsgo.plist ]; then
  launchctl unload /Library/LaunchDaemons/labstatsgo.plist
fi

if [ -f /Library/LaunchAgents/labstatsgo.plist ]; then
  sudo -u daemon launchctl unload /Library/LaunchAgents/labstatsgo.plist
fi

if [ -f /Library/LaunchDaemons/labstatsgo.plist ]; then
  rm -f /Library/LaunchDaemons/labstatsgo.plist
fi

if [ -f /Library/LaunchAgents/labstatsgo.plist ]; then
  rm -f /Library/LaunchAgents/labstatsgo.plist
fi

pkill LabStatsGoUserSpace

if [ -f /usr/local/bin/LabStatsGoClient ]; then
  rm -f /usr/local/bin/LabStatsGoClient
fi

if [ -f /usr/local/bin/LabStatsGoUserSpace ]; then
  rm -f /usr/local/bin/LabStatsGoUserSpace
fi

rm -rf /Library/Application\ Support/LabStatsGo

echo Uninstall successful!