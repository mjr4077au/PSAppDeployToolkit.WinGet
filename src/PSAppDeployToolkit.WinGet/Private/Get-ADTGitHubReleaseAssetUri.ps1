#-----------------------------------------------------------------------------
#
# MARK: Get-ADTGitHubReleaseAssetUri
#
#-----------------------------------------------------------------------------

function Get-ADTGitHubReleaseAssetUri
{
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'FilePattern', Justification = "This parameter is used within delegates that PSScriptAnalyzer has no visibility of. See https://github.com/PowerShell/PSScriptAnalyzer/issues/1472 for more details.")]
    [CmdletBinding(DefaultParameterSetName = 'None')]
    [OutputType([System.Uri])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Account,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Repository,

        [Parameter(Mandatory = $true, ParameterSetName = 'FilePattern')]
        [ValidateNotNullOrEmpty()]
        [System.String]$FilePattern,

        [Parameter(Mandatory = $false, ParameterSetName = 'FilePattern')]
        [System.Management.Automation.SwitchParameter]$Regex
    )

    # Get the list of URLs from GitHub's API.
    $links = (Invoke-RestMethod -UseBasicParsing -Uri "https://api.github.com/repos/$Account/$Repository/releases/latest" -Verbose:$false).assets.browser_download_url

    # Find the one that matches the pattern and confirm we have a singular result.
    if ($PSCmdlet.ParameterSetName.Equals('FilePattern'))
    {
        if (!(($link = $links | Where-Object { $_.Split('/').Where($(if ($Regex) { { $_ -match $FilePattern } } else { { $_ -like $FilePattern } })) }) | Measure-Object).Count.Equals(1))
        {
            $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new(
                    [System.InvalidOperationException]::new("The match against the provided file pattern returned an invalid result."),
                    'UriPatternMatchInvalidResult',
                    [System.Management.Automation.ErrorCategory]::InvalidResult,
                    $link
                ))
        }
        return [System.Uri]$link
    }
    return $links
}
