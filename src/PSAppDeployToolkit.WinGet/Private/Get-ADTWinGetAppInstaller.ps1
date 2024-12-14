#-----------------------------------------------------------------------------
#
# MARK: Get-ADTWinGetAppInstaller
#
#-----------------------------------------------------------------------------

function Get-ADTWinGetAppInstaller
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [pscustomobject]$Manifest
    )

    # Get correct installation data from the manifest based on scope and system architecture.
    Write-ADTLogEntry -Message "Processing installer metadata from the package manifest."
    $systemArch = $Script:ADT.ArchLookupTable.([PSADT.OperatingSystem.OSHelper]::GetArchitecture())
    $nativeArch = $Manifest.Installers.Architecture -contains $systemArch
    $cultureName = [System.Globalization.CultureInfo]::CurrentUICulture.Name
    $wgInstaller = $Manifest.Installers | Where-Object {
        (!$_.PSObject.Properties.Name.Contains('Scope') -or ($_.Scope -eq $Scope)) -and
        (!$_.PSObject.Properties.Name.Contains('InstallerLocale') -or ($_.InstallerLocale -eq $cultureName)) -and
        (!${Installer-Type} -or (($instType = $_ | Get-ADTWinGetInstallerType) -and ($instType -eq ${Installer-Type}))) -and
        ($_.Architecture.Equals($Architecture) -or ($haveArch = $_.Architecture -eq $systemArch) -or (!$haveArch -and !$nativeArch))
    }

    # Validate the output. The yoda notation is to keep PSScriptAnalyzer happy.
    if ($null -eq $wgInstaller)
    {
        # We found nothing and therefore can't continue.
        $naerParams = @{
            Exception = [System.InvalidOperationException]::new("Error occurred while processing installer metadata from the package's manifest.")
            Category = [System.Management.Automation.ErrorCategory]::InvalidResult
            ErrorId = 'WinGetManifestInstallerResultNull'
            TargetObject = $wgInstaller
            RecommendedAction = "Please review the package's installer metadata within the manifest, then try again."
        }
        $PSCmdlet.ThrowTerminatingError((New-ADTErrorRecord @naerParams))
    }
    elseif ($wgInstaller -is [System.Collections.IEnumerable])
    {
        # We got multiple values. Get all unique installer types from the metadata and check for uniqueness.
        if (!$wgInstaller.Count.Equals((($wgInstTypes = $wgInstaller | Get-ADTWinGetInstallerType | Select-Object -Unique) | Measure-Object).Count))
        {
            # Something's gone wrong as we've got duplicate installer types.
            $naerParams = @{
                Exception = [System.InvalidOperationException]::new("Error determining correct installer metadata from the package's manifest.")
                Category = [System.Management.Automation.ErrorCategory]::InvalidResult
                ErrorId = 'WinGetManifestInstallerResultInconclusive'
                TargetObject = $wgInstaller
                RecommendedAction = "Please review the package's installer metadata within the manifest, then try again."
            }
            $PSCmdlet.ThrowTerminatingError((New-ADTErrorRecord @naerParams))
        }

        # Installer types were unique, just return the first one and hope for the best.
        Write-ADTLogEntry -Message "Found installer types ['$([System.String]::Join("', '", $wgInstTypes))']; using [$($wgInstTypes[0])] metadata."
        $wgInstaller = $wgInstaller | Where-Object { ($_ | Get-ADTWinGetInstallerType).Equals($wgInstTypes[0]) }
    }

    # Return installer metadata to the caller.
    return $wgInstaller
}
