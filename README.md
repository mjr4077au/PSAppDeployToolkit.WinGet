# PSAppDeployToolkit.WinGet

## Synopsis

A PSAppDeployToolkit v4 extension module for WinGet.

## Description

This PowerShell module is a WinGet extension for PSAppDeployToolkit v4, allowing WinGet application installation and uninstallation via PSAppDeployToolkit.

This PowerShell module has been developed to match Microsoft.WinGet.Client's API as closely as possible. This is to ease the transition over from people who have used Microsoft's module before, and because when the WinGet team do have their PowerShell module able to install packages while running as SYSTEM, the internals of this one will change to simply wrap Microsoft's cmdlets.

## Why

More people ask for WinGet support in PSAppDeployToolkit than any other feature, so here's an implementation from one of PSAppDeployToolkit's very own developers.

## Quick start

Below are some quick commands to get you started. Full documentation for all commands within this module is available in the [docs](/docs) folder.

### Installing the module

```PowerShell
PS C:\> Install-Module -Name PSAppDeployToolkit.WinGet
```
Installs this PowerShell module from the PSGallery.

### Importing the module

```PowerShell
PS C:\> Import-Module -Name PSAppDeployToolkit.WinGet
```
Imports this installed PowerShell module into your current runspace.

### Installing Microsoft Visual Studio Tools for Office

```PowerShell
PS C:\> Install-ADTWinGetPackage -Id Microsoft.VSTOR -Verbose

VERBOSE: [2024-12-20T15:10:36.5532477+11:00] [Invoke-ADTWinGetDeploymentOperation] :: Executing [C:\Users\user\AppData\Local\Microsoft\WindowsApps\winget.exe Install --id Microsoft.VSTOR --scope Machine --source winget --log
C:\Users\user\AppData\Local\Temp\Invoke-ADTWinGetOperation_2024-12-20T151035_WinGet.log --accept-source-agreements --accept-package-agreements].
VERBOSE: [2024-12-20T15:10:38.4421583+11:00] [Invoke-ADTWinGetDeploymentOperation] :: Found Microsoft Visual Studio 2010 Tools for Office Runtime [Microsoft.VSTOR] Version 10.0.60917.
VERBOSE: [2024-12-20T15:10:38.4491578+11:00] [Invoke-ADTWinGetDeploymentOperation] :: This application is licensed to you by its owner.
VERBOSE: [2024-12-20T15:10:38.4541596+11:00] [Invoke-ADTWinGetDeploymentOperation] :: Microsoft is not responsible for, nor does it grant any licenses to, third-party packages.
VERBOSE: [2024-12-20T15:10:38.4741576+11:00] [Invoke-ADTWinGetDeploymentOperation] :: Downloading https://download.microsoft.com/download/5/d/2/5d24f8f8-efbb-4b63-aa33-3785e3104713/vstor_redist.exe.
VERBOSE: [2024-12-20T15:10:45.4299315+11:00] [Invoke-ADTWinGetDeploymentOperation] :: Successfully verified installer hash.
VERBOSE: [2024-12-20T15:10:46.3636918+11:00] [Invoke-ADTWinGetDeploymentOperation] :: Starting package install...
VERBOSE: [2024-12-20T15:11:06.8850828+11:00] [Invoke-ADTWinGetDeploymentOperation] :: Successfully installed.


Id                 : Microsoft.VSTOR
Name               : Microsoft Visual Studio 2010 Tools for Office Runtime
Source             : winget
CorrelationData    :
ExtendedErrorCode  :
RebootRequired     : False
Status             : Ok
InstallerErrorCode : 0
```
Installs the package with Id `Microsoft.VSTOR` onto the computer.

### Detecting/confirming Microsoft Visual Studio Tools for Office is installed

```PowerShell
PS C:\> Get-ADTWinGetPackage -Id Microsoft.VSTOR -Verbose

VERBOSE: [2024-12-20T15:11:47.1654182+11:00] [Invoke-ADTWinGetQueryOperation] :: Finding packages matching input criteria, please wait...
VERBOSE: [2024-12-20T15:11:49.4147398+11:00] [Invoke-ADTWinGetQueryOperation] :: Found 1 package matching input criteria.

Name                                                        Id              Version    Source
----                                                        --              -------    ------
Microsoft Visual Studio 2010 Tools for Office Runtime (x64) Microsoft.VSTOR 10.0.60917 winget
```
Returns an object of the installed package with Id `Microsoft.VSTOR` on this computer.

### Uninstalling Microsoft Visual Studio Tools for Office

```PowerShell
PS C:\> Uninstall-ADTWinGetPackage -Id Microsoft.VSTOR -Verbose

VERBOSE: [2024-12-20T15:09:15.2037222+11:00] [Invoke-ADTWinGetDeploymentOperation] :: Executing [C:\Users\user\AppData\Local\Microsoft\WindowsApps\winget.exe Uninstall --id Microsoft.VSTOR --scope Machine --source winget --log
C:\Users\user\AppData\Local\Temp\Invoke-ADTWinGetOperation_2024-12-20T150914_WinGet.log --accept-source-agreements].
VERBOSE: [2024-12-20T15:09:17.1155415+11:00] [Invoke-ADTWinGetDeploymentOperation] :: Found Microsoft Visual Studio 2010 Tools for Office Runtime (x64) [Microsoft.VSTOR].
VERBOSE: [2024-12-20T15:09:17.2270534+11:00] [Invoke-ADTWinGetDeploymentOperation] :: Starting package uninstall...
VERBOSE: [2024-12-20T15:09:26.4758529+11:00] [Invoke-ADTWinGetDeploymentOperation] :: Successfully uninstalled.


Id                   : Microsoft.VSTOR
Name                 : Microsoft Visual Studio 2010 Tools for Office Runtime
Source               : winget
CorrelationData      :
ExtendedErrorCode    :
RebootRequired       : False
Status               : Ok
UninstallerErrorCode : 0
```
Uninstalls the package with Id `Microsoft.VSTOR` from the computer.

### Performing a full deployment of Microsoft Visual Studio Tools for Office

```PowerShell
PS C:\> Invoke-ADTWinGetOperation -Id Microsoft.VSTOR -DeployMode Silent

[2024-12-20 15:04:43.996] [Initialization] [Open-ADTSession] [Info] :: *******************************************************************************
[2024-12-20 15:04:43.996] [Initialization] [Open-ADTSession] [Info] :: *******************************************************************************
[2024-12-20 15:04:43.999] [Initialization] [Open-ADTSession] [Info] :: [MicrosoftVisualStudio2010ToolsforOfficeRuntime_10.0.60917] install started.
[2024-12-20 15:04:44.000] [Initialization] [Open-ADTSession] [Info] :: [Invoke-ADTWinGetOperation] script version is [1.0.0].
[2024-12-20 15:04:44.002] [Initialization] [Open-ADTSession] [Info] :: The following parameters were passed to [Invoke-ADTWinGetOperation]: [-Id:'Microsoft.VSTOR' -DeployMode:'Silent'].
[2024-12-20 15:04:44.004] [Initialization] [Open-ADTSession] [Info] :: [PSAppDeployToolkit] module version is [4.0.4].
[2024-12-20 15:04:44.005] [Initialization] [Open-ADTSession] [Info] :: [PSAppDeployToolkit] module imported in [3.8406832] seconds.
[2024-12-20 15:04:44.006] [Initialization] [Open-ADTSession] [Info] :: [PSAppDeployToolkit] module initialized in [1.0229584] seconds.
[2024-12-20 15:04:44.007] [Initialization] [Open-ADTSession] [Info] :: [PSAppDeployToolkit] module path is ['C:\Program Files\WindowsPowerShell\Modules\PSAppDeployToolkit\4.0.4'].
[2024-12-20 15:04:44.009] [Initialization] [Open-ADTSession] [Info] :: [PSAppDeployToolkit] config path is ['C:\Program Files\WindowsPowerShell\Modules\PSAppDeployToolkit\4.0.4\Config'].
[2024-12-20 15:04:44.010] [Initialization] [Open-ADTSession] [Info] :: [PSAppDeployToolkit] string path is ['C:\Program Files\WindowsPowerShell\Modules\PSAppDeployToolkit\4.0.4\Strings'].
[2024-12-20 15:04:44.011] [Initialization] [Open-ADTSession] [Info] :: [PSAppDeployToolkit] session mode is [Native].
[2024-12-20 15:04:44.024] [Initialization] [Open-ADTSession] [Info] :: Computer Name is [WORKSTATION].
[2024-12-20 15:04:44.025] [Initialization] [Open-ADTSession] [Info] :: Current User is [WORKSTATION\user].
[2024-12-20 15:04:44.027] [Initialization] [Open-ADTSession] [Info] :: OS Version is [Microsoft Windows 11 Enterprise AMD64 10.0.26100.2605].
[2024-12-20 15:04:44.028] [Initialization] [Open-ADTSession] [Info] :: OS Type is [Workstation].
[2024-12-20 15:04:44.030] [Initialization] [Open-ADTSession] [Info] :: Hardware Platform is [Physical].
[2024-12-20 15:04:44.031] [Initialization] [Open-ADTSession] [Info] :: Current Culture is [en-AU], language is [EN] and UI language is [EN].
[2024-12-20 15:04:44.032] [Initialization] [Open-ADTSession] [Info] :: PowerShell Host is [ConsoleHost] with version [5.1.26100.2161].
[2024-12-20 15:04:44.034] [Initialization] [Open-ADTSession] [Info] :: PowerShell Version is [5.1.26100.2161 AMD64].
[2024-12-20 15:04:44.035] [Initialization] [Open-ADTSession] [Info] :: PowerShell CLR (.NET) version is [4.0.30319.42000].
[2024-12-20 15:04:44.037] [Initialization] [Open-ADTSession] [Info] :: *******************************************************************************
[2024-12-20 15:04:44.040] [Initialization] [Open-ADTSession] [Info] :: The following users are logged on to the system: [WORKSTATION\user].
[2024-12-20 15:04:44.041] [Initialization] [Open-ADTSession] [Info] :: Current process is running with user account [WORKSTATION\user] under logged on user session for [WORKSTATION\user].
[2024-12-20 15:04:44.048] [Initialization] [Open-ADTSession] [Info] :: The following user is the console user [WORKSTATION\user] (user with control of physical monitor, keyboard, and mouse).
[2024-12-20 15:04:44.057] [Initialization] [Open-ADTSession] [Info] :: The active logged on user is [WORKSTATION\user].
[2024-12-20 15:04:44.058] [Initialization] [Open-ADTSession] [Info] :: The current execution context has a primary UI language of [EN].
[2024-12-20 15:04:44.060] [Initialization] [Open-ADTSession] [Info] :: The following UI messages were imported from the config file: [en-GB].
[2024-12-20 15:04:44.061] [Initialization] [Open-ADTSession] [Info] :: Unable to find COM object [Microsoft.SMS.TSEnvironment]. Therefore, script is not currently running from a SCCM Task Sequence.
[2024-12-20 15:04:44.063] [Initialization] [Open-ADTSession] [Info] :: Session 0 not detected.
[2024-12-20 15:04:44.064] [Initialization] [Open-ADTSession] [Info] :: Installation is running in [Silent] mode.
[2024-12-20 15:04:44.065] [Initialization] [Open-ADTSession] [Info] :: Deployment type is [Install].
[2024-12-20 15:04:44.101] [Pre-Install] [Show-ADTInstallationWelcome] [Info] :: Evaluating disk space requirements.
[2024-12-20 15:04:44.110] [Pre-Install] [Get-ADTFreeDiskSpace] [Info] :: Retrieving free disk space for drive [C:\].
[2024-12-20 15:04:44.115] [Pre-Install] [Get-ADTFreeDiskSpace] [Info] :: Free disk space for drive [C:\]: [22107 MB].
[2024-12-20 15:04:44.121] [Pre-Install] [Show-ADTInstallationWelcome] [Info] :: Successfully passed minimum disk space requirement check.
[2024-12-20 15:04:44.124] [Pre-Install] [Get-ADTDeferHistory] [Info] :: Getting deferral history...
[2024-12-20 15:04:44.129] [Pre-Install] [Show-ADTInstallationWelcome] [Info] :: Defer history shows [0] deferrals remaining.
[2024-12-20 15:04:44.132] [Pre-Install] [Show-ADTInstallationWelcome] [Info] :: Deferral has expired.
[2024-12-20 15:04:44.166] [Pre-Install] [Show-ADTInstallationProgress] [Info] :: Bypassing Show-ADTInstallationProgress [Mode: Silent]. Status message: Installation in progress. Please wait...
[2024-12-20 15:04:44.953] [Install] [Invoke-ADTWinGetDeploymentOperation] [Info] :: Executing [C:\Users\user\AppData\Local\Microsoft\WindowsApps\winget.exe Install --id Microsoft.VSTOR --scope Machine --source winget --log C:\WINDOWS\Logs\Software\MicrosoftVisualStudio2010ToolsforOfficeRuntime_10.0.60917_WinGet.log --accept-source-agreements --accept-package-agreements].
[2024-12-20 15:04:47.739] [Install] [Invoke-ADTWinGetDeploymentOperation] [Info] :: Found an existing package already installed. Trying to upgrade the installed package...
[2024-12-20 15:04:48.477] [Install] [Invoke-ADTWinGetDeploymentOperation] [Info] :: Found Microsoft Visual Studio 2010 Tools for Office Runtime [Microsoft.VSTOR] Version 10.0.60917.
[2024-12-20 15:04:48.482] [Install] [Invoke-ADTWinGetDeploymentOperation] [Info] :: This application is licensed to you by its owner.
[2024-12-20 15:04:48.488] [Install] [Invoke-ADTWinGetDeploymentOperation] [Info] :: Microsoft is not responsible for, nor does it grant any licenses to, third-party packages.
[2024-12-20 15:04:48.505] [Install] [Invoke-ADTWinGetDeploymentOperation] [Info] :: Downloading https://download.microsoft.com/download/5/d/2/5d24f8f8-efbb-4b63-aa33-3785e3104713/vstor_redist.exe.
[2024-12-20 15:04:55.359] [Install] [Invoke-ADTWinGetDeploymentOperation] [Info] :: Successfully verified installer hash.
[2024-12-20 15:04:56.260] [Install] [Invoke-ADTWinGetDeploymentOperation] [Info] :: Starting package install...
[2024-12-20 15:05:28.229] [Install] [Invoke-ADTWinGetDeploymentOperation] [Info] :: Successfully installed.
[2024-12-20 15:05:28.721] [Finalization] [Close-ADTSession] [Info] :: Removing deferral history...
[2024-12-20 15:05:28.728] [Finalization] [Close-ADTSession] [Success] :: [MicrosoftVisualStudio2010ToolsforOfficeRuntime_10.0.60917] install completed with exit code [0].
[2024-12-20 15:05:28.731] [Finalization] [Close-ADTSession] [Info] :: *******************************************************************************
```
Instantiates a complete PSAppDeployToolkit deployment session, and installs package with Id `Microsoft.VSTOR` onto the computer.

## Compiling the module from source

### Prerequisites

From PowerShell, run `& .\actions_bootstrap.ps1` to install the required pre-requisites. This is only needed once.

### Building

From PowerShell, run `Invoke-Build -File .\src\PSAppDeployToolkit.WinGet.build.ps1`, which will compile this module (and your own if you use this project as your basis).

### Importing

From PowerShell, run `Import-Module -Name .\src\Artifacts\Module\PSAppDeployToolkit.WinGet`, which will import the built module into your current PowerShell invocation.

## Author

Mitch Richters

