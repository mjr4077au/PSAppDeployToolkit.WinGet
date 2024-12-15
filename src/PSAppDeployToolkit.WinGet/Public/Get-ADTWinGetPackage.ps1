#-----------------------------------------------------------------------------
#
# MARK: Get-ADTWinGetPackage
#
#-----------------------------------------------------------------------------

function Get-ADTWinGetPackage
{
    <#
    .SYNOPSIS
        Lists installed packages.

    .DESCRIPTION
        This command lists all of the packages installed on your system. The output includes packages installed from WinGet sources and packages installed by other methods. Packages that have package identifiers starting with `MSIX` or `ARP` could not be correlated to a WinGet source.

    .PARAMETER Command
        Specify the name of the command defined in the package manifest.

    .PARAMETER Count
        Limits the number of items returned by the command.

    .PARAMETER Id
        Specify the package identifier for the package you want to list.

    .PARAMETER Moniker
        Specify the moniker of the package you want to list.

    .PARAMETER Name
        Specify the name of the package to list.

    .PARAMETER Source
        Specify the name of the WinGet source of the package.

    .PARAMETER Tag
        Specify a package tag to search for.

    .INPUTS
        None

        You cannot pipe objects to this function.

    .OUTPUTS
        None

        This function does not return any output.

    .EXAMPLE
        Get-ADTWinGetPackage

        This example shows how to list all packages installed on your system.

    .EXAMPLE
        Get-ADTWinGetPackage -Id "Microsoft.PowerShell"

        This example shows how to get an installed package by its package identifier.

    .EXAMPLE
        Get-ADTWinGetPackage -Name "PowerShell"

        This example shows how to get installed packages that match a name value. The command does a substring comparison of the provided name with installed package names.

    .LINK
        https://github.com/mjr4077au/PSAppDeployToolkit.WinGet
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Command,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.UInt32]$Count,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Id,

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
        [System.String]$Tag
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
                return (Invoke-ADTWinGetQueryOperation -Action List @PSBoundParameters)
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
