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
        [ValidateNotNullOrEmpty()]
        [System.String]$Source,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Tag
    )

    # Confirm WinGet is good to go.
    try
    {
        Assert-ADTWinGetPackageManager
    }
    catch
    {
        $PSCmdlet.ThrowTerminatingError($_)
    }

    # Confirm the validity of the provided source.
    if ($PSBoundParameters.ContainsKey('Source'))
    {
        try
        {
            $null = Get-ADTWinGetSource -Name $PSBoundParameters.Source
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }

    # Set up arguments array for WinGet.
    $wingetArgs = $(
        $Action
        $PSBoundParameters | Convert-ADTFunctionParamsToArgArray -Preset WinGet -Exclude Action, MatchOption
        if ($MatchOption -eq 'Equals') { '--exact' }
        '--accept-source-agreements'
    )

    # Invoke WinGet and return early if we couldn't find a package.
    Write-ADTLogEntry -Message "Finding packages matching input criteria, please wait..."
    if (($wingetOutput = & (Get-ADTWinGetPath) $wingetArgs 2>&1 | & { process { if ($_ -match '^\w+') { return $_.Trim() } } }) -match '^No.+package found matching input criteria\.$')
    {
        Write-ADTLogEntry -Message "No package found matching input criteria."
        return
    }

    # Convert the cached output to proper PowerShell objects.
    $wingetObjects = Convert-ADTWinGetQueryOutput -WinGetOutput $wingetOutput
    Write-ADTLogEntry -Message "Found $(($wingetObjCount = ($wingetObjects | Measure-Object).Count)) package$(if (!$wingetObjCount.Equals(1)) { 's' }) matching input criteria."
    return $wingetObjects
}
