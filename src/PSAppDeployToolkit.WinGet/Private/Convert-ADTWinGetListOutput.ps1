#-----------------------------------------------------------------------------
#
# MARK: Convert-ADTWinGetListOutput
#
#-----------------------------------------------------------------------------

function Convert-ADTWinGetListOutput
{
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
