﻿<#

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

1.  Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.

2.  Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

3.  Neither the name of the copyright holder nor the names of its
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

# Throw if we're running in the ISE, it can't support different character encoding.
if ($Host.Name.Equals('Windows PowerShell ISE Host'))
{
    throw [System.Management.Automation.ErrorRecord]::new(
        [System.NotSupportedException]::new("This module does not support Windows PowerShell ISE as it's not possible to set the output character encoding correctly."),
        'WindowsPowerShellIseNotSupported',
        [System.Management.Automation.ErrorCategory]::InvalidOperation,
        $Host
    )
}

# Throw if this psm1 file isn't being imported via our manifest.
if (!([System.Environment]::StackTrace.Split("`n") -like '*Microsoft.PowerShell.Commands.ModuleCmdletBase.LoadModuleManifest(*'))
{
    throw [System.Management.Automation.ErrorRecord]::new(
        [System.InvalidOperationException]::new("This module must be imported via its .psd1 file, which is recommended for all modules that supply a .psd1 file."),
        'ModuleImportError',
        [System.Management.Automation.ErrorCategory]::InvalidOperation,
        $MyInvocation.MyCommand.ScriptBlock.Module
    )
}

# Rethrowing caught exceptions makes the error output from Import-Module look better.
try
{
    # Set up lookup table for all cmdlets used within module, using PSAppDeployToolkit's as a basis.
    $CommandTable = [System.Collections.Generic.Dictionary[System.String, System.Management.Automation.CommandInfo]](& (& 'Microsoft.PowerShell.Core\Get-Command' -Name Get-ADTCommandTable -FullyQualifiedModule @{ ModuleName = 'PSAppDeployToolkit'; Guid = '8c3c366b-8606-4576-9f2d-4051144f7ca2'; ModuleVersion = '4.0.5' }))

    # Expand command lookup table with cmdlets used through this module.
    & {
        # Set up list of modules this module depends upon.
        $RequiredModules = [System.Collections.Generic.List[Microsoft.PowerShell.Commands.ModuleSpecification]][Microsoft.PowerShell.Commands.ModuleSpecification[]]$(
            @{ ModuleName = "$PSScriptRoot\Submodules\psyml"; Guid = 'a88e2e67-a937-4d98-a4d3-0b03d3ade169'; ModuleVersion = '1.0.0' }
        )

        # Handle the Appx module differently due to PowerShell 7 shenanighans. https://github.com/PowerShell/PowerShell/issues/13138
        if ($PSEdition.Equals('Core'))
        {
            try
            {
                (Import-Module -FullyQualifiedName @{ ModuleName = 'Appx'; Guid = 'aeef2bef-eba9-4a1d-a3d2-d0b52df76deb'; ModuleVersion = '1.0' } -Global -UseWindowsPowerShell -Force -PassThru -WarningAction Ignore -ErrorAction Stop).ExportedCommands.Values | & { process { $CommandTable.Add($_.Name, $_) } }
            }
            catch
            {
                (Import-Module -FullyQualifiedName @{ ModuleName = 'Appx'; Guid = 'aeef2bef-eba9-4a1d-a3d2-d0b52df76deb'; ModuleVersion = '1.0' } -Global -UseWindowsPowerShell -Force -PassThru -WarningAction Ignore -ErrorAction Stop).ExportedCommands.Values | & { process { $CommandTable.Add($_.Name, $_) } }
            }
        }
        else
        {
            $RequiredModules.Add(@{ ModuleName = 'Appx'; Guid = 'aeef2bef-eba9-4a1d-a3d2-d0b52df76deb'; ModuleVersion = '1.0' })
        }

        # Import required modules and add their commands to the command table.
        (Import-Module -FullyQualifiedName $RequiredModules -Global -Force -PassThru -ErrorAction Stop).ExportedCommands.Values | & { process { $CommandTable.Add($_.Name, $_) } }
    }

    # Set required variables to ensure module functionality.
    New-Variable -Name ErrorActionPreference -Value ([System.Management.Automation.ActionPreference]::Stop) -Option Constant -Force
    New-Variable -Name InformationPreference -Value ([System.Management.Automation.ActionPreference]::Continue) -Option Constant -Force
    New-Variable -Name ProgressPreference -Value ([System.Management.Automation.ActionPreference]::SilentlyContinue) -Option Constant -Force

    # Ensure module operates under the strictest of conditions.
    Set-StrictMode -Version 3

    # Store build information pertaining to this module's state.
    New-Variable -Name Module -Option Constant -Force -Value ([ordered]@{
            Manifest = Import-LocalizedData -BaseDirectory $PSScriptRoot -FileName 'PSAppDeployToolkit.WinGet.psd1'
            Compiled = $MyInvocation.MyCommand.Name.Equals('PSAppDeployToolkit.WinGet.psm1')
        }).AsReadOnly()

    # Remove any previous functions that may have been defined.
    if ($Module.Compiled)
    {
        New-Variable -Name FunctionPaths -Option Constant -Value ($MyInvocation.MyCommand.ScriptBlock.Ast.EndBlock.Statements | & { process { if ($_ -is [System.Management.Automation.Language.FunctionDefinitionAst]) { return "Microsoft.PowerShell.Core\Function::$($_.Name)" } } })
        Remove-Item -LiteralPath $FunctionPaths -Force -ErrorAction Ignore
    }

    # Define enum for all known WinGet exit codes.
    enum ADTWinGetExitCode
    {
        INTERNAL_ERROR = -1978335231
        INVALID_CL_ARGUMENTS = -1978335230
        COMMAND_FAILED = -1978335229
        MANIFEST_FAILED = -1978335228
        CTRL_SIGNAL_RECEIVED = -1978335227
        SHELLEXEC_INSTALL_FAILED = -1978335226
        UNSUPPORTED_MANIFESTVERSION = -1978335225
        DOWNLOAD_FAILED = -1978335224
        CANNOT_WRITE_TO_UPLEVEL_INDEX = -1978335223
        INDEX_INTEGRITY_COMPROMISED = -1978335222
        SOURCES_INVALID = -1978335221
        SOURCE_NAME_ALREADY_EXISTS = -1978335220
        INVALID_SOURCE_TYPE = -1978335219
        PACKAGE_IS_BUNDLE = -1978335218
        SOURCE_DATA_MISSING = -1978335217
        NO_APPLICABLE_INSTALLER = -1978335216
        INSTALLER_HASH_MISMATCH = -1978335215
        SOURCE_NAME_DOES_NOT_EXIST = -1978335214
        SOURCE_ARG_ALREADY_EXISTS = -1978335213
        NO_APPLICATIONS_FOUND = -1978335212
        NO_SOURCES_DEFINED = -1978335211
        MULTIPLE_APPLICATIONS_FOUND = -1978335210
        NO_MANIFEST_FOUND = -1978335209
        EXTENSION_PUBLIC_FAILED = -1978335208
        COMMAND_REQUIRES_ADMIN = -1978335207
        SOURCE_NOT_SECURE = -1978335206
        MSSTORE_BLOCKED_BY_POLICY = -1978335205
        MSSTORE_APP_BLOCKED_BY_POLICY = -1978335204
        EXPERIMENTAL_FEATURE_DISABLED = -1978335203
        MSSTORE_INSTALL_FAILED = -1978335202
        COMPLETE_INPUT_BAD = -1978335201
        YAML_INIT_FAILED = -1978335200
        YAML_INVALID_MAPPING_KEY = -1978335199
        YAML_DUPLICATE_MAPPING_KEY = -1978335198
        YAML_INVALID_OPERATION = -1978335197
        YAML_DOC_BUILD_FAILED = -1978335196
        YAML_INVALID_EMITTER_STATE = -1978335195
        YAML_INVALID_DATA = -1978335194
        LIBYAML_ERROR = -1978335193
        MANIFEST_VALIDATION_WARNING = -1978335192
        MANIFEST_VALIDATION_FAILURE = -1978335191
        INVALID_MANIFEST = -1978335190
        UPDATE_NOT_APPLICABLE = -1978335189
        UPDATE_ALL_HAS_FAILURE = -1978335188
        INSTALLER_SECURITY_CHECK_FAILED = -1978335187
        DOWNLOAD_SIZE_MISMATCH = -1978335186
        NO_UNINSTALL_INFO_FOUND = -1978335185
        EXEC_UNINSTALL_COMMAND_FAILED = -1978335184
        ICU_BREAK_ITERATOR_ERROR = -1978335183
        ICU_CASEMAP_ERROR = -1978335182
        ICU_REGEX_ERROR = -1978335181
        IMPORT_INSTALL_FAILED = -1978335180
        NOT_ALL_PACKAGES_FOUND = -1978335179
        JSON_INVALID_FILE = -1978335178
        SOURCE_NOT_REMOTE = -1978335177
        UNSUPPORTED_RESTSOURCE = -1978335176
        RESTSOURCE_INVALID_DATA = -1978335175
        BLOCKED_BY_POLICY = -1978335174
        RESTAPI_INTERNAL_ERROR = -1978335173
        RESTSOURCE_INVALID_URL = -1978335172
        RESTAPI_UNSUPPORTED_MIME_TYPE = -1978335171
        RESTSOURCE_INVALID_VERSION = -1978335170
        SOURCE_DATA_INTEGRITY_FAILURE = -1978335169
        STREAM_READ_FAILURE = -1978335168
        PACKAGE_AGREEMENTS_NOT_ACCEPTED = -1978335167
        PROMPT_INPUT_ERROR = -1978335166
        UNSUPPORTED_SOURCE_REQUEST = -1978335165
        RESTAPI_ENDPOINT_NOT_FOUND = -1978335164
        SOURCE_OPEN_FAILED = -1978335163
        SOURCE_AGREEMENTS_NOT_ACCEPTED = -1978335162
        CUSTOMHEADER_EXCEEDS_MAXLENGTH = -1978335161
        MISSING_RESOURCE_FILE = -1978335160
        MSI_INSTALL_FAILED = -1978335159
        INVALID_MSIEXEC_ARGUMENT = -1978335158
        FAILED_TO_OPEN_ALL_SOURCES = -1978335157
        DEPENDENCIES_VALIDATION_FAILED = -1978335156
        MISSING_PACKAGE = -1978335155
        INVALID_TABLE_COLUMN = -1978335154
        UPGRADE_VERSION_NOT_NEWER = -1978335153
        UPGRADE_VERSION_UNKNOWN = -1978335152
        ICU_CONVERSION_ERROR = -1978335151
        PORTABLE_INSTALL_FAILED = -1978335150
        PORTABLE_REPARSE_POINT_NOT_SUPPORTED = -1978335149
        PORTABLE_PACKAGE_ALREADY_EXISTS = -1978335148
        PORTABLE_SYMLINK_PATH_IS_DIRECTORY = -1978335147
        INSTALLER_PROHIBITS_ELEVATION = -1978335146
        PORTABLE_UNINSTALL_FAILED = -1978335145
        ARP_VERSION_VALIDATION_FAILED = -1978335144
        UNSUPPORTED_ARGUMENT = -1978335143
        BIND_WITH_EMBEDDED_NULL = -1978335142
        NESTEDINSTALLER_NOT_FOUND = -1978335141
        EXTRACT_ARCHIVE_FAILED = -1978335140
        NESTEDINSTALLER_INVALID_PATH = -1978335139
        PINNED_CERTIFICATE_MISMATCH = -1978335138
        INSTALL_LOCATION_REQUIRED = -1978335137
        ARCHIVE_SCAN_FAILED = -1978335136
        PACKAGE_ALREADY_INSTALLED = -1978335135
        PIN_ALREADY_EXISTS = -1978335134
        PIN_DOES_NOT_EXIST = -1978335133
        CANNOT_OPEN_PINNING_INDEX = -1978335132
        MULTIPLE_INSTALL_FAILED = -1978335131
        MULTIPLE_UNINSTALL_FAILED = -1978335130
        NOT_ALL_QUERIES_FOUND_SINGLE = -1978335129
        PACKAGE_IS_PINNED = -1978335128
        PACKAGE_IS_STUB = -1978335127
        APPTERMINATION_RECEIVED = -1978335126
        DOWNLOAD_DEPENDENCIES = -1978335125
        DOWNLOAD_COMMAND_PROHIBITED = -1978335124
        SERVICE_UNAVAILABLE = -1978335123
        RESUME_ID_NOT_FOUND = -1978335122
        CLIENT_VERSION_MISMATCH = -1978335121
        INVALID_RESUME_STATE = -1978335120
        CANNOT_OPEN_CHECKPOINT_INDEX = -1978335119
        RESUME_LIMIT_EXCEEDED = -1978335118
        INVALID_AUTHENTICATION_INFO = -1978335117
        AUTHENTICATION_TYPE_NOT_SUPPORTED = -1978335116
        AUTHENTICATION_FAILED = -1978335115
        AUTHENTICATION_INTERACTIVE_REQUIRED = -1978335114
        AUTHENTICATION_CANCELLED_BY_USER = -1978335113
        AUTHENTICATION_INCORRECT_ACCOUNT = -1978335112
        NO_REPAIR_INFO_FOUND = -1978335111
        REPAIR_NOT_APPLICABLE = -1978335110
        EXEC_REPAIR_FAILED = -1978335109
        REPAIR_NOT_SUPPORTED = -1978335108
        ADMIN_CONTEXT_REPAIR_PROHIBITED = -1978335107
        SQLITE_CONNECTION_TERMINATED = -1978335106
        DISPLAYCATALOG_API_FAILED = -1978335105
        NO_APPLICABLE_DISPLAYCATALOG_PACKAGE = -1978335104
        SFSCLIENT_API_FAILED = -1978335103
        NO_APPLICABLE_SFSCLIENT_PACKAGE = -1978335102
        LICENSING_API_FAILED = -1978335101
        INSTALL_PACKAGE_IN_USE = -1978334975
        INSTALL_INSTALL_IN_PROGRESS = -1978334974
        INSTALL_FILE_IN_USE = -1978334973
        INSTALL_MISSING_DEPENDENCY = -1978334972
        INSTALL_DISK_FULL = -1978334971
        INSTALL_INSUFFICIENT_MEMORY = -1978334970
        INSTALL_NO_NETWORK = -1978334969
        INSTALL_CONTACT_SUPPORT = -1978334968
        INSTALL_REBOOT_REQUIRED_TO_FINISH = -1978334967
        INSTALL_REBOOT_REQUIRED_FOR_INSTALL = -1978334966
        INSTALL_REBOOT_INITIATED = -1978334965
        INSTALL_CANCELLED_BY_USER = -1978334964
        INSTALL_ALREADY_INSTALLED = -1978334963
        INSTALL_DOWNGRADE = -1978334962
        INSTALL_BLOCKED_BY_POLICY = -1978334961
        INSTALL_DEPENDENCIES = -1978334960
        INSTALL_PACKAGE_IN_USE_BY_APPLICATION = -1978334959
        INSTALL_INVALID_PARAMETER = -1978334958
        INSTALL_SYSTEM_NOT_SUPPORTED = -1978334957
        INSTALL_UPGRADE_NOT_SUPPORTED = -1978334956
        INVALID_CONFIGURATION_FILE = -1978286079
        INVALID_YAML = -1978286078
        INVALID_FIELD_TYPE = -1978286077
        UNKNOWN_CONFIGURATION_FILE_VERSION = -1978286076
        SET_APPLY_FAILED = -1978286075
        DUPLICATE_IDENTIFIER = -1978286074
        MISSING_DEPENDENCY = -1978286073
        DEPENDENCY_UNSATISFIED = -1978286072
        ASSERTION_FAILED = -1978286071
        MANUALLY_SKIPPED = -1978286070
        WARNING_NOT_ACCEPTED = -1978286069
        SET_DEPENDENCY_CYCLE = -1978286068
        INVALID_FIELD_VALUE = -1978286067
        MISSING_FIELD = -1978286066
        TEST_FAILED = -1978286065
        TEST_NOT_RUN = -1978286064
        GET_FAILED = -1978286063
        UNIT_NOT_INSTALLED = -1978285823
        UNIT_NOT_FOUND_REPOSITORY = -1978285822
        UNIT_MULTIPLE_MATCHES = -1978285821
        UNIT_INVOKE_GET = -1978285820
        UNIT_INVOKE_TEST = -1978285819
        UNIT_INVOKE_SET = -1978285818
        UNIT_MODULE_CONFLICT = -1978285817
        UNIT_IMPORT_MODULE = -1978285816
        UNIT_INVOKE_INVALID_RESULT = -1978285815
        UNIT_SETTING_CONFIG_ROOT = -1978285808
        UNIT_IMPORT_MODULE_ADMIN = -1978285807
        NOT_SUPPORTED_BY_PROCESSOR = -1978285806
    }
}
catch
{
    throw
}
