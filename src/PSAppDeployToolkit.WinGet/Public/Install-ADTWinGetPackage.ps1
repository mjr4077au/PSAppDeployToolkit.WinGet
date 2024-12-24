#-----------------------------------------------------------------------------
#
# MARK: Install-ADTWinGetPackage
#
#-----------------------------------------------------------------------------

function Install-ADTWinGetPackage
{
    <#
    .SYNOPSIS
        Installs a WinGet Package.

    .DESCRIPTION
        This command installs a WinGet package from a configured source. The command includes parameters to specify values used to search for packages in the configured sources. By default, the command searches the winget source. All string-based searches are case-insensitive substring searches. Wildcards are not supported.

    .PARAMETER Query
        Specify one or more strings to search for. By default, the command searches all configured sources.

    .PARAMETER MatchOption
        Specify matching logic used for search.

    .PARAMETER AllowHashMismatch
        Allows you to download package even when the SHA256 hash for an installer or a dependency does not match the SHA256 hash in the WinGet package manifest.

    .PARAMETER Architecture
        Specify the processor architecture for the WinGet package installer.

    .PARAMETER Custom
        Use this parameter to pass additional arguments to the installer. The parameter takes a single string value. To add multiple arguments, include the arguments in the string. The arguments must be provided in the format expected by the installer. If the string contains spaces, it must be enclosed in quotes. This string is added to the arguments defined in the package manifest.

    .PARAMETER Force
        Force the installer to run even when other checks WinGet would perform would prevent this action.

    .PARAMETER Header
        Custom value to be passed via HTTP header to WinGet REST sources.

    .PARAMETER Id
        Specify the package identifier to search for. The command does a case-insensitive full text match, rather than a substring match.

    .PARAMETER InstallerType
        A package may contain multiple installer types.

    .PARAMETER Locale
        Specify the locale of the installer package. The locale must provided in the BCP 47 format, such as `en-US`. For more information, see Standard locale names (/globalization/locale/standard-locale-names).

    .PARAMETER Location
        Specify the file path where you want the packed to be installed. The installer must be able to support alternate install locations.

    .PARAMETER Log
        Specify the location for the installer log. The value can be a fully-qualified or relative path and must include the file name. For example: `$env:TEMP\package.log`.

    .PARAMETER Mode
        Specify the output mode for the installer.

    .PARAMETER Moniker
        Specify the moniker of the WinGet package to install. For example, the moniker for the Microsoft.PowerShell package is `pwsh`.

    .PARAMETER Name
        Specify the name of the package to be installed.

    .PARAMETER Override
        Use this parameter to override the existing arguments passed to the installer. The parameter takes a single string value. To add multiple arguments, include the arguments in the string. The arguments must be provided in the format expected by the installer. If the string contains spaces, it must be enclosed in quotes. This string overrides the arguments specified in the package manifest.

    .PARAMETER Scope
        Specify WinGet package installer scope.

    .PARAMETER SkipDependencies
        Specifies that the command shouldn't install the WinGet package dependencies.

    .PARAMETER Source
        Specify the name of the WinGet source from which the package should be installed.

    .PARAMETER Version
        Specify the version of the package.

    .PARAMETER DebugHashMismatch
        Forces the AllowHashMismatch for debugging purposes.

    .PARAMETER PassThru
        Returns an object detailing the operation, just as Microsoft's module does by default.

    .INPUTS
        None

        You cannot pipe objects to this function.

    .OUTPUTS
        PSObject

        This function returns a PSObject containing the outcome of the operation.

    .EXAMPLE
        Install-WinGetPackage -Id Microsoft.PowerShell

        This example shows how to install a package by the specifying the package identifier. If the package identifier is available from more than one source, you must provide additional search criteria to select a specific instance of the package. If more than one source is configured with the same package identifier, the user must disambiguate.

    .EXAMPLE
        Install-WinGetPackage -Name "PowerToys (Preview)"

        This example shows how to install a package by specifying the package name.

    .EXAMPLE
        Install-WinGetPackage Microsoft.PowerShell -Version 7.4.4.0

        This example shows how to install a specific version of a package using a query. The command does a query search for packages matching `Microsoft.PowerShell`. The results of the search a limited to matches with the version of `7.4.4.0`.

    .LINK
        https://github.com/mjr4077au/PSAppDeployToolkit.WinGet
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Query,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Equals', 'EqualsCaseInsensitive')]
        [System.String]$MatchOption,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$AllowHashMismatch,

        [Parameter(Mandatory = $false)]
        [ValidateSet('x86', 'x64', 'arm64')]
        [System.String]$Architecture,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Custom,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$Force,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Header,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Id,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Inno', 'Wix', 'Msi', 'Nullsoft', 'Zip', 'Msix', 'Exe', 'Burn', 'MSStore', 'Portable')]
        [System.String]$InstallerType,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Locale,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Location,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Log,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Silent', 'Interactive')]
        [System.String]$Mode,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Moniker,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Name,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Override,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Any', 'User', 'System', 'UserOrUnknown', 'SystemOrUnknown')]
        [System.String]$Scope,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$SkipDependencies,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Source,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Version,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$DebugHashMismatch,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$PassThru
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
                # Send this to the backend common function.
                Invoke-ADTWinGetDeploymentOperation -Action Install @PSBoundParameters
            }
            catch
            {
                # Re-writing the ErrorRecord with Write-Error ensures the correct PositionMessage is used.
                Write-Error -ErrorRecord $_
            }
            finally
            {
                # Invoke-ADTWinGetDeploymentOperation writes this variable within our scope so we can get to it.
                if ($PassThru -and (Get-Variable -Name wingetResult -ValueOnly -ErrorAction Ignore))
                {
                    $PSCmdlet.WriteObject($wingetResult)
                }
            }
        }
        catch
        {
            # Process the caught error, log it and throw depending on the specified ErrorAction.
            Invoke-ADTFunctionErrorHandler -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorRecord $_ -LogMessage "Failed to install the specified WinGet package."
        }
    }

    end
    {
        # Finalize function.
        Complete-ADTFunction -Cmdlet $PSCmdlet
    }
}
