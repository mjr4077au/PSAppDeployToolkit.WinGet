#-----------------------------------------------------------------------------
#
# MARK: Invoke-ADTWinGetExecutable
#
#-----------------------------------------------------------------------------

function Invoke-ADTWinGetExecutable
{
    <#

    .NOTES
    This function expects the console to be UTF-8 using `[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8`.

    The encoding is globally set in this function, but exporting this function and using it without setting the console first will have unexpected results.

    Attempts were made to set this and reset it in in the begin{} and end{} blocks respectively, but this only worked with PowerShell 5.1 and not 7.x.

    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Silent', Justification = "This parameter is used within delegates that PSScriptAnalyzer has no visibility of. See https://github.com/PowerShell/PSScriptAnalyzer/issues/1472 for more details.")]
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]$Arguments,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$Silent
    )

    # Test whether the specified source is valid before continuing.
    if ($Source -and !($sources = & $LiteralPath source list | Convert-ADTWinGetListOutput).Name.Contains($Source))
    {
        $naerParams = @{
            Exception = [System.InvalidOperationException]::new("The specified source '$Source' is not valid. Currently configured WinGet sources are [$([System.String]::Join(', ', $sources.Name -replace '^|$','"'))].")
            Category = [System.Management.Automation.ErrorCategory]::InvalidOperation
            ErrorId = 'WinGetSourceInvalidError'
            TargetObject = [pscustomobject]@{SpecifiedSource = $Source; ConfiguredSources = $sources }
            RecommendedAction = "Please validate the list of installed WinGet sources, then try again."
        }
        $PSCmdlet.ThrowTerminatingError((New-ADTErrorRecord @naerParams))
    }

    # Invoke winget and print each non-null line that doesn't contain a hex code.
    Write-ADTLogEntry -Message "Executing [winget.exe $Arguments]."
    [System.String[]]$wgOutput = & $LiteralPath @Arguments | & {
        process
        {
            if ($_ -match '^\w+')
            {
                $line = $_.Trim() -replace '((?<![.:])|:)$', '.'
                if (!$Silent -and ($line -notmatch '^0x\w{8}'))
                {
                    Write-ADTLogEntry -Message $line
                }
                return $line
            }
        }
    }

    # Return accumulated output to the caller. This must be a string array!
    return , $wgOutput
}
