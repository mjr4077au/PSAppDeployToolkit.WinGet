#-----------------------------------------------------------------------------
#
# MARK: Repair-ADTWinGetDesktopAppInstaller
#
#-----------------------------------------------------------------------------

function Repair-ADTWinGetDesktopAppInstaller
{
    # Update WinGet to the latest version. Don't rely in 3rd party store API services for this.
    # https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget-on-windows-sandbox
    Write-ADTLogEntry -Message "Installing/updating $(($pkgName = "Microsoft.DesktopAppInstaller")) dependency, please wait..."
    [System.Uri[]]$links = Get-ADTGitHubReleaseAssetUri -Account microsoft -Repository winget-cli

    # Define installation file info.
    $packages = @(
        @{
            Name = 'latest WinGet dependencies'
            Uri = ($uri = $links | & { process { if ($_.AbsoluteUri.EndsWith('DesktopAppInstaller_Dependencies.zip')) { return $_ } } } | Select-Object -First 1)
            FilePath = "$([System.IO.Path]::GetTempPath())$($uri.Segments[-1])"
        }
        @{
            Name = 'latest WinGet msixbundle'
            Uri = ($uri = $links | & { process { if ($_.AbsoluteUri.EndsWith('Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle')) { return $_ } } } | Select-Object -First 1)
            FilePath = "$([System.IO.Path]::GetTempPath())$($uri.Segments[-1])"
        }
    )

    # Download all packages.
    foreach ($package in $packages)
    {
        Write-ADTLogEntry -Message "Downloading [$($package.Name)], please wait..."
        Invoke-ADTWebDownload -Uri $package.Uri -OutFile $package.FilePath
    }

    # Set the log file path.
    $logFile = if (Test-ADTSessionActive)
    {
        "$((Get-ADTConfig).Toolkit.LogPath)\$((Get-ADTSession).InstallName)_Dism.log"
    }
    else
    {
        "$([System.IO.Path]::GetFileNameWithoutExtension($packages[(-1)].FilePath)).log"
    }

    # Extract dependencies so they can be used with Add-AppxProvisionedPackage.
    Expand-Archive -LiteralPath $packages[0].FilePath -DestinationPath ($depsPath = [System.IO.Path]::GetFileNameWithoutExtension($packages[0].FilePath)) -Force

    # Pre-provision package in the system.
    $aappParams = @{
        Online = $true
        SkipLicense = $true
        PackagePath = $packages[-1].FilePath
        DependencyPackagePath = [System.IO.Directory]::GetFiles([System.IO.Path]::Combine($depsPath, $Script:ADT.SystemArchitecture))
        LogPath = $logFile
    }
    Write-ADTLogEntry -Message "Pre-provisioning [$pkgName] $($packages[-1].Uri.Segments[-2].Trim('/')), please wait..."
    $null = Add-AppxProvisionedPackage @aappParams

    # Register the package again if we're not running as SYSTEM.
    if (!$Script:ADT.RunningAsSystem)
    {
        Write-ADTLogEntry -Message "Registering [$pkgName] $($packages[-1].Uri.Segments[-2].Trim('/')), please wait..."
        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
    }
}
