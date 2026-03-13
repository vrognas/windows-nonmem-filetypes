# uninstall.ps1
#
# Removes NONMEM file type associations registered by install.ps1.
# Only removes keys written by that script under HKCU — does not touch system-level registry.
#
# No admin rights required. Run as current user.
# Usage: irm https://raw.githubusercontent.com/vrognas/windows-nonmem-filetypes/main/uninstall.ps1 | iex

$base = "HKCU:\Software\Classes"

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

foreach ($ext in $extensions) {
    $path = "$base\$ext"
    if (Test-Path $path) {
        Remove-Item $path -Recurse -Force
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

Stop-Process -Name explorer -Force
Start-Process explorer
Write-Host "Done."
