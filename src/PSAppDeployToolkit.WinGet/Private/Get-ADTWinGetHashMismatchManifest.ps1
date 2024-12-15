#-----------------------------------------------------------------------------
#
# MARK: Get-ADTWinGetHashMismatchManifest
#
#-----------------------------------------------------------------------------

function Get-ADTWinGetHashMismatchManifest
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Id,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Version
    )

    # Set up vars and get package manifest.
    Write-ADTLogEntry -Message "Downloading and parsing the package manifest from GitHub."
    try
    {
        $wgUriBase = "https://raw.githubusercontent.com/microsoft/winget-pkgs/master/manifests/{0}/{1}/{2}/{3}.installer.yaml"
        $wgPkgsUri = [System.String]::Format($wgUriBase, $Id.Substring(0, 1).ToLower(), $Id.Replace('.', '/'), $Version, $Id)
        $wgPkgYaml = Invoke-RestMethod -UseBasicParsing -Uri $wgPkgsUri -Verbose:$false
        $wgManifest = $wgPkgYaml | ConvertFrom-Yaml
        return $wgManifest
    }
    catch
    {
        $naerParams = @{
            Exception = [System.IO.InvalidDataException]::new("Failed to download or parse the package manifest from GitHub.", $_.Exception)
            Category = [System.Management.Automation.ErrorCategory]::InvalidResult
            ErrorId = 'WinGetManifestParseFailure'
            RecommendedAction = "Please review the package's manifest, then try again."
        }
        $PSCmdlet.ThrowTerminatingError((New-ADTErrorRecord @naerParams))
    }
}
