# Windows HubKit uninstall Cleanup
# Cleans up a bit more thoroughly after an Uninstall has occurred

# Runs the HubKit uninstaller
# Runs the Studio uninstaller
# Deletes old Registry Keys not caught by the uninstallers
# Deletes files and folders left over
# Closes Firewall ports from Studio (29440-29450)


Param(
    [switch]$Execute=$false,
    [switch]$RemoveStudio=$false,
    [switch]$RemoveHubKit=$false
)

function print {
    param([string] $message)
    $d = (get-date).tostring("MM/dd/yyyy @ HH:mm tt")
    $m = "[$d] $message"
    echo $m
}

function Main {
    print "Clearing old Gravio Files...";
    if(-not $Execute) {
        print ""
        print "This is script is being run in Dry Run mode. It will show you what will be deleted, but not delete the items"
        print "To actually delete the reported items, run the script again with the --Execute=True argument"
        print ""
    }
    $regs = FindExistingRegistryItems
    $dirs = FindExistingFolders
    $fwrules = GetGravioFirewallRules
    if ($RemoveStudio) {
        if (IsStudioInstalled) {
            $appx = GetStudioPackageReference
            print "Will remove Gravio Studio ($($appx.PackageFullName))"
        }
        else {
            print "Gravio Studio was not found on this machine, or was already uninstalled. Open Gravio ports will still be closed"
        }
    }
    if ($RemoveHubKit) {
        if (IsHubkitInstalled)  {
            $b = get-wmiobject -Class win32_product -Filter "Name like 'Gravio Hubkit%'" | Select -First 1 # get the Gravio Hubkit instance
            print "Will remove Gravio HubKit ($($b.Name))"
        }
        else {
            print "HubKit was not found on this machine, or was already uninstalled. Leftover items will still be deleted."
        }
    }
    print "Will delete $($fwrules.length) firewall rules"
    if ($fwrules.length -gt 0) {
        foreach($i in $fwrules) {
            print "  - $($i.Name)`n`t`t`t`t`t`t`t`t`t`tDirection: $($i.Direction) ($($i.Action)) ($($i.LocalPort))"
            #print "     "
        }
    }
    print “Will delete $($regs.length) registry keys"
    if ($regs.length -gt 0) {
        foreach($i in $regs) {
            print "  - $($i)"
        }
    }
    print “Will delete $($dirs.length) folders"
    if ($dirs.length -gt 0) {
        foreach($i in $dirs) {
            print "  - $($i)"
        }
    }
    # doesnt execute unless explicitly told to
    if ($Execute) {
        if($RemoveStudio -and (IsStudioInstalled)) {
            UninstallGravioStudio
        }
        if ($RemoveHubKit) {
            if (IsHubkitInstalled) {
                UninstallHubKit
            }
            if ($regs.length -gt 0) {
                ClearRegistry $regs
            }
            if ($dirs.length -gt 0) {
                ClearFolders $dirs
            }
        }
        if (($RemoveStudio -or $RemoveHubKit) -and ($fwrules -ne $null)) {
            CloseFirewallRules $fwrules
        }
    }

}

# Returns the list of Registry Keys that should be deleted
function FindExistingRegistryItems {
    # No registry keys are left over after an uninstall
    $regs = @();
    return $regs
}

# Given a list of strings as registry keys, clear them
# Returns 0 if successful, 1 if failure
function ClearRegistry {
    param(
        [Parameter(Mandatory=$True)]
        [string[]] $RegistryKeys
    )
    $error = 0
    # todo
    return $error
}

# Returns the list of Folders that should be deleted
function FindExistingFolders {
    $folders = @('C:\Documents and Settings\All Users\HubKit','C:\ProgramData\HubKit')
    $deleteMe = @();
    foreach ($i in $folders) {
        if(Test-Path $i) {
            $deleteMe += $i;
        }
    }
    return $deleteMe;
}

# Given a list of strings as registry keys, delete them form the Registry
# Returns 0 if successful, 1 if failure
function ClearFolders{
    param(
        [Parameter(Mandatory=$True)]
        [string[]] $Folders
    )
    $error = 0
    foreach($i in $Folders) {
        if (Test-Path $i) {
            Remove-Item -Recurse -Force $i
        }
    }
    print "deleted $($Folders.length) items"
    return $error
}

# Returns $True if Studio is installed on the system
function IsStudioInstalled {
    $appx = GetStudioPackageReference
    return ($appx -ne $null)
}

# Returns an Appx Package reference to Gravio Studio 4
# or $null if not installed
function GetStudioPackageReference {
    $appx = Get-AppxPackage -Name "InfoteriaPte.Ltd.GravioStudio4"
    return $appx
}

# Silently uninstalls Studio
# Returns 0 if successful, 1 if failure
function UninstallGravioStudio {
    $error = 0
    print "Stopping Gravio Studio"
    Get-Process -Name gs* | Stop-Process
    print "Uninstalling Gravio Studio"
    $appx = GetStudioPackageReference
    Remove-AppxPackage -Package $appx.PackageFullName
    print "Finished uninstalling Gravio Studio"
    return $error
}

# Silently uninstalls HubKit
# Returns 0 if successful, 1 if failure
function UninstallHubkit {
$error = 0
$Activity = "Uninstalling HubKit..."
Write-Progress -Activity $Activity -Status "Processing" -PercentComplete 0;

print "Stopping Gravio Services"
Write-Progress -Activity $Activity -Status "Stopping Gravio Services" -PercentComplete 20;
Get-Service -Name *Gravio* | ?{$_.status -eq 'running'} | Stop-Service # Stop gravio services

print "Stopping the Hubkit instance"
Write-Progress -Activity $Activity -Status "Stopping Hubkit Instance" -PercentComplete 40;
Get-Process -Name *GravioTools* | Stop-Process # Stop Gravio Tools
$b = get-wmiobject -Class win32_product -Filter "Name like 'Gravio Hubkit%'" | Select -First 1 # get the Gravio Hubkit instance
print "Uninstalling Hubkit"
Write-Progress -Activity $Activity -Status "Uninstalling Hubkit" -PercentComplete 80;

$m = ""

if ($b -eq $null) {
    Write-Progress -Activity $Activity -Status "Uninstalling Hubkit" -PercentComplete 100;
    $m ="Hubkit was already uninstalled."
    print $m
} else {
    $ret = $b.Uninstall(); # Uninstall it
    if ($ret.ReturnValue -ne 0) {
        Write-Progress -Activity $Activity -Status "Uninstalling Hubkit" -PercentComplete 100;
        Write-Error ("Issue uninstalling Gravio Hubkit: error code" + $ret.ReturnValue)
        $Output = $wshell.Popup("Hubkit Failed to Uninstall")
        $error = $ret.ReturnValue
    } else {
        $m = "successfully uninstalled Gravio Hubkit"
        print $m
    }
}
Write-Progress -Activity "Uninstallation in Progress" -Status "Processing" -PercentComplete 100;
return $error
}

# Returns $True if Hubkit is installed on the system
function IsHubkitInstalled {
    $b = get-wmiobject -Class win32_product -Filter "Name like 'Gravio Hubkit%'" | Select -First 1 # get the Gravio Hubkit instance
    return ($b -ne $null)
}


# Returns the list of Firewall rules that contain the Name "gravio"
function GetGravioFirewallRules {
    return Show-NetFirewallRule | Where-Object {$_.Name -like "*gravio*"}
}

# Studio and Hubkit use ports 29440-29450
# This will close any rules that have the name "Gravio" in them
# Returns 0 if successful, 1 if failure
function CloseFirewallRules {
    param(
        [Parameter(Mandatory=$True)]
        [Microsoft.Management.Infrastructure.CimInstance[]] $FirewallRules
    )
    $error = 0

    foreach($fwr in $FirewallRules) {
        Remove-NetFirewallRule -InputObject $fwr
    }

    return $error    
}

Main