
if ($PSEdition -eq 'Desktop') {
    $loadPath = 'net4.8'
} else {
    $loadPath = 'netstandard2.1'
}

try {
    Add-Type -Path $PSScriptRoot/$loadPath/YamlDotNet.dll `
        -ErrorAction Ignore | Out-Null
} catch {
    Write-Verbose $_
}

try {
    Import-Module $PSScriptRoot/$loadPath/psyml.dll `
        -ErrorAction Ignore | Out-Null
} catch {
    Write-Verbose $_
}
