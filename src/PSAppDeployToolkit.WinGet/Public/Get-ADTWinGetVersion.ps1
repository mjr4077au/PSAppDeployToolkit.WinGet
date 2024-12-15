#-----------------------------------------------------------------------------
#
# MARK: Get-ADTWinGetVersion
#
#-----------------------------------------------------------------------------

function Get-ADTWinGetVersion
{
    <#
    .SYNOPSIS
        Gets the installed version of WinGet.

    .DESCRIPTION
        Gets the installed version of WinGet.

    .INPUTS
        None

        You cannot pipe objects to this function.

    .OUTPUTS
        System.String

        This function returns the installed WinGet's version number as a string.

    .EXAMPLE
        Get-ADTWinGetVersion -All

        Gets the installed version of WinGet.

    .LINK
        https://github.com/mjr4077au/PSAppDeployToolkit.WinGet
    #>

    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
    )

    begin
    {
        # Initialize function.
        Initialize-ADTFunction -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

        # Try to get the path to WinGet before proceeding.
        try
        {
            $wingetPath = Get-ADTWinGetPath
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }

    process
    {
        try
        {
            try
            {
                # Get the WinGet version and return it to the caller. The API here 1:1 matches WinGet's PowerShell module, rightly or wrongly.
                Write-ADTLogEntry -Message "Running [$wingetPath] with [--version] parameter."
                $wingetVer = & $wingetPath --version

                # If we've got a null string, we're probably missing the Visual Studio Runtime or something.
                if ([System.String]::IsNullOrWhiteSpace($wingetVer))
                {
                    $naerParams = @{
                        Exception = [System.InvalidOperationException]::new("The installed version of WinGet was unable to run.")
                        Category = [System.Management.Automation.ErrorCategory]::PermissionDenied
                        ErrorId = 'WinGetNullOutputError'
                        RecommendedAction = "Please run [Repair-ADTWinGetPackageManager] as an admin, then try again."
                    }
                    throw (New-ADTErrorRecord @naerParams)
                }
                Write-ADTLogEntry -Message "Installed WinGet version is [$($wingetVer)]."
                return $wingetVer
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
