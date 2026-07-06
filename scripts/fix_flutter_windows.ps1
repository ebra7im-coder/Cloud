# fix_flutter_windows.ps1
# Patches the Flutter tool snapshot to fix Windows build on VS2022
# Flutter hardcodes CMake generator "Visual Studio 16 2019" in its
# compiled snapshot. We find and binary-patch the string.

param(
    [string]$FlutterRoot = $env:FLUTTER_ROOT
)

if (-not $FlutterRoot) {
    Write-Error "FLUTTER_ROOT not set"
    exit 1
}

Write-Host "Flutter root: $FlutterRoot"

# The snapshot file that contains the hardcoded generator string
$snapshotPaths = @(
    "$FlutterRoot\bin\cache\flutter_tools.snapshot",
    "$FlutterRoot\packages\flutter_tools\bin\flutter_tools.dart"
)

$oldStr = "Visual Studio 16 2019"
$newStr = "Visual Studio 17 2022"

$patched = $false

foreach ($path in $snapshotPaths) {
    if (-not (Test-Path $path)) { continue }
    
    $ext = [System.IO.Path]::GetExtension($path)
    
    if ($ext -eq ".dart") {
        # Text file — simple replacement
        $content = Get-Content $path -Raw -Encoding UTF8
        if ($content -match [regex]::Escape($oldStr)) {
            $content = $content -replace [regex]::Escape($oldStr), $newStr
            Set-Content $path $content -Encoding UTF8 -NoNewline
            Write-Host "Patched dart file: $path"
            $patched = $true
        }
    } elseif ($ext -eq ".snapshot") {
        # Binary snapshot — byte-level patch
        $bytes = [System.IO.File]::ReadAllBytes($path)
        $oldBytes = [System.Text.Encoding]::UTF8.GetBytes($oldStr)
        $newBytes = [System.Text.Encoding]::UTF8.GetBytes($newStr)
        
        # Both strings are same length (21 chars each), safe to replace in-place
        if ($oldBytes.Length -ne $newBytes.Length) {
            Write-Warning "String lengths differ — skipping binary patch"
            continue
        }
        
        $found = $false
        for ($i = 0; $i -le $bytes.Length - $oldBytes.Length; $i++) {
            $match = $true
            for ($j = 0; $j -lt $oldBytes.Length; $j++) {
                if ($bytes[$i+$j] -ne $oldBytes[$j]) { $match = $false; break }
            }
            if ($match) {
                for ($j = 0; $j -lt $newBytes.Length; $j++) {
                    $bytes[$i+$j] = $newBytes[$j]
                }
                Write-Host "Patched at offset $i in snapshot"
                $found = $true
                break
            }
        }
        
        if ($found) {
            [System.IO.File]::WriteAllBytes($path, $bytes)
            Write-Host "Patched snapshot: $path"
            $patched = $true
        } else {
            Write-Host "String not found in snapshot (may already be patched or different Flutter version)"
        }
    }
}

if (-not $patched) {
    Write-Warning "Nothing was patched. Trying alternative: check build_windows.dart"
    
    # Try patching the dart source if available
    $dartFiles = Get-ChildItem -Recurse "$FlutterRoot\packages\flutter_tools\lib" `
        -Filter "*.dart" -ErrorAction SilentlyContinue |
        Where-Object { (Get-Content $_.FullName -Raw) -match [regex]::Escape($oldStr) }
    
    foreach ($f in $dartFiles) {
        $c = Get-Content $f.FullName -Raw -Encoding UTF8
        $c = $c -replace [regex]::Escape($oldStr), $newStr
        Set-Content $f.FullName $c -Encoding UTF8 -NoNewline
        Write-Host "Patched source: $($f.FullName)"
        $patched = $true
    }
}

if ($patched) {
    Write-Host "SUCCESS: Flutter patched to use VS2022"
    exit 0
} else {
    Write-Host "WARNING: Could not patch Flutter. Build may fail."
    exit 0  # Don't fail the CI step — let flutter build try anyway
}
