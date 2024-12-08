#-----------------------------------------------------------------------------
#
# MARK: Get-ADTWinGetArgArray
#
#-----------------------------------------------------------------------------

function Get-ADTWinGetArgArray
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCmdlet]$Cmdlet,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Action,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$LogFile,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]$Exclude
    )

    # Define exclusions.
    $exclusions = $(if ($Exclude) { $Exclude }; if ($Action.Equals('list')) { 'Version' })

    # Standard args.
    $Action
    '--exact'
    '--verbose-logs'
    '--accept-source-agreements'

    # Calculated args from function's parameter block.
    $cpaParams = @{
        Invocation = $Cmdlet.MyInvocation
        ParameterSetName = $Action
        HelpMessage = 'WinGet Argument'
        Preset = 'WinGet'
    }
    if ($exclusions) { $cpaParams.Add('Exclude', $exclusions) }
    Convert-ADTFunctionParamsToArgArray @cpaParams

    # Calculated args based on the function's action.
    if ($Action.Equals('install'))
    {
        '--accept-package-agreements'
    }
    if (!$Action.Equals('list'))
    {
        '--silent'
        '--log'; $LogFile
    }
}
