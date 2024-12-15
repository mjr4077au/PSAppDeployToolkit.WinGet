#-----------------------------------------------------------------------------
#
# MARK: Repair-ADTWinGetPackage
#
#-----------------------------------------------------------------------------

function Repair-ADTWinGetPackage
{
    <#
    .SYNOPSIS
        Repairs a WinGet Package.

    .DESCRIPTION
        This command repairs a WinGet package from your computer, provided the package includes repair support. The command includes parameters to specify values used to search for installed packages. By default, all string-based searches are case-insensitive substring searches. Wildcards are not supported.

        Note: Not all packages support repair.

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

    .INPUTS
        None

        You cannot pipe objects to this function.

    .OUTPUTS
        PSObject

        This function returns a PSObject containing the outcome of the operation.

    .EXAMPLE
        Repair-WinGetPackage -Id "Microsoft.GDK.2406"

        This example shows how to repair a package by specifying the package identifier. If the package identifier is available from more than one source, you must provide additional search criteria to select a specific instance of the package.

    .EXAMPLE
        Repair-WinGetPackage -Name "Microsoft Game Development Kit - 240602 (June 2024 Update 2)"

        This example shows how to repair a package using the package name. Please note that the examples mentioned above are mainly reference examples for the repair cmdlet and may not be operational as is, since many installers don't support repair as a standard functionality. For the Microsoft.GDK.2406 example, the assumption is that Microsoft.GDK.2406 supports repair capability and the author of the installer has provided the necessary repair context/switches in the Package Manifest in the Package Source referenced by the WinGet Client.

    .LINK
        https://github.com/mjr4077au/PSAppDeployToolkit.WinGet
    #>

    [CmdletBinding()]
    param
    (
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
        [System.String]$Version
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
                return (Invoke-ADTWinGetDeploymentOperation -Action Repair @PSBoundParameters)
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
