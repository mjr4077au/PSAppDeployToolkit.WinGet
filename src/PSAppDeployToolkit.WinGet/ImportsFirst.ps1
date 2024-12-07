<#

.SYNOPSIS
PSAppDeployToolkit.WinGet - This module script a basic scaffold to use with PSAppDeployToolkit modules destined for the PowerShell Gallery.

.DESCRIPTION
This module can be directly imported from the command line via Import-Module, but it is usually imported by the Invoke-AppDeployToolkit.ps1 script.

PSAppDeployToolkit is licensed under the BSD 3-Clause License - Copyright (C) 2024 Mitch Richters. All rights reserved.

.NOTES
BSD 3-Clause License

Copyright (c) 2024, Mitch Richters

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#>

#-----------------------------------------------------------------------------
#
# MARK: Module Initialization Code
#
#-----------------------------------------------------------------------------

# Define modules needed to build out CommandTable.
$RequiredModules = [System.Collections.ObjectModel.ReadOnlyCollection[Microsoft.PowerShell.Commands.ModuleSpecification]]$(
    @{ ModuleName = 'Microsoft.PowerShell.Management'; Guid = 'eefcb906-b326-4e99-9f54-8b4bb6ef3c6d'; ModuleVersion = '1.0' }
    @{ ModuleName = 'Microsoft.PowerShell.Utility'; Guid = '1da87e53-152b-403e-98dc-74d7b4d63d59'; ModuleVersion = '1.0' }
    @{ ModuleName = 'PSAppDeployToolkit'; Guid = '8c3c366b-8606-4576-9f2d-4051144f7ca2'; ModuleVersion = '4.0.2' }
)

# Build out lookup table for all cmdlets used within module, starting with the core cmdlets.
$CommandTable = [ordered]@{}; $ExecutionContext.SessionState.InvokeCommand.GetCmdlets() | & { process { if ($_.PSSnapIn -and $_.PSSnapIn.Name.Equals('Microsoft.PowerShell.Core') -and $_.PSSnapIn.IsDefault) { $CommandTable.Add($_.Name, $_) } } }
(& $CommandTable.'Import-Module' -FullyQualifiedName $RequiredModules -Global -Force -PassThru -ErrorAction Stop).ExportedCommands.Values | & { process { $CommandTable.Add($_.Name, $_) } }

# Set required variables to ensure module functionality.
& $CommandTable.'New-Variable' -Name ErrorActionPreference -Value ([System.Management.Automation.ActionPreference]::Stop) -Option Constant -Force
& $CommandTable.'New-Variable' -Name InformationPreference -Value ([System.Management.Automation.ActionPreference]::Continue) -Option Constant -Force
& $CommandTable.'New-Variable' -Name ProgressPreference -Value ([System.Management.Automation.ActionPreference]::SilentlyContinue) -Option Constant -Force

# Ensure module operates under the strictest of conditions.
& $CommandTable.'Set-StrictMode' -Version 3

# Import this module's manifest via the language parser. This allows us to test with potential extra variables that are permitted in manifests.
# https://github.com/PowerShell/PowerShell/blob/7ca7aae1d13d19e38c7c26260758f474cb9bef7f/src/System.Management.Automation/engine/Modules/ModuleCmdletBase.cs#L509-L512
$Module = [System.Management.Automation.Language.Parser]::ParseFile("$PSScriptRoot\PSAppDeployToolkit.WinGet.psd1", [ref]$null, [ref]$null).GetScriptBlock()
$Module.CheckRestrictedLanguage([System.String[]]$null, [System.String[]]('PSEdition'), $true); $Module = & $Module

# Store build information pertaining to this module's state.
& $CommandTable.'New-Variable' -Name Module -Option Constant -Force -Value ([ordered]@{
        Manifest = $Module
        Compiled = $MyInvocation.MyCommand.Name.Equals('PSAppDeployToolkit.WinGet.psm1')
    }).AsReadOnly()

# Remove any previous functions that may have been defined.
if ($Module.Compiled)
{
    & $CommandTable.'New-Variable' -Name FunctionNames -Option Constant -Value ($MyInvocation.MyCommand.ScriptBlock.Ast.EndBlock.Statements | & { process { if ($_ -is [System.Management.Automation.Language.FunctionDefinitionAst]) { return $_.Name } } })
    & $CommandTable.'New-Variable' -Name FunctionPaths -Option Constant -Value ($FunctionNames -replace '^', 'Microsoft.PowerShell.Core\Function::')
    & $CommandTable.'Remove-Item' -LiteralPath $FunctionPaths -Force -ErrorAction Ignore
}
