# Test Plan: AllVersions Parameter for Uninstall-ADTWinGetPackage

## Overview

This document outlines the validation steps for the new `AllVersions` switch parameter added to `Uninstall-ADTWinGetPackage`, which maps to WinGet's `--all-versions` flag.

## Prerequisites

- Windows 10/11 with WinGet installed
- PowerShell 5.1 or later
- Administrator privileges (for machine-scope installations)
- PSAppDeployToolkit.WinGet module loaded

## Test Setup

### Step 1: Import the Module

```powershell
cd "N:\Tools\PSAppDeployToolkit.WinGet\src\PSAppDeployToolkit.WinGet"
Import-Module .\PSAppDeployToolkit.WinGet.psd1 -Force
```

### Step 2: Install Multiple Versions of 1Password

Install an older version first:

```powershell
winget.exe install --id "AgileBits.1Password" --exact --source winget --accept-source-agreements --disable-interactivity --scope machine --version "8.11.8.40" --silent --accept-package-agreements --force --architecture x64
```

Install the latest version (MSIX bundle from 1Password website):

```powershell
# Download the latest MSIX bundle
Invoke-WebRequest -Uri "https://c.1password.com/dist/1P/win8/1PasswordSetup-latest.msixbundle" -OutFile "$env:TEMP\1PasswordSetup-latest.msixbundle"

# Install the MSIX bundle
Add-AppxPackage -Path "$env:TEMP\1PasswordSetup-latest.msixbundle"
```

### Step 3: Verify Multiple Versions Are Installed

```powershell
winget list AgileBits.1Password
```

Expected output should show multiple versions installed.

## Test Cases

### Test Case 1: Parameter Visibility

**Objective**: Verify the `AllVersions` parameter is recognized by the cmdlet.

```powershell
Get-Command Uninstall-ADTWinGetPackage -Syntax
```

**Expected**: Output includes `[-AllVersions]` parameter.

```powershell
Get-Help Uninstall-ADTWinGetPackage -Parameter AllVersions
```

**Expected**: Returns parameter documentation describing its purpose.

### Test Case 2: Uninstall All Versions

**Objective**: Verify all installed versions are uninstalled with a single command.

```powershell
Uninstall-ADTWinGetPackage -Id AgileBits.1Password -AllVersions -Scope Any -PassThru
```

**Expected**:

- All versions of 1Password are uninstalled
- Command completes successfully (Status: Ok)

### Test Case 3: Verify Uninstallation

**Objective**: Confirm no versions remain after uninstall.

```powershell
winget list AgileBits.1Password
```

**Expected**: No packages found or empty result.

### Test Case 4: Uninstall Without AllVersions (Control Test)

**Objective**: Verify default behavior (single version uninstall) still works.

Re-install multiple versions (repeat Step 2), then:

```powershell
Uninstall-ADTWinGetPackage -Id AgileBits.1Password -Scope Any -PassThru
```

**Expected**: Only one version is uninstalled, other version(s) remain.

## Cleanup

After testing, ensure 1Password is either:

- Fully uninstalled, or
- Reinstalled to user's preferred version

```powershell
# Full cleanup
winget uninstall --id AgileBits.1Password --all-versions

# Or reinstall latest
winget install --id AgileBits.1Password --source winget
```

## Results Summary

| Test Case | Description | Pass/Fail | Notes |
|-----------|-------------|-----------|-------|
| 1 | Parameter Visibility | | |
| 2 | Uninstall All Versions | | |
| 3 | Verify Uninstallation | | |
| 4 | Control Test (Single Version) | | |

## Notes

- The `-Scope Any` parameter may be required depending on how the package was installed (user vs machine scope)
- The module defaults to machine scope for safety; use `-Scope User` or `-Scope Any` if packages are installed per-user
