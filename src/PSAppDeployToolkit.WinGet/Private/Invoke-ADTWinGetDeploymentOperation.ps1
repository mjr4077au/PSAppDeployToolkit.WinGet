#-----------------------------------------------------------------------------
#
# MARK: Invoke-ADTWinGetDeploymentOperation
#
#-----------------------------------------------------------------------------

function Invoke-ADTWinGetDeploymentOperation
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('install', 'repair', 'uninstall', 'upgrade')]
        [System.String]$Action,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Equals', 'EqualsCaseInsensitive')]
        [System.String]$MatchOption,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Query,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Id,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Log,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Silent', 'Interactive')]
        [System.String]$Mode,

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
        [System.String]$Version,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$PassThru
    )

    dynamicparam
    {
        # Define parameter dictionary for returning at the end.
        $paramDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

        # Add in parameters for specific modes.
        if ($Action -match '^(install|upgrade)$')
        {
            if ($Action -eq 'upgrade')
            {
                $paramDictionary.Add('Include-Unknown', [System.Management.Automation.RuntimeDefinedParameter]::new(
                        'Include-Unknown', [System.Management.Automation.SwitchParameter], $(
                            [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                            [System.Management.Automation.AliasAttribute]::new('IncludeUnknown')
                        )
                    ))
            }
            $paramDictionary.Add('Ignore-Security-Hash', [System.Management.Automation.RuntimeDefinedParameter]::new(
                    'Ignore-Security-Hash', [System.Management.Automation.SwitchParameter], $(
                        [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                        [System.Management.Automation.AliasAttribute]::new('AllowHashMismatch')
                    )
                ))
            $paramDictionary.Add('DebugHashMismatch', [System.Management.Automation.RuntimeDefinedParameter]::new(
                    'DebugHashMismatch', [System.Management.Automation.SwitchParameter], $(
                        [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                    )
                ))
            $paramDictionary.Add('Architecture', [System.Management.Automation.RuntimeDefinedParameter]::new(
                    'Architecture', [System.String], $(
                        [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                        [System.Management.Automation.ValidateSetAttribute]::new('x86', 'x64', 'arm64')
                    )
                ))
            $paramDictionary.Add('Custom', [System.Management.Automation.RuntimeDefinedParameter]::new(
                    'Custom', [System.String], $(
                        [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                        [System.Management.Automation.ValidateNotNullOrEmptyAttribute]::new()
                    )
                ))
            $paramDictionary.Add('Header', [System.Management.Automation.RuntimeDefinedParameter]::new(
                    'Header', [System.String], $(
                        [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                        [System.Management.Automation.ValidateNotNullOrEmptyAttribute]::new()
                    )
                ))
            $paramDictionary.Add('Installer-Type', [System.Management.Automation.RuntimeDefinedParameter]::new(
                    'Installer-Type', [System.String], $(
                        [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                        [System.Management.Automation.ValidateSetAttribute]::new('Inno', 'Wix', 'Msi', 'Nullsoft', 'Zip', 'Msix', 'Exe', 'Burn', 'MSStore', 'Portable')
                        [System.Management.Automation.AliasAttribute]::new('InstallerType')
                    )
                ))
            $paramDictionary.Add('Locale', [System.Management.Automation.RuntimeDefinedParameter]::new(
                    'Locale', [System.String], $(
                        [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                        [System.Management.Automation.ValidateNotNullOrEmptyAttribute]::new()
                    )
                ))
            $paramDictionary.Add('Location', [System.Management.Automation.RuntimeDefinedParameter]::new(
                    'Location', [System.String], $(
                        [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                        [System.Management.Automation.ValidateNotNullOrEmptyAttribute]::new()
                    )
                ))
            $paramDictionary.Add('Override', [System.Management.Automation.RuntimeDefinedParameter]::new(
                    'Override', [System.String], $(
                        [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                        [System.Management.Automation.ValidateNotNullOrEmptyAttribute]::new()
                    )
                ))
            $paramDictionary.Add('Scope', [System.Management.Automation.RuntimeDefinedParameter]::new(
                    'Scope', [String], $(
                        [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                        [System.Management.Automation.ValidateSetAttribute]::new('Any', 'User', 'System', 'UserOrUnknown', 'SystemOrUnknown')
                    )
                ))
            $paramDictionary.Add('Skip-Dependencies', [System.Management.Automation.RuntimeDefinedParameter]::new(
                    'Skip-Dependencies', [System.Management.Automation.SwitchParameter], $(
                        [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                        [System.Management.Automation.AliasAttribute]::new('SkipDependencies')
                    )
                ))
        }
        if ($Action -ne 'repair')
        {
            $paramDictionary.Add('Force', [System.Management.Automation.RuntimeDefinedParameter]::new(
                    'Force', [System.Management.Automation.SwitchParameter], $(
                        [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                    )
                ))
        }

        # Return the populated dictionary.
        if ($paramDictionary.Count)
        {
            return $paramDictionary
        }
    }

    begin
    {
        # Internal function to generate arguments array for WinGet.
        function Out-ADTWinGetDeploymentArgumentList
        {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory = $true)]
                [ValidateNotNullOrEmpty()]
                [System.Collections.Generic.Dictionary[System.String, System.Object]]$BoundParameters,

                [Parameter(Mandatory = $false)]
                [ValidateNotNullOrEmpty()]
                [System.String[]]$Exclude
            )

            # Ensure the action is also excluded.
            $PSBoundParameters.Exclude = $('Action'; 'MatchOption'; 'Mode'; 'Ignore-Security-Hash'; 'DebugHashMismatch'; 'PassThru'; $(if ($Exclude) { $Exclude } ))

            # Output each item for the caller to collect.
            return $(
                $Action
                Convert-ADTFunctionParamsToArgArray @PSBoundParameters -Preset WinGet
                if ($MatchOption -eq 'Equals')
                {
                    '--exact'
                }
                if (($Mode -eq 'Silent') -or ($adtSession -and ($adtSession.DeployMode -eq 'Silent')))
                {
                    '--silent'
                }
                '--accept-source-agreements'
                if ($Action -ne 'Uninstall')
                {
                    '--accept-package-agreements'
                }
            )
        }

        # Define internal scriptblock for invoking WinGet. This is a
        # scriptblock so Write-ADTLogEntry uses this function's source.
        $wingetInvoker = {
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory = $true)]
                [ValidateNotNullOrEmpty()]
                [System.String[]]$ArgumentList
            )

            # This scriptblock must always return the output as a string array, even for singular lines.
            Write-ADTLogEntry -Message "Executing [$wingetPath $ArgumentList]."
            return , [System.String[]](& $wingetPath $ArgumentList 2>&1 | & {
                    begin
                    {
                        $waleParams = @{ PassThru = $true }
                    }

                    process
                    {
                        if ($_ -match '^\w+')
                        {
                            $waleParams.Severity = if ($_ -match 'exit code: \d+') { 3 } else { 1 }
                            Write-ADTLogEntry @waleParams -Message ($_.Trim() -replace '((?<![.:])|:)$', '.')
                        }
                    }
                })
        }

        # Throw if an id, name, or moniker hasn't been provided. This is done like this
        # and not via parameter sets because this is what Install-WinGetPackage does.
        if (!$PSBoundParameters.ContainsKey('Id') -and !$PSBoundParameters.ContainsKey('Name') -and !$PSBoundParameters.ContainsKey('Moniker'))
        {
            $naerParams = @{
                Exception = [System.ArgumentException]::new("Please specify a package by Id, Name, or Moniker.")
                Category = [System.Management.Automation.ErrorCategory]::InvalidArgument
                ErrorId = "WinGet$([System.Globalization.CultureInfo]::CurrentUICulture.TextInfo.ToTitleCase($Action))FilterError"
                TargetObject = $PSBoundParameters
                RecommendedAction = "Please specify a package by Id, Name, or Moniker; then try again."
            }
            $PSCmdlet.ThrowTerminatingError((New-ADTErrorRecord @naerParams))
        }

        # Perform initial setup.
        try
        {
            # Ensure WinGet is good to go.
            if (!$PSBoundParameters.ContainsKey('Source'))
            {
                Assert-ADTWinGetPackageManager
            }
            $wingetPath = Get-ADTWinGetPath

            # Attempt to find the package to install.
            $fawgpParams = @{}; if ($PSBoundParameters.ContainsKey('Id'))
            {
                $fawgpParams.Add('Id', $PSBoundParameters.Id)
            }
            if ($PSBoundParameters.ContainsKey('Name'))
            {
                $fawgpParams.Add('Name', $PSBoundParameters.Name)
            }
            if ($PSBoundParameters.ContainsKey('Moniker'))
            {
                $fawgpParams.Add('Moniker', $PSBoundParameters.Moniker)
            }
            if ($PSBoundParameters.ContainsKey('Source'))
            {
                $fawgpParams.Add('Source', $PSBoundParameters.Source)
            }
            $wgPackage = Find-ADTWinGetPackage @fawgpParams -InformationAction SilentlyContinue
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($_)
        }

        # Get the active ADT session object if one's in play.
        $adtSession = if (Test-ADTSessionActive)
        {
            Get-ADTSession
        }

        # Add in a default log file if the caller hasn't specified one.
        if (!$PSBoundParameters.ContainsKey('Log'))
        {
            $PSBoundParameters.Log = if ($adtSession)
            {
                "$((Get-ADTConfig).Toolkit.LogPath)\$($adtSession.InstallName)_WinGet.log"
            }
            else
            {
                "$([System.IO.Path]::GetTempPath())Invoke-ADTWinGetOperation_$([System.DateTime]::Now.ToString('O').Split('.')[0].Replace(':', $null))_WinGet.log"
            }
        }

        # Default the scope to "Machine" for the safety of users.
        # It's super easy to install user-scoped apps into the SYSTEM
        # user's account, and it's painful to diagnose/clean up.
        if (($noScope = !$PSBoundParameters.ContainsKey('Scope')) -and !$wgPackage.Source.Equals('msstore'))
        {
            $PSBoundParameters.Add('Scope', 'Machine')
        }

        # Generate action lookup table for verbage.
        $actionTranslator = @{
            Install = 'Installer'
            Repair = 'Repair'
            Uninstall = 'Uninstaller'
            Upgrade = 'Installer'
        }
    }

    end
    {
        # Test whether we're debugging the AllowHashMismatch feature.
        if (($Action -notmatch '^(install|upgrade)$') -or !$PSBoundParameters.ContainsKey('DebugHashMismatch') -or !$PSBoundParameters.DebugHashMismatch)
        {
            # Invoke WinGet and print each non-null line.
            $wingetOutput = & $wingetInvoker -ArgumentList (Out-ADTWinGetDeploymentArgumentList -BoundParameters $PSBoundParameters)

            # If package isn't found, rerun again without --Scope argument.
            if (($Global:LASTEXITCODE -eq [ADTWinGetExitCode]::NO_APPLICABLE_INSTALLER) -and $noScope)
            {
                Write-ADTLogEntry -Message "Attempting to execute WinGet again without '--scope' argument."
                $wingetOutput = & $wingetInvoker -ArgumentList (Out-ADTWinGetDeploymentArgumentList -BoundParameters $PSBoundParameters -Exclude Scope)
            }
        }
        else
        {
            # Going into bypass mode. Simulate WinGet output for the purpose of getting the app's version later on.
            Write-ADTLogEntry -Message "Bypassing WinGet as `-DebugHashMismatch` has been passed. This switch should only be used for debugging purposes."
            $Global:LASTEXITCODE = [ADTWinGetExitCode]::INSTALLER_HASH_MISMATCH.value__
            $PSBoundParameters.'Ignore-Security-Hash' = $true
        }

        # If we're bypassing a hash failure, process the WinGet manifest ourselves.
        if (($Global:LASTEXITCODE -eq [ADTWinGetExitCode]::INSTALLER_HASH_MISMATCH) -and $PSBoundParameters.ContainsKey('Ignore-Security-Hash') -and $PSBoundParameters.'Ignore-Security-Hash')
        {
            # The hash failed, however we're forcing an override. Set up default parameters for Get-ADTWinGetHashMismatchInstaller and get started.
            Write-ADTLogEntry -Message "Installation failed due to mismatched hash, attempting to override as `-IgnoreHashFailure` has been passed."
            $gawgaiParams = @{}; if ($PSBoundParameters.ContainsKey('Scope'))
            {
                $gawgaiParams.Add('Scope', $PSBoundParameters.Scope)
            }
            if ($PSBoundParameters.ContainsKey('Architecture'))
            {
                $gawgaiParams.Add('Architecture', $PSBoundParameters.Architecture)
            }
            if ($PSBoundParameters.ContainsKey('Installer-Type'))
            {
                $gawgaiParams.Add('InstallerType', $PSBoundParameters.'Installer-Type')
            }

            # Grab the manifest so we can parse out the installation info as required.
            $wgAppInfo = [ordered]@{ Manifest = Get-ADTWinGetHashMismatchManifest -Id $wgPackage.Id -Version $wgPackage.Version }
            $wgAppInfo.Add('Installer', (Get-ADTWinGetHashMismatchInstaller @gawgaiParams -Manifest $wgAppInfo.Manifest))
            $wgAppInfo.Add('FilePath', (Get-ADTWinGetHashMismatchDownload -Installer $wgAppInfo.Installer))

            # Set up arguments to pass to Start-Process.
            $spParams = @{
                WorkingDirectory = $ExecutionContext.SessionState.Path.CurrentLocation.Path
                ArgumentList = Get-ADTWinGetHashMismatchArgumentList @wgAppInfo -LogFile $PSBoundParameters.Log
                FilePath = $(if ($wgAppInfo.FilePath.EndsWith('msi')) { 'msiexec.exe' } else { $wgAppInfo.FilePath })
                PassThru = $true
                Wait = $true
            }

            # Commence installation and test the resulting exit code for success.
            $wingetOutput = $(
                Write-ADTLogEntry -Message "Starting package install..." -PassThru
                Write-ADTLogEntry -Message "Executing [$($spParams.FilePath) $($spParams.ArgumentList)]" -PassThru
                if ((Get-ADTWinGetHashMismatchExitCodes @wgAppInfo) -notcontains ($Global:LASTEXITCODE = (Start-Process @spParams).ExitCode))
                {
                    Write-ADTLogEntry -Message "Uninstall failed with exit code: $Global:LASTEXITCODE." -PassThru
                }
                else
                {
                    Write-ADTLogEntry -Message "Successfully installed." -PassThru
                }
            )
        }

        # Generate an exception if we received any failure.
        $wingetException = if (($wingetErrLine = $($wingetOutput -match 'exit code: \d+')))
        {
            [System.Runtime.InteropServices.ExternalException]::new($wingetErrLine, [System.Int32]($wingetErrLine -replace '^.+:\s(\d+)\.$', '$1'))
        }
        elseif ($Global:LASTEXITCODE)
        {
            # All this bullshit is to change crap like '0x800704c7 : unknown error.' to 'Unknown error.'...
            $wgErrorDef = if ([System.Enum]::IsDefined([ADTWinGetExitCode], $Global:LASTEXITCODE)) { [ADTWinGetExitCode]$Global:LASTEXITCODE }
            $wgErrorMsg = [System.Text.RegularExpressions.Regex]::Replace($wingetOutput[-1], '^0x\w{8}\s:\s(\w)', { $args[0].Groups[1].Value.ToUpper() })
            [System.Runtime.InteropServices.ExternalException]::new("WinGet operation finished with exit code [0x$($Global:LASTEXITCODE.ToString('X'))$(if ($wgErrorDef) {" ($wgErrorDef)"})]: $($wgErrorMsg.TrimEnd('.')).", $Global:LASTEXITCODE)
        }

        # Calculate the exit code of the deployment operation.
        $wingetExitCode = if ($wingetException)
        {
            $wingetException.ErrorCode
        }
        else
        {
            $Global:LASTEXITCODE
        }

        # Update the session's exit code if one's in play.
        if ($adtSession)
        {
            $adtSession.SetExitCode($wingetExitCode)
        }

        # The WinGet cmdlets don't throw on install failure, but we need to within PSADT. Try
        # to give as much information as we can to the caller, including installer exit code.
        try
        {
            if ($wingetException)
            {
                # Throw our determined exception out to the caller to handle.
                $naerParams = @{
                    Exception = $wingetException
                    Category = [System.Management.Automation.ErrorCategory]::InvalidResult
                    ErrorId = "WinGetPackage$([System.Globalization.CultureInfo]::CurrentUICulture.TextInfo.ToTitleCase($Action))Failure"
                    TargetObject = $wingetOutput
                    RecommendedAction = "Please review the exit code, then try again."
                }
                throw (New-ADTErrorRecord @naerParams)
            }
        }
        catch
        {
            $PSCmdlet.ThrowTerminatingError($_)
        }
        finally
        {
            # Construct the return object to the caller. We try to closely match WinGet's output as possible.
            # According to WinGet: The Windows Package Manager does not support the reboot behavior currently.
            # https://github.com/microsoft/winget-pkgs/blob/master/doc/manifest/schema/1.6.0/installer.md
            if ($PassThru)
            {
                New-Variable -Name wingetResult -Scope 1 -Value ([pscustomobject]@{
                        Id = $wgPackage.Id
                        Name = $wgPackage.Name
                        Source = if ($PSBoundParameters.ContainsKey('Source')) { $Source } else { $wgPackage.Source }
                        CorrelationData = [System.String]::Empty
                        ExtendedErrorCode = $wingetException
                        RebootRequired = $Global:LASTEXITCODE.Equals(1641) -or ($Global:LASTEXITCODE.Equals(3010))
                        Status = if ($wingetException) { "$($Action)Error" } else { 'Ok' }
                        "$($actionTranslator.$Action)ErrorCode" = $wingetExitCode
                    })
            }
        }
    }
}
