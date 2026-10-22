<#
.SYNOPSIS
Adds or removes GSMLG Editor from this user's Open With choices.
.EXAMPLE
.\register-editor.ps1 -ExecutablePath 'C:\Apps\GSMLG\gsmlg.exe'
.EXAMPLE
.\register-editor.ps1 -Unregister
#>
[CmdletBinding()]
param(
    [string]$ExecutablePath = (Join-Path $PSScriptRoot 'gsmlg.exe'),
    [switch]$Unregister
)

$ErrorActionPreference = 'Stop'
$progId = 'GSMLG.Editor'
$markerName = 'GSMLGEditorRegistration'
$markerValue = 'gsmlg-editor-v1'
$classesPath = 'Software\Classes'
$extensions = @(
    '.txt', '.text', '.md', '.markdown', '.log', '.csv', '.tsv',
    '.json', '.jsonl', '.yaml', '.yml', '.toml', '.xml', '.ini', '.conf',
    '.dart', '.js', '.jsx', '.ts', '.tsx', '.html', '.htm', '.css', '.scss',
    '.py', '.sh', '.bash', '.zsh', '.ps1', '.sql', '.c', '.h', '.cpp', '.hpp',
    '.rs', '.go', '.java', '.kt', '.swift', '.ex', '.exs', '.erl', '.rb', '.php'
)

if (-not $Unregister) {
    $ExecutablePath = (Resolve-Path -LiteralPath $ExecutablePath).ProviderPath
    if (-not (Test-Path -LiteralPath $ExecutablePath -PathType Leaf) -or
        [IO.Path]::GetExtension($ExecutablePath) -ine '.exe') {
        throw 'ExecutablePath must point to the built GSMLG executable.'
    }
}

$classes = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($classesPath)
try {
    $existing = $classes.OpenSubKey($progId)
    try {
        if ($null -ne $existing -and $existing.GetValue($markerName) -ne $markerValue) {
            throw "Refusing to change an unowned $progId registration."
        }
    } finally {
        if ($null -ne $existing) { $existing.Dispose() }
    }

    if ($Unregister) {
        foreach ($extension in $extensions) {
            $key = $classes.OpenSubKey("$extension\OpenWithProgids", $true)
            if ($null -ne $key) {
                try { $key.DeleteValue($progId, $false) } finally { $key.Dispose() }
            }
        }
        $classes.DeleteSubKeyTree($progId, $false)
    } else {
        $key = $classes.CreateSubKey($progId)
        try {
            $key.SetValue('', 'GSMLG Editor')
            $key.SetValue($markerName, $markerValue)
            $icon = $key.CreateSubKey('DefaultIcon')
            try { $icon.SetValue('', ('"{0}",0' -f $ExecutablePath)) } finally { $icon.Dispose() }
            $application = $key.CreateSubKey('Application')
            try {
                $application.SetValue('ApplicationName', 'GSMLG Editor')
                $application.SetValue('ApplicationDescription', 'Edit text and source files in GSMLG.')
            } finally { $application.Dispose() }
            $command = $key.CreateSubKey('shell\open\command')
            try { $command.SetValue('', ('"{0}" "%1"' -f $ExecutablePath)) } finally { $command.Dispose() }
        } finally { $key.Dispose() }
        foreach ($extension in $extensions) {
            $key = $classes.CreateSubKey("$extension\OpenWithProgids")
            try {
                $key.SetValue($progId, [byte[]]@(), [Microsoft.Win32.RegistryValueKind]::None)
            } finally { $key.Dispose() }
        }
    }
} finally {
    $classes.Dispose()
}

# Refresh Explorer's association cache; never write extension defaults or UserChoice.
if (-not ('GSMLGEditor.AssociationNotification' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
namespace GSMLGEditor {
    public static class AssociationNotification {
        [DllImport("shell32.dll")]
        public static extern void SHChangeNotify(uint eventId, uint flags, IntPtr item1, IntPtr item2);
    }
}
'@
}
[GSMLGEditor.AssociationNotification]::SHChangeNotify(0x08000000, 0, [IntPtr]::Zero, [IntPtr]::Zero)
if ($Unregister) { Write-Output 'Removed GSMLG Editor Open With registration for the current user.' }
else { Write-Output 'Registered GSMLG Editor as an Open With choice for the current user.' }
