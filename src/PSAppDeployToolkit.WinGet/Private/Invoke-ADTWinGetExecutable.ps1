#-----------------------------------------------------------------------------
#
# MARK: Invoke-ADTWinGetExecutable
#
#-----------------------------------------------------------------------------

function Invoke-ADTWinGetExecutable
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Silent', Justification = "This parameter is used within delegates that PSScriptAnalyzer has no visibility of. See https://github.com/PowerShell/PSScriptAnalyzer/issues/1472 for more details.")]
    [CmdletBinding()]
    [OutputType([System.Object[]])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]$LiteralPath,

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
