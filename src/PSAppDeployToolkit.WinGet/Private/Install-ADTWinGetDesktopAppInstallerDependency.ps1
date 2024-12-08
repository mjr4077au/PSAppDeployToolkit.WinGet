#-----------------------------------------------------------------------------
#
# MARK: Install-ADTWinGetDesktopAppInstallerDependency
#
#-----------------------------------------------------------------------------

function Install-ADTWinGetDesktopAppInstallerDependency
{
    # Update WinGet to the latest version. Don't rely in 3rd party store API services for this.
    # https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget-on-windows-sandbox
    Write-ADTLogEntry -Message "Installing/updating $(($pkgName = "Microsoft.DesktopAppInstaller")) dependency, please wait..."

    # Define installation file info.
    $packages = @(
        @{
            Name = 'C++ Desktop Bridge Runtime dependency'
            Uri = ($uri = [System.Uri]'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx')
            FilePath = "$([System.IO.Path]::GetTempPath())$($uri.Segments[-1])"
        }
        @{
            Name = 'Windows UI Library dependency'
            Uri = ($uri = [System.Uri]'https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx')
            FilePath = "$([System.IO.Path]::GetTempPath())$($uri.Segments[-1])"
        }
        @{
            Name = 'latest WinGet msixbundle'
            Uri = ($uri = Get-ADTRedirectedUri -Uri 'https://aka.ms/getwinget')
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

    # Pre-provision package in the system.
    $aappParams = @{
        Online = $true
        SkipLicense = $true
        PackagePath = $packages[(-1)].FilePath
        DependencyPackagePath = $packages[(0)..($packages.Count - 2)].FilePath
        LogPath = $logFile
    }
    Write-ADTLogEntry -Message "Pre-provisioning [$pkgName] $($packages[-1].Uri.Segments[-2].Trim('/')), please wait..."
    $null = Add-AppxProvisionedPackage @aappParams
}
