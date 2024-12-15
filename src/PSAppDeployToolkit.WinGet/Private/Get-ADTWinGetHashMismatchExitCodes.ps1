#-----------------------------------------------------------------------------
#
# MARK: Get-ADTWinGetHashMismatchExitCodes
#
#-----------------------------------------------------------------------------

function Get-ADTWinGetHashMismatchExitCodes
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = "This function is appropriately named and we don't need PSScriptAnalyzer telling us otherwise.")]
    [CmdletBinding()]
    [OutputType([System.Int32])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [pscustomobject]$Manifest,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [pscustomobject]$Installer,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$FilePath
    )

    # Try to get switches from the installer, then the manifest, then by whatever known defaults we have.
    if ($Installer.PSObject.Properties.Name.Contains('InstallerSuccessCodes'))
    {
        return $Installer.InstallerSuccessCodes
    }
    elseif ($Manifest.PSObject.Properties.Name.Contains('InstallerSuccessCodes'))
    {
        return $Manifest.InstallerSuccessCodes
    }
    else
    {
        # Zero is valid for everything.
        0

        # Factor in two msiexec.exe-specific exit codes.
        if ($FilePath.EndsWith('msi'))
        {
            1641  # Machine needs immediate reboot.
            3010  # Reboot should be rebooted.
        }
    }
}
