#-----------------------------------------------------------------------------
#
# MARK: Invoke-ADTWinGetQueryOperation
#
#-----------------------------------------------------------------------------

function Invoke-ADTWinGetQueryOperation
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('list', 'search')]
        [System.String]$Action,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Query,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Equals', 'EqualsCaseInsensitive')]
        [System.String]$MatchOption,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Command,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.UInt32]$Count,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Id,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Moniker,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Name,

        [Parameter(Mandatory = $false)]
        [ValidateScript({
                try
                {
                    return (Get-ADTWinGetSource -Name $_ -InformationAction SilentlyContinue)
                }
                catch
                {
                    $PSCmdlet.ThrowTerminatingError($_)
                }
            })]
        [System.String]$Source,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Tag,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Any', 'User', 'System', 'UserOrUnknown', 'SystemOrUnknown')]
        [System.String]$Scope
    )

    # Confirm WinGet is good to go.
    if (!$PSBoundParameters.ContainsKey('Source'))
    {
        try
        {
            Assert-ADTWinGetPackageManager
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }

    # Force exact matching when using an Id.
    if ($PSBoundParameters.ContainsKey('Id'))
    {
        $MatchOption = 'Equals'
    }

    # Translate Scope parameter values to WinGet CLI equivalents.
    # PowerShell uses 'System'/'User' but WinGet CLI expects 'machine'/'user'.
    # This must happen BEFORE Convert-ADTFunctionParamsToArgArray is called.
    if ($PSBoundParameters.ContainsKey('Scope'))
    {
        $PSBoundParameters['Scope'] = switch ($PSBoundParameters['Scope'])
        {
            'System' { 'machine'; break }
            'SystemOrUnknown' { 'machine'; break }
            'User' { 'user'; break }
            'UserOrUnknown' { 'user'; break }
            'Any' { $null; break }
            default { $PSBoundParameters['Scope'] }
        }
        # Remove Scope if it was set to $null (e.g., 'Any' means no scope filter).
        if ($null -eq $PSBoundParameters['Scope'])
        {
            $null = $PSBoundParameters.Remove('Scope')
        }
    }

    # Set up arguments array for WinGet.
    $wingetArgs = $(
        $Action
        $PSBoundParameters | Convert-ADTFunctionParamsToArgArray -Preset WinGet -Exclude Action, MatchOption
        if ($MatchOption -eq 'Equals') { '--exact' }
        '--accept-source-agreements'
    )

    # Invoke WinGet, handling the required change in console output encoding.
    Write-ADTLogEntry -Message "Finding packages matching input criteria, please wait..."
    $origEncoding = [System.Console]::OutputEncoding; [System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    $wingetOutput = & (Get-ADTWinGetPath) $wingetArgs 2>&1 | & { process { if ($_ -match '^(\w+|-+$)') { return $_.Trim() } } }
    [System.Console]::OutputEncoding = $origEncoding

    # Return early if we couldn't find a package.
    if ($WinGetOutput -match '^No.+package found matching input criteria\.$')
    {
        # Throw if we're searching.
        if ($Action -eq 'search')
        {
            $naerParams = @{
                Exception         = [System.IO.InvalidDataException]::new("No package found matching input criteria.")
                Category          = [System.Management.Automation.ErrorCategory]::InvalidResult
                ErrorId           = "WinGetPackageNotFoundError"
                TargetObject      = $PSBoundParameters
                RecommendedAction = "Please review the specified input, then try again."
            }
            $PSCmdlet.ThrowTerminatingError((New-ADTErrorRecord @naerParams))
        }
        Write-ADTLogEntry -Message "No package found matching input criteria."
        return
    }

    # Convert the cached output to proper PowerShell objects.
    $wingetObjects = Convert-ADTWinGetQueryOutput -WinGetOutput $wingetOutput
    Write-ADTLogEntry -Message "Found $(($wingetObjCount = ($wingetObjects | Measure-Object).Count)) package$(if (!$wingetObjCount.Equals(1)) { 's' }) matching input criteria."
    return $wingetObjects
}
