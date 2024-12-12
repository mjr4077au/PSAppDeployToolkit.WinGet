#-----------------------------------------------------------------------------
#
# MARK: Repair-ADTWinGetVisualStudioRuntime
#
#-----------------------------------------------------------------------------

function Repair-ADTWinGetVisualStudioRuntime
{
    # Set required variables for install operation.
    $pkgArch = @('x86', 'x64')[[System.Environment]::Is64BitProcess]
    $pkgName = "Microsoft Visual C++ 2015-2022 Redistributable ($pkgArch)"
    $uriPath = "https://aka.ms/vs/17/release/vc_redist.$pkgArch.exe"
    Write-ADTLogEntry -Message "Preparing $pkgName dependency, please wait..."

    # Get the active ADT session object for log naming, if available.
    $adtSession = if (Test-ADTSessionActive)
    {
        Get-ADTSession
    }

    # Set up the filename for the download.
    $fileName = Get-Random

    # Set the log filename.
    $logFile = if ($adtSession)
    {
        "$((Get-ADTConfig).Toolkit.LogPath)\$($adtSession.InstallName)_MSVCRT.log"
    }
    else
    {
        "$([System.IO.Path]::GetTempPath())$fileName.log"
    }

    # Define arguments for installation.
    $spParams = @{
        FilePath = "$([System.IO.Path]::GetTempPath())$fileName.exe"
        ArgumentList = "/install", "/quiet", "/norestart", "/log `"$logFile`""
    }

    # Download and extract installer.
    Write-ADTLogEntry -Message "Downloading [$pkgName], please wait..."
    Invoke-ADTWebDownload -Uri $uriPath -OutFile $spParams.FilePath

    # Invoke installer and throw if we failed.
    Write-ADTLogEntry -Message "Installing [$pkgName], please wait..."
    if (($exitCode = (Start-Process @spParams -Wait -PassThru).ExitCode))
    {
        if ($adtSession)
        {
            $adtSession.SetExitCode($exitCode)
        }
        $naerParams = @{
            Exception = [System.Runtime.InteropServices.ExternalException]::new("The installation of [$pkgName] failed with exit code [$exitCode].", $exitCode)
            Category = [System.Management.Automation.ErrorCategory]::InvalidResult
            ErrorId = 'VcRedistInstallFailure'
            TargetObject = $exitCode
            RecommendedAction = "Please review the exit code, then try again."
        }
        throw (New-ADTErrorRecord @naerParams)
    }
}
