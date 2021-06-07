# Gravio Utils
This repository collects useful tools for working with Gravio


# Uninstallation Scripts
Uninstalling Gravio can leave some artifacts on the machine. These scripts do their best to clean up those artifacts.
These scripts also uninstall Gravio Studio

## Mac
1. mac/scripts/completely_uninstall_gravio_mac_sh.sh
## Windows
1. win/scripts/GravioCleanUninstall.ps1


# Log Utilities
These tools make working with Gravio's log output easier/more useful/add additional miscellaneous features

* lin/scripts/ActionSpeed.py
    This script takes a log file or a directory of log files and produces statistics on Action execution speed:
    ```bash
     python .\ActionSpeed.py txt  C:\Users\user\Desktop\glogs\*
     Action Name (ms)     Count                Mean                 Median               Mode                 Min                  Max                  Standard Dev         
    lightToGreen              2588                 2.763                2.842                0.18                 0.162                10.043               1.076
    lightToRed                31                   1.607                2.611                0.18                 0.169                3.105                1.334
    co2ToRed                  2345                 2.229                1.735                1.564                1.472                5.449                0.948
    co2ToYellow               14                   1.952                2.448                0.176                0.176                2.968                1.178
    ```