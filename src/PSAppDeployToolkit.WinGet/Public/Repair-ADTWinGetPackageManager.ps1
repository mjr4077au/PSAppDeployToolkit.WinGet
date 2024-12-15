#-----------------------------------------------------------------------------
#
# MARK: Repair-ADTWinGetPackageManager
#
#-----------------------------------------------------------------------------

function Repair-ADTWinGetPackageManager
{
    <#
    .SYNOPSIS
        Repairs the installation of the WinGet client on your computer.

    .DESCRIPTION
        This command repairs the installation of the WinGet client on your computer by installing the specified version or the latest version of the client. This command can also install the WinGet client if it is not already installed on your machine. It ensures that the client is installed in a working state.

    .INPUTS
        None

        You cannot pipe objects to this function.

    .OUTPUTS
        None

        This function does not return any output.

    .EXAMPLE
        Repair-ADTWinGetPackageManager

        This example shows how to repair they WinGet client by installing the latest version and ensuring it functions properly.

    .LINK
        https://github.com/mjr4077au/PSAppDeployToolkit.WinGet
    #>

    [CmdletBinding()]
    param
    (
    )

    begin
    {
        # Initialize function.
        Initialize-ADTFunction -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
    }

    process
    {
        try
        {
            try
            {
                # Test whether WinGet is installed and available at all.
                Write-ADTLogEntry -Message "Confirming whether [Microsoft.DesktopAppInstaller] is installed, please wait..."
                if (!($wingetPath = Get-ADTWinGetPath) -or !$wingetPath.Exists)
                {
                    # Throw if we're not admin.
                    if (!$Script:ADT.RunningAsAdmin)
                    {
                        $naerParams = @{
                            Exception = [System.UnauthorizedAccessException]::new("WinGet is not installed. Please install [Microsoft.DesktopAppInstaller] and try again.")
                            Category = [System.Management.Automation.ErrorCategory]::PermissionDenied
                            ErrorId = 'MicrosoftDesktopAppInstallerCannotInstallFailure'
                            RecommendedAction = "Please install [Microsoft.DesktopAppInstaller] as an admin, then try again."
                        }
                        throw (New-ADTErrorRecord @naerParams)
                    }

                    # Install Microsoft.DesktopAppInstaller.
                    Repair-ADTWinGetDesktopAppInstaller

                    # Throw if the installation was successful but we still don't have WinGet.
                    if (!($wingetPath = Get-ADTWinGetPath) -or !$wingetPath.Exists)
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
                else
                {
                    Write-ADTLogEntry -Message "Successfully confirmed that [Microsoft.DesktopAppInstaller] is installed on system."
                }

                # Test whether we have any output from winget.exe. If this is null, it typically means the appropriate MSVC++ runtime is not installed.
                Write-ADTLogEntry -Message "Testing whether [Microsoft Visual C++ 2015-2022 Runtime] is installed, please wait..."
                if (!(& $wingetPath))
                {
                    # Throw if we're not admin.
                    if (!$Script:ADT.RunningAsAdmin)
                    {
                        $naerParams = @{
                            Exception = [System.InvalidOperationException]::new("The installed version of WinGet was unable to run. Please ensure the latest [Microsoft Visual C++ 2015-2022 Runtime] is installed and try again.")
                            Category = [System.Management.Automation.ErrorCategory]::PermissionDenied
                            ErrorId = 'VcRedistCannotInstallFailure'
                            RecommendedAction = "Please install the latest [Microsoft Visual C++ 2015-2022 Runtime] as an admin, then try again."
                        }
                        throw (New-ADTErrorRecord @naerParams)
                    }

                    # Install MSVCRT onto device.
                    Repair-ADTWinGetVisualStudioRuntime

                    # Throw if we're still not able to run WinGet.
                    if (!(& $wingetPath))
                    {
                        $naerParams = @{
                            Exception = [System.InvalidOperationException]::new("The installed version of WinGet was unable to run. This is possibly related to a missing [Microsoft Visual C++ 2015-2022 Runtime] library.")
                            Category = [System.Management.Automation.ErrorCategory]::InvalidResult
                            ErrorId = 'MicrosoftDesktopAppInstallerExecutionFailure'
                            RecommendedAction = "Please verify that WinGet.exe can run on this system, then try again."
                        }
                        throw (New-ADTErrorRecord @naerParams)
                    }
                }
                else
                {
                    Write-ADTLogEntry -Message "Successfully confirmed that [Microsoft Visual C++ 2015-2022 Runtime] is installed on system."
                }

                # Ensure winget.exe is above the minimum version.
                Write-ADTLogEntry -Message "Testing whether the installed WinGet is version [$($Script:ADT.WinGetMinVersion)] or higher, please wait..."
                if (([System.Version]$wingetVer = (Get-ADTWinGetVersion -InformationAction SilentlyContinue).Trim('v')) -lt $Script:ADT.WinGetMinVersion)
                {
                    # Throw if we're not admin.
                    if (!$Script:ADT.RunningAsAdmin)
                    {
                        $naerParams = @{
                            Exception = [System.Activities.VersionMismatchException]::new("The installed WinGet version of [$wingetVer] is less than [$($Script:ADT.WinGetMinVersion)]. Please update [Microsoft.DesktopAppInstaller] and try again.", [System.Activities.WorkflowIdentity]::new('winget.exe', $wingetVer, $wingetPath.FullName), [System.Activities.WorkflowIdentity]::new('winget.exe', $Script:ADT.WinGetMinVersion, $wingetPath.FullName))
                            Category = [System.Management.Automation.ErrorCategory]::PermissionDenied
                            ErrorId = 'VcRedistCannotInstallFailure'
                            RecommendedAction = "Please update [Microsoft.DesktopAppInstaller] as an admin, then try again."
                        }
                        throw (New-ADTErrorRecord @naerParams)
                    }

                    # Install the missing dependency and reset variables.
                    Repair-ADTWinGetDesktopAppInstaller
                    $wingetPath = Get-ADTWinGetPath

                    # Ensure winget.exe is above the minimum version.
                    if (([System.Version]$wingetVer = (Get-ADTWinGetVersion -InformationAction SilentlyContinue).Trim('v')) -lt $Script:ADT.WinGetMinVersion)
                    {
                        $naerParams = @{
                            Exception = [System.Activities.VersionMismatchException]::new("The installed WinGet version of [$wingetVer] is less than [$($Script:ADT.WinGetMinVersion)]. Please check the DISM pre-provisioning logs and try again.", [System.Activities.WorkflowIdentity]::new('winget.exe', $wingetVer, $wingetPath.FullName), [System.Activities.WorkflowIdentity]::new('winget.exe', $Script:ADT.WinGetMinVersion, $wingetPath.FullName))
                            Category = [System.Management.Automation.ErrorCategory]::InvalidResult
                            ErrorId = 'MicrosoftDesktopAppInstallerVersionError'
                            RecommendedAction = "Please check the DISM pre-provisioning logs, then try again."
                        }
                        throw (New-ADTErrorRecord @naerParams)
                    }

                    # Reset WinGet sources after updating. Helps with a corner-case issue discovered.
                    Reset-ADTWinGetSource -All
                }
                else
                {
                    Write-ADTLogEntry -Message "Successfully confirmed WinGet version [$wingetVer] is installed on system."
                }
            }
            catch
            {
                # Re-writing the ErrorRecord with Write-Error ensures the correct PositionMessage is used.
                Write-Error -ErrorRecord $_
            }
        }
        catch
        {
            # Process the caught error, log it and throw depending on the specified ErrorAction.
            Invoke-ADTFunctionErrorHandler -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorRecord $_
        }
    }

    end
    {
        # Finalize function.
        Complete-ADTFunction -Cmdlet $PSCmdlet
    }
}
