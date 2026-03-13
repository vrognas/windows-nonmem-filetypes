# install.ps1
#
# Registers NONMEM and related file type associations on Windows 11.
# - Sets PerceivedType=text and Content Type=text/plain for all extensions
# - Adds Windows Terminal preview handler (Monaco editor with minimap)
# - Associates extensions with a text editor (Positron > VS Code > Notepad++ > Notepad)
#
# No admin rights required. Run as current user.
# Usage: irm https://raw.githubusercontent.com/vrognas/windows-nonmem-filetypes/main/install.ps1 | iex

$base           = "HKCU:\Software\Classes"
$previewHandler = "{8895b1c6-b41f-4c1c-a562-0d564250836f}"
$monacoGuid     = "{D8034CFA-F34B-41FE-AD45-62FCBB52A6DA}"  # Monaco (Windows Terminal / QuickLook)
$plainTextGuid  = "{1531d583-8375-4d3f-b5fb-d23bbd169f22}"  # Built-in Windows plain text handler

# Check if Monaco preview handler COM server is registered (requires Windows Terminal or QuickLook)
if (Test-Path "Registry::HKEY_CLASSES_ROOT\CLSID\$monacoGuid") {
    $previewGuid = $monacoGuid
    Write-Host "Monaco preview handler found — using Monaco (minimap + themed preview)"
} else {
    $previewGuid = $plainTextGuid
    Write-Warning "Monaco preview handler not found — using plain text preview as fallback"
    Write-Warning "For Monaco preview, install PowerToys first: winget install Microsoft.PowerToys"
}

# Select editor — first one found wins
$editor = @(
    "${env:LOCALAPPDATA}\Programs\Positron\Positron.exe",
    "${env:LOCALAPPDATA}\Programs\Microsoft VS Code\Code.exe",
    "${env:ProgramFiles}\Notepad++\notepad++.exe",
    "${env:WINDIR}\system32\notepad.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $editor) {
    Write-Error "No suitable editor found. Aborting."
    exit 1
}

Write-Host "Using editor: $editor"

@(
    @{ ext = ".mod";  handler = "nonmem.mod";  label = "NONMEM Model File"          },
    @{ ext = ".ctl";  handler = "nonmem.ctl";  label = "NONMEM Control Stream"      },
    @{ ext = ".lst";  handler = "nonmem.lst";  label = "NONMEM List File"           },
    @{ ext = ".clt";  handler = "nonmem.clt";  label = "NONMEM Clt file"            },
    @{ ext = ".cnv";  handler = "nonmem.cnv";  label = "NONMEM Convergence file"    },
    @{ ext = ".coi";  handler = "nonmem.coi";  label = "NONMEM Coi file"            },
    @{ ext = ".cor";  handler = "nonmem.cor";  label = "NONMEM Cor file"            },
    @{ ext = ".cov";  handler = "nonmem.cov";  label = "NONMEM Cov file"            },
    @{ ext = ".cpu";  handler = "nonmem.cpu";  label = "NONMEM Cpu file"            },
    @{ ext = ".ets";  handler = "nonmem.ets";  label = "NONMEM ETA samples file"    },
    @{ ext = ".ext";  handler = "nonmem.ext";  label = "NONMEM Ext file"            },
    @{ ext = ".grd";  handler = "nonmem.grd";  label = "NONMEM Gradient file"       },
    @{ ext = ".phi";  handler = "nonmem.phi";  label = "NONMEM Phi file"            },
    @{ ext = ".phm";  handler = "nonmem.phm";  label = "NONMEM Phi mixture file"    },
    @{ ext = ".pnm";  handler = "nonmem.pnm";  label = "Parallel NONMEM config"     },
    @{ ext = ".scm";  handler = "psn.scm";     label = "PsN SCM file"               },
    @{ ext = ".set";  handler = "nonmem.set";  label = "NONMEM Set file"            },
    @{ ext = ".shk";  handler = "nonmem.shk";  label = "NONMEM Shrinkage file"      },
    @{ ext = ".shm";  handler = "nonmem.shm";  label = "NONMEM Shrinkage map file"  },
    @{ ext = ".f90";  handler = "fortran.f90"; label = "Fortran 90 source file"     }
) | ForEach-Object {
    $ext     = $_.ext
    $handler = $_.handler
    $label   = $_.label

    # Extension → file type handler
    New-Item "$base\$ext" -Force | Out-Null
    Set-ItemProperty "$base\$ext" "(default)" $handler
    Set-ItemProperty "$base\$ext" "PerceivedType" "text"
    Set-ItemProperty "$base\$ext" "Content Type" "text/plain"

    # Preview handler on extension key (Monaco editor with minimap)
    New-Item "$base\$ext\shellex\$previewHandler" -Force | Out-Null
    Set-ItemProperty "$base\$ext\shellex\$previewHandler" "(default)" $previewGuid

    # File type handler
    New-Item "$base\$handler" -Force | Out-Null
    Set-ItemProperty "$base\$handler" "(default)" $label

    # Open with editor
    New-Item "$base\$handler\DefaultIcon" -Force | Out-Null
    Set-ItemProperty "$base\$handler\DefaultIcon" "(default)" "`"$editor`",0"
    New-Item "$base\$handler\shell\open\command" -Force | Out-Null
    Set-ItemProperty "$base\$handler\shell\open\command" "(default)" "`"$editor`" `"%1`""

    Write-Host "Registered $ext"
}

Write-Host "Restarting File Explorer..."
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Process explorer
Write-Host "Done."
