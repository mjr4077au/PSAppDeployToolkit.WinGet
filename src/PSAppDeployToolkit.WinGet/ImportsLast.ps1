#-----------------------------------------------------------------------------
#
# MARK: Module Constants and Function Exports
#
#-----------------------------------------------------------------------------

# Set all functions as read-only, export all public definitions and finalise the CommandTable.
Set-Item -LiteralPath $FunctionPaths -Options ReadOnly
Get-Item -LiteralPath $FunctionPaths | & { process { $CommandTable.Add($_.Name, $_) } }
New-Variable -Name CommandTable -Value ([System.Collections.ObjectModel.ReadOnlyDictionary[System.String, System.Management.Automation.CommandInfo]]::new($CommandTable)) -Option Constant -Force -Confirm:$false
Export-ModuleMember -Function $Module.Manifest.FunctionsToExport

# Store module globals needed for the lifetime of the module.
New-Variable -Name ADT -Option Constant -Value ([pscustomobject]@{
        WinGetMinVersion = [System.Version]::new(1, 7, 10582)
        RunningAsSystem = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.IsWellKnown([System.Security.Principal.WellKnownSidType]::LocalSystemSid)
        RunningAsAdmin = Test-ADTCallerIsAdmin
        SystemArchitecture = switch ([PSADT.OperatingSystem.OSHelper]::GetArchitecture())
        {
            ([PSADT.Shared.SystemArchitecture]::ARM64)
            {
                'arm64'
                break
            }
            ([PSADT.Shared.SystemArchitecture]::AMD64)
            {
                'x64'
                break
            }
            ([PSADT.Shared.SystemArchitecture]::i386)
            {
                'x86'
                break
            }
            default
            {
                throw [System.Management.Automation.ErrorRecord]::new(
                    [System.InvalidOperationException]::new("The operating system of this computer is of an unsupported architecture."),
                    'WinGetInvalidArchitectureError',
                    [System.Management.Automation.ErrorCategory]::InvalidOperation,
                    $_
                )
            }
        }
    })

# Following the successful import, set the console's output encoding to UTF8 as required by WinGet's command line.
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
