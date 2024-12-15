#-----------------------------------------------------------------------------
#
# MARK: Get-ADTWinGetHashMismatchArgumentList
#
#-----------------------------------------------------------------------------

function Get-ADTWinGetHashMismatchArgumentList
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = "This function is appropriately named and we don't need PSScriptAnalyzer telling us otherwise.")]
    [CmdletBinding()]
    [OutputType([System.String])]
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
        [System.String]$FilePath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$LogFile
    )

    # Internal filter to process manifest install switches.
    filter Get-ADTWinGetManifestInstallSwitches
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = "This function is appropriately named and we don't need PSScriptAnalyzer telling us otherwise.")]
        [CmdletBinding()]
        param
        (
            [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
            [ValidateNotNullOrEmpty()]
            [pscustomobject]$InputObject,

            [Parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [System.String]$Type
        )

        # Test whether the piped object has InstallerSwitches and it's not null.
        if (($InputObject.PSObject.Properties.Name -notcontains 'InstallerSwitches') -or ($null -eq $InputObject.InstallerSwitches))
        {
            return
        }

        # Return the requested type. This will be null if its not available.
        return $InputObject.InstallerSwitches.PSObject.Properties | Where-Object { $_.Name -eq $Type } | Select-Object -ExpandProperty Value
    }

    # Internal function to return default install switches based on type.
    function Get-ADTDefaultKnownSwitches
    {
        [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = "This function is appropriately named and we don't need PSScriptAnalyzer telling us otherwise.")]
        [CmdletBinding()]
        [OutputType([System.String])]
        param
        (
            [Parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [System.String]$InstallerType
        )

        # Switch on the installer type and return an array of strings for the args.
        switch -Regex ($InstallerType)
        {
            '^(Burn|Wix|Msi)$'
            {
                "/quiet"
                "/norestart"
                "/log `"$LogFile`""
                break
            }
            '^Nullsoft$'
            {
                "/S"
                break
            }
            '^Inno$'
            {
                "/VERYSILENT"
                "/NORESTART"
                "/LOG=`"$LogFile`""
                break
            }
            default
            {
                $naerParams = @{
                    Exception = [System.InvalidOperationException]::new("The installer type '$_' is unsupported.")
                    Category = [System.Management.Automation.ErrorCategory]::InvalidData
                    ErrorId = 'WinGetInstallerTypeUnknown'
                    TargetObject = $_
                    RecommendedAction = "Please report the installer type to the project's maintainer for further review."
                }
                $PSCmdlet.ThrowTerminatingError((New-ADTErrorRecord @naerParams))
            }
        }
    }

    # Add standard msiexec.exe args.
    if ($FilePath.EndsWith('msi'))
    {
        "/i `"$FilePath`""
    }

    # If we're not overriding, get silent switches from manifest and $Custom if we can.
    if (!$Override)
    {
        # Try to get switches from the installer, then the manifest, then by what the installer is, either from the installer or the manifest.
        if ($switches = $Installer | Get-ADTWinGetManifestInstallSwitches -Type Silent)
        {
            # First check the installer array for a silent switch.
            $switches
            Write-ADTLogEntry -Message "Using Silent switches from the manifest's installer data."
        }
        elseif ($switches = $Manifest | Get-ADTWinGetManifestInstallSwitches -Type Silent)
        {
            # Fall back to the manifest itself.
            $switches
            Write-ADTLogEntry -Message "Using Silent switches from the manifest's top level."
        }
        elseif ($instType = $Installer | Get-ADTWinGetHashMismatchInstallerType)
        {
            # We have no defined switches, try to determine switches from the installer's defined type.
            Get-ADTDefaultKnownSwitches -InstallerType $instType
            Write-ADTLogEntry -Message "Using default switches for the manifest installer's installer type ($instType)."
        }
        elseif ($instType = $Manifest | Get-ADTWinGetHashMismatchInstallerType)
        {
            # The installer array doesn't define a type, see if the manifest itself does.
            Get-ADTDefaultKnownSwitches -InstallerType $instType
            Write-ADTLogEntry -Message "Using default switches for the manifest's installer type ($instType)."
        }
        elseif ($switches = $Installer | Get-ADTWinGetManifestInstallSwitches -Type SilentWithProgress)
        {
            # We're shit out of luck... circle back and see if we have _anything_ we can use.
            $switches
            Write-ADTLogEntry -Message "Using SilentWithProgress switches from the manifest's installer data."
        }
        elseif ($switches = $Manifest | Get-ADTWinGetManifestInstallSwitches -Type SilentWithProgress)
        {
            # Last-ditch effort. It's this or bust.
            $switches
            Write-ADTLogEntry -Message "Using SilentWithProgress switches from the manifest's top level."
        }
        else
        {
            $naerParams = @{
                Exception = [System.InvalidOperationException]::new("Unable to determine how to silently install the application.")
                Category = [System.Management.Automation.ErrorCategory]::InvalidResult
                ErrorId = 'WinGetInstallerTypeUnknown'
                TargetObject = $PSBoundParameters
                RecommendedAction = "Please report this issue to the project's maintainer for further review."
            }
            $PSCmdlet.ThrowTerminatingError((New-ADTErrorRecord @naerParams))
        }

        # Append any custom switches the caller has provided.
        if ($Custom)
        {
            $Custom
        }
    }
    else
    {
        # Override replaces anything the manifest provides.
        $Override
    }
}
