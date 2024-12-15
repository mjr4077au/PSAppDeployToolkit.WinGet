#-----------------------------------------------------------------------------
#
# MARK: Convert-ADTFunctionParamsToArgArray
#
#-----------------------------------------------------------------------------

function Convert-ADTFunctionParamsToArgArray
{
    <#
    .SYNOPSIS
        Converts the provided parameter metadata into an argument array for applications, with presets for MSI, Dell Command | Update, and WinGet.

    .DESCRIPTION
        This function accepts parameter metadata and with this, the parameter set name and a help message tag, converts the parameters into an array of arguments for applications.

        There are presets available for MSI, Dell Command | Update, WinGet, and PnpUtil, or a completely custom arrangement can be accomodated.

    .PARAMETER BoundParameters
        A hashtable of parameters to process.

    .PARAMETER Invocation
        The script or function's InvocationInfo ($MyInvocation) to process.

    .PARAMETER ParameterSetName
        The ParameterSetName to use as a filter against the Invocation's parameters.

    .PARAMETER HelpMessage
        The HelpMessage field to use as a filter against the Invocation's parameters.

    .PARAMETER Exclude
        One or more parameter names to exclude from the results.

    .PARAMETER Ordered
        Instructs that the returned parameters are in the exact order they're read from the BoundParameters or Invocation.

    .PARAMETER Preset
        The preset of which to use when generating an argument array. Current presets are MSI, Dell Command | Update, WinGet, PnpUtil, and PowerShell.

    .PARAMETER ArgValSeparator
        For non-preset modes, the separator between an argument's name and value.

    .PARAMETER ArgPrefix
        For non-preset modes, the prefix to apply to an argument's name.

    .PARAMETER ValueWrapper
        For non-preset modes, what, if anything, to use as characters to wrap around the value (e.g. --ArgName="Value").

    .PARAMETER MultiValDelimiter
        For non-preset modes, how to handle parameters where their value is an array of data.

    .INPUTS
        System.Collections.IDictionary. Convert-ADTFunctionParamsToArgArray can accept one or more IDictionary objects for processing.
        System.Management.Automation.InvocationInfo. Convert-ADTFunctionParamsToArgArray can accept one or more InvocationInfo objects for processing.

    .OUTPUTS
        System.String[]. Convert-ADTFunctionParamsToArgArray returns one or more string objects representing the converted parameters.

    .LINK
        https://github.com/mjr4077au/PSAppDeployToolkit.WinGet
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'ParameterSetName', Justification = "This parameter is used within delegates that PSScriptAnalyzer has no visibility of. See https://github.com/PowerShell/PSScriptAnalyzer/issues/1472 for more details.")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'HelpMessage', Justification = "This parameter is used within delegates that PSScriptAnalyzer has no visibility of. See https://github.com/PowerShell/PSScriptAnalyzer/issues/1472 for more details.")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Exclude', Justification = "This parameter is used within delegates that PSScriptAnalyzer has no visibility of. See https://github.com/PowerShell/PSScriptAnalyzer/issues/1472 for more details.")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Ordered', Justification = "This parameter is used within delegates that PSScriptAnalyzer has no visibility of. See https://github.com/PowerShell/PSScriptAnalyzer/issues/1472 for more details.")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'MultiValDelimiter', Justification = "This parameter is used within delegates that PSScriptAnalyzer has no visibility of. See https://github.com/PowerShell/PSScriptAnalyzer/issues/1472 for more details.")]
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'BoundParametersPreset', ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = 'BoundParametersCustom', ValueFromPipeline = $true)]
        [AllowEmptyCollection()]
        [System.Collections.IDictionary]$BoundParameters,

        [Parameter(Mandatory = $true, ParameterSetName = 'InvocationPreset', HelpMessage = 'Primary parameter', ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ParameterSetName = 'InvocationCustom', HelpMessage = 'Primary parameter', ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.InvocationInfo]$Invocation,

        [Parameter(Mandatory = $false, ParameterSetName = 'InvocationPreset', HelpMessage = 'Primary parameter')]
        [Parameter(Mandatory = $false, ParameterSetName = 'InvocationCustom', HelpMessage = 'Primary parameter')]
        [ValidateNotNullOrEmpty()]
        [System.String]$ParameterSetName,

        [Parameter(Mandatory = $false, ParameterSetName = 'InvocationPreset', HelpMessage = 'Primary parameter')]
        [Parameter(Mandatory = $false, ParameterSetName = 'InvocationCustom', HelpMessage = 'Primary parameter')]
        [ValidateNotNullOrEmpty()]
        [System.String]$HelpMessage,

        [Parameter(Mandatory = $false, ParameterSetName = 'BoundParametersPreset', HelpMessage = 'Primary parameter')]
        [Parameter(Mandatory = $false, ParameterSetName = 'BoundParametersCustom', HelpMessage = 'Primary parameter')]
        [Parameter(Mandatory = $false, ParameterSetName = 'InvocationPreset', HelpMessage = 'Primary parameter')]
        [Parameter(Mandatory = $false, ParameterSetName = 'InvocationCustom', HelpMessage = 'Primary parameter')]
        [ValidateNotNullOrEmpty()]
        [System.String[]]$Exclude,

        [Parameter(Mandatory = $false, ParameterSetName = 'InvocationPreset', HelpMessage = 'Primary parameter')]
        [Parameter(Mandatory = $false, ParameterSetName = 'InvocationCustom', HelpMessage = 'Primary parameter')]
        [System.Management.Automation.SwitchParameter]$Ordered,

        [Parameter(Mandatory = $true, ParameterSetName = 'BoundParametersPreset')]
        [Parameter(Mandatory = $true, ParameterSetName = 'InvocationPreset')]
        [ValidateSet('MSI', 'WinGet', 'DellCommandUpdate', 'PnpUtil', 'PowerShell')]
        [System.String]$Preset,

        [Parameter(Mandatory = $true, ParameterSetName = 'BoundParametersCustom')]
        [Parameter(Mandatory = $true, ParameterSetName = 'InvocationCustom')]
        [ValidateSet(' ', '=', "`n")]
        [System.String]$ArgValSeparator,

        [Parameter(Mandatory = $false, ParameterSetName = 'BoundParametersCustom')]
        [Parameter(Mandatory = $false, ParameterSetName = 'InvocationCustom')]
        [ValidateSet('-', '--', '/')]
        [System.String]$ArgPrefix,

        [Parameter(Mandatory = $false, ParameterSetName = 'BoundParametersCustom')]
        [Parameter(Mandatory = $false, ParameterSetName = 'InvocationCustom')]
        [ValidateSet("'", '"')]
        [System.String]$ValueWrapper,

        [Parameter(Mandatory = $false, ParameterSetName = 'BoundParametersPreset')]
        [Parameter(Mandatory = $false, ParameterSetName = 'InvocationPreset')]
        [Parameter(Mandatory = $false, ParameterSetName = 'BoundParametersCustom')]
        [Parameter(Mandatory = $false, ParameterSetName = 'InvocationCustom')]
        [ValidateSet(',', '|')]
        [System.String]$MultiValDelimiter = ','
    )

    begin
    {
        # Initialize function.
        Initialize-ADTFunction -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

        # Set up regex for properly trimming lines. Yes, reflection == long lines.
        $invalidends = "$($MyInvocation.MyCommand.Parameters.Values.GetEnumerator().Where({$_.Name.Equals('ArgValSeparator')}).Attributes.Where({$_ -is [System.Management.Automation.ValidateSetAttribute]}).ValidValues | Convert-ADTArrayToRegexCaptureGroup)+$"
        $nullvalues = "\s$($MyInvocation.MyCommand.Parameters.Values.GetEnumerator().Where({$_.Name.Equals('ValueWrapper')}).Attributes.Where({$_ -is [System.Management.Automation.ValidateSetAttribute]}).ValidValues | Convert-ADTArrayToRegexCaptureGroup){2}$"

        # Set up the string for formatting.
        $string = switch ($Preset)
        {
            MSI { "{0}=`"{1}`""; break }
            WinGet { "--{0}`n{1}"; break }
            DellCommandUpdate { "-{0}={1}"; break }
            PnpUtil { "/{0}`n{1}"; break }
            PowerShell { "-{0}`n`"{1}`""; break }
            default { "$($ArgPrefix){0}$($ArgValSeparator)$($ValueWrapper){1}$($ValueWrapper)"; break }
        }

        # Persistent scriptblocks stored in RAM for Convert-ADTFunctionParamsToArgArray.
        $script = if ($Preset -eq 'MSI')
        {
            {
                # For switches, we want to convert the $true/$false into 1/0 respectively.
                if ($_.Value -isnot [System.Management.Automation.SwitchParameter])
                {
                    [System.String]::Format($string, $_.Key.ToUpper(), $_.Value -join $MultiValDelimiter).Split("`n").Trim()
                }
                else
                {
                    [System.String]::Format($string, $_.Key.ToUpper(), [System.UInt32][System.Boolean]$_.Value).Split("`n").Trim()
                }
            }
        }
        else
        {
            {
                # For switches, we only want true switches, and we drop the $true value entirely.
                $notswitch = $_.Value -isnot [System.Management.Automation.SwitchParameter]
                if ($notswitch -or $_.Value)
                {
                    $name = if ($Preset -eq 'PowerShell') { $_.Key } else { $_.Key.ToLower() }
                    $value = if ($notswitch) { $_.Value -join $MultiValDelimiter }
                    [System.String]::Format($string, $name, $value).Split("`n").Trim() -replace $nullvalues
                }
            }
        }
    }

    process
    {
        try
        {
            try
            {
                # If we're processing an invocation, get its bound parameters as required.
                if ($Invocation)
                {
                    $bpdvParams = Get-ADTBoundParametersAndDefaultValues -Invocation $MyInvocation -HelpMessage 'Primary parameter'
                    $BoundParameters = Get-ADTBoundParametersAndDefaultValues @bpdvParams
                }

                # Process the parameters into an argument array and return to the caller.
                return $BoundParameters.GetEnumerator().Where({ $Exclude -notcontains $_.Key }).ForEach($script) -replace $invalidends | Where-Object { ![System.String]::IsNullOrWhiteSpace($_) }
            }
            catch
            {
                # Re-writing the ErrorRecord with Write-Error ensures the correct PositionMessage is used.
                Write-Error -ErrorRecord $_
            }
        }
        catch
        {
            # Process the caught error, log it and throw depending on the specified ErrorAction.
            Invoke-ADTFunctionErrorHandler -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorRecord $_ -LogMessage "Failed to convert the provided input to an argument array."
        }
    }

    end
    {
        # Finalize function.
        Complete-ADTFunction -Cmdlet $PSCmdlet
    }
}
