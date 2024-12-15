#-----------------------------------------------------------------------------
#
# MARK: Get-ADTWinGetHashMismatchDownload
#
#-----------------------------------------------------------------------------

function Get-ADTWinGetHashMismatchDownload
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [pscustomobject]$Installer
    )

    Write-ADTLogEntry -Message "Downloading [$($Installer.InstallerUrl)], please wait..."
    try
    {
        # Download WinGet app and store path to binary.
        $wgFilePath = "$([System.IO.Directory]::CreateDirectory("$([System.IO.Path]::GetTempPath())$(Get-Random)").FullName)\$(Get-ADTUriFileName -Uri $Installer.InstallerUrl)"
        Invoke-ADTWebDownload -Uri $Installer.InstallerUrl -OutFile $wgFilePath

        # If downloaded file is a zip, we need to expand it and modify our file path before returning.
        if ($wgFilePath -match 'zip$')
        {
            Write-ADTLogEntry -Message "Downloaded installer is a zip file, expanding its contents."
            Expand-Archive -LiteralPath $wgFilePath -DestinationPath ([System.IO.Path]::GetTempPath()) -Force
            $wgFilePath = "$([System.IO.Path]::GetTempPath())$($Installer.NestedInstallerFiles.RelativeFilePath)"
        }
        return $wgFilePath
    }
    catch
    {
        $naerParams = @{
            Exception = [System.InvalidOperationException]::new("Failed to download [$($Installer.InstallerUrl)].", $_.Exception)
            Category = [System.Management.Automation.ErrorCategory]::InvalidOperation
            ErrorId = 'WinGetInstallerDownloadFailure'
            RecommendedAction = "Please verify the installer's URI is valid, then try again."
        }
        $PSCmdlet.ThrowTerminatingError((New-ADTErrorRecord @naerParams))
    }
}
