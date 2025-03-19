#-----------------------------------------------------------------------------
#
# MARK: Invoke-ADTWinGetOperation
#
#-----------------------------------------------------------------------------

function Invoke-ADTWinGetOperation
{
    <#
    .SYNOPSIS
        This function performs the end-to-end installation or uninstallation of a WinGet application using PSAppDeployToolkit.

    .DESCRIPTION
        This function performs the end-to-end installation or uninstallation of a WinGet application using PSAppDeployToolkit.

        - The function is provided as a basic implementation to perform an install, uninstall, or repair of a WinGet application.
        - The function either performs an "Install", "Uninstall", or "Repair" deployment type.
        - The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.

        This function is not intended to be called from an existing `Invoke-AppDeployToolkit.ps1` script. For usage within your own script, please use the individual WinGet functions, such as `Install-ADTWinGetPackage`, etc.

    .PARAMETER Id
        The WinGet package identifier for the deployment.

    .PARAMETER DeploymentType
        The type of deployment to perform.

    .PARAMETER DeployMode
        Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode.

    .PARAMETER AllowRebootPassThru
        Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.

    .EXAMPLE
        powershell.exe -File Invoke-AppDeployToolkit.ps1 -Id Microsoft.VSTOR

    .EXAMPLE
        powershell.exe -File Invoke-AppDeployToolkit.ps1 -Id Microsoft.VSTOR -DeployMode Silent

    .EXAMPLE
        powershell.exe -File Invoke-AppDeployToolkit.ps1 -Id Microsoft.VSTOR -AllowRebootPassThru

    .EXAMPLE
        powershell.exe -File Invoke-AppDeployToolkit.ps1 -Id Microsoft.VSTOR -DeploymentType Uninstall

    .EXAMPLE
        Invoke-AppDeployToolkit.exe -Id Microsoft.VSTOR -DeploymentType Install -DeployMode Silent

    .INPUTS
        None. You cannot pipe objects to this function.

    .OUTPUTS
        None. This function does not generate any output.

    .LINK
        https://github.com/mjr4077au/PSAppDeployToolkit.WinGet
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]$Id,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Install', 'Uninstall', 'Repair')]
        [PSDefaultValue(Help = 'Install', Value = 'Install')]
        [System.String]$DeploymentType,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
        [PSDefaultValue(Help = 'Interactive', Value = 'Interactive')]
        [System.String]$DeployMode,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$AllowRebootPassThru
    )

    # Set strict error handling across entire operation.
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    $ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
    Set-StrictMode -Version 3
    $mainError = $null

    # Perform initial setup and establish new DeploymentSession.
    try
    {
        try
        {
            Assert-ADTWinGetPackageManager
        }
        catch
        {
            Invoke-ADTWinGetRepair
            Assert-ADTWinGetPackageManager
        }
        $adtSession = @{
            AppName = (($wgPackage = Find-ADTWinGetPackage -Id $Id -MatchOption Equals).Name -replace ([regex]::Escape($wgPackage.Version))).Trim()
            AppVersion = $wgPackage.Version
            DeployAppScriptFriendlyName = $MyInvocation.MyCommand.Name
            DeployAppScriptVersion = $MyInvocation.MyCommand.Module.Version
            DeployAppScriptParameters = $PSBoundParameters
        }
        $adtSession = Open-ADTSession -SessionState $ExecutionContext.SessionState @adtSession @PSBoundParameters -PassThru
    }
    catch
    {
        $PSCmdlet.ThrowTerminatingError($_)
    }

    # Main invocation once session is open.
    try
    {
        # Show Welcome Message.
        $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"
        $saiwParams = if ($adtSession.DeploymentType -eq 'Install')
        {
            @{ AllowDefer = $true; DeferTimes = 3; CheckDiskSpace = $true; PersistPrompt = $true; NoMinimizeWindows = $true }
        }
        else
        {
            @{ CloseProcessesCountdown = 60; NoMinimizeWindows = $true }
        }
        Show-ADTInstallationWelcome @saiwParams
        Show-ADTInstallationProgress

        # Perform our WinGet action and close out
        $adtSession.InstallPhase = $adtSession.DeploymentType
        $null = & "$($adtSession.DeploymentType)-ADTWinGetPackage" -Id $Id
        Close-ADTSession
    }
    catch
    {
        Write-ADTLogEntry -Message ($mainErrorMessage = Resolve-ADTErrorRecord -ErrorRecord ($mainError = $_)) -Severity 3
        Show-ADTDialogBox -Text $mainErrorMessage -Icon Stop | Out-Null
        Close-ADTSession -ExitCode 60001
    }
    finally
    {
        if ($mainError -and !([System.Environment]::GetCommandLineArgs() -eq '-NonInteractive'))
        {
            $PSCmdlet.ThrowTerminatingError($mainError)
        }
    }
}
