#-----------------------------------------------------------------------------
#
# MARK: Get-ADTWinGetSource
#
#-----------------------------------------------------------------------------

function Get-ADTWinGetSource
{
    <#
    .SYNOPSIS
        Lists configured WinGet sources.

    .DESCRIPTION
        Lists the configured WinGet sources.

    .PARAMETER Name
        Lists the configured WinGet sources.

    .INPUTS
        None

        You cannot pipe objects to this function.

    .OUTPUTS
        PSObject

        This function returns one or more objects for each WinGet source.

    .EXAMPLE
        Get-ADTWinGetSource

        Lists all configured WinGet sources.

    .LINK
        https://github.com/mjr4077au/PSAppDeployToolkit.WinGet
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Name
    )

    begin
    {
        # Confirm WinGet is good to go.
        try
        {
            Assert-ADTWinGetPackageManager
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($_)
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
                # Get all sources, returning early if there's none (1:1 API with `Get-WinGetSource`).
                Write-ADTLogEntry -Message "Getting list of WinGet sources, please wait..."
                if (($wgSrcRes = & (Get-ADTWinGetPath) source list 2>&1).Equals('There are no sources configured.'))
                {
                    Write-ADTLogEntry -Message "There are no WinGet sources configured on this system."
                    return
                }

                # Convert the results into proper PowerShell data.
                $wgSrcObjs = Convert-ADTWinGetQueryOutput -WinGetOutput $wgSrcRes

                # Filter by the name if specified.
                if ($PSBoundParameters.ContainsKey('Name'))
                {
                    if (!($wgSrcObj = $wgSrcObjs | & { process { if ($_.Name -eq $Name) { return $_ } } } | Select-Object -First 1))
                    {
                        $naerParams = @{
                            Exception = [System.ArgumentException]::new("No source found matching the given value [$Name].")
                            Category = [System.Management.Automation.ErrorCategory]::InvalidArgument
                            ErrorId = 'WinGetSourceNotFoundFailure'
                            TargetObject = $wgSrcObjs
                            RecommendedAction = "Please review the configured sources, then try again."
                        }
                        throw (New-ADTErrorRecord @naerParams)
                    }
                    Write-ADTLogEntry -Message "Found WinGet source [$Name]."
                    return $wgSrcObj
                }
                Write-ADTLogEntry -Message "Found $(($wgSrcObjCount = ($wgSrcObjs | Measure-Object).Count)) WinGet source$(if (!$wgSrcObjCount.Equals(1)) { 's' }): ['$([System.String]::Join("', '", $wgSrcObjs.Name))']."
                return $wgSrcObjs
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
            Invoke-ADTFunctionErrorHandler -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorRecord $_ -LogMessage "Failed to get the specified WinGet source(s)."
        }
    }

    end
    {
        # Finalize function.
        Complete-ADTFunction -Cmdlet $PSCmdlet
    }
}
