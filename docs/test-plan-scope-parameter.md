# Test Plan: Validate -Scope Parameter for Get-ADTWinGetPackage

## Prerequisites

- 1Password (`AgileBits.1Password`) must be installed in **machine scope** on the test system
- PSAppDeployToolkit v4.0.6+ must be installed
- WinGet CLI must be available

---

## Step 1: Import the Modified Module for Testing

### Option A: Import Directly from Source (Recommended for Development)

Open an **elevated PowerShell** session and run:

```powershell
# Remove any previously loaded version of the module
Remove-Module PSAppDeployToolkit.WinGet -Force -ErrorAction SilentlyContinue

# Import PSAppDeployToolkit first (required dependency)
Import-Module PSAppDeployToolkit -MinimumVersion 4.1.7

# Import the modified module directly from source
Import-Module "N:\Tools\PSAppDeployToolkit.WinGet\src\PSAppDeployToolkit.WinGet\PSAppDeployToolkit.WinGet.psd1" -Force
```

### Option B: Verify Import and New Parameter

After importing, verify the `-Scope` parameter is available:

```powershell
# Check that the Scope parameter exists
(Get-Command Get-ADTWinGetPackage).Parameters['Scope']

# View parameter details
Get-Help Get-ADTWinGetPackage -Parameter Scope
```

**Expected Output:** Shows the `Scope` parameter with valid values: `Any`, `User`, `System`, `UserOrUnknown`, `SystemOrUnknown`

### Option C: Quick Verification Script

```powershell
# One-liner to verify everything is working
Remove-Module PSAppDeployToolkit.WinGet -Force -ErrorAction SilentlyContinue
Import-Module PSAppDeployToolkit -MinimumVersion 4.0.6
Import-Module "N:\Tools\PSAppDeployToolkit.WinGet\src\PSAppDeployToolkit.WinGet\PSAppDeployToolkit.WinGet.psd1" -Force
(Get-Command Get-ADTWinGetPackage).Parameters.Keys -contains 'Scope'  # Should return True
```

---

## Test Cases

### Test 1: Verify Package Listed with `-Scope System`

Run in an elevated PowerShell session or SYSTEM context:

```powershell
Get-ADTWinGetPackage -Id "AgileBits.1Password" -Scope System
```

**Expected Result:** Returns the 1Password package with its Name, Id, Version, and Source properties.

### Test 2: Verify Package NOT Listed with `-Scope User` (when installed machine-wide)

```powershell
Get-ADTWinGetPackage -Id "AgileBits.1Password" -Scope User
```

**Expected Result:** Returns nothing (or different results if user also has a per-user installation).

### Test 3: Verify `-Scope Any` Returns All Installations

```powershell
Get-ADTWinGetPackage -Id "AgileBits.1Password" -Scope Any
```

**Expected Result:** Returns all installations regardless of scope.

### Test 4: List All Machine-Scoped Packages

```powershell
Get-ADTWinGetPackage -Scope System
```

**Expected Result:** Returns all packages installed in machine scope.

### Test 5: Validate WinGet CLI Argument Passthrough

Enable verbose/debug logging and verify the command generates:

```
winget list --id AgileBits.1Password --scope machine --exact --accept-source-agreements
```

### Test 6: Test in SYSTEM Context (Critical Use Case)

Use `PsExec -s` or a SYSTEM-level deployment tool to run:

```powershell
Get-ADTWinGetPackage -Id "AgileBits.1Password" -Scope System
```

**Expected Result:** Successfully lists the package when running as SYSTEM.

### Test 7: Combine with Other Parameters

```powershell
Get-ADTWinGetPackage -Name "1Password" -Scope System -MatchOption EqualsCaseInsensitive
```

**Expected Result:** Filters work correctly in combination with scope.

## Validation Checklist

- [ ] `-Scope System` returns machine-scoped packages
- [ ] `-Scope User` returns user-scoped packages only
- [ ] `-Scope Any` returns all packages
- [ ] Works correctly in SYSTEM context
- [ ] No errors when scope parameter is omitted (backward compatibility)
- [ ] Documentation matches implementation
