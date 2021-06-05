#!/bin/sh

if [ `id -u` -ne 0 ]; then
	echo "### $0 must be run as root"
	exit 1
fi

echo "Unload HubKit managers..."

# unload serial port manager
if [ -e "/Library/LaunchDaemons/com.asteria.gravio4.serialportmanager.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio4.serialportmanager.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio4.serialportmanager.agent.plist
	/bin/rm -f /usr/local/bin/GravioSerialPortManager
	/bin/rm -f /usr/local/bin/iotool
fi

# unload bluetooth manager
if [ -e "/Library/LaunchDaemons/com.asteria.gravio4.bluetooth.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio4.bluetooth.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio4.bluetooth.agent.plist
	/bin/rm -f /usr/local/bin/GravioBluetoothManager
fi

# unload video manager
if [ -e "/Library/LaunchDaemons/com.asteria.gravio4.videomanager.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio4.videomanager.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio4.videomanager.agent.plist
	/bin/rm -f /usr/local/bin/GravioVideoManager
fi

# unload ivar manager
if [ -e "/Library/LaunchDaemons/com.asteria.gravio4.ivarmanager.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio4.ivarmanager.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio4.ivarmanager.agent.plist
	/bin/rm -f /usr/local/bin/GravioIVARManager
fi

# unload mqtt manager
if [ -e "/Library/LaunchDaemons/com.asteria.gravio4.mqttmanager.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio4.mqttmanager.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio4.mqttmanager.agent.plist
	/bin/rm -f /usr/local/bin/GravioMQTTManager
fi

# unload trigger manager
if [ -e "/Library/LaunchDaemons/com.asteria.gravio4.triggermanager.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio4.triggermanager.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio4.triggermanager.agent.plist
	/bin/rm -f /usr/local/bin/GravioTriggerManager
fi

# unload action manager
if [ -e "/Library/LaunchDaemons/com.asteria.gravio4.actionmanager.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio4.actionmanager.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio4.actionmanager.agent.plist
	/bin/rm -f /usr/local/bin/GravioActionManager
fi

# unload control manager
if [ -e "/Library/LaunchDaemons/com.asteria.gravio4.controlmanager.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio4.controlmanager.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio4.controlmanager.agent.plist
	/bin/rm -f /usr/local/bin/GravioControlManager
fi

# unload helper
echo "Unload HubKit helper..."
if [ -e "/Library/LaunchDaemons/com.asteria.mac.gravio4.helper.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.mac.gravio4.helper.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.mac.gravio4.helper.plist
fi
/bin/rm -f /Library/PrivilegedHelperTools/com.asteria.mac.gravio4.helper

/usr/bin/security -q authorizationdb remove "com.asteria.mac.gravio4.helper.loadAgents"
/usr/bin/security -q authorizationdb remove "com.asteria.mac.gravio4.helper.unloadAgents"
/usr/bin/security -q authorizationdb remove "com.asteria.mac.gravio4.helper.checkstatus"
/usr/bin/security -q authorizationdb remove "com.asteria.mac.gravio4.helper.unloadhelper"
/usr/bin/security -q authorizationdb remove "com.asteria.mac.gravio4.helper.uninstall"

# delete hubkit app, data and log files
echo "Delete HubKit data..."
/bin/rm -rf /Applications/Gravio\ HubKit\ 4.app
/bin/rm -rf /Library/Application\ Support/HubKit
/bin/rm -rf /Library/Logs/HubKit

# delete cache and preferences
echo "Delete HubKit cache..."
/bin/rm -rf $HOME/Library/Caches/com.asteria.mac.gravio4
/bin/rm -f $HOME/Library/Preferences/com.asteria.mac.gravio4.plist

echo "Done"
