#-----------------------------------------------------------------------------
#
# MARK: Uninstall-ADTWinGetPackage
#
#-----------------------------------------------------------------------------

function Uninstall-ADTWinGetPackage
{
    <#
    .SYNOPSIS
        Uninstalls a WinGet Package.

    .DESCRIPTION
        This command uninstalls a WinGet package from your computer. The command includes parameters to specify values used to search for installed packages. By default, all string-based searches are case-insensitive substring searches. Wildcards are not supported.

    .PARAMETER Query
        Specify one or more strings to search for. By default, the command searches all configured sources.

    .PARAMETER MatchOption
        Specify matching logic used for search.

    .PARAMETER Force
        Force the installer to run even when other checks WinGet would perform would prevent this action.

    .PARAMETER Id
        Specify the package identifier to search for. The command does a case-insensitive full text match, rather than a substring match.

    .PARAMETER Log
        Specify the location for the installer log. The value can be a fully-qualified or relative path and must include the file name. For example: `$env:TEMP\package.log`.

    .PARAMETER Mode
        Specify the output mode for the installer.

    .PARAMETER Moniker
        Specify the moniker of the WinGet package to install. For example, the moniker for the Microsoft.PowerShell package is `pwsh`.

    .PARAMETER Name
        Specify the name of the package to be installed.

    .PARAMETER Source
        Specify the name of the WinGet source from which the package should be installed.

    .PARAMETER Version
        Specify the version of the package.

    .PARAMETER PassThru
        Returns an object detailing the operation, just as Microsoft's module does by default.

    .INPUTS
        None

        You cannot pipe objects to this function.

    .OUTPUTS
        PSObject

        This function returns a PSObject containing the outcome of the operation.

    .EXAMPLE
        Uninstall-WinGetPackage -Id Microsoft.PowerShell

        This example shows how to uninstall a package by the specifying the package identifier. If the package identifier is available from more than one source, you must provide additional search criteria to select a specific instance of the package.

    .EXAMPLE
        Uninstall-WinGetPackage -Name "PowerToys (Preview)"

        This sample uninstalls the PowerToys package by the specifying the package name.

    .EXAMPLE
        Uninstall-WinGetPackage Microsoft.PowerShell -Version 7.4.4.0

        This example shows how to uninstall a specific version of a package using a query. The command does a query search for packages matching `Microsoft.PowerShell`. The results of the search a limited to matches with the version of `7.4.4.0`.

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
        [System.Management.Automation.SwitchParameter]$Force,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Id,

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
        [System.String]$Source,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Version,

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
                Invoke-ADTWinGetDeploymentOperation -Action Uninstall @PSBoundParameters
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
            Invoke-ADTFunctionErrorHandler -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorRecord $_ -LogMessage "Failed to uninstall the specified WinGet package."
        }
    }

    end
    {
        # Finalize function.
        Complete-ADTFunction -Cmdlet $PSCmdlet
    }
}
