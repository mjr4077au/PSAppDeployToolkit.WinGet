#-----------------------------------------------------------------------------
#
# MARK: Find-ADTWinGetPackage
#
#-----------------------------------------------------------------------------

function Find-ADTWinGetPackage
{
    <#
    .SYNOPSIS
        Searches for packages from configured sources.

    .DESCRIPTION
        Searches for packages from configured sources.

    .PARAMETER Query
        Specify one or more strings to search for. By default, the command searches all configured sources.

    .PARAMETER MatchOption
        Specify matching logic used for search.

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
        Specify the name of the WinGet source to search. The most common sources are `msstore` and `winget`.

    .PARAMETER Tag
        Specify a package tag to search for.

    .INPUTS
        None

        You cannot pipe objects to this function.

    .OUTPUTS
        None

        This function does not return any output.

    .EXAMPLE
        Find-ADTWinGetPackage -Id Microsoft.PowerShell

        This example shows how to search for packages by package identifier. By default, the command searches all configured sources. The command performs a case-insensitive substring match against the PackageIdentifier property of the packages.

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
        # Throw if at least one filtration method isn't provided.
        if (!($PSBoundParameters.Keys -match '^(Query|Command|Id|Moniker|Name|Tag)$'))
        {
            $naerParams = @{
                Exception = [System.ArgumentException]::new("At least one search parameter must be provided to this function.")
                Category = [System.Management.Automation.ErrorCategory]::InvalidArgument
                ErrorId = "WinGetPackageSearchError"
                TargetObject = $PSBoundParameters
                RecommendedAction = "Please review the specified parameters, then try again."
            }
            $PSCmdlet.ThrowTerminatingError((New-ADTErrorRecord @naerParams))
        }

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
                if (!($wgPackage = Invoke-ADTWinGetQueryOperation -Action Search @PSBoundParameters))
                {
                    $naerParams = @{
                        Exception = [System.IO.InvalidDataException]::new("No packages matched the given input criteria.")
                        Category = [System.Management.Automation.ErrorCategory]::InvalidResult
                        ErrorId = "WinGetPackageNotFoundError"
                        TargetObject = $PSBoundParameters
                        RecommendedAction = "Please review the specified input, then try again."
                    }
                    throw (New-ADTErrorRecord @naerParams)
                }
                return $wgPackage
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
            Invoke-ADTFunctionErrorHandler -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorRecord $_ -LogMessage "Failed to find the specified WinGet package."
        }
    }

    end
    {
        # Finalize function.
        Complete-ADTFunction -Cmdlet $PSCmdlet
    }
}
