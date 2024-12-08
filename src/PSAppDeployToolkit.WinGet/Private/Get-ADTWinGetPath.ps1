#-----------------------------------------------------------------------------
#
# MARK: Get-ADTWinGetPath
#
#-----------------------------------------------------------------------------

function Get-ADTWinGetPath
{
    # Internal function to get the WinGet Path. We can't rely on the output of Get-AppxPackage for some systems as it'll update, but Get-AppxPackage won't reflect the new path fast enough.
    function Out-ADTWinGetPath
    {
        # For the system user, get the path from Program Files directly.
        if ($Script:ADT.RunningAsSystem)
        {
            return (Get-ChildItem -Path "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ProgramFiles))\WindowsApps\Microsoft.DesktopAppInstaller*\winget.exe" | Sort-Object -Descending | Select-Object -First 1)
        }
        elseif ([System.IO.File]::Exists(($wingetPath = "$(Get-AppxPackage -Name Microsoft.DesktopAppInstaller -AllUsers:$Script:ADT.RunningAsSystem | Sort-Object -Property Version -Descending | Select-Object -ExpandProperty InstallLocation -First 1)\winget.exe")))
        {
            return $wingetPath
        }
    }

    # Test whether WinGet is installed and available at all.
    if (!($wingetPath = Out-ADTWinGetPath) -or ![System.IO.File]::Exists($wingetPath))
    {
        # Throw if we're not admin.
        if (!$Script:ADT.RunningAsAdmin)
        {
            $naerParams = @{
                Exception = [System.UnauthorizedAccessException]::new("WinGet is not installed. Please install Microsoft.DesktopAppInstaller and try again.")
                Category = [System.Management.Automation.ErrorCategory]::PermissionDenied
                ErrorId = 'MicrosoftDesktopAppInstallerCannotInstallFailure'
                RecommendedAction = "Please install Microsoft.DesktopAppInstaller as an admin, then try again."
            }
            throw (New-ADTErrorRecord @naerParams)
        }

        # Install Microsoft.DesktopAppInstaller.
        Install-ADTWinGetDesktopAppInstallerDependency

        # Throw if the installation was successful but we still don't have WinGet.
        if (!($wingetPath = Out-ADTWinGetPath) -or ![System.IO.File]::Exists($wingetPath))
        {
            $naerParams = @{
                Exception = [System.InvalidOperationException]::new("Failed to get a valid WinGet path after successfully pre-provisioning the app. Please report this issue for further analysis.")
                Category = [System.Management.Automation.ErrorCategory]::InvalidResult
                ErrorId = 'MicrosoftDesktopAppInstallerMissingFailure'
                RecommendedAction = "Please report this issue to the project's maintainer for further analysis."
            }
            throw (New-ADTErrorRecord @naerParams)
        }
    }

    # Test whether we have any output from winget.exe. If this is null, it typically means the appropriate MSVC++ runtime is not installed.
    if (!($wingetOutput = & $wingetPath))
    {
        # Throw if we're not admin.
        if (!$Script:ADT.RunningAsAdmin)
        {
            $naerParams = @{
                Exception = [System.UnauthorizedAccessException]::new("The installed version of WinGet was unable to run. Please ensure the latest Visual Studio 2015-2022 Runtime is installed and try again.")
                Category = [System.Management.Automation.ErrorCategory]::PermissionDenied
                ErrorId = 'VcRedistCannotInstallFailure'
                RecommendedAction = "Please install the latest Visual Studio 2015-2022 Runtime as an admin, then try again."
            }
            throw (New-ADTErrorRecord @naerParams)
        }

        # Install MSVCRT onto device.
        Install-ADTWinGetVcRedistDependency

        # Throw if we're still not able to run WinGet.
        if (!($wingetOutput = & $wingetPath))
        {
            $naerParams = @{
                Exception = [System.InvalidOperationException]::new("The installed version of WinGet was unable to run. This is possibly related to the Visual Studio 2015-2022 Runtime.")
                Category = [System.Management.Automation.ErrorCategory]::InvalidResult
                ErrorId = 'MicrosoftDesktopAppInstallerExecutionFailure'
                RecommendedAction = "Please verify that WinGet.exe can run on this system, then try again."
            }
            throw (New-ADTErrorRecord @naerParams)
        }
    }

    # Ensure winget.exe is above the minimum version.
    if ([System.Version](($wingetOutput | Select-Object -First 1) -replace '^.+\sv') -lt $Script:ADT.WinGetMinVersion)
    {
        # Throw if we're not admin.
        if (!$Script:ADT.RunningAsAdmin)
        {
            $naerParams = @{
                Exception = [System.UnauthorizedAccessException]::new("The installed version of WinGet is less than $($Script:ADT.WinGetMinVersion). Please update Microsoft.DesktopAppInstaller and try again.")
                Category = [System.Management.Automation.ErrorCategory]::PermissionDenied
                ErrorId = 'VcRedistCannotInstallFailure'
                RecommendedAction = "Please update Microsoft.DesktopAppInstaller as an admin, then try again."
            }
            throw (New-ADTErrorRecord @naerParams)
        }

        # Install the missing dependency and reset variables.
        Install-ADTWinGetDesktopAppInstallerDependency
        $wingetPath = Out-ADTWinGetPath

        # Ensure winget.exe is above the minimum version.
        if ([System.Version]($wingetVer = (($wingetOutput = & $wingetPath) | Select-Object -First 1) -replace '^.+\sv') -lt $Script:ADT.WinGetMinVersion)
        {
            $naerParams = @{
                Exception = [System.InvalidOperationException]::new("The installed WinGet version of $wingetVer is less than $($Script:ADT.WinGetMinVersion). Please check the DISM pre-provisioning logs and try again.")
                Category = [System.Management.Automation.ErrorCategory]::InvalidResult
                ErrorId = 'MicrosoftDesktopAppInstallerVersionError'
                RecommendedAction = "Please check the DISM pre-provisioning logs, then try again."
            }
            throw (New-ADTErrorRecord @naerParams)
        }

        # Reset WinGet sources after updating. Helps with a corner-case issue discovered.
        Write-ADTLogEntry -Message "Resetting all WinGet sources following update, please wait..."
        if (!($wgSrcRes = & $wingetPath source reset --force 2>&1).Equals('Resetting all sources...Done'))
        {
            Write-ADTLogEntry -Message "An issue occurred while resetting WinGet sources [$($wgSrcRes.TrimEnd('.'))]. Continuing with operation." -Severity 2
        }
    }

    # Return tested path to the caller.
    Write-ADTLogEntry -Message "Using WinGet path [$wingetPath]."
    return $wingetPath
}
