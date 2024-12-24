#-----------------------------------------------------------------------------
#
# MARK: Convert-ADTArrayToRegexCaptureGroup
#
#-----------------------------------------------------------------------------

function Convert-ADTArrayToRegexCaptureGroup
{
    <#
    .SYNOPSIS
        Accepts one or more strings and converts the results into a regex capture group.

    .DESCRIPTION
        This function accepts one or more strings and converts the results into a regex capture group.

    .PARAMETER InputObject
        One or more string objects to parse and return as a regex capture group.

    .INPUTS
        System.String. Convert-ADTArrayToRegexCaptureGroup accepts accepts one or more string objects for returning as a regex capture group.

    .OUTPUTS
        System.String. Convert-ADTArrayToRegexCaptureGroup returns a string object of the concatenated input as a regex capture group.

    .LINK
        https://github.com/mjr4077au/PSAppDeployToolkit.WinGet
    #>

    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowNull()]
        [System.String[]]$InputObject
    )

    begin
    {
        # Open collector to hold escaped and parsed values.
        $items = [System.Collections.Specialized.StringCollection]::new()
    }

    process
    {
        # Process incoming data and store in the collector.
        $null = $InputObject | & {
            process
            {
                if (![System.String]::IsNullOrWhiteSpace($_))
                {
                    $items.Add([System.Text.RegularExpressions.Regex]::Escape($_))
                }
            }
        }
    }

    end
    {
        # Return collected strings as a regex capture group.
        if ($items.Count) { return "($($items -join '|'))" }
    }
}
