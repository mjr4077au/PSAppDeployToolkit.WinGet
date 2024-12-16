#-----------------------------------------------------------------------------
#
# MARK: Invoke-ADTWinGetOperation
#
#-----------------------------------------------------------------------------

function Invoke-ADTWinGetOperation
{
    <#
    .SYNOPSIS
        PSAppDeployToolkit - This script performs the installation or uninstallation of an application(s).

    .DESCRIPTION
        - The script is provided as a template to perform an install, uninstall, or repair of an application(s).
        - The script either performs an "Install", "Uninstall", or "Repair" deployment type.
        - The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.

        The script imports the PSAppDeployToolkit module which contains the logic and functions required to install or uninstall an application.

    .PARAMETER Id
        The WinGet package identifier for the deployment.

    .PARAMETER DeploymentType
        The type of deployment to perform. Default is: Install.

    .PARAMETER DeployMode
        Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.

    .PARAMETER AllowRebootPassThru
        Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.

    .PARAMETER TerminalServerMode
        Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Desktop Session Hosts/Citrix servers.

    .PARAMETER DisableLogging
        Disables logging to file for the script. Default is: $false.

    .EXAMPLE
        powershell.exe -File Invoke-AppDeployToolkit.ps1 -DeployMode Silent

    .EXAMPLE
        powershell.exe -File Invoke-AppDeployToolkit.ps1 -AllowRebootPassThru

    .EXAMPLE
        powershell.exe -File Invoke-AppDeployToolkit.ps1 -DeploymentType Uninstall

    .EXAMPLE
        Invoke-AppDeployToolkit.exe -DeploymentType "Install" -DeployMode "Silent"

    .INPUTS
        None. You cannot pipe objects to this script.

    .OUTPUTS
        None. This script does not generate any output.

    .LINK
        https://psappdeploytoolkit.com
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Id,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Install', 'Uninstall', 'Repair')]
        [System.String]$DeploymentType = 'Install',

        [Parameter(Mandatory = $false)]
        [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
        [System.String]$DeployMode = 'Interactive',

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$AllowRebootPassThru,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$TerminalServerMode,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$DisableLogging
    )


    ##================================================
    ## MARK: Pre-initialization
    ##================================================

    # Set strict error handling across entire operation.
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    $ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
    Set-StrictMode -Version 1

    # Confirm WinGet is healthy, then try to find the specified package.
    try
    {
        Assert-ADTWinGetPackageManager
        $wgPackage = Find-ADTWinGetPackage -Id $Id
    }
    catch
    {
        $Host.UI.WriteErrorLine((Out-String -InputObject $_ -Width ([System.Int32]::MaxValue)))
        exit 60008
    }


    ##================================================
    ## MARK: Variables
    ##================================================

    $adtSession = @{
        # App variables.
        AppName = ($wgPackage.Name -replace ([regex]::Escape($wgPackage.Version))).Trim()
        AppVersion = $wgPackage.Version

        # Script variables.
        DeployAppScriptFriendlyName = $MyInvocation.MyCommand.Name
        DeployAppScriptParameters = $PSBoundParameters

        # Script parameters.
        DeploymentType = $DeploymentType
        DeployMode = $DeployMode
        AllowRebootPassThru = $AllowRebootPassThru
        TerminalServerMode = $TerminalServerMode
        DisableLogging = $DisableLogging
    }

    function Install-ADTDeployment
    {
        ##================================================
        ## MARK: Pre-Install
        ##================================================
        $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

        ## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt.
        Show-ADTInstallationWelcome -AllowDefer -DeferTimes 3 -CheckDiskSpace -PersistPrompt -NoMinimizeWindows

        ## Show Progress Message (with the default message).
        Show-ADTInstallationProgress


        ##================================================
        ## MARK: Install
        ##================================================
        $adtSession.InstallPhase = $adtSession.DeploymentType

        ## Install our WinGet package.
        $null = Install-ADTWinGetPackage -Id $Id


        ##================================================
        ## MARK: Post-Install
        ##================================================
        $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"
    }

    function Uninstall-ADTDeployment
    {
        ##================================================
        ## MARK: Pre-Uninstall
        ##================================================
        $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

        ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing.
        Show-ADTInstallationWelcome -CloseProcessesCountdown 60 -NoMinimizeWindows

        ## Show Progress Message (with the default message).
        Show-ADTInstallationProgress


        ##================================================
        ## MARK: Uninstall
        ##================================================
        $adtSession.InstallPhase = $adtSession.DeploymentType

        ## Uninstall our WinGet package.
        $null = Uninstall-ADTWinGetPackage -Id $Id


        ##================================================
        ## MARK: Post-Uninstallation
        ##================================================
        $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"
    }

    function Repair-ADTDeployment
    {
        ##================================================
        ## MARK: Pre-Repair
        ##================================================
        $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

        ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing.
        Show-ADTInstallationWelcome -CloseProcessesCountdown 60 -NoMinimizeWindows

        ## Show Progress Message (with the default message).
        Show-ADTInstallationProgress


        ##================================================
        ## MARK: Repair
        ##================================================
        $adtSession.InstallPhase = $adtSession.DeploymentType

        ## Repair our WinGet package.
        $null = Repair-ADTWinGetPackage -Id $Id


        ##================================================
        ## MARK: Post-Repair
        ##================================================
        $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"
    }


    ##================================================
    ## MARK: Initialization
    ##================================================

    # Import the module and instantiate a new session.
    try
    {
        $adtSession = Open-ADTSession -SessionState $ExecutionContext.SessionState @adtSession -PassThru
    }
    catch
    {
        $Host.UI.WriteErrorLine((Out-String -InputObject $_ -Width ([System.Int32]::MaxValue)))
        exit 60008
    }


    ##================================================
    ## MARK: Invocation
    ##================================================

    try
    {
        & "$($adtSession.DeploymentType)-ADTDeployment"
        Close-ADTSession
    }
    catch
    {
        Write-ADTLogEntry -Message ($mainErrorMessage = Resolve-ADTErrorRecord -ErrorRecord $_) -Severity 3
        Show-ADTDialogBox -Text $mainErrorMessage -Icon Stop | Out-Null
        Close-ADTSession -ExitCode 60001
    }
    finally
    {
        Remove-Module -Name PSAppDeployToolkit* -Force
    }
}
