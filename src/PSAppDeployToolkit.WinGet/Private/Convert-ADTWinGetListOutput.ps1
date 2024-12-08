#-----------------------------------------------------------------------------
#
# MARK: Convert-ADTWinGetListOutput
#
#-----------------------------------------------------------------------------

function Convert-ADTWinGetListOutput
{
    <#

    .NOTES
    This function expects the console to be UTF-8 using `[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8`.

    The encoding is globally set in this function, but exporting this function and using it without setting the console first will have unexpected results.

    Attempts were made to set this and reset it in in the begin{} and end{} blocks respectively, but this only worked with PowerShell 5.1 and not 7.x.

    #>

    begin
    {
        # Define variables for heading data that'll be the first line via the pipe.
        $listHeading = $headIndices = $null
    }

    process
    {
        try
        {
            # Filter out nonsense lines from the pipe.
            if (($line = $_.Trim().TrimEnd('.')) -notmatch '^\w+')
            {
                return
            }

            # Use our first valid line to set up the keys for each property.
            if (!$listHeading)
            {
                # Get all headings and the indices from the output.
                $listHeading = $line -split '\s+'
                $headIndices = $listHeading.ForEach({ $line.IndexOf($_) }) + 10000
                return
            }

            # Establish hashtable to hold contents we're converting.
            $obj = [ordered]@{}

            # Begin conversion and return object to the pipeline.
            for ($i = 0; $i -lt $listHeading.Length; $i++)
            {
                $thisi = [System.Math]::Min($headIndices[$i], $line.Length)
                $nexti = [System.Math]::Min($headIndices[$i + 1], $line.Length)
                $value = $line.Substring($thisi, $nexti - $thisi).Trim()
                $obj.Add($listHeading[$i], $(if (![System.String]::IsNullOrWhiteSpace($value)) { $value }))
            }
            return [pscustomobject]$obj
        }
        catch
        {
            $naerParams = @{
                Exception = [System.IO.InvalidDataException]::new("Failed to parse provided winget.exe output.", $_.Exception)
                Category = [System.Management.Automation.ErrorCategory]::InvalidResult
                ErrorId = 'WinGetListOutputParseFailure'
                TargetObject = $($input)
                RecommendedAction = "Please review the winget.exe output manually, then try again."
            }
            throw (New-ADTErrorRecord @naerParams)
        }
    }
}
