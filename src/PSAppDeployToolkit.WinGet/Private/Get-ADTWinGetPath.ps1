#-----------------------------------------------------------------------------
#
# MARK: Get-ADTWinGetPath
#
#-----------------------------------------------------------------------------

function Get-ADTWinGetPath
{
    [CmdletBinding()]
    [OutputType([System.IO.FileInfo])]
    param
    (
    )

    # For the system user, get the path from Program Files directly. For some systems, we can't rely on the
    # output of Get-AppxPackage as it'll update, but Get-AppxPackage won't reflect the new path fast enough.
    $wingetPath = if ($Script:ADT.RunningAsSystem)
    {
        Get-ChildItem -Path "$([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ProgramFiles))\WindowsApps\Microsoft.DesktopAppInstaller*\winget.exe" | Sort-Object -Descending | Select-Object -First 1
    }
    elseif (($wingetCommand = Get-Command -Name winget.exe -ErrorAction Ignore))
    {
        $wingetCommand.Source
    }
    elseif ([System.IO.File]::Exists(($appxPath = "$(Get-AppxPackage -Name Microsoft.DesktopAppInstaller -AllUsers:$Script:ADT.RunningAsSystem | Sort-Object -Property Version -Descending | Select-Object -ExpandProperty InstallLocation -First 1)\winget.exe")))
    {
        $appxPath
    }

    # Throw if we didn't find a WinGet path.
    if (!$wingetPath)
    {
        $naerParams = @{
            Exception = [System.IO.FileNotFoundException]::new("Failed to find a valid path to winget.exe on this system.")
            Category = [System.Management.Automation.ErrorCategory]::InvalidResult
            ErrorId = 'MicrosoftDesktopAppInstallerVersionError'
            RecommendedAction = "Please invoke [Repair-ADTWinGetPackageManager], then try again."
        }
        $PSCmdlet.ThrowTerminatingError((New-ADTErrorRecord @naerParams))
    }

    # Return the found path to the caller.
    return [System.IO.FileInfo]$wingetPath
}
