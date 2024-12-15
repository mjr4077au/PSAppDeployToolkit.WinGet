#-----------------------------------------------------------------------------
#
# MARK: Assert-ADTWinGetPackageManager
#
#-----------------------------------------------------------------------------

function Assert-ADTWinGetPackageManager
{
    <#
    .SYNOPSIS
        Verifies that WinGet is installed properly.

    .DESCRIPTION
        Verifies that WinGet is installed properly.

        Note: The cmdlet doesn't ensure that the latest version of WinGet is installed. It just verifies that the installed version of Winget is supported by installed version of this module.

    .INPUTS
        None

        You cannot pipe objects to this function.

    .OUTPUTS
        None

        This function does not return any output.

    .EXAMPLE
        Assert-ADTWinGetPackageManager

        If the current version of WinGet is installed correctly, the command returns without error.

    .LINK
        https://github.com/mjr4077au/PSAppDeployToolkit.WinGet
    #>

    [CmdletBinding()]
    param
    (
    )

    # Try to get the WinGet version.
    try
    {
        [System.Version]$wingetVer = (Get-ADTWinGetVersion -InformationAction SilentlyContinue).Trim('v')
    }
    catch
    {
        $PSCmdlet.ThrowTerminatingError($_)
    }

    # Test that the retrieved version is greater than or equal to our minimum.
    if ($wingetVer -lt $Script:ADT.WinGetMinVersion)
    {
        $naerParams = @{
            Exception = [System.Activities.VersionMismatchException]::new("The installed WinGet version of [$wingetVer] is less than [$($Script:ADT.WinGetMinVersion)].", [System.Activities.WorkflowIdentity]::new('winget.exe', $wingetVer, $wingetPath.FullName), [System.Activities.WorkflowIdentity]::new('winget.exe', $Script:ADT.WinGetMinVersion, $wingetPath.FullName))
            Category = [System.Management.Automation.ErrorCategory]::InvalidResult
            ErrorId = 'WinGetMinimumVersionError'
            RecommendedAction = "Please run [Repair-ADTWinGetPackageManager] as an admin, then try again."
        }
        $PSCmdlet.ThrowTerminatingError((New-ADTErrorRecord @naerParams))
    }
}
