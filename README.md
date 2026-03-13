# windows-nonmem-filetypes

Registers NONMEM and related file type associations on Windows 11 so that:

- Files open in a text editor (Positron, VS Code, Notepad++, or Notepad — whichever is found first)
- Files are recognized as plain text by Windows (search indexing, shell operations)
- Files get a Monaco editor preview with minimap in File Explorer's preview pane (`Alt+P`) — note that syntax highlighting may not apply since Monaco does not recognize these extensions

No admin rights required.

![Demo](win-nm-demo.gif)

## How to run

1. Press `Win + R`, type `powershell`, press Enter
2. Paste the following and press Enter:

```powershell
irm https://raw.githubusercontent.com/vrognas/windows-nonmem-filetypes/main/install.ps1 | iex
```

3. File Explorer will restart automatically when done

## How to uninstall

To undo all changes, run the uninstall script the same way:

1. Press `Win + R`, type `powershell`, press Enter
2. Paste the following and press Enter:

```powershell
irm https://raw.githubusercontent.com/vrognas/windows-nonmem-filetypes/main/uninstall.ps1 | iex
```

## Troubleshooting

- **Script is blocked** — if running the `.ps1` file directly is blocked by PowerShell execution policy, use the `irm ... | iex` method instead
- **Preview pane not working** — make sure Windows Terminal is installed (`winget install Microsoft.WindowsTerminal`) and try pressing `Alt+P` in File Explorer
- **Script won't run at all** — some IT security policies (AppLocker, WDAC) block unsigned scripts entirely. In that case, contact your IT department

## Safety

All changes are written only to `HKCU\Software\Classes` — the current user's registry hive. This means:

- No system-wide changes are made
- Other users on the same machine are not affected
- The script is safe to run multiple times (it overwrites its own previous entries, nothing else)
- The uninstall script removes only keys written by the install script

## Covered extensions

| Extension | Description |
| :-------- | :---------- |
| `.mod`    | NONMEM model file |
| `.ctl`    | NONMEM control stream |
| `.lst`    | NONMEM list file |
| `.clt`    | NONMEM clt file |
| `.cnv`    | NONMEM convergence file |
| `.coi`    | NONMEM coi file |
| `.cor`    | NONMEM cor file |
| `.cov`    | NONMEM covariance file |
| `.cpu`    | NONMEM cpu file |
| `.ets`    | NONMEM ETA samples file |
| `.ext`    | NONMEM ext file |
| `.grd`    | NONMEM gradient file |
| `.phi`    | NONMEM phi file |
| `.phm`    | NONMEM phi mixture file |
| `.pnm`    | Parallel NONMEM config |
| `.scm`    | PsN SCM file |
| `.set`    | NONMEM set file |
| `.shk`    | NONMEM shrinkage file |
| `.shm`    | NONMEM shrinkage map file |
| `.f90`    | Fortran 90 source file |

## Editor priority

The script automatically picks the first available editor in this order:

1. Positron
2. VS Code
3. Notepad++
4. Notepad (always available on Windows 11)
