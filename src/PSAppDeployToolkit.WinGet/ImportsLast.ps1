#-----------------------------------------------------------------------------
#
# MARK: Module Constants and Function Exports
#
#-----------------------------------------------------------------------------

# Set all functions as read-only, export all public definitions and finalise the CommandTable.
& $CommandTable.'Set-Item' -LiteralPath $FunctionPaths -Options ReadOnly
& $CommandTable.'Get-Item' -LiteralPath $FunctionPaths | & { process { $CommandTable.Add($_.Name, $_) } }
& $CommandTable.'New-Variable' -Name CommandTable -Value $CommandTable.AsReadOnly() -Option Constant -Force -Confirm:$false
& $CommandTable.'Export-ModuleMember' -Function $Module.Manifest.FunctionsToExport
