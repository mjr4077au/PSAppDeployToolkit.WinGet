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

        # Set up some default parameter values.
        if (!$PSBoundParameters.ContainsKey('Scope'))
        {
            $PSBoundParameters.Add('Scope', 'Machine')
        }
        if (!$PSBoundParameters.ContainsKey('Source'))
        {
            $PSBoundParameters.Add('Source', 'winget')
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
        $wingetArgs = $(
            $Action
            $PSBoundParameters | Convert-ADTFunctionParamsToArgArray -Preset WinGet -Exclude Action
            '--accept-source-agreements'
            '--accept-package-agreements'
        )

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
        [System.String[]]$wingetOutput = & $wingetPath $wingetArgs 2>&1 | & {
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
        }

        # Get the WinGet package code. If we didn't error out, assume zero as it's all we can do.
        $wingetPackageErrCode = if (($wingetErrLine = $($wingetOutput -match 'exit code: \d+')))
        {
            [System.Int32]($wingetErrLine -replace '^.+:\s(\d+)\.$', '$1')
        }
        else
        {
            0
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
            # Get the installer's exit code if there is one.
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
