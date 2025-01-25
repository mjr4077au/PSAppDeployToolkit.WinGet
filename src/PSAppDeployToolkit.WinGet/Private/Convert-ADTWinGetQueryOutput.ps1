#-----------------------------------------------------------------------------
#
# MARK: Convert-ADTWinGetQueryOutput
#
#-----------------------------------------------------------------------------

function Convert-ADTWinGetQueryOutput
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]$WinGetOutput
    )

    # Test whether the provided output is convertable.
    $wingetDivider = $($WinGetOutput -match '^-+$'); if (!$wingetDivider)
    {
        $naerParams = @{
            Exception = [System.IO.InvalidDataException]::new("The provided WinGet output is not valid query output. Provided WinGet output was:`n$([System.String]::Join("`n", $WinGetOutput))")
            Category = [System.Management.Automation.ErrorCategory]::InvalidData
            ErrorId = 'WinGetQueryOutputInvalid'
            TargetObject = $WinGetOutput
            RecommendedAction = "Please review the WinGet output, then try again."
        }
        $PSCmdlet.ThrowTerminatingError((New-ADTErrorRecord @naerParams))
    }

    # Process each collected line into an object.
    try
    {
        $WinGetOutput[($WinGetOutput.IndexOf($wingetDivider) - 1)..($WinGetOutput.Count - 1)].Trim() | & {
            begin
            {
                # Define variables for heading data that'll be the first line via the pipe.
                $listHeading = $headIndices = $null
            }

            process
            {
                if ($_ -notmatch '^\w+')
                {
                    return
                }

                # Use our first valid line to set up the keys for each property.
                if (!$listHeading)
                {
                    # Get all headings and the indices from the output.
                    $listHeading = $_ -split '\s+'
                    $headIndices = $($listHeading | & { process { $args[0].IndexOf($_) } } $_; 10000)
                    return
                }

                # Establish hashtable to hold contents we're converting.
                $obj = [ordered]@{}

                # Begin conversion and return object to the pipeline.
                for ($i = 0; $i -lt $listHeading.Length; $i++)
                {
                    $thisi = [System.Math]::Min($headIndices[$i], $_.Length)
                    $nexti = [System.Math]::Min($headIndices[$i + 1], $_.Length)
                    $value = $_.Substring($thisi, $nexti - $thisi).Trim()
                    $obj.Add($listHeading[$i], $(if (![System.String]::IsNullOrWhiteSpace($value)) { $value }))
                }
                return [pscustomobject]$obj
            }
        }
    }
    catch
    {
        $naerParams = @{
            Exception = [System.IO.InvalidDataException]::new("Failed to parse provided WinGet output. Provided WinGet output was:`n$([System.String]::Join("`n", $WinGetOutput))", $_.Exception)
            Category = [System.Management.Automation.ErrorCategory]::InvalidResult
            ErrorId = 'WinGetQueryOutputParseFailure'
            TargetObject = $WinGetOutput
            RecommendedAction = "Please review the WinGet output, then try again."
        }
        $PSCmdlet.ThrowTerminatingError((New-ADTErrorRecord @naerParams))
    }
}
