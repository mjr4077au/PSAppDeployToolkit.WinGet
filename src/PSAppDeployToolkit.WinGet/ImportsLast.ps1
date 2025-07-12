#-----------------------------------------------------------------------------
#
# MARK: Module Constants and Function Exports
#
#-----------------------------------------------------------------------------

# Rethrowing caught exceptions makes the error output from Import-Module look better.
try
{
    # Set all functions as read-only, export all public definitions and finalise the CommandTable.
    Set-Item -LiteralPath $FunctionPaths -Options ReadOnly
    Get-Item -LiteralPath $FunctionPaths | & { process { $CommandTable.Add($_.Name, $_) } }
    New-Variable -Name CommandTable -Value ([System.Collections.ObjectModel.ReadOnlyDictionary[System.String, System.Management.Automation.CommandInfo]]::new($CommandTable)) -Option Constant -Force -Confirm:$false
    Export-ModuleMember -Function $Module.Manifest.FunctionsToExport

    # Store module globals needed for the lifetime of the module.
    $currentWindowsIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    try
    {
        New-Variable -Name ADT -Option Constant -Value ([pscustomobject]@{
                WinGetMinVersion = [System.Version]::new(1, 7, 10582)
                RunningAsSystem = $currentWindowsIdentity.User.IsWellKnown([System.Security.Principal.WellKnownSidType]::LocalSystemSid)
                RunningAsAdmin = Test-ADTCallerIsAdmin
                SystemArchitecture = [System.Runtime.InteropServices.RuntimeInformation, mscorlib, Version = 4.0.0.0, Culture = neutral, PublicKeyToken = b77a5c561934e089]::OSArchitecture.ToString().ToLower()
            })
    }
    finally
    {
        $currentWindowsIdentity.Dispose()
        Remove-Variable -Name currentWindowsIdentity -Force -Confirm:$false
    }

    # Announce successful importation of module.
    Write-ADTLogEntry -Message "Module [PSAppDeployToolkit.WinGet] imported successfully." -ScriptSection Initialization -Source 'PSAppDeployToolkit.WinGet.psm1'
}
catch
{
    throw
}
