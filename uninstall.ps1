# uninstall.ps1
#
# Removes NONMEM file type associations registered by install.ps1.
# Only removes keys written by that script under HKCU — does not touch system-level registry.
#
# No admin rights required. Run as current user.
# Usage: irm https://raw.githubusercontent.com/vrognas/windows-nonmem-filetypes/main/uninstall.ps1 | iex

$base = "HKCU:\Software\Classes"
$previewHandler = "{8895b1c6-b41f-4c1c-a562-0d564250836f}"

$extensions = @(
    ".mod", ".ctl", ".lst", ".clt", ".cnv", ".coi", ".cor", ".cov", ".cpu",
    ".ets", ".ext", ".grd", ".phi", ".phm", ".pnm", ".scm", ".set", ".shk",
    ".shm", ".f90"
)

$handlers = @(
    "nonmem.mod", "nonmem.ctl", "nonmem.lst", "nonmem.clt", "nonmem.cnv",
    "nonmem.coi", "nonmem.cor", "nonmem.cov", "nonmem.cpu", "nonmem.ets",
    "nonmem.ext", "nonmem.grd", "nonmem.phi", "nonmem.phm", "nonmem.pnm",
    "psn.scm",    "nonmem.set", "nonmem.shk", "nonmem.shm", "fortran.f90"
)

$confirm = Read-Host "This will remove NONMEM file type associations. Continue? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Cancelled."
    exit 0
}

foreach ($ext in $extensions) {
    $extPath = "$base\$ext"
    if (Test-Path $extPath) {
        # Only remove the specific values and shellex key we added — leave the rest intact
        Remove-ItemProperty "$extPath" "(default)"      -ErrorAction SilentlyContinue
        Remove-ItemProperty "$extPath" "PerceivedType"  -ErrorAction SilentlyContinue
        Remove-ItemProperty "$extPath" "Content Type"   -ErrorAction SilentlyContinue
        $shellexPath = "$extPath\shellex\$previewHandler"
        if (Test-Path $shellexPath) {
            Remove-Item $shellexPath -Recurse -Force
        }
        Write-Host "Removed $ext"
    }
}

foreach ($handler in $handlers) {
    $path = "$base\$handler"
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force
        Write-Host "Removed handler $handler"
    }
}

Write-Host "Restarting File Explorer..."
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Process explorer
Write-Host "Done."
