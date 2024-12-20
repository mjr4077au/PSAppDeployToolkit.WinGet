#-----------------------------------------------------------------------------
#
# MARK: Invoke-ADTWinGetRepair
#
#-----------------------------------------------------------------------------

function Invoke-ADTWinGetRepair
{
    <#
    .SYNOPSIS
        PSAppDeployToolkit - This script performs the installation or uninstallation of an application(s).

    .DESCRIPTION
        - The script is provided as a template to perform an install, uninstall, or repair of an application(s).
        - The script either performs an "Install", "Uninstall", or "Repair" deployment type.
        - The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.

        The script imports the PSAppDeployToolkit module which contains the logic and functions required to install or uninstall an application.

    .PARAMETER AllowRebootPassThru
        Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.

    .EXAMPLE
        powershell.exe -File Invoke-AppDeployToolkit.ps1 -AllowRebootPassThru

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
        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]$AllowRebootPassThru
    )


    ##================================================
    ## MARK: Variables
    ##================================================

    $adtSession = @{
        # App variables.
        AppName = "$($MyInvocation.MyCommand.Module.Name) Repair Operation"

        # Script variables.
        DeployAppScriptFriendlyName = $MyInvocation.MyCommand.Name
        DeployAppScriptVersion = $MyInvocation.MyCommand.Module.Version
        DeployAppScriptParameters = $PSBoundParameters

        # Script parameters.
        DeploymentType = 'Repair'
        DeployMode = 'Silent'
    }


    ##================================================
    ## MARK: Initialization
    ##================================================

    # Set strict error handling across entire operation.
    $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    $ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
    Set-StrictMode -Version 3
    $mainError = $null

    # Import the module and instantiate a new session.
    try
    {
        $adtSession = Open-ADTSession -SessionState $ExecutionContext.SessionState @adtSession @PSBoundParameters -PassThru
        $adtSession.InstallPhase = $adtSession.DeploymentType
    }
    catch
    {
        $PSCmdlet.ThrowTerminatingError($_)
    }


    ##================================================
    ## MARK: Invocation
    ##================================================

    try
    {
        Repair-ADTWinGetPackageManager
        Close-ADTSession
        $Global:LASTEXITCODE = $adtSession.GetExitCode()
    }
    catch
    {
        Write-ADTLogEntry -Message (Resolve-ADTErrorRecord -ErrorRecord ($mainError = $_)) -Severity 3
        Close-ADTSession -ExitCode 60001 -Force:(!(Get-PSCallStack).Command.Equals('Invoke-ADTWinGetOperation'))
        $Global:LASTEXITCODE = 60001
    }
    finally
    {
        if ($mainError -and !([System.Environment]::GetCommandLineArgs() -eq '-NonInteractive'))
        {
            $PSCmdlet.ThrowTerminatingError($mainError)
        }
    }
}
