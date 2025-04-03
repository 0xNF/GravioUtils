#!/bin/sh

if [ `id -u` -ne 0 ]; then
	echo "### $0 must be run as root"
	exit 1
fi

echo "Delete Gravio Studio..."

# delete gravio studio app, data and scripts
/bin/rm -rf /Applications/Gravio\ Studio.app
/bin/rm -rf $HOME/Library/Containers/com.asteria.mac.graviostudio4
/bin/rm -rf $HOME/Library/Application\ Scripts/com.asteria.mac.graviostudio4

echo "Unload HubKit services..."

# unload serial port manager
if [ -e "/Library/LaunchDaemons/com.asteria.gravio.serialportmanager.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio.serialportmanager.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio.serialportmanager.agent.plist
	/bin/rm -f /usr/local/bin/GravioSerialPortManager
	/bin/rm -f /usr/local/bin/iotool
fi

# unload bluetooth manager
if [ -e "/Library/LaunchDaemons/com.asteria.gravio.bluetooth.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio.bluetooth.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio.bluetooth.agent.plist
	/bin/rm -f /usr/local/bin/GravioBluetoothManager
fi

# unload video manager
if [ -e "/Library/LaunchDaemons/com.asteria.gravio.videomanager.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio.videomanager.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio.videomanager.agent.plist
	/bin/rm -f /usr/local/bin/GravioVideoManager
fi

# unload image processing manager
if [ -e "/Library/LaunchDaemons/com.asteria.gravio.imageprocessingmanager.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio.imageprocessingmanager.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio.imageprocessingmanager.agent.plist
	/bin/rm -f /usr/local/bin/GravioImageProcessingManager
fi

# unload mqtt manager
if [ -e "/Library/LaunchDaemons/com.asteria.gravio.mqttmanager.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio.mqttmanager.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio.mqttmanager.agent.plist
	/bin/rm -f /usr/local/bin/GravioMQTTManager
fi

# unload trigger manager
if [ -e "/Library/LaunchDaemons/com.asteria.gravio.triggermanager.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio.triggermanager.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio.triggermanager.agent.plist
	/bin/rm -f /usr/local/bin/GravioTriggerManager
fi

# unload action manager
if [ -e "/Library/LaunchDaemons/com.asteria.gravio.actionmanager.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio.actionmanager.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio.actionmanager.agent.plist
	/bin/rm -f /usr/local/bin/GravioActionManager
fi

# unload control manager
if [ -e "/Library/LaunchDaemons/com.asteria.gravio.controlmanager.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio.controlmanager.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio.controlmanager.agent.plist
	/bin/rm -f /usr/local/bin/GravioControlManager
fi

# unload app service
if [ -e "/Library/LaunchDaemons/com.asteria.gravio.appservice.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio.appservice.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio.appservice.agent.plist
	/bin/rm -f /usr/local/bin/GravioAppService
fi

# unload coordinator
if [ -e "/Library/LaunchDaemons/com.asteria.gravio.coordinator.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio.coordinator.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio.coordinator.agent.plist
	/bin/rm -f /usr/local/bin/Coordinator
fi

# unload configuration manager
if [ -e "/Library/LaunchDaemons/com.asteria.gravio.configurationmanager.agent.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.gravio.configurationmanager.agent.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.gravio.configurationmanager.agent.plist
	/bin/rm -f /usr/local/bin/ConfigurationManager
fi

# unload helper
echo "Unload HubKit helper..."
if [ -e "/Library/LaunchDaemons/com.asteria.mac.gravio.helper.plist" ]; then
	/bin/launchctl unload /Library/LaunchDaemons/com.asteria.mac.gravio.helper.plist 2> /dev/null
	/bin/rm -f /Library/LaunchDaemons/com.asteria.mac.gravio.helper.plist
fi
/bin/rm -f /Library/PrivilegedHelperTools/com.asteria.mac.gravio.helper

/usr/bin/security -q authorizationdb remove "com.asteria.mac.gravio.helper.loadAgents"
/usr/bin/security -q authorizationdb remove "com.asteria.mac.gravio.helper.unloadAgents"
/usr/bin/security -q authorizationdb remove "com.asteria.mac.gravio.helper.checkstatus"
/usr/bin/security -q authorizationdb remove "com.asteria.mac.gravio.helper.unloadhelper"
/usr/bin/security -q authorizationdb remove "com.asteria.mac.gravio.helper.uninstall"

# delete hubkit app, data and log files
echo "Delete HubKit data..."
/bin/rm -rf /Applications/Gravio\ HubKit.app
/bin/rm -rf /Library/Application\ Support/HubKit
/bin/rm -rf /Library/Logs/HubKit

# delete cache and preferences
echo "Delete HubKit cache..."
/bin/rm -rf $HOME/Library/Caches/com.asteria.mac.gravio4
/bin/rm -f $HOME/Library/Preferences/com.asteria.mac.gravio4.plist

echo "Done"
