#-----------------------------------------------------------------------------
#
# MARK: Reset-ADTWinGetSource
#
#-----------------------------------------------------------------------------

function Reset-ADTWinGetSource
{
    <#
    .SYNOPSIS
        Resets WinGet sources.

    .DESCRIPTION
        Resets a named WinGet source by removing the source configuration. You can reset all configured sources and add the default source configurations using the All switch parameter. This command must be executed with administrator permissions.

    .PARAMETER Name
        The name of the source.

    .PARAMETER All
        Reset all sources and add the default sources.

    .INPUTS
        None

        You cannot pipe objects to this function.

    .OUTPUTS
        None

        This function does not return any output.

    .EXAMPLE
        Reset-ADTWinGetSource -Name msstore

        This example resets the configured source named 'msstore' by removing it.

    .EXAMPLE
        Reset-ADTWinGetSource -All

        This example resets all configured sources and adds the default sources.

    .LINK
        https://github.com/mjr4077au/PSAppDeployToolkit.WinGet
    #>

    [CmdletBinding(DefaultParameterSetName = 'Name')]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'Name')]
        [ValidateNotNullOrEmpty()]
        [System.String]$Name,

        [Parameter(Mandatory = $true, ParameterSetName = 'All')]
        [System.Management.Automation.SwitchParameter]$All
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
                # Reset all sources if specified.
                if ($All)
                {
                    Write-ADTLogEntry -Message "Resetting all WinGet sources, please wait..."
                    if (!($wgSrcRes = & $wingetPath source reset --force 2>&1).Equals('Resetting all sources...Done'))
                    {
                        $naerParams = @{
                            Exception = [System.Runtime.InteropServices.ExternalException]::new("Failed to reset all WinGet sources. $($wgSrcRes.TrimEnd('.')).", $Global:LASTEXITCODE)
                            Category = [System.Management.Automation.ErrorCategory]::InvalidResult
                            ErrorId = 'WinGetSourceAllResetFailure'
                            TargetObject = $wgSrcRes
                            RecommendedAction = "Please review the result in this error's TargetObject property and try again."
                        }
                        throw (New-ADTErrorRecord @naerParams)
                    }
                    Write-ADTLogEntry -Message "Successfully reset all WinGet sources."
                    return
                }

                # Reset the specified source.
                Write-ADTLogEntry -Message "Resetting WinGet source [$Name], please wait..."
                if (!($wgSrcRes = & $wingetPath source reset $Name 2>&1).Equals("Resetting source: $Name...Done"))
                {
                    $naerParams = @{
                        Exception = [System.Runtime.InteropServices.ExternalException]::new("Failed to WinGet source [$Name]. $($wgSrcRes.TrimEnd('.')).", $Global:LASTEXITCODE)
                        Category = [System.Management.Automation.ErrorCategory]::InvalidResult
                        ErrorId = "WinGetNamedSourceResetFailure"
                        TargetObject = $wgSrcRes
                        RecommendedAction = "Please review the result in this error's TargetObject property and try again."
                    }
                    throw (New-ADTErrorRecord @naerParams)
                }
                Write-ADTLogEntry -Message "Successfully WinGet source [$Name]."
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
            Invoke-ADTFunctionErrorHandler -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorRecord $_ -LogMessage "Failed to repair the specified WinGet source(s)."
        }
    }

    end
    {
        # Finalize function.
        Complete-ADTFunction -Cmdlet $PSCmdlet
    }
}
