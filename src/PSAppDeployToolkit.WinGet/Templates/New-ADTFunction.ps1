#-----------------------------------------------------------------------------
#
# MARK: New-ADTFunction
#
#-----------------------------------------------------------------------------

function New-ADTFunction
{
    <#
    .SYNOPSIS
        Basis for a new PSAppDeployToolkit function.

    .DESCRIPTION
        This function serves as the basis for a new PSAppDeployToolkit function.

    .INPUTS
        None

        You cannot pipe objects to this function.

    .OUTPUTS
        None

        This function does not return any output.

    .EXAMPLE
        New-ADTFunction

        Invokes the New-ADTFunction function and returns any output.
    #>

    [CmdletBinding()]
    param
    (
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
