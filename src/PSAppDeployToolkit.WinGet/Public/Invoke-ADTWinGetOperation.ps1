#-----------------------------------------------------------------------------
#
# MARK: Invoke-ADTWinGetOperation
#
#-----------------------------------------------------------------------------

function Invoke-ADTWinGetOperation
{
    <#
    .SYNOPSIS
        A PowerShell wrapper for WinGet, supporting install, uninstall and list operations.

    .DESCRIPTION
        This script wraps around the winget.exe binary to provide enhanced usability for install, uninstall and list (detection) operations via Intune or SCCM.

        Additionally, this script logs all transactions to disk, colour-codes errors and extracts install failure exit codes and provides it to the caller, plus more.

        For Version 2.0, we'll (probably) swap to WinGet's PowerShell module when its out of alpha/beta and if they do end up supporting PowerShell/WMF 5.1.

    .PARAMETER Install
        Installs a WinGet package.

    .PARAMETER Uninstall
        Uninstalls a WinGet Package.

    .PARAMETER Id
        The ID of the package for the requested operation.

    .PARAMETER Version
        The Version of the package for the requested operation (if null, the latest will be installed).

    .PARAMETER Scope
        Whether the package is machine or user-scoped (if null, the packaged will be scoped to the machine).

    .PARAMETER Source
        Provide the pre-configured WinGet source where the package should come from.

    .PARAMETER Installer-Type
        Provide the type of installer that WinGet should use. Some manifests give both MSI and non-MSI installer types.

    .PARAMETER Architecture
        The archtecture of the package for the requested operation (if null, WinGet's default behaviour will be used).

    .PARAMETER Custom
        Install/uninstall arguments to append to default arguments during the requested operation.

    .PARAMETER Override
        Install/uninstall arguments to override default arguments during the requested operation.

    .PARAMETER Force
        Forces an install/uninstall operation to be attempted, even if the application is deemed installed/uninstalled already.

    .PARAMETER IgnoreHashFailure
        Allows overriding a failed installer hash comparison in an administrative context. Useful for apps like Google Chrome where the URLs are not versioned.

    .PARAMETER DebugHashFailure
        Forces the $IgnoreHashFailure pathway for debugging purposes without having to edit the script to force it.

    .EXAMPLE
        Invoke-ADTWinGetOperation -Install -Id Google.Chrome

        Installs Google Chrome via WinGet.

    .LINK
        https://github.com/mjr4077au/PSAppDeployToolkit.WinGet
    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Install', Justification = "This parameter is used via [Get-ADTWinGetArgArray] which PSScriptAnalyzer doesn't know or understand.")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Uninstall', Justification = "This parameter is used via [Get-ADTWinGetArgArray] which PSScriptAnalyzer doesn't know or understand.")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Scope', Justification = "This parameter is used via [Get-ADTWinGetArgArray] which PSScriptAnalyzer doesn't know or understand.")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Source', Justification = "This parameter is used via [Get-ADTWinGetArgArray] which PSScriptAnalyzer doesn't know or understand.")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Installer-Type', Justification = "This parameter is used via [Get-ADTWinGetArgArray] which PSScriptAnalyzer doesn't know or understand.")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Architecture', Justification = "This parameter is used via [Get-ADTWinGetArgArray] which PSScriptAnalyzer doesn't know or understand.")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Custom', Justification = "This parameter is used via [Get-ADTWinGetArgArray] which PSScriptAnalyzer doesn't know or understand.")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Override', Justification = "This parameter is used via [Get-ADTWinGetArgArray] which PSScriptAnalyzer doesn't know or understand.")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', 'Force', Justification = "This parameter is used via [Get-ADTWinGetArgArray] which PSScriptAnalyzer doesn't know or understand.")]

    [CmdletBinding(DefaultParameterSetName = 'list')]
    param
    (
        [Parameter(Mandatory = $true, ParameterSetName = 'install')]
        [Parameter(Mandatory = $true, ParameterSetName = 'install-custom')]
        [Parameter(Mandatory = $true, ParameterSetName = 'install-override')]
        [System.Management.Automation.SwitchParameter]$Install,

        [Parameter(Mandatory = $true, ParameterSetName = 'uninstall')]
        [System.Management.Automation.SwitchParameter]$Uninstall,

        [Parameter(Mandatory = $true, ParameterSetName = 'list', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $true, ParameterSetName = 'install', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $true, ParameterSetName = 'install-custom', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $true, ParameterSetName = 'install-override', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $true, ParameterSetName = 'uninstall', HelpMessage = 'WinGet Argument')]
        [ValidateNotNullOrEmpty()]
        [System.String]$Id,

        [Parameter(Mandatory = $false, ParameterSetName = 'list', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $false, ParameterSetName = 'install', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $false, ParameterSetName = 'install-custom', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $false, ParameterSetName = 'install-override', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $false, ParameterSetName = 'uninstall', HelpMessage = 'WinGet Argument')]
        [ValidatePattern('^\d+(?=\.)[\d.]+$')]
        [System.String]$Version, # Must be a string to preserve leading/trailing zeros!

        [Parameter(Mandatory = $false, ParameterSetName = 'install', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $false, ParameterSetName = 'install-custom', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $false, ParameterSetName = 'install-override', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $false, ParameterSetName = 'uninstall', HelpMessage = 'WinGet Argument')]
        [ValidateSet('User', 'Machine')]
        [ValidateScript({
                if ($_ -notmatch '^(User|Machine)$')
                {
                    $PSCmdlet.ThrowTerminatingError((New-ADTValidateScriptErrorRecord -ParameterName Scope -ProvidedValue $_ -ExceptionMessage 'The specified scope is invalid.'))
                }
                if ($Script:ADT.RunningAsSystem -and $_.Equals('User'))
                {
                    $PSCmdlet.ThrowTerminatingError((New-ADTValidateScriptErrorRecord -ParameterName Scope -ProvidedValue $_ -ExceptionMessage 'Installing user-scoped applications as the system user is not supported.'))
                }
                return ![System.String]::IsNullOrWhiteSpace($_)
            })]
        [System.String]$Scope = 'Machine',

        [Parameter(Mandatory = $false, ParameterSetName = 'list', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $false, ParameterSetName = 'install', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $false, ParameterSetName = 'install-custom', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $false, ParameterSetName = 'install-override', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $false, ParameterSetName = 'uninstall', HelpMessage = 'WinGet Argument')]
        [ValidateNotNullOrEmpty()]
        [System.String]$Source = 'winget',

        [Parameter(Mandatory = $false, ParameterSetName = 'install', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $false, ParameterSetName = 'install-custom', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $false, ParameterSetName = 'install-override', HelpMessage = 'WinGet Argument')]
        [ValidateSet('Burn', 'Wix', 'Msi', 'Nullsoft', 'Inno')]
        [Alias('InstallerType')]
        [System.String]${Installer-Type},

        [Parameter(Mandatory = $false, ParameterSetName = 'install', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $false, ParameterSetName = 'install-custom', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $false, ParameterSetName = 'install-override', HelpMessage = 'WinGet Argument')]
        [ValidateSet('x86', 'x64')]
        [System.String]$Architecture,

        [Parameter(Mandatory = $false, ParameterSetName = 'install', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $true, ParameterSetName = 'install-custom', HelpMessage = 'WinGet Argument')]
        [ValidateNotNullOrEmpty()]
        [System.String]$Custom,

        [Parameter(Mandatory = $false, ParameterSetName = 'install', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $true, ParameterSetName = 'install-override', HelpMessage = 'WinGet Argument')]
        [ValidateNotNullOrEmpty()]
        [System.String]$Override,

        [Parameter(Mandatory = $false, ParameterSetName = 'install', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $false, ParameterSetName = 'install-custom', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $false, ParameterSetName = 'install-override', HelpMessage = 'WinGet Argument')]
        [Parameter(Mandatory = $false, ParameterSetName = 'uninstall', HelpMessage = 'WinGet Argument')]
        [System.Management.Automation.SwitchParameter]$Force,

        [Parameter(Mandatory = $false, ParameterSetName = 'install')]
        [Parameter(Mandatory = $false, ParameterSetName = 'install-custom')]
        [Parameter(Mandatory = $false, ParameterSetName = 'install-override')]
        [System.Management.Automation.SwitchParameter]$IgnoreHashFailure,

        [Parameter(Mandatory = $false, ParameterSetName = 'install')]
        [Parameter(Mandatory = $false, ParameterSetName = 'install-custom')]
        [Parameter(Mandatory = $false, ParameterSetName = 'install-override')]
        [System.Management.Automation.SwitchParameter]$DebugHashFailure
    )

    begin
    {
        # Initialize function.
        Initialize-ADTFunction -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

        # Get the active ADT session object exit code setting.
        $adtSession = if (Test-ADTSessionActive)
        {
            Get-ADTSession
        }

        # Store the mode of operation.
        $wgAction = $PSCmdlet.ParameterSetName -replace '-.+'

        # Set the log file path.
        $logFile = if (Test-ADTSessionActive)
        {
            "$((Get-ADTConfig).Toolkit.LogPath)\$((Get-ADTSession).InstallName)_WinGet.log"
        }
        else
        {
            "$([System.IO.Path]::GetTempPath())Invoke-ADTWinGetOperation_$([System.DateTime]::Now.ToString('O').Split('.')[0].Replace(':', $null))_WinGet.log"
        }
    }

    process
    {
        Write-ADTLogEntry -Message "Commencing WinGet $wgAction operation."
        try
        {
            try
            {
                # Define variables needed for operations.
                Repair-ADTWinGetPackageManager
                $wgExecPath = Get-ADTWinGetPath

                # Test whether we're debugging $IgnoreHashFailure.
                if (!$wgAction.Equals('install') -or !$DebugHashFailure)
                {
                    # Set up args for Invoke-ADTWinGetExecutable and commence process.
                    $wpParams = @{
                        LiteralPath = $wgExecPath
                        Arguments = Get-ADTWinGetArgArray -Cmdlet $PSCmdlet -Action $wgAction -LogFile $logFile
                        Silent = $wgAction.Equals('list')
                    }
                    $wgOutput = Invoke-ADTWinGetExecutable @wpParams

                    # If package isn't found, rerun again without --Scope argument.
                    if ($Global:LASTEXITCODE -eq [ADTWinGetExitCode]::NO_APPLICABLE_INSTALLER)
                    {
                        Write-ADTLogEntry -Message "Attempting to execute WinGet again without '--scope' argument."
                        $wpParams.Arguments = Get-ADTWinGetArgArray -Cmdlet $PSCmdlet -Action $wgAction -LogFile $logFile -Exclude Scope
                        $wgOutput = Invoke-ADTWinGetExecutable @wpParams
                    }
                }
                else
                {
                    # Going into bypass mode. Simulate WinGet output for the purpose of getting the app's version later on.
                    Write-ADTLogEntry -Message "Bypassing WinGet as `-DebugHashFailure` has been passed. This switch should only be used for debugging purposes."
                    $wgAppData = Convert-ADTWinGetQueryOutput -WinGetOutput (& $wgExecPath search --Id $id --exact --accept-source-agreements)
                    $wgOutput = [System.String[]]"Found $($wgAppData.Name) [$Id] Version $($wgAppData.Version)."
                    $Global:LASTEXITCODE = [ADTWinGetExitCode]::INSTALLER_HASH_MISMATCH.value__
                    $IgnoreHashFailure = $true
                }

                # Process resulting exit code.
                if (($Global:LASTEXITCODE -eq [ADTWinGetExitCode]::INSTALLER_HASH_MISMATCH) -and $IgnoreHashFailure)
                {
                    # The hash failed, however we're forcing an override.
                    Write-ADTLogEntry -Message "Installation failed due to mismatched hash, attempting to override as `-IgnoreHashFailure` has been passed."

                    # Munge out the app's version from WinGet's log without having to call WinGet again for it.
                    $wgAppVerRegex = "^Found\s.+\s[$([System.Text.RegularExpressions.Regex]::Escape($Id))].+Version\s((\d|\.)+)\.$"
                    $wgAppVersion = $($wgOutput -match $wgAppVerRegex -replace $wgAppVerRegex, '$1')

                    # Get relevant app information.
                    $wgAppInfo = [ordered]@{}
                    $wgAppInfo.Add('Manifest', (Get-ADTWinGetAppManifest -AppVersion $wgAppVersion))
                    $wgAppInfo.Add('Installer', (Get-ADTWinGetAppInstaller -Manifest $wgAppInfo.Manifest))
                    $wgAppInfo.Add('FilePath', (Get-ADTWinGetAppDownload -Installer $wgAppInfo.Installer))

                    # Set up arguments to pass to Start-Process.
                    $spParams = @{
                        WorkingDirectory = $PWD.Path
                        ArgumentList = Get-ADTWinGetAppArguments @wgAppInfo -LogFile $logFile
                        FilePath = $(if ($wgAppInfo.FilePath.EndsWith('msi')) { 'msiexec.exe' } else { $wgAppInfo.FilePath })
                        PassThru = $true
                        Wait = $true
                    }

                    # Commence installation and test the resulting exit code for success.
                    Write-ADTLogEntry -Message "Starting package install..."
                    Write-ADTLogEntry -Message "Executing [$($spParams.FilePath) $($spParams.ArgumentList)]"
                    if ((Get-ADTWinGetAppExitCodes @wgAppInfo) -notcontains ($wgAppInfo.ExitCode = (Start-Process @spParams).ExitCode))
                    {
                        if ($adtSession)
                        {
                            $adtSession.SetExitCode($wgAppInfo.ExitCode)
                        }
                        $naerParams = @{
                            Exception = [System.Runtime.InteropServices.ExternalException]::new("The package installation failed with exit code [$($wgAppInfo.ExitCode)].", $wgAppInfo.ExitCode)
                            Category = [System.Management.Automation.ErrorCategory]::InvalidResult
                            ErrorId = 'WinGetPackageInstallationFailure'
                            TargetObject = [pscustomobject]$wgAppInfo
                            RecommendedAction = "Please review the exit code, then try again."
                        }
                        throw (New-ADTErrorRecord @naerParams)
                    }

                    # Yay, we made it!
                    Write-ADTLogEntry -Message "Successfully installed."
                }
                elseif ($wgAction.Equals('list') -and !$Global:LASTEXITCODE)
                {
                    # Convert the console output into a proper object.
                    $wgAppData = Convert-ADTWinGetQueryOutput -WinGetOutput $wgOutput
                    $wgLogBase = "$($wgAppData.Name) [$($wgAppData.Id)] $($wgAppData.Version)"

                    # Do some version checking of the found application.
                    if (![System.String]::IsNullOrWhiteSpace($Version) -and ([System.Version]($wgAppData.Version -replace '[^\d.]') -lt [System.Version]($Version -replace '[^\d.]')))
                    {
                        $naerParams = @{
                            Exception = [System.Activities.VersionMismatchException]::new("Detected $wgLogBase, but $Version or higher is required.", [System.Activities.WorkflowIdentity]::new($wgAppData.Name, $Version, $wgAppData.Id), [System.Activities.WorkflowIdentity]::new($wgAppData.Name, $wgAppData.Version, $wgAppData.Id))
                            Category = [System.Management.Automation.ErrorCategory]::InvalidResult
                            ErrorId = 'WinGetPackageVersionFailure'
                            TargetObject = $wgAppData
                        }
                        throw (New-ADTErrorRecord @naerParams)
                    }
                    elseif ($wgAppData.PSObject.Properties.Name.Contains('Available') -and ([System.Version]($wgAppData.Available -replace '[^\d.]') -gt [System.Version]($wgAppData.Version -replace '[^\d.]')))
                    {
                        Write-ADTLogEntry -Message "Detected $wgLogBase, but $($wgAppData.Available) is available." -Severity 2
                    }
                    else
                    {
                        Write-ADTLogEntry -Message "Successfully detected $wgLogBase."
                    }
                }
                elseif ($Global:LASTEXITCODE)
                {
                    # Update the session exit code, favouring an installer's exit code over WinGet's where possible.
                    $wgExitCode = if (($wgAppErrorLine = $($wgOutput -match 'exit code: \d+')))
                    {
                        [System.Int32]($wgAppErrorLine -replace '^.+:\s(\d+)\.$', '$1')
                    }
                    else
                    {
                        $Global:LASTEXITCODE
                    }
                    if ($adtSession)
                    {
                        $adtSession.SetExitCode($wgExitCode)
                    }

                    # Throw a terminating error message. All this bullshit is to change crap like '0x800704c7 : unknown error.' to 'Unknown error.'...
                    $wgErrorDef = if ([System.Enum]::IsDefined([ADTWinGetExitCode], $Global:LASTEXITCODE)) { [ADTWinGetExitCode]$Global:LASTEXITCODE }
                    $wgErrorMsg = [System.Text.RegularExpressions.Regex]::Replace($wgOutput[-1], '^0x\w{8}\s:\s(\w)', { $args[0].Groups[1].Value.ToUpper() })
                    $naerParams = @{
                        Exception = [System.Runtime.InteropServices.ExternalException]::new("WinGet operation finished with exit code 0x$($Global:LASTEXITCODE.ToString('X'))$(if ($wgErrorDef) {" ($wgErrorDef)"}) [$($wgErrorMsg.TrimEnd('.'))].", $wgExitCode)
                        Category = [System.Management.Automation.ErrorCategory]::InvalidResult
                        ErrorId = 'WinGetPackageInstallationFailure'
                        TargetObject = $wgOutput
                        RecommendedAction = "Please review the exit code, then try again."
                    }
                    throw (New-ADTErrorRecord @naerParams)
                }
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
            Invoke-ADTFunctionErrorHandler -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -ErrorRecord $_
        }
    }

    end
    {
        # Finalize function.
        Complete-ADTFunction -Cmdlet $PSCmdlet
    }
}
