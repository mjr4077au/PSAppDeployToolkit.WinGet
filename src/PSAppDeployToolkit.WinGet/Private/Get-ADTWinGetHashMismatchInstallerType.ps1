#-----------------------------------------------------------------------------
#
# MARK: Get-ADTWinGetHashMismatchInstallerType
#
#-----------------------------------------------------------------------------

filter Get-ADTWinGetHashMismatchInstallerType
{
    if ($_.PSObject.Properties.Name.Contains('NestedInstallerType'))
    {
        return $_.NestedInstallerType
    }
    elseif ($_.PSObject.Properties.Name.Contains('InstallerType'))
    {
        return $_.InstallerType
    }
}
