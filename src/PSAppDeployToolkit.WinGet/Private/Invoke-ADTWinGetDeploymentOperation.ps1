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
        [System.String]$Action
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

        # Add in parameters used by all actions.
        $paramDictionary.Add('Id', [System.Management.Automation.RuntimeDefinedParameter]::new(
                'Id', [System.String], $(
                    [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                    [System.Management.Automation.ValidateNotNullOrEmptyAttribute]::new()
                )
            ))
        $paramDictionary.Add('Log', [System.Management.Automation.RuntimeDefinedParameter]::new(
                'Log', [System.String], $(
                    [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                    [System.Management.Automation.ValidateNotNullOrEmptyAttribute]::new()
                )
            ))
        $paramDictionary.Add('Mode', [System.Management.Automation.RuntimeDefinedParameter]::new(
                'Mode', [System.String], $(
                    [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                    [System.Management.Automation.ValidateSetAttribute]::new('Silent', 'Interactive')
                )
            ))
        $paramDictionary.Add('Moniker', [System.Management.Automation.RuntimeDefinedParameter]::new(
                'Moniker', [System.String], $(
                    [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                    [System.Management.Automation.ValidateNotNullOrEmptyAttribute]::new()
                )
            ))
        $paramDictionary.Add('Name', [System.Management.Automation.RuntimeDefinedParameter]::new(
                'Name', [System.String], $(
                    [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                    [System.Management.Automation.ValidateNotNullOrEmptyAttribute]::new()
                )
            ))
        $paramDictionary.Add('Source', [System.Management.Automation.RuntimeDefinedParameter]::new(
                'Source', [System.String], $(
                    [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                    [System.Management.Automation.ValidateNotNullOrEmptyAttribute]::new()
                )
            ))
        $paramDictionary.Add('Version', [System.Management.Automation.RuntimeDefinedParameter]::new(
                'Version', [System.String], $(
                    [System.Management.Automation.ParameterAttribute]@{ Mandatory = $false }
                    [System.Management.Automation.ValidateNotNullOrEmptyAttribute]::new()
                )
            ))

        # Return the populated dictionary.
        return $paramDictionary
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
            $PSBoundParameters.Exclude = $('Action'; $Exclude)

            # Output each item for the caller to collect.
            return $(
                $Action
                Convert-ADTFunctionParamsToArgArray @PSBoundParameters -Preset WinGet
                '--accept-source-agreements'
                '--accept-package-agreements'
            )
        }

        # Define internal scriptblock for invoking WinGet. This is a
        # scriptblock so Write-ADTLogEntry uses this function's source.
        $wingetInvoker = {
            return ,[System.String[]](& $wingetPath $wingetArgs 2>&1 | & {
                begin
                {
                    $waleParams = @{PassThru = $true}
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

        # Try to get the path to WinGet before proceeding.
        try
        {
            $wingetPath = Get-ADTWinGetPath
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

        # Default the scope to "Machine" for the safety of users.
        # It's super easy to install user-scoped apps into the SYSTEM
        # user's account, and it's painful to diagnose/clean up.
        if (($noScope = !$PSBoundParameters.ContainsKey('Scope')))
        {
            $PSBoundParameters.Add('Scope', 'Machine')
        }

        # Most of the time, we're only wanting a WinGet package anyway.
        # Defaulting to the winget source speeds up operations.
        if (!$PSBoundParameters.ContainsKey('Source'))
        {
            $PSBoundParameters.Add('Source', 'winget')
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

        # Attempt to find the package to install.
        try
        {
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

        # Set up arguments array for WinGet.
        $wingetArgs = Out-ADTWinGetDeploymentArgumentList -BoundParameters $PSBoundParameters

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
        # Invoke WinGet and print each non-null line.
        Write-ADTLogEntry -Message "Executing [$wingetPath $wingetArgs]."
        $wingetOutput = & $wingetInvoker

        # If package isn't found, rerun again without --Scope argument.
        if (($Global:LASTEXITCODE -eq [ADTWinGetExitCode]::NO_APPLICABLE_INSTALLER) -and $noScope)
        {
            Write-ADTLogEntry -Message "Attempting to execute WinGet again without '--scope' argument."
            $wingetArgs = Out-ADTWinGetDeploymentArgumentList -BoundParameters $PSBoundParameters -Exclude Scope
            $wingetOutput = & $wingetInvoker
        }

        # Get the WinGet package code. If we didn't error out, assume zero as it's all we can do.
        $wingetPackageErrCode = if (($wingetErrLine = $($wingetOutput -match 'exit code: \d+')))
        {
            [System.Int32]($wingetErrLine -replace '^.+:\s(\d+)\.$', '$1')
        }
        else
        {
            $Global:LASTEXITCODE
        }

        # Generate an exception if we received any failure.
        $wingetException = if ($wingetErrLine)
        {
            [System.Runtime.InteropServices.ExternalException]::new($wingetErrLine, $wingetPackageErrCode)
        }
        elseif ($Global:LASTEXITCODE)
        {
            # All this bullshit is to change crap like '0x800704c7 : unknown error.' to 'Unknown error.'...
            $wgErrorDef = if ([System.Enum]::IsDefined([ADTWinGetExitCode], $Global:LASTEXITCODE)) { [ADTWinGetExitCode]$Global:LASTEXITCODE }
            $wgErrorMsg = [System.Text.RegularExpressions.Regex]::Replace($wingetOutput[-1], '^0x\w{8}\s:\s(\w)', { $args[0].Groups[1].Value.ToUpper() })
            [System.ComponentModel.Win32Exception]::new($Global:LASTEXITCODE, "WinGet operation finished with exit code 0x$($Global:LASTEXITCODE.ToString('X'))$(if ($wgErrorDef) {" ($wgErrorDef)"}) [$($wgErrorMsg.TrimEnd('.'))].")
        }

        # The WinGet cmdlets don't throw on install failure, but we need to within PSADT. Try
        # to give as much information as we can to the caller, including installer exit code.
        if ($wingetException)
        {
            # Update the session's exit code if one's in play.
            if ($adtSession)
            {
                $adtSession.SetExitCode($wingetPackageErrCode)
            }

            # Throw our determined exception out to the caller to handle.
            $naerParams = @{
                Exception = $wingetException
                Category = [System.Management.Automation.ErrorCategory]::InvalidResult
                ErrorId = "WinGetPackage$([System.Globalization.CultureInfo]::CurrentUICulture.TextInfo.ToTitleCase($Action))Failure"
                TargetObject = $wingetOutput
                RecommendedAction = "Please review the exit code, then try again."
            }
            $PSCmdlet.ThrowTerminatingError((New-ADTErrorRecord @naerParams))
        }

        # Construct the return object to the caller. We try to closely match WinGet's output as possible.
        # According to WinGet: The Windows Package Manager does not support the reboot behavior currently.
        # https://github.com/microsoft/winget-pkgs/blob/master/doc/manifest/schema/1.6.0/installer.md
        return [pscustomobject]@{
            Id = $wgPackage.Id
            Name = $wgPackage.Name
            Source = $PSBoundParameters.Source
            CorrelationData = [System.String]::Empty
            ExtendedErrorCode = $wingetException
            RebootRequired = $Global:LASTEXITCODE.Equals(1641) -or ($Global:LASTEXITCODE.Equals(3010))
            Status = if ($wingetPackageErrCode) { "$($Action)Error" } else { 'Ok' }
            "$($actionTranslator.$Action)ErrorCode" = $wingetPackageErrCode
        }
    }
}
